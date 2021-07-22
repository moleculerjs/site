title: 缓存
---

Moleculer 有一个内置的缓存服务动作的解决方案。 要启用它， 在 [broker option](configuration.html#Broker-options)中设置一种 <1>cacher</1> 类型 并在 [action](services.html#Actions) 定义中设置 `cacher：true` 用以缓存想要的内容。

**动作缓存示例**
```js
const { ServiceBroker } = require("moleculer");

// Create broker
const broker = new ServiceBroker({
    cacher: "Memory"
});

// Create a service
broker.createService({
    name: "users",
    actions: {
        list: {
            // Enable caching to this action
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
        // Will be called the handler, because the cache is empty
        return broker.call("users.list").then(res => broker.logger.info("Users count:", res.length));
    })
    .then(() => {
        // Return from cache, handler won't be called
        return broker.call("users.list").then(res => broker.logger.info("Users count from cache:", res.length));
    });
```

**Console messages:**
```
[2017-08-18T13:04:33.845Z] INFO  dev-pc/BROKER: Broker started.
[2017-08-18T13:04:33.848Z] INFO  dev-pc/USERS: Handler called!
[2017-08-18T13:04:33.849Z] INFO  dev-pc/BROKER: Users count: 2
[2017-08-18T13:04:33.849Z] INFO  dev-pc/BROKER: Users count from cache: 2
```
如你所见，调用 `Handler called` 信息只出现一次，因为第二次请求的响应是从缓存中返回的。

> [Try it on Runkit](https://runkit.com/icebob/moleculer-cacher-example2)

## 缓存键
缓存器从服务名称、动作名称和上下文参数生成键。 键的语法是：
```
<serviceName>.<actionName>:<parameters or hash of parameters>
```
因此, 当使用参数`{ limit: 5, offset: 20 }`调用 `posts.list` 动作时, cacher 从参数中计算 hash. 下一次，当你用相同的参数来调用此操作时，它将会通过键在缓存中找到此项。

**"posts.find" 动作 hash 键示例**
```
posts.find:limit|5|offset|20
```

参数对象可以包含与缓存键无关的属性。 而且，如果键太长，这也会造成性能问题。 因此建议为 `cache` 属性设置一个对象，对象包含一个在 `keys` 属性中。 若要在缓存 `keys` 使用 meta，相关属性用 `#` 前缀装饰。

**留意以下键生成器使用了 `params` & `meta` 属性**
```js
{
    name: "posts",
    actions: {
        list: {
            cache: {
                //  generate cache key from "limit", "offset" params and "user.id" meta
                keys: ["limit", "offset","#user.id"]
            },
            handler(ctx) {
                return this.getList(ctx.params.limit, ctx.params.offset);
            }
        }
    }
}

// If params is { limit: 10, offset: 30 } and meta is { user: { id: 123 } }, 
// the cache key will be:
//   posts.list:10|30|123
```

{% note info Performance tip %}
这个解决方案很快，所以我们建议在生产环境中使用它。 ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)
{% endnote %}

### 限制缓存键长度
有时，键可能很长，可能造成性能问题。 为了避免它，在缓存配置中限制键长度为 `maxParamsLength` 。 当键长于配置的限制值时， 缓存从全键计算哈希(SHA256)，并将其添加到键的末尾。

> `maxParamsLength` 不要小于 `44` (SHA 256 hash length in Base64).
> 
> 要禁用此功能，请将其设置为 `0` 或 `null`。

**不受限制地从整个参数生成完整键**
```js
cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. So this key will also be too long" });
// Key: 'posts.find:id|2|title|New post|content|It can be very very looooooooooooooooooong content. So this key will also be too long'
```

**生成限长键**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            maxParamsLength: 60
        }
    }
});

cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. So this key will also be too long" });
// Key: 'posts.find:id|2|title|New pL4ozUU24FATnNpDt1B0t1T5KP/T5/Y+JTIznKDspjT0='
```

## 条件缓存

条件缓存允许绕过缓存的响应并执行操作以获取“新”数据。 若要绕过缓存，请将 `ctx.meta.$cache` 设置为 `false` 然后调用一个动作。

**示例关闭 `greeter.hello` 动作缓存**
```js
broker.call("greeter.hello", { name: "Moleculer" }, { meta: { $cache: false }}))
```

作为替代，可以实现一个自定义函数来绕过 cache。 自定义函数接受上下文(`ctx`) 作为参数，因此它可以访问任何参数或 meta 数据。 这允许在请求中传递旁路 flag。

**自定义缓存函数示例**
```js
// greeter.service.js
module.exports = {
    name: "greeter",
    actions: {
        hello: {
            cache: {
                enabled: ctx => ctx.params.noCache !== true, //`noCache` passed as a parameter
                keys: ["name"]
            },
            handler(ctx) {
                this.logger.debug(chalk.yellow("Execute handler"));
                return `Hello ${ctx.params.name}`;
            }
        }
    }
};

// Use custom `enabled` function to turn off caching for this request
broker.call("greeter.hello", { name: "Moleculer", noCache: true }))
```

## TTL
在动作定义中可以覆盖默认的 TTL 设置。

```js
const broker = new ServiceBroker({
    cacher: {
        type: "memory",
        options: {
            ttl: 30 // 30 seconds
        }
    }
});

