title: Кеширование
---

Moleculer имеет встроенное решение для кэширования результатов вызова методов сервисов. Чтобы включить его, укажите тип кэша `cacher` в [параметрах брокера](configuration.html#Broker-options) и включите кэш `cache: true` в [определении метода](services.html#Actions) результаты выполнения которого необходимо кэшировать.

**Пример**
```js
const { ServiceBroker } = require("moleculer");

// Создание брокера
const broker = new ServiceBroker({
    cacher: "Memory"
});

// Создание сервиса
broker.createService({
    name: "users",
    actions: {
        list: {
            // Включение кеширования для этого действия
            cache: true, 
            handler(ctx) {
                this.logger.info("Handler called!");
                return [
                    { id: 1, name: "John" },
                    { id: 2, name: "Jane" }
                ]
            }
        }
    }
});

broker.start()
    .then(() => {
        // Будет вызван обработчик, поскольку кеш пуст
        return broker.call("users.list").then(res => broker.logger.info("Users count:", res.length));
    })
    .then(() => {
        // Вернуть данные из кеша, без вызова обработчика
        return broker.call("users.list").then(res => broker.logger.info("Users count from cache:", res.length));
    });
```

**Сообщения консоли:**
```
[2017-08-18T13:04:33.845Z] INFO  dev-pc/BROKER: Broker started.
[2017-08-18T13:04:33.848Z] INFO  dev-pc/USERS: Handler called!
[2017-08-18T13:04:33.849Z] INFO  dev-pc/BROKER: Users count: 2
[2017-08-18T13:04:33.849Z] INFO  dev-pc/BROKER: Users count from cache: 2
```
Как видите, сообщение `Handler called` появляется только один раз, потому что ответ второго запроса был возвращён из кэша.

> [Попробуйте это в Runkit](https://runkit.com/icebob/moleculer-cacher-example2)

## Ключи кэширования
Ключ кэширования генерируется из имени сервиса, имени метода и параметров контекста. Синтаксис ключа:
```
<serviceName>.<actionName>:<parameters or hash of parameters>
```
Если вызвать метод `posts.list` с параметрами `{ limit: 5, offset: 20 }`, алгоритм кэширования вычислит хэш от параметров. Таким образом, при следующем вызове с такими же параметрами, результат будет найдет кэше по ключу.

**Пример хэш-ключа кэша для действия "posts.find"**
```
posts.find:limit|5|offset|20
```

Объект params может содержать свойства, которые не имеют отношения к ключу кэша. Также, это может вызвать проблемы с производительностью, если ключ слишком длинный. Поэтому рекомендуется задать объект `cache` со списком основных имён параметров в свойстве `keys`. Для указания ключей кэша из объекта мета в свойстве `keys` используйте префикс `#`.

**Для генерации ключа кэша используются свойства только объектов `params` и `meta`**
```js
{
    name: "posts",
    actions: {
        list: {
            cache: {
                // формирует ключ кеширования из параметров "limit", "offset" и мета "user.id"
                keys: ["limit", "offset","#user.id"]
            },
            handler(ctx) {
                return this.getList(ctx.params.limit, ctx.params.offset);
            }
        }
    }
}

// если параметры равны { limit: 10, offset: 30 } и мета равна { user: { id: 123 } }, 
// ключ кэширования будет:
//   posts.list:10|30|123
```

{% note info Performance tip %}
Это решение работает довольно быстро, поэтому мы рекомендуем использовать его на продакшене. ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)
{% endnote %}

### Ограничение длины ключа кэша
Иногда ключ может быть очень длинным, что может вызвать проблемы с производительностью. Чтобы избежать этого, можно задать параметр кеширования `maxParamsLength`. Когда длина ключа превысит указанное значение, алгоритм вычисляет хэш (SHA256) от полного ключа и добавляет его в конец ключа.

> Минимум для `maxParamsLength` составляет `44` (SHA 256 хэш в Base64).
> 
> Для отключения этой функции установите значение `0` или `null`.

**Формирование полного ключ из всех параметров без ограничения**
```js
cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. So this key will also be too long" });
// Key: 'posts.find:id|2|title|New post|content|It can be very very looooooooooooooooooong content. So this key will also be too long'
```

**Формирование ключа ограниченной длины**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            maxParamsLength: 60
        }
    }
});

cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. Таким образом, этот ключ также будет слишком длинным" });
// ключ: 'posts.find:id|2|title|New pL4ozU24FATnNpDt1B0t1T5KP/T5/Y+JTIznKDspjT0='
```

## Условное кэширование

Условное кэширование позволяет обойти кэш и выполнить действие для получения "свежих" данных. Чтобы обойти кэш необходимо присвоить `ctx.meta.$cache` `false` перед вызовом действия.

**Пример отключения кэширования для действия `greeter.hello`**
```js
broker.call("greeter.hello", { name: "Moleculer" }, { meta: { $cache: false }}))
```

В качестве альтернативы, можно использовать пользовательскую функцию, чтобы активировать обход кэша. Пользовательская функция принимает в качестве аргумента контекст (`ctx`), поэтому она имеет доступ к любым параметрам или мета-данным. Это позволяет передать флаг обхода внутри запроса.

**Пример пользовательской функции условного кэширования**
```js
// greeter.service.js
module.exports = {
    name: "greeter",
    actions: {
        hello: {
            cache: {
                enabled: ctx => ctx.params.noCache !== true, //`noCache` передан в качестве параметра
                keys: ["name"]
            },
            handler(ctx) {
                this.logger.debug(chalk.yellow("Execute handler"));
                return `Hello ${ctx.params.name}`;
            }
        }
    }
};

// использование пользовательской функции `выключающей` кэширование этого запроса
broker.call("greeter.hello", { name: "Moleculer", noCache: true }))
```

## TTL время жизни
Настройки TTL по умолчанию могут быть переопределены в определении действия.

```js
const broker = new ServiceBroker({
    cacher: {
        type: "memory",
        options: {
            ttl: 30 // 30 секунд
        }
    }
});

broker.createService({
    name: "posts",
    actions: {
        list: {
            cache: {
                // этот кэш устареет спустя 5 секунд вместо 30.
                ttl: 5
            },
            handler(ctx) {
                // ...
            }
        }
    }
});
```

## Пользовательский формирователь ключа
Чтобы переопределить встроенный формирователь ключей кэширования, установите собственную функцию `keygen` в параметрах кэширования.

```js
const broker = new ServiceBroker({
    cacher: {
        type: "memory",
        options: {
            keygen(name, params, meta, keys) {
                // формирует ключ кеширования
                // name - имя действия
                // params - ctx.params
                // meta - ctx.meta
                // keys - ключи, заданные в описании действия
                return "";
            }
        }
    }
});
```

## Ручное кэширование
Модуль кэширования может использоваться вручную. Just call the `get`, `set`, `del` methods of `broker.cacher`.

```js
// Save to cache
broker.cacher.set("mykey.a", { a: 5 });

// Get from cache (async)
const obj = await broker.cacher.get("mykey.a")

// Remove entry from cache
await broker.cacher.del("mykey.a");

// Clean all 'mykey' entries
await broker.cacher.clean("mykey.**");

