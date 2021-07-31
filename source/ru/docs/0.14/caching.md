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
Модуль кэширования может использоваться вручную. Просто вызовите методы `get`, `set`, `del` в `broker.cacher`.

```js
// сохранить в кэш
broker.cacher.set("mykey.a", { a: 5 });

// получить из кэша (async)
const obj = await broker.cacher.get("mykey.a")

// удалить запись из кэша
await broker.cacher.del("mykey.a");

// очистить все записи 'mykey'
await broker.cacher.clean("mykey.**");

// очистить все записи
await broker.cacher.clean();
```

Кроме того, при использовании встроенного Redis кэша можно использовать любой метод API [ioredis](https://github.com/luin/ioredis) в `broker.cacher.client`:

```js
// создать конвейер ioredis
const pipeline = broker.cacher.client.pipeline();
// записать кэш
pipeline.set('mykey.a', 'myvalue.a');
pipeline.set('mykey.b', 'myvalue.b');
// выполнить конвейер
pipeline.exec();
```

## Очистка кэша
Когда вы создаете новую модель в своём сервисе, вам необходимо очистить старые записи в кэше.

**Пример очистки кэша внутри действий**
```js
{
    name: "users",
    actions: {
        create(ctx) {
            // создание новой записи user
            const user = new User(ctx.params);

            // очистка всего кеша
            this.broker.cacher.clean();

            // очистка всех записей у которых ключ начинается с `users.`
            this.broker.cacher.clean("users.**");

            // очистка множества записей
            this.broker.cacher.clean([ "users.**", "posts.**" ]);

            // удаление конкретной записи
            this.broker.cacher.del("users.list");

            // удаление нескольких записей
            this.broker.cacher.del([ "users.model:5", "users.model:8" ]);
        }
    }
}
```

### Очистка кэша для нескольких экземпляров сервиса
Наилучшая практика очистки кэша среди нескольких экземпляров сервиса заключается в использовании широковещательных событий. Обратите внимание, что это требуется только для децентрализованных кэшей, таких как `Memory` или `MemoryLRU`.

**Пример**
```js
module.exports = {
    name: "users",
    actions: {
        create(ctx) {
            // создание новой записи
            const user = new User(ctx.params);

            // очистка кеша
            this.cleanCache();

            return user;
        }
    },

    methods: {
        cleanCache() {
            // отправка широковещательного события, так что все экземпляры сервиса получат его (включая этот экземпляр). 
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

### Очистка кэша между различными сервисами
Зависимость сервисов - обычная ситуация. Например сервис `posts` хранит информацию из сервиса `users` в кэшированных записях (в случае заполнения).

**Пример записи кэша в сервисе `posts`**
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
Поле `author` получено из сервиса `users`. Если сервис `users` очищает записи кэша, то служба `posts` также должна очистить собственные записи кэша. Поэтому вы должны также подписаться на событие `cache.clear.users` в сервисе `posts`.

Чтобы упростить это, создайте примесь `CacheCleaner` и определите схему зависимости сервисов.

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

При этом, если сервис `users` вызывает событие `cache.clean.users`, то сервис `posts` также очистит свои собственные записи кэша.

## Блокировка кэша
Moleculer также поддерживает функцию блокировки кэша. Для получения подробной информации [ознакомьтесь с PR](https://github.com/moleculerjs/moleculer/pull/490).

**Включение блокировки**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: true, // передать true для включения блокировки кэша. По умолчанию отключено.
    }
});
```

**Включение с TTL**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: {
            ttl: 15, // максимальное время блокировки в секундах
            staleTime: 10, // если TTL меньше этого числа, то кэш устарел
        }
    }
});
```

**Отключение блокировки**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: {
            enable: false, // установить в false для отключения.
            ttl: 15, // максимальное время блокировки в секундах
            staleTime: 10, // если TTL меньше этого числа, то кэш устарел
        }
    }
});
```
**Пример кэша Redis с использованием библиотеки `redlock`**
```js
const broker = new ServiceBroker({
  cacher: {
    type: "Redis",
    options: {
      // префикс ключей
      prefix: "MOL",
      // установить время жизни 30 сек
      ttl: 30,
      // включить мониторинг Redis.
      monitor: false,
      // настройки Redis
      redis: {
        host: "redis-server",
        port: 6379,
        password: "1234",
        db: 0
      },
      lock: {
        ttl: 15, // максимальное время блокировки в секундах
        staleTime: 10, // если TTL меньше этого числа, то кэш устарел
      },
      // настройки Redlock
      redlock: {
        // клиенты Redis. Поддерживаются Node-redis или ioredis. По умолчанию будет использован локальный клиент.
        clients: [client1, client2, client3],
        // ожидаемое отклонение времени; подробнее
        // см. http://redis.io/topics/distlock
        driftFactor: 0.01, // время в мс

        // максимальное количество попыток Redlock
        // получить блокировку перед вызовом ошибки
        retryCount: 10,

        // задержка между попытками
        retryDelay: 200, // время в мс

        // максимальное время, случайно добавляемое перед попыткой
        // для улучшения производительности при большом разбросе
        // см. https://www.awsarchitectureblog.com/2015/03/backoff.html
        retryJitter: 200 // время в мс
      }
    }
  }
});
```

## Встроенные типы кэша

### Memory cacher
`MemoryCacher` это встроенный модуль кэширования. Он сохраняет записи в памяти кучи.

**Включение**
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

