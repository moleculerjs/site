title: Middlewares
---

Moleculer supports middlewares. It's same as plugins in other frameworks. The middleware is an `Object` with hooks & wrapper functions. It allows to wrap action handlers, event handlers, broker methods and hook lifecycle events.

**Example**
```js
// awesome.middleware.js
module.exports = {
    name: "Awesome",

    localAction(next, action) {
        return function(ctx) {
            console.log(`My middleware is called before the `${ctx.action.name}` action executed.`);
            return next(ctx);
        }
    }
};
```

## Wrapping handlers
Some hooks are wrappers. It means that you can wrap the original handler and return a new Function. Wrap hooks are which the first parameter is `next`.

**Wrap local action handler**
```js
const MyDoSomethingMiddleware = {
    localAction(next, action) {
        if (action.myFunc) {
            // Wrap the handler
            return function(ctx) {
                doSomethingBeforeHandler(ctx);

                return next(ctx)
                    .then(res => {
                        doSomethingAfterHandler(res);
                        // Return the original result
                        return res;
                    })
                    .catch(err => {
                        doSomethingAfterHandlerIfFailed(err);

                        // Throw further the error
                        throw err;
                    });
            }
        }

        // If the feature is disabled we don't wrap it, return the original handler
        // So it won't cut down the performance when the feature is disabled.
        return next;
    }
};
```

**Example validator middleware**
```js
const MyValidator = {
    localAction(next, action) {
        // Wrap with a param validator if `action.params` is defined
        if (_.isObject(action.params)) {
            return ctx => {
                this.validate(action.params, ctx.params);
                return next(ctx);
            };
        }
        return next;
    }
};
```

The `next` is the original handler or the following wrapped handler. The middleware should return either the original `handler` or a new wrapped handler. As you can see above, the middleware checks whether the action has a `params` property. If yes, it will return a wrapped handler which calls the validator module before calling the original `handler`. If the `params` property is not defined, it simply returns the original `handler` (skip wrapping).
> If you don't call the original `next` in the middleware it will break the request. It can be used in cachers. For example, if it finds the requested data in the cache, it'll return the cached data instead of calling the `next`.

**Example cacher middleware**
```js
const MyCacher = {
    localAction(next, action) {
        return async function cacherMiddleware(ctx) {
            const cacheKey = this.getCacheKey(action.name, ctx.params, action.cache.keys);
            const content = await this.get(cacheKey);
            if (content != null) {
                // Found in the cache! Don't call next, return with the cached content
                ctx.cachedResult = true;
                return content;
            }

            // Call the next
            const result = await next(ctx);

            // Save the response to the cache
            this.set(cacheKey, result);
            return result;

        }.bind(this);
    }
};
```
> The `next()` always returns a `Promise`. So you can access to responses and manipulate them, as well.

## Decorate core modules (extend functionality)
Middleware functions can be used to add new features to `ServiceBroker` or `Service` classes.

**Decorate broker with a new `allCall` method**
```js
// moleculer.config.js
module.exports = {
    middlewares: [
        {
            // After broker is created
            created(broker) {
                // Call action on all available nodes
                broker.allCall = function(action, params, opts = {}) {
                    const nodeIDs = this.registry.getNodeList({ onlyAvailable: true })
                        .map(node => node.id);

                    // Make direct call to the given Node ID
                    return Promise.all(
                        nodeIDs.map(nodeID => broker.call(action, params, Object.assign({ nodeID }, opts)))
                    );
                }
            }
        }
    ]
};
```

Call the new method in order to call `$node.health` on every nodes:
```js
const res = await broker.allCall("$node.health");
```

## Hooks

### `localAction(next, action)`
This hook wraps the local action handlers.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    localAction(next, action) {
        return function(ctx) {
            // Change context properties or something
            return next(ctx)
                .then(res => {
                    // Do something with the response
                    return res;
                })
                .catch(err => {
                    // Handle error or throw further
                    throw err;
                });
        }
    }
}
```

### `remoteAction(next, action)`
This hook wraps the remote action handlers.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    remoteAction(next, action) {
        return function(ctx) {
            // Change context properties or something
            return next(ctx)
                .then(res => {
                    // Do something with the response
                    return res;
                })
                .catch(err => {
                    // Handle error or throw further
                    throw err;
                });
        }
    }
}
```

