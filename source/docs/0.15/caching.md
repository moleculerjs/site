title: Caching
---

Moleculer has a built-in caching solution to cache responses of service actions. To enable it, set a `cacher` type in [broker option](configuration.html#Broker-options) and set the `cache: true` in [action definition](services.html#Actions) what you want to cache.

**Cached action example**
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
As you can see, the `Handler called` message appears only once because the response of second request is returned from the cache.

> [Try it on Runkit](https://runkit.com/icebob/moleculer-cacher-example2)

## Cache keys
The cacher generates key from service name, action name and the params of context.
The syntax of key is:
```
<serviceName>.<actionName>:<parameters or hash of parameters>
```
So if you call the `posts.list` action with params `{ limit: 5, offset: 20 }`, the cacher calculates a hash from the params. So the next time, when you call this action with the same params, it will find the entry in the cache by key.

**Example hashed cache key for "posts.find" action**
```
posts.find:limit|5|offset|20
```

The params object can contain properties that are not relevant for the cache key. Also, it can cause performance issues if the key is too long. Therefore it is recommended to set an object for `cache` property which contains a list of essential parameter names under the `keys` property.
To use meta keys in cache `keys` use the `#` prefix.

**Strict the list of `params`, `meta`, `headers` properties for key generation**
```js
// posts.service.js
module.exports = {
  name: "posts",
  actions: {
    list: {
      cache: {
        keys: [
          "limit", // value from `ctx.params`
          "#tenant", // value from `ctx.meta`
          "@customProp", // value from `ctx.headers`
        ],
      },
      handler(ctx) {
        const tenant = ctx.meta.tenant;
        const limit = ctx.params.limit;
        const customProp = ctx.headers.customProp;        
      },
    },
  },
};

```

{% note info Performance tip %}
This solution is pretty fast, so we recommend to use it in production. ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)
{% endnote %}

### Limiting cache key length
Occasionally, the key can be very long, which can cause performance issues. To avoid it, maximize the length of concatenated params in the key with `maxParamsLength` cacher option. When the key is longer than the configured limit value, the cacher calculates a hash (SHA256) from the full key and adds it to the end of the key.

> The minimum of `maxParamsLength` is `44` (SHA 256 hash length in Base64).
> 
> To disable this feature, set it to `0` or `null`.

**Generate a full key from the whole params without limit**
```js
cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. So this key will also be too long" });
// Key: 'posts.find:id|2|title|New post|content|It can be very very looooooooooooooooooong content. So this key will also be too long'
```

**Generate a limited-length key**
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

## Conditional caching

Conditional caching allows to bypass the cached response and execute an action in order to obtain "fresh" data.
To bypass the cache set `ctx.meta.$cache` to `false` before calling an action.

**Example of turning off the caching for the `greeter.hello` action**
```js
broker.call("greeter.hello", { name: "Moleculer" }, { meta: { $cache: false }}))
```

As an alternative, a custom function can be implemented to enable bypassing the cache. The custom function accepts as an argument the context (`ctx`) instance therefore it has access any params or meta data. This allows to pass the bypass flag within the request.

**Example of a custom conditional caching function**
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
Default TTL setting can be overriden in action definition.

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

## Custom key-generator
To overwrite the built-in cacher key generator, set your own function as `keygen` in cacher options.

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

## Manual caching
The cacher module can be used manually. Just call the `get`, `set`, `del` methods of `broker.cacher`.

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

## Clear cache
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
The best practice to clear cache entries among multiple service instances is to use broadcast events. Note this is only required for non-centralized cachers like `Memory` or `MemoryLRU`.

**Example**
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
    },

    events: {
        "cache.clean.users"() {
            if (this.broker.cacher) {
                this.broker.cacher.clean("users.**");
            }
        }
    }
};
```

### Clear cache among different services
Service dependency is a common situation. E.g. `posts` service stores information from `users` service in cached entries (in case of populating).

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
Or
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

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `ttl` | `Number` | `null` | Time-to-live in seconds. |
| `clone` | `Boolean` or `Function` | `false` | Clone the cached data when return it. |
| `keygen` | `Function` | `null` | Custom cache key generator function. |
| `maxParamsLength` | `Number` | `null` | Maximum length of params in generated keys. |
| `lock` | `Boolean` or `Object` | `null` | Enable lock feature. |

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

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `ttl` | `Number` | `null` | Time-to-live in seconds. |
| `max` | `Number` | `null` | Maximum items in the cache. |
| `clone` | `Boolean` or `Function` | `false` | Clone the cached data when return it. |
| `keygen` | `Function` | `null` | Custom cache key generator function. |
| `maxParamsLength` | `Number` | `null` | Maximum length of params in generated keys. |
| `lock` | `Boolean` or `Object` | `null` | Enable lock feature. |


{% note info Dependencies %}
To be able to use this cacher, install the `lru-cache` module with the `npm install lru-cache --save` command.
{% endnote %}

### Redis cacher
`RedisCacher` is a built-in [Redis](https://redis.io/) based distributed cache module. It uses [`ioredis`](https://github.com/luin/ioredis) library.
Use it, if you have multiple instances of services because if one instance stores some data in the cache, other instances will find it.

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
            monitor: false,
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

**With MessagePack serializer**
You can define a serializer for Redis Cacher. By default, it uses the JSON serializer.
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

**Options**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `prefix` | `String` | `null` | Prefix for generated keys. |
| `ttl` | `Number` | `null` | Time-to-live in seconds. Disabled: 0 or null |
| `monitor` | `Boolean` | `false` | Enable Redis client [monitoring feature](https://github.com/luin/ioredis#monitor). If enabled, every client operation will be logged (on debug level) |
| `redis` | `Object` | `null` | Custom Redis options. Will be passed to the `new Redis()` constructor. [Read more](https://github.com/luin/ioredis#connect-to-redis). |
| `keygen` | `Function` | `null` | Custom cache key generator function. |
| `maxParamsLength` | `Number` | `null` | Maximum length of params in generated keys. |
| `serializer` | `String` | `"JSON"` | Name of a built-in serializer. |
| `cluster` | `Object` | `null` | Redis Cluster client configuration. [More information](https://github.com/luin/ioredis#cluster) |
| `lock` | `Boolean` or `Object` | `null` | Enable lock feature. |
| `pingInterval` | `Number` | `null` | Emit a Redis PING command every `pingInterval` milliseconds. Can be used to keep connections alive which may have idle timeouts. |

{% note info Dependencies %}
To be able to use this cacher, install the `ioredis` module with the `npm install ioredis --save` command.
{% endnote %}


## Custom cacher
Custom cache module can be created. We recommend to copy the source of [MemoryCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/memory.js) or [RedisCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/redis.js) and implement the `get`, `set`, `del` and `clean` methods.

### Create custom cacher
```js
const BaseCacher = require("moleculer").Cachers.Base;

class MyCacher extends BaseCacher {
    async get(key) { /*...*/ }
    async set(key, data, ttl) { /*...*/ }
    async del(key) { /*...*/ }
    async clean(match = "**") { /*...*/ }
}
```

### Use custom cacher

```js
const { ServiceBroker } = require("moleculer");
const MyCacher = require("./my-cacher");

const broker = new ServiceBroker({
    cacher: new MyCacher()
});
```


### Handling missing cache entries
To be able to distinguish between a cache miss and a cache with a `null` value you can use the `missingResponse` option. This option allows you to define a custom response for cache misses.

By default, the cache miss response is `undefined`.

**Example: using a custom symbol to detect missing entries**

```js
const missingSymbol = Symbol("MISSING");

// moleculer.config.js
module.exports = {
    cacher: {
        type: "Memory",
        options: {
            missingResponse: missingSymbol
        }
    }
}

// Get data from cache

const res = await cacher.get("not-existing-key");
if (res === cacher.opts.missingSymbol) {
    console.log("It's not cached.");
}
```