// Clean all entries
await broker.cacher.clean();
```

Additionally, the complete [ioredis](https://github.com/luin/ioredis) client API is available at `broker.cacher.client` when using the built-in Redis cacher:

```js
// create an ioredis pipeline
const pipeline = broker.cacher.client.pipeline();
// set values in cache
pipeline.set('mykey.a', 'myvalue.a');
pipeline.set('mykey.b', 'myvalue.b');
// execute pipeline
pipeline.exec();
```

## Очистить кэш
When you create a new model in your service, you have to clear the old cached model entries.

**Example to clean the cache inside actions**
```js
{
    name: "users",
    actions: {
        create(ctx) {
            // Create new user entity
            const user = new User(ctx.params);

            // Clear all cache entries
            this.broker.cacher.clean();

            // Clear all cache entries which keys start with `users.`
            this.broker.cacher.clean("users.**");

            // Clear multiple cache entries
            this.broker.cacher.clean([ "users.**", "posts.**" ]);

            // Delete an entry
            this.broker.cacher.del("users.list");

            // Delete multiple entries
            this.broker.cacher.del([ "users.model:5", "users.model:8" ]);
        }
    }
}
```

### Clear cache among multiple service instances
The best practice to clear cache entries among multiple service instances is to use broadcast events. Note that this is is only required for non-centralized cachers like `Memory` or `MemoryLRU`.

**Пример**
```js
module.exports = {
    name: "users",
    actions: {
        create(ctx) {
            // Create new user entity
            const user = new User(ctx.params);

            // Clear cache
            this.cleanCache();

            return user;
        }
    },

    methods: {
        cleanCache() {
            // Broadcast the event, so all service instances receive it (including this instance). 
            this.broker.broadcast("cache.clean.users");
        }
    }

    events: {
        "cache.clean.users"() {
            if (this.broker.cacher) {
                this.broker.cacher.clean("users.**");
            }
        }
    }
}
```

### Clear cache among different services
Зависимость от услуг - обычная ситуация. E.g. `posts` service stores information from `users` service in cached entries (in case of populating).

**Example cache entry in `posts` service**
```js
{
    _id: 1,
    title: "My post",
    content: "Some content",
    author: {
        _id: 130,
        fullName: "John Doe",
        avatar: "https://..."
    },
    createdAt: 1519729167666
}
```
The `author` field is received from `users` service. So if the `users` service clears cache entries, the `posts` service has to clear own cache entries, as well. Therefore you should also subscribe to the `cache.clear.users` event in `posts` service.

To make it easier, create a `CacheCleaner` mixin and define in the dependent services schema.

**cache.cleaner.mixin.js**
```js
module.exports = function(serviceNames) {
    const events = {};

    serviceNames.forEach(name => {
        events[`cache.clean.${name}`] = function() {
            if (this.broker.cacher) {
                this.logger.debug(`Clear local '${this.name}' cache`);
                this.broker.cacher.clean(`${this.name}.*`);
            }
        };
    });

    return {
        events
    };
};
```

**posts.service.js**
```js
const CacheCleaner = require("./cache.cleaner.mixin");

module.exports = {
    name: "posts",
    mixins: [CacheCleaner([
        "users",
        "posts"
    ])],

    actions: {
        //...
    }
};
```

With this solution if the `users` service emits a `cache.clean.users` event, the `posts` service will also clear its own cache entries.

## Cache locking
Moleculer also supports cache locking feature. For detailed info [check this PR](https://github.com/moleculerjs/moleculer/pull/490).

**Enable Lock**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: true, // Set to true to enable cache locks. Default is disabled.
    }
});
```