### `localEvent(next, event)`
This hook wraps the local event handlers.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    localEvent(next, event) {
        return (ctx) => {
            return next(ctx);
        };
    }
}
```

### `createService(next)`
This hook wraps the `broker.createService` method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    createService(next) {
        return function(schema, schemaMods) {
            console.log("The 'createService' is called.");
            return next(schema, schemaMods);
        };
    }
}
```

### `destroyService(next)`
This hook wraps the `broker.destroyService` method

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    destroyService(next) {
        return function(service) {
            console.log("The 'destroyService' is called.");
            return next(service);
        };
    }
}
```

### `call(next)`
This hook wraps the `broker.call` method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    call(next) {
        return function(actionName, params, opts) {
            console.log("The 'call' is called.", eventName);
            return next(actionName, params, opts).then(res => {
                console.log("Response:", res);
                return res;
            });
        };
    }
}
```

### `mcall(next)`
This hook wraps the `broker.mcall` method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    mcall(next) {
        return function() {
            console.log("The 'call' is called.", eventName);
            return next(...arguments).then(res => {
                console.log("Response:", res);
                return res;
            });
        };
    }
}
```

### `emit(next)`
This hook wraps the `broker.emit` method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    emit(next) {
        return function(eventName, payload, opts) {
            console.log("The 'emit' is called.", eventName);
            return next(eventName, payload, opts);
        };
    }
}
```

### `broadcast(next)`
This hook wraps the `broker.broadcast` method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    broadcast(next) {
        return function(eventName, payload, opts) {
            console.log("The 'broadcast' is called.", eventName);
            return next(eventName, payload, opts);
        };
    }
}
```

### `broadcastLocal(next)`
This hook wraps the `broker.broadcastLocal` method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    broadcastLocal(next) {
        return function(eventName, payload, opts) {
            console.log("The 'broadcastLocal' is called.", eventName);
            return next(eventName, payload, opts);
        };
    }
}
```

### `serviceCreated(service)` _(sync)_
This hook is called after local service creating.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceCreated(service) {
        console.log("Service created", service.fullName);
    }
}
```

### `serviceStarting(service)` _(async)_
This hook is called before service starting.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStarting(service) {
        console.log("Service is starting", service.fullName);
    }
}
```

### `serviceStarted(service)` _(async)_
This hook is called after service starting.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStarted(service) {
        console.log("Service started", service.fullName);
    }
}
```

### `serviceStopping(service)` _(async)_
This hook is called before service stopping.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStopping(service) {
        console.log("Service is stopping", service.fullName);
    }
}
```

### `serviceStopped(service)` _(async)_
This hook is called after service stopping.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStopped(service) {
        console.log("Service stopped", service.fullName);
    }
}
```

### `registerLocalService(next)`
This hook wraps broker's local service registering method.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    registerLocalService(next) {
        return (service) => {
            console.log("Registering a local service", service.name);
            return next(service);
        };
    }
}
```

### `serviceCreating(service, schema)`
This hook is called during local service creation (after mixins are applied, so service schema is merged completely).

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceCreating(service, schema) {
        // Modify schema
        schema.myProp = "John";
    }
}
```

### `transitPublish(next)`
This hook is called before sending a communication packet.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transitPublish(next) {
        return (packet) => {
            return next(packet);
        };
    }
}
```

### `transitMessageHandler(next)`
This hook is called before transit receives & parses an incoming message.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transitMessageHandler(next) {
        return (cmd, packet) => {
            return next(cmd, packet);
        };
    }
}
```

### `transporterSend(next)`
This hook is called after serialization but before the transporter sends a communication packet.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transporterSend(next) {
        return (topic, data, meta) => {
            // Do something with data. Data is a `Buffer`
            return next(topic, data, meta);
        };
    }
}
```

### `transporterReceive(next)`
This hook is called after transporter received a communication packet but before serialization.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transporterReceive(next) {
        return (cmd, data, s) => {
            // Do something with data. Data is a `Buffer`
            return next(cmd, data, s);
        };
    }
}
```

### `newLogEntry(type, args, bindings)` _(sync)_
This hook is called when a new log messages iscreated.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    newLogEntry(type, args, bindings) {
        // Do something with the `args`.
    }
}
```