**Включить с параметрами**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            ttl: 30 // установить время жизни 30 сек. Отключить: 0 или null
            clone: true // глубокое клонирование возвращаемого значения
        }
    }
});
```

**Параметры**

| Имя               | Тип                      | По умолчанию | Описание                                               |
| ----------------- | ------------------------ | ------------ | ------------------------------------------------------ |
| `ttl`             | `Number`                 | `null`       | Время жизни в секундах.                                |
| `clone`           | `Boolean` или `Function` | `false`      | Клонировать кэшированные данные при возврате.          |
| `keygen`          | `Function`               | `null`       | Функция формирования ключей кэша.                      |
| `maxParamsLength` | `Number`                 | `null`       | Максимальная длина параметров в сформированных ключах. |
| `lock`            | `Boolean` или `Object`   | `null`       | Включить функцию блокировки.                           |

#### Клонирование
Кэшер использует метод клонирования `_.cloneDeep` из библиотеки lodash. Чтобы его изменить, передайте `Function` в свойство `clone` вместо `Boolean`.

**Пользовательская функция клонирования через JSON сериализацию**
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

### Кэш памяти LRU
`Кэш памяти LRU` - это встроенный [кэш LRU](https://github.com/isaacs/node-lru-cache) модуль. Он удаляет наименее используемые элементы.

**Включение LRU кэша**
```js
const broker = new ServiceBroker({
    cacher: "MemoryLRU"
});
```

**С параметрами**
```js
let broker = new ServiceBroker({
    logLevel: "debug",
    cacher: {
        type: "MemoryLRU",
        options: {
            // Максимальное количество элементов
            max: 100,
            // Время жизни
            ttl: 3
        }
    }
});
```

**Параметры**

| Имя               | Тип                      | По умолчанию | Описание                                              |
| ----------------- | ------------------------ | ------------ | ----------------------------------------------------- |
| `ttl`             | `Number`                 | `null`       | Время жизни в секундах.                               |
| `max`             | `Number`                 | `null`       | Максимальное количестов элементов в кэше.             |
| `clone`           | `Boolean` или `Function` | `false`      | Клонировать кэшированные данные при возврате.         |
| `keygen`          | `Function`               | `null`       | Пользовательская функция генерации ключей кэша.       |
| `maxParamsLength` | `Number`                 | `null`       | Максимальная длина параметров сгенерированных ключей. |
| `lock`            | `Boolean` или `Object`   | `null`       | Включить функцию блокировки.                          |


{% note info Dependencies %}
Чтобы использовать этот тип кэша, необходимо установить модуль `lru-cache` командой `npm install lru-cache --save`.
{% endnote %}

### Кэш Redis
`RedisCacher` является встроенным распределенным модулем кэша на базе [Redis](https://redis.io/). Он использует библиотеку [`ioredis`](https://github.com/luin/ioredis). Используйте его, если имеется несколько экземпляров сервисов, потому что если в одном экземпляре хранятся некоторые данные в кэше, другие экземпляры смогут найти их.

**Включение Redis кэша**
```js
const broker = new ServiceBroker({
    cacher: "Redis"
});
```

**С указанием строки подключения**
```js
const broker = new ServiceBroker({
    cacher: "redis://redis-server:6379"
});
```

**С параметрами**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            // Префикс для ключей
            prefix: "MOL",            
            // установить время жизни равное 30 сек.
            ttl: 30, 
            // Включает мониторинг Redis клиента.
            monitor: false 
            // настройки Redis
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

**С использованием сериализатора MessagePack** Вы можете определить сериализатор для кэша Redis. По умолчанию используется сериализатор JSON.
```js
const broker = new ServiceBroker({
    nodeID: "node-123",
    cacher: {
        type: "Redis",
        options: {
            ttl: 30,

            // Использовать сериализатор MessagePack для хранения данных.
            serializer: "MsgPack",

            redis: {
                host: "my-redis"
            }
        }
    }
});
```

**С использованием клиента для Redis кластера**
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
                options: { /* Больше информации:
https://github.com/luin/ioredis#cluster */ }
            }   
        }
    }
});
```

**Параметры**

| Имя               | Тип                    | По умолчанию | Описание                                                                                                                                                               |
| ----------------- | ---------------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `prefix`          | `String`               | `null`       | Префикс для сгенерированных ключей.                                                                                                                                    |
| `ttl`             | `Number`               | `null`       | Время жизни в секундах. Отключить: 0 или null                                                                                                                          |
| `monitor`         | `Boolean`              | `false`      | Включить [функцию мониторинга](https://github.com/luin/ioredis#monitor) клиента Redis. Если включено, каждая операция клиента будет записана в лог (на уровне отладки) |
| `redis`           | `Object`               | `null`       | Пользовательские параметры Redis. Будут переданы в конструктор `new Redis()`. [Подробнее](https://github.com/luin/ioredis#connect-to-redis).                           |
| `keygen`          | `Function`             | `null`       | Пользовательская функция генерации ключей кэша.                                                                                                                        |
| `maxParamsLength` | `Number`               | `null`       | Максимальная длина параметров сгенерированных ключей.                                                                                                                  |
| `serializer`      | `String`               | `"JSON"`     | Имя встроенного сериализатора.                                                                                                                                         |
| `cluster`         | `Object`               | `null`       | Конфигурация кластера Redis. [Подробнее](https://github.com/luin/ioredis#cluster)                                                                                      |
| `lock`            | `Boolean` или `Object` | `null`       | Включить функции блокировок.                                                                                                                                           |
| `pingInterval`    | `Number`               | `null`       | Emit a Redis PING command every `pingInterval` milliseconds. Can be used to keep connections alive which may have idle timeouts.                                       |

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