**Enable with TTL**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: {
            ttl: 15, // The maximum amount of time you want the resource locked in seconds
            staleTime: 10, // If the TTL is less than this number, means that the resources are staled
        }
    }
});
```

**Disable Lock**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: {
            enable: false, // Set to false to disable.
            ttl: 15, // The maximum amount of time you want the resource locked in seconds
            staleTime: 10, // If the TTL is less than this number, means that the resources are staled
        }
    }
});
```
**Example for Redis cacher with `redlock` library**
```js
const broker = new ServiceBroker({
  cacher: {
    type: "Redis",
    options: {
      // Prefix for keys
      prefix: "MOL",
      // set Time-to-live to 30sec.
      ttl: 30,
      // Turns Redis client monitoring on.
      monitor: false,
      // Redis settings
      redis: {
        host: "redis-server",
        port: 6379,
        password: "1234",
        db: 0
      },
      lock: {
        ttl: 15, //the maximum amount of time you want the resource locked in seconds
        staleTime: 10, // If the TTL is less than this number, means that the resources are staled
      },
      // Redlock settings
      redlock: {
        // Redis clients. Support node-redis or ioredis. By default will use the local client.
        clients: [client1, client2, client3],
        // the expected clock drift; for more details
        // see http://redis.io/topics/distlock
        driftFactor: 0.01, // time in ms

        // the max number of times Redlock will attempt
        // to lock a resource before erroring
        retryCount: 10,

        // the time in ms between attempts
        retryDelay: 200, // time in ms

        // the max time in ms randomly added to retries
        // to improve performance under high contention
        // see https://www.awsarchitectureblog.com/2015/03/backoff.html
        retryJitter: 200 // time in ms
      }
    }
  }
});
```

## Built-in cachers

### Memory cacher
`MemoryCacher` is a built-in memory cache module. It stores entries in the heap memory.

**Enable memory cacher**
```js
const broker = new ServiceBroker({
    cacher: "Memory"
});
```
Или
```js
const broker = new ServiceBroker({
    cacher: true
});
```

**Enable with options**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            ttl: 30 // Set Time-to-live to 30sec. Disabled: 0 or null
            clone: true // Deep-clone the returned value
        }
    }
});
```

**Options**

| Name              | Type                    | Default | Description                                 |
| ----------------- | ----------------------- | ------- | ------------------------------------------- |
| `ttl`             | `Number`                | `null`  | Time-to-live in seconds.                    |
| `clone`           | `Boolean` or `Function` | `false` | Clone the cached data when return it.       |
| `keygen`          | `Function`              | `null`  | Custom cache key generator function.        |
| `maxParamsLength` | `Number`                | `null`  | Maximum length of params in generated keys. |
| `lock`            | `Boolean` or `Object`   | `null`  | Enable lock feature.                        |

#### Cloning
The cacher uses the lodash `_.cloneDeep` method for cloning. To change it, set a `Function` to the `clone` option instead of a `Boolean`.

**Custom clone function with JSON parse & stringify**
```js
const broker = new ServiceBroker({ 
    cacher: {
        type: "Memory",
        options: {
            clone: data => JSON.parse(JSON.stringify(data))
        }
    }
});
```

### LRU memory cacher
`LRU memory cacher` is a built-in [LRU cache](https://github.com/isaacs/node-lru-cache) module. It deletes the least-recently-used items.

**Enable LRU cacher**
```js
const broker = new ServiceBroker({
    cacher: "MemoryLRU"
});
```

**With options**
```js
let broker = new ServiceBroker({
    logLevel: "debug",
    cacher: {
        type: "MemoryLRU",
        options: {
            // Maximum items
            max: 100,
            // Time-to-Live
            ttl: 3
        }
    }
});
```

**Options**

| Name              | Type                    | Default | Description                                 |
| ----------------- | ----------------------- | ------- | ------------------------------------------- |
| `ttl`             | `Number`                | `null`  | Time-to-live in seconds.                    |
| `max`             | `Number`                | `null`  | Maximum items in the cache.                 |
| `clone`           | `Boolean` or `Function` | `false` | Clone the cached data when return it.       |
| `keygen`          | `Function`              | `null`  | Custom cache key generator function.        |
| `maxParamsLength` | `Number`                | `null`  | Maximum length of params in generated keys. |
| `lock`            | `Boolean` or `Object`   | `null`  | Enable lock feature.                        |


{% note info Dependencies %}
To be able to use this cacher, install the `lru-cache` module with the `npm install lru-cache --save` command.
{% endnote %}

### Redis cacher
`RedisCacher` is a built-in [Redis](https://redis.io/) based distributed cache module. It uses [`ioredis`](https://github.com/luin/ioredis) library. Use it, if you have multiple instances of services because if one instance stores some data in the cache, other instances will find it.

**Enable Redis cacher**
```js
const broker = new ServiceBroker({
    cacher: "Redis"
});
```

**With connection string**
```js
const broker = new ServiceBroker({
    cacher: "redis://redis-server:6379"
});
```

**With options**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            // Prefix for keys
            prefix: "MOL",            
            // set Time-to-live to 30sec.
            ttl: 30, 
            // Turns Redis client monitoring on.
            monitor: false 
            // Redis settings
            redis: {
                host: "redis-server",
                port: 6379,
                password: "1234",
                db: 0
            }
        }
    }
});
```