broker.createService({
    name: "posts",
    actions: {
        list: {
            cache: {
                // These cache entries will be expired after 5 seconds instead of 30.
                ttl: 5
            },
            handler(ctx) {
                // ...
            }
        }
    }
});
```

## 自定义键生成器
要覆盖内置的缓存键生成器，请在缓存选项中设置您自己的函数为 `keygen`。

```js
const broker = new ServiceBroker({
    cacher: {
        type: "memory",
        options: {
            keygen(name, params, meta, keys) {
                // Generate a cache key
                // name - action name
                // params - ctx.params
                // meta - ctx.meta
                // keys - cache keys defined in action
                return "";
            }
        }
    }
});
```

## 手动操作缓存
缓存模块可以手动使用。 只需调用 `broker.cacher` 的`get`, `set`, `del` 方法。

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

此外，使用内置Redis 缓存时，可用在 [broker.cacher.client](https://github.com/luin/ioredis) 使用完整的 `ioredis` API ：

```js
// create an ioredis pipeline
const pipeline = broker.cacher.client.pipeline();
// set values in cache
pipeline.set('mykey.a', 'myvalue.a');
pipeline.set('mykey.b', 'myvalue.b');
// execute pipeline
pipeline.exec();
```

## 清除缓存
当您在您的服务中创建一个新模型时，您必须清除旧的缓存模型条目。

**清除操作内缓存的示例**
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

### 清除多个服务实例中的缓存
清除多个服务实例中的缓存条目的最佳做法是使用广播事件。 请注意，这仅适用于非集中缓存，如 `Memory` 或 `MemoryLRU`。

**示例**
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

### 清除不同服务之间的缓存
有依赖的服务是常见的。 例如： `posts` 服务存储来自 `users` 服务缓存条目中的信息(in case of populating)。

**`posts` 服务中的缓存条目示例**
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
`author` 字段来自 `users` 服务 。 如果 `users` 服务清除缓存条目， `posts` 服务也必须清除自己的缓存条目。 因此，您也应该在 `posts` 服务中订阅 `cache.clear.user` 事件。

更简捷一点，请在依赖的服务方案中创建一个 `CacheCleaner` mixin 并定义。

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

如果 `users` 服务发布了 `cache.clean.users` 事件, `posts` 服务也将清除自己的缓存条目。

## 缓存锁定
Moleculer 也支持缓存锁定功能。 详情信息 [请检查此 PR](https://github.com/moleculerjs/moleculer/pull/490)。

**启用锁定**
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

**禁用锁定**
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
**使用 `redlock` 库的 Redis 缓存示例**
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

## 内建缓存

### Memory cacher
`MemoryCacher` 是一个内置内存缓存模块。 它在堆内存中储存条目。

**启用内存缓存**
```js
const broker = new ServiceBroker({
    cacher: "Memory"
});
```
或
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

| 名称                | 类型                      | 默认设置    | 说明                                          |
| ----------------- | ----------------------- | ------- | ------------------------------------------- |
| `ttl`             | `Number`                | `null`  | Time-to-live in seconds.                    |
| `clone`           | `Boolean` or `Function` | `false` | 返回时克隆缓存的数据。                                 |
| `keygen`          | `Function`              | `null`  | 自定义缓存键生成器函数。                                |
| `maxParamsLength` | `Number`                | `null`  | Maximum length of params in generated keys. |
| `lock`            | `Boolean` or `Object`   | `null`  | 启用锁定功能。                                     |

#### 克隆
Cacher 使用 lodash `_.cloneDeep` 方法进行克隆。 To change it, set a `Function` to the `clone` option instead of a `Boolean`.

**使用 JSON parse & stringify 自定义克隆函数**
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
`LRU memory cacher` is a built-in [LRU cache](https://github.com/isaacs/node-lru-cache) module. 删除最近使用最少的项目。

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

| 名称                | 类型                      | 默认设置    | 说明                                          |
| ----------------- | ----------------------- | ------- | ------------------------------------------- |
| `ttl`             | `Number`                | `null`  | Time-to-live in seconds.                    |
| `max`             | `Number`                | `null`  | Maximum items in the cache.                 |
| `clone`           | `Boolean` or `Function` | `false` | Clone the cached data when return it.       |
| `keygen`          | `Function`              | `null`  | Custom cache key generator function.        |
| `maxParamsLength` | `Number`                | `null`  | Maximum length of params in generated keys. |
| `lock`            | `Boolean` or `Object`   | `null`  | Enable lock feature.                        |


{% note info Dependencies %}
要使用此缓存，请安装 `lru-cache` 模块, 使用 `npm install lru-cache --save` 命令。
{% endnote %}

### Redis 缓存
`RedisCacher` is a built-in [Redis](https://redis.io/) based distributed cache module. 它使用 [`ioredis`](https://github.com/luin/ioredis) 库. Use it, if you have multiple instances of services because if one instance stores some data in the cache, other instances will find it.

**启用 Redis 缓存**
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

**With MessagePack serializer** 您可以为 Redis Cacher 定义一个序列化器。 默认情况下，它使用 JSON 序列化器。
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

**使用 Redis 集群客户端**
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

**Options**

| 名称                | 类型                    | 默认设置     | 说明                                                                                                                                    |
| ----------------- | --------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `prefix`          | `String`              | `null`   | 键前缀                                                                                                                                   |
| `ttl`             | `Number`              | `null`   | Time-to-live in seconds. Disabled: 0 or null                                                                                          |
| `monitor`         | `Boolean`             | `false`  | 启用 Redis 客户端 [监测功能](https://github.com/luin/ioredis#monitor)。 If enabled, every client operation will be logged (on debug level)      |
| `redis`           | `Object`              | `null`   | Custom Redis options. Will be passed to the `new Redis()` constructor. [Read more](https://github.com/luin/ioredis#connect-to-redis). |
| `keygen`          | `Function`            | `null`   | Custom cache key generator function.                                                                                                  |
| `maxParamsLength` | `Number`              | `null`   | Maximum length of params in generated keys.                                                                                           |
| `serializer`      | `String`              | `"JSON"` | Name of a built-in serializer.                                                                                                        |
| `cluster`         | `Object`              | `null`   | Redis Cluster client configuration. [More information](https://github.com/luin/ioredis#cluster)                                       |
| `lock`            | `Boolean` or `Object` | `null`   | Enable lock feature.                                                                                                                  |
| `pingInterval`    | `Number`              | `null`   | Emit a Redis PING command every `pingInterval` milliseconds. Can be used to keep connections alive which may have idle timeouts.      |

{% note info Dependencies %}
要使用此缓存，请使用 `npm install ioredis --save` 命令安装 `ioredis` 模块。
{% endnote %}


## 自定义缓存
可以创建自定义缓存模块。 我们建议复制 [MemoryCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/memory.js) 或 [RedisCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/redis.js) 并实现 `get` `set`, `del` 和 `clean` 方法。

### 创建自定义缓存
```js
const BaseCacher = require("moleculer").Cachers.Base;

class MyCacher extends BaseCacher {
    async get(key) { /*...*/ }
    async set(key, data, ttl) { /*...*/ }
    async del(key) { /*...*/ }
    async clean(match = "**") { /*...*/ }
}
```

### 使用自定义缓存

```js
const { ServiceBroker } = require("moleculer");
const MyCacher = require("./my-cacher");

const broker = new ServiceBroker({
    cacher: new MyCacher()
});
```