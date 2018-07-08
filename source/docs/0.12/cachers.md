title: Cachers
---
Moleculer has a built-in caching solution. To enable it:
1. Set the `cacher` [broker option](broker.html#Broker-options).
2. Set the `cache: true` in [action definition](service.html#Actions).

```js
let { ServiceBroker } = require("moleculer");

let broker = new ServiceBroker({
    logger: console,
    cacher: "Memory"
});

broker.createService({
    name: "users",
    actions: {
        list: {
            cache: true, // Enable caching to this action
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
> [Try it on Runkit](https://runkit.com/icebob/moleculer-cacher-example)

## Cache keys
The cacher creates keys by service name, action name, and the hash of params of context.
The syntax of key is:
```
    <serviceName>.<actionName>:<parameters or hash of parameters>
```
So if you call the `posts.list` action with params `{ limit: 5, offset: 20 }`, the cacher calculates a hash from the params. So the next time, when you call this action with the same params, it will find the entry in the cache by key.
```
// Example hashed cache key for "posts.find" action
posts.find:0d6bcb785d1ae84c8c20203401460341b84eb8b968cffcf919a9904bb1fbc29a
```

However, the hash generation is an expensive operation. Therefore it is recommended to set an object for `cache` property which contains a list of essential parameter names under the `keys` property.
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

// If params is { limit: 10, offset: 30 } and meta is { user: { id: 123 } }, the cache key will be:
//   posts.list:10-30-123
```

{% note info Performance %}
This solution is pretty fast, so we recommend to use it in production instead of hashing. ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)
{% endnote %}

### Cache meta keys
To use meta keys in cache `keys` use the `#` prefix.

```js
broker.createService({
    name: "posts",
    actions: {
        list: {
            cache: {
                // Cache key:  "limit" & "offset" from ctx.params, "user.id" from ctx.meta
                keys: ["limit", "offset", "#user.id"],
                ttl: 5
            },
            handler(ctx) {

            }
        }
    }
});
```

## TTL
You can override the cacher default TTL setting in action definition.

```js
let broker = new ServiceBroker({
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

            }
        }
    }
});
```

## Custom key-generator
You can change the built-in cacher keygen function to your own one.

```js
let broker = new ServiceBroker({
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
You can also use the cacher module manually. Just call the `get`, `set`, `del` methods of `broker.cacher`.

```js
// Save to cache
broker.cacher.set("mykey.a", { a: 5 });

// Get from cache (async)
const obj = await broker.cacher.get("mykey.a")

// Remove entry from cache
broker.cacher.del("mykey.a");

// Clean all 'mykey' entries
broker.cacher.clean("mykey.*");

// Clean all entries
broker.cacher.clean();
```

## Clear cache
When you create a new model in your service, sometimes you have to clear the old cached model entries.

**Example to clean the cache inside actions**
```js
{
    name: "users",
    actions: {
        create(ctx) {
            // Create new user entity
            let user = new User(ctx.params);

            // Clear all cache entries
            this.broker.cacher.clean();

            // Clear all cache entries which keys start with `users.`
            this.broker.cacher.clean("users.*");

            // Clear multiple cache entries
            this.broker.cacher.clean([ "users.*", "posts.*" ]);

            // Delete only one entry
            this.broker.cacher.del("users.list");

            // Delete multiple entries
            this.broker.cacher.del([ "users.model:5", "users.model:8" ]);
        }
    }
}
```

## Clear cache among multiple service instances
The best practice to clear cache entries among multiple service instances is that use broadcast events.

**Example**
```js
module.exports = {
    name: "users",
    actions: {
        create(ctx) {
            // Create new user entity
            let user = new User(ctx.params);

            // Clear cache
            this.cleanCache();
        }
    },

    methods: {
        cleanCache() {
            this.broker.broadcast("cache.clean.users");
        }
    }

    events: {
        "cache.clean.users"() {
            if (this.broker.cacher) {
                this.broker.cacher.clean("users.*");
            }
        }
    }
}
```

## Clear cache among different services
Common way is that your service depends on other ones. E.g. `posts` service stores information from `users` service in cached entries.

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
So the `author` field is received from `users` service. So if the `users` service clears cache entries, the `posts` service has to clear own cache entries as well. Therefore you should also subscribe to the `cache.clear.users` event in `posts` service.

To make it better, create a `CacheCleaner` mixin and define in constructor the dependent services.

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
        "users"
    ])],

    actions: {
        //...
    }
};
```

With this solution if the `users` service emits a `cache.clean.users` event, the `posts` service will also clear the own cache entries.

## Built-in cachers

### Memory cacher
`MemoryCacher` is a built-in memory cache module. It stores entries in the heap memory.

```js
const broker = new ServiceBroker({
    cacher: "Memory"
});

// Or
const broker = new ServiceBroker({
    cacher: true
});

// With options
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            ttl: 30 // Set Time-to-live to 30sec. Disabled: 0 or null
        }
    }
});

```

### Redis cacher
`RedisCacher` is a built-in [Redis](https://redis.io/) based distributed cache module. It uses [`ioredis`](https://github.com/luin/ioredis) library.

```js
const broker = new ServiceBroker({
    cacher: "Redis"
});

// With connection string
const broker = new ServiceBroker({
    cacher: "redis://redis-server:6379"
});

// With options
const broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            // Prefix for keys
            prefix: "MOL",            
            // set Time-to-live to 30sec. Disabled: 0 or null
            ttl: 30, 
            // Turns Redis client monitoring on/off. If enabled, every client
            // operation will be logged (on debug level)            
            monitor: false 
            // Redis settings, pass it to the `new Redis()` constructor
            redis: {
                host: "redis",
                port: 6379,
                password: "1234",
                db: 0
            }
        }
    }
});
```

{% note info Dependencies %}
To be able to use this cacher, install the `ioredis` module with the `npm install ioredis --save` command.
{% endnote %}

### Custom cacher
You can also create your custom cache module. We recommend to copy the source of [MemoryCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/memory.js) or [RedisCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/redis.js) and implement the `get`, `set`, `del` and `clean` methods.

#### Use custom cacher

```js
const { ServiceBroker } = require("moleculer");
const MyAwesomeCacher = require("./my-cacher");

const broker = new ServiceBroker({
    cacher: new MyAwesomeCacher()
});
```