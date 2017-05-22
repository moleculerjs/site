title: Cachers
---
Moleculer has built-in cache solutions. You have to do two things to enable it:

1. Set a cacher instance to the broker in [constructor options](#constructor-options)
2. Set the `cache: true` in [action definition](#actions).

```js
let { ServiceBroker } = require("moleculer");
let MemoryCacher = require("moleculer").Cachers.Memory;

let broker = new ServiceBroker({
    logger: console,
    cacher: new MemoryCacher()
});

broker.createService({
    name: "users",
    // cache: true, // If you enable here, all actions will be cached!
    actions: {
        list: {
            cache: true, // Cache this action
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

Promise.resolve()
.then(() => {
    // Will be called the handler, because the cache is empty
    return broker.call("users.list").then(res => console.log("Users count: " + res.length));
})
.then(() => {
    // Return from cache, handler won't be called
    return broker.call("users.list").then(res => console.log("Users count from cache: " + res.length));
});
```
Console messages:
```
[BROKER] users service registered!
[USERS-SVC] Handler called!
Users count: 2
Users count from cache: 2
```
[Try it on Runkit](https://runkit.com/icebob/58b1fa48215e1500140b8fa7)

## Cache keys
The cacher creates keys by service name, action name, and hash of params of context.
The key syntax is
```
    <actionName>:<parameters or hash of parameters>
```
So if you call the `posts.list` action with params `{ limit: 5, offset: 20 }`, the cacher calculate a hash from the params. So next time if you call this action with the same params, it will find in the cache by key. 
```
// Hashed cache key for "posts.find" action
posts.find:0d6bcb785d1ae84c8c20203401460341b84eb8b968cffcf919a9904bb1fbc29a
```

However the hash calculation is an expensive operation. But you can specify which parameters you want to use for caching. In this case you need to set an object for `cache` property that contains the list of parameters.
```js
{
    name: "posts",
    actions: {
        list: {
            cache: {
                // Only generate cache by from "limit" and "offset" param values
                keys: ["limit", "offset"]
            },
            handler(ctx) {
                return this.getList(ctx.params.limit, ctx.params.offset);
            }
        }
    }
}

// If params is { limit: 10, offset: 30 }, the cache will be:
//   posts.list:10-30
```
> This solution is faster, so we recommend to use it in production environment. ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)

## Manual caching
You can also use the cacher manually. Just call the `get`, `set`, `del` methods of `broker.cacher`.

```js
// Save to cache
broker.cacher.set("mykey", { a: 5 });

// Get from cache (Please note! Some cacher maybe returns with Promise)
let obj = broker.cacher.get("mykey", { a: 5 });

// Remove entry from cache
broker.cacher.del("mykey");

// Clean all entries
broker.cacher.clean();
```

## Clear cache
When you create a new model in your service, sometimes you have to clear the old cache entries. For this purpose there are internal events. When an event like this is fired, the cacher will clean the cache.

```js
{
    name: "users",
    actions: {
        create(ctx) {
            // Create new user
            let user = new User(ctx.params);

            // Clear all cache entries
            ctx.emit("cache.clean");

            // Clear all cache entries which keys start with `users.`
            ctx.emit("cache.clean", "users.*");

            // Clear multiple cache entries
            ctx.emit("cache.clean", [ "users.*", "posts.*" ]);

            // Delete only one entry
            ctx.emit("cache.del", "users.list");

            // Delete multiple entries
            ctx.emit("cache.del", [ "users.model:5", "users.model:8" ]);
        }
    }
}
```

## Memory cacher
`MemoryCacher` is a built-in memory cache module.

```js
let MemoryCacher = require("moleculer").Cachers.Memory;

let broker = new ServiceBroker({
    cacher: new MemoryCacher({
        ttl: 30 // Time-to-live is 30sec. Disabled: 0 or null
    })
});
```

## Redis cacher
`RedisCacher` is a built-in [Redis](https://redis.io/) based cache module. It uses [`ioredis`](https://github.com/luin/ioredis) client.

```js
let RedisCacher = require("moleculer").Cachers.Redis;

let broker = new ServiceBroker({
    cacher: new RedisCacher({
        ttl: 30, // Time-to-live is 30sec. Disabled: 0 or null
        prefix: "SERVICER" // Prefix for cache keys
        monitor: false // Turn on/off Redis client monitoring. Will be logged (on debug level) every client operations.

        // Redis settings, pass to the `new Redis()` constructor
        redis: { 
            host: "redis",
            port: 6379,
            password: "1234",
            db: 0
        }
    })
});
```

## Custom cacher
You can also create your custom cache module. We recommend you to copy the source of [`MemoryCacher`](src/cachers/memory.js) or [`RedisCacher`](src/cachers/redis.js) and implement the `get`, `set`, `del` and `clean` methods.