### `created(broker)` _(async)_
This hook is called when broker created.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    created(broker) {
        console.log("Broker created");
    }
}
```

### `starting(broker)` _(async)_
This hook is called before broker starting.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    starting(broker) {
        console.log("Broker is starting");
    }
}
```

### `started(broker)` _(async)_
This hook is called after broker starting.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    started(broker) {
        console.log("Broker started");
    }
}
```

### `stopping(broker)` _(async)_
This hook is called before broker stopping.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    stopping(broker) {
        console.log("Broker is stopping");
    }
}
```

### `stopped(broker)` _(async)_
This hook is called after broker stopped.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    stopped(broker) {
        console.log("Broker stopped");
    }
}
```

## Internal middlewares
Many integrated features have been exposed as internal middlewares. These middlewares are loaded by default when broker is created. However, they can be turned off by setting the `internalMiddlewares: false` in broker option. In this case you must explicitly specify the required middlewares in the `middlewares: []` broker option.

**Internal middlewares**

| Class name                | Type     | Leírás                                                                     |
| ------------------------- | -------- | -------------------------------------------------------------------------- |
| `ActionHook`              | Optional | Action hooks handler. [Read more](actions.html#Action-hooks)               |
| `Validator`               | Optional | Parameter validation. [Read more](validating.html)                         |
| `Bulkhead`                | Optional | Bulkhead feature. [Read more](fault-tolerance.html#Bulkhead)               |
| `Cacher`                  | Optional | Cacher middleware. [Read more](caching.html)                               |
| `ContextTracker`          | Optional | Context tracker feature. [Read more](actions.html#Context-tracking)        |
| `CircuitBreaker`          | Optional | Circuit Breaker feature. [Read more](fault-tolerance.html#Circuit-Breaker) |
| `Timeout`                 | Always   | Timeout feature. [Read more](fault-tolerance.html#Timeout)                 |
| `Retry`                   | Always   | Retry feature. [Read more](fault-tolerance.html#Retry)                     |
| `Fallback`                | Always   | Fallback feature. [Read more](fault-tolerance.html#Fallback)               |
| `ErrorHandler`            | Always   | Error handling.                                                            |
| `Metrikák`                | Optional | Metrics feature. [Read more](metrics.html)                                 |
| `Debounce`                | Optional | Debounce feature. [Read more](#Debounce)                                   |
| `Throttle`                | Optional | Throttle feature. [Read more](#Throttle)                                   |
| `Transmit.Encryption`     | Optional | Transmission encryption middleware. [Read more](#Encryption)               |
| `Transmit.Compression`    | Optional | Transmission compression middleware. [Read more](#Compression)             |
| `Debugging.TransitLogger` | Optional | Transit Logger. [Read more](#Transit-Logger)                               |
| `Debugging.ActionLogger`  | Optional | Action logger. [Read more](#Action-Logger)                                 |

**Access to internal middlewares**
```js
const { Bulkhead, Retry } = require("moleculer").Middlewares;
```

### Transmission Middleware

#### Encryption
AES encryption middleware protects all inter-services communications that use the transporter module. This middleware uses built-in Node [`crypto`](https://nodejs.org/api/crypto.html) lib.

```js
// moleculer.config.js
const crypto = require("crypto");
const { Middlewares } = require("moleculer");
const initVector = crypto.randomBytes(16);