**With MessagePack serializer** You can define a serializer for Redis Cacher. By default, it uses the JSON serializer.
```js
const broker = new ServiceBroker({
    nodeID: "node-123",
    cacher: {
        type: "Redis",
        options: {
            ttl: 30,

            // Using MessagePack serializer to store data.
            serializer: "MsgPack",

            redis: {
                host: "my-redis"
            }
        }
    }
});
```

**With Redis Cluster Client**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            ttl: 30, 

            cluster: {
                nodes: [
                    { port: 6380, host: "127.0.0.1" },
                    { port: 6381, host: "127.0.0.1" },
                    { port: 6382, host: "127.0.0.1" }
                ],
                options: { /* More information: https://github.com/luin/ioredis#cluster */ }
            }   
        }
    }
});
```

**Параметры**

| Имя               | Тип              | По умолчанию | Описание                                                                                                                                                               |
| ----------------- | ---------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `prefix`          | `String`         | `null`       | Префикс для сгенерированных ключей.                                                                                                                                    |
| `ttl`             | `Number`         | `null`       | Время жизни в секундах. Отключить: 0 или null                                                                                                                          |
| `monitor`         | `Boolean`        | `false`      | Включить [функцию мониторинга](https://github.com/luin/ioredis#monitor) клиента Redis. Если включено, каждая операция клиента будет записана в лог (на уровне отладки) |
| `redis`           | `Object`         | `null`       | Custom Redis options. Will be passed to the `new Redis()` constructor. [Read more](https://github.com/luin/ioredis#connect-to-redis).                                  |
| `keygen`          | `Function`       | `null`       | Custom cache key generator function.                                                                                                                                   |
| `maxParamsLength` | `Number`         | `null`       | Maximum length of params in generated keys.                                                                                                                            |
| `serializer`      | `String`         | `"JSON"`     | Name of a built-in serializer.                                                                                                                                         |
| `cluster`         | `Object`         | `null`       | Конфигурация кластера Redis. [More information](https://github.com/luin/ioredis#cluster)                                                                               |
| `lock`            | `Boolean|Object` | `null`       | Включить функции блокировок.                                                                                                                                           |

{% note info Dependencies %}
Чтобы использовать этот тип кэша, необходимо установить модуль `ioredis` командой `npm install ioredis --save`.
{% endnote %}


## Собственный алгоритм кэширования
Можно создать собственный модуль кэширования. Рекомендуется использовать в качестве образца модуль [MemoryCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/memory.js) или [RedisCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/redis.js) и реализовать методы `get`, `set`, `del` и `clean`.

### Создание собственного алгоритма кэширования
```js
const BaseCacher = require("moleculer").Cachers.Base;

class MyCacher extends BaseCacher {
    async get(key) { /*...*/ }
    async set(key, data, ttl) { /*...*/ }
    async del(key) { /*...*/ }
    async clean(match = "**") { /*...*/ }
}
```

### Использование собственного алгоритма кэширования

```js
const { ServiceBroker } = require("moleculer");
const MyCacher = require("./my-cacher");

const broker = new ServiceBroker({
    cacher: new MyCacher()
});
```