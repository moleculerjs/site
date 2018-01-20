title: Cachers
---
Moleculer has a built-in caching solution. To enable it:
1. Set the `cacher` [broker option](broker.html#Constructor-options).
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
Console messages:
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
So if you call the `posts.list` action with params `{ limit: 5, offset: 20 }`, the cacher calculates a hash from the params. So the next time, when you call this action with the same params, it finds it within the cache by key. 
```
// Hashed cache key for "posts.find" action
posts.find:0d6bcb785d1ae84c8c20203401460341b84eb8b968cffcf919a9904bb1fbc29a
```

However, the hash calculation is an expensive operation. So you can specify which parameters you want to use for caching. In this case, you need to set an object for `cache` property that contains the list of parameters under the `keys` property.
```js
{
    name: "posts",
    actions: {
        list: {
            cache: {
                // Only generate cache key from "limit" and "offset" values
                keys: ["limit", "offset"]
            },
            handler(ctx) {
                return this.getList(ctx.params.limit, ctx.params.offset);
            }
        }
    }
}

// If params is { limit: 10, offset: 30 }, the cache key will be:
//   posts.list:10-30
```
> This solution is pretty fast, so we recommend to use it in production. ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)

## Manual caching
You can also use the cacher module manually. Just call the `get`, `set`, `del` methods of `broker.cacher`.

```js
// Save to cache
broker.cacher.set("mykey.a", { a: 5 });

// Get from cache (Please note! Some cacher maybe returns with Promise)
broker.cacher.get("mykey.a").then(obj => console.log(obj));

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
## Built-in cachers

### Memory cacher
`MemoryCacher` is a built-in memory cache module.

```js
let MemoryCacher = require("moleculer").Cachers.Memory;

let broker = new ServiceBroker({
    cacher: new MemoryCacher({
        ttl: 30 // Set Time-to-live to 30sec. Disabled: 0 or null
    })
});

// Shorthand
let broker = new ServiceBroker({
    cacher: "Memory"
});

// Or
let broker = new ServiceBroker({
    cacher: true
});
```

### Redis cacher
`RedisCacher` is a built-in [Redis](https://redis.io/) based cache module. It uses [`ioredis`](https://github.com/luin/ioredis) library.

```js
let RedisCacher = require("moleculer").Cachers.Redis;

let broker = new ServiceBroker({
    cacher: new RedisCacher({
        ttl: 30, // set Time-to-live to 30sec. Disabled: 0 or null
        monitor: false // Turns Redis client monitoring on/off. If enabled, every client operation will be logged (on debug level)

        // Redis settings, pass it to the `new Redis()` constructor
        redis: { 
            host: "redis",
            port: 6379,
            password: "1234",
            db: 0
        }
    })
});

// Shorthand
let broker = new ServiceBroker({
    cacher: "Redis"
});

// Shorthand with connection string
let broker = new ServiceBroker({
    cacher: "redis://redis-server:6379"
});

// Shorthand with options
let broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            prefix: "MOL",
            redis: {
                db: 3
            }
        }
    }
});
```

{% note info Dependencies %}
To be able to use this cacher, install the `ioredis` module with the `npm install ioredis --save` command.
{% endnote %}

### Custom cacher
You can also create your custom cache module. We recommend you to copy the source of [MemoryCacher](https://github.com/ice-services/moleculer/blob/master/src/cachers/memory.js) or [RedisCacher](https://github.com/ice-services/moleculer/blob/master/src/cachers/redis.js) and implement the `get`, `set`, `del` and `clean` methods.