module.exports = {
  middlewares: [
    Middlewares.Transmit.Encryption("secret-password", "aes-256-cbc", initVector) // "aes-256-cbc" is the default
  ]
};
```
#### Compression
Compression middleware reduces the size of the messages that go through the transporter module. This middleware uses built-in Node [`zlib`](https://nodejs.org/api/zlib.html) lib.

```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Create broker
module.exports = {
  middlewares: [
    Middlewares.Transmit.Compression("deflate") // or "deflateRaw" or "gzip"
  ]
};
```

### Debug Middlewares

#### Transit Logger
Transit logger middleware allows to easily track the messages that are exchanged between services.

```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Create broker
module.exports = {
  middlewares: [
    Middlewares.Debugging.TransitLogger({
      logPacketData: false,
      folder: null,
      colors: {
        send: "magenta",
        receive: "blue"
      },
      packetFilter: ["HEARTBEAT"]
    })
  ]
};
```

**Complete option list**

| Class name      | Type                   | Default     | Leírás                                                             |
| --------------- | ---------------------- | ----------- | ------------------------------------------------------------------ |
| `naplózó`       | `Object` or `Function` | `null`      | Logger class. [Read more](logging.html).                           |
| `logLevel`      | `String`               | `info`      | Log level for built-in console logger. [Read more](logging.html).  |
| `logPacketData` | `Boolean`              | `false`     | Logs packet parameters                                             |
| `folder`        | `Object`               | `null`      | Folder where logs will be written                                  |
| `extension`     | `String`               | `.json`     | File extension of log file                                         |
| `color.receive` | `String`               | `grey`      | Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `color.send`    | `String`               | `grey`      | Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `packetFilter`  | `Array<String>`  | `HEARTBEAT` | Type of [packets](protocol.html#Packets) to skip                   |

#### Action Logger
Action Logger middleware tracks "how" service actions were executed.

```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Create broker
module.exports = {
  middlewares: [
    Middlewares.Debugging.ActionLogger({
      logParams: true,
      logResponse: true,
      folder: null,
      colors: {
        send: "magenta",
        receive: "blue"
      },
      whitelist: ["**"]
    })
  ]
};

```

**Complete option list**

| Class name       | Type                   | Default  | Leírás                                                                                                  |
| ---------------- | ---------------------- | -------- | ------------------------------------------------------------------------------------------------------- |
| `naplózó`        | `Object` or `Function` | `null`   | Logger class. [Read more](logging.html).                                                                |
| `logLevel`       | `String`               | `info`   | Log level for built-in console logger. [Read more](logging.html).                                       |
| `logParams`      | `Boolean`              | `false`  | Logs request parameters                                                                                 |
| `logMeta`        | `Boolean`              | `false`  | Logs meta parameters                                                                                    |
| `folder`         | `String`               | `null`   | Path do folder where logs will be written                                                               |
| `extension`      | `String`               | `.json`  | File extension of log file                                                                              |
| `color.request`  | `String`               | `yellow` | Supports all [Chalk colors](https://github.com/chalk/chalk#colors)                                      |
| `color.response` | `String`               | `cyan`   | Supports all [Chalk colors](https://github.com/chalk/chalk#colors)                                      |
| `colors.error`   | `String`               | `red`    | Supports all [Chalk colors](https://github.com/chalk/chalk#colors)                                      |
| `whitelist`      | `Array<String>`  | `["**"]` | Actions to log. Uses the same whitelisting mechanism as in [API Gateway](moleculer-web.html#Whitelist). |

### Event Execution Rate

#### Throttle
Throttling is a straightforward reduction of the trigger rate. It will cause the event listener to ignore some portion of the events while still firing the listeners at a constant (but reduced) rate. Same functionality as [lodash's `_.throttle`](https://lodash.com/docs/4.17.14#throttle). For more info about throttling check [this article](https://css-tricks.com/debouncing-throttling-explained-examples).

```js
//my.service.js
module.exports = {
    name: "my",
    events: {
        "config.changed": {
            throttle: 3000,
            // It won't be invoked again in 3 seconds.
            handler(ctx) { /* ... */}
        }
    }
};
```

#### Debounce
Unlike throttling, debouncing is a technique of keeping the trigger rate at exactly 0 until a period of calm, and then triggering the listener exactly once. Same functionality as [lodash's `_.debounce`](https://lodash.com/docs/4.17.14#debounce). For more info about debouncing check [this article](https://css-tricks.com/debouncing-throttling-explained-examples).

```js
//my.service.js
module.exports = {
    name: "my",
    events: {
        "config.changed": {
            debounce: 5000,
            // Handler will be invoked when events are not received in 5 seconds.
            handler(ctx) { /* ... */}
        }
    }
};
```

## Loading & Extending
If you want to use the built-in middlewares use their names in `middlewares[]` broker option. Also, the `Middlewares` can be easily extended with custom functions.

**Load middleware by name**
```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Extend with custom middleware
Middlewares.MyCustom = {
    created(broker) {
        broker.logger.info("My custom middleware is created!");
    }
};

module.exports = {
    logger: true,
    middlewares: [
        // Load middleware by name
        "MyCustom"
    ]
};  
```

## Global view

<div align="center">
    <img src="assets/middlewares.svg" alt="Middlewares diagram" />
</div>

