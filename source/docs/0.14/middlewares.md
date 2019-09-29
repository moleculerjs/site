title: Middlewares
---

Moleculer supports middlewares. The middleware is an `Object` with hooks & wrapper functions. It allows to wrap action handlers, event handlers, broker methods and hook lifecycle events.

## Complete List
**All available methods:**
```js
const MyCustomMiddleware = {
    // Wrap local action handlers (legacy middleware handler)
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
    },

    // Wrap remote action calling
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
    },

    // Wrap local event handlers
    localEvent(next, event) {
        return (ctx) => {
			return next(ctx);
		};
    },

    // Wrap broker.createService method
    createService(next) {
        return function(schema, schemaMods) {
            console.log("The 'createService' is called.");
            return next(schema, schemaMods);
        };
    },

    // Wrap broker.destroyService method
    destroyService(next) {
        return function(service) {
            console.log("The 'destroyService' is called.");
            return next(service);
        };
    },

    // Wrap broker.call method
    call(next) {
        return function(actionName, params, opts) {
            console.log("The 'call' is called.", eventName);
            return next(actionName, params, opts).then(res => {
                console.log("Response:", res);
                return res;
            });
        };
    },

    // Wrap broker.mcall method
    mcall(next) {
        return function() {
            console.log("The 'call' is called.", eventName);
            return next(...arguments).then(res => {
                console.log("Response:", res);
                return res;
            });
        };
    },

    // Wrap broker.emit method
    emit(next) {
        return function(eventName, payload, groups) {
            console.log("The 'emit' is called.", eventName);
            return next(eventName, payload, groups);
        };
    },

    // Wrap broker.broadcast method
    broadcast(next) {
        return function(eventName, payload, groups) {
            console.log("The 'broadcast' is called.", eventName);
            return next(eventName, payload, groups);
        };
    },

    // Wrap broker.broadcastLocal method
    broadcastLocal(next) {
        return function(eventName, payload, groups) {
            console.log("The 'broadcastLocal' is called.", eventName);
            return next(eventName, payload, groups);
        };
    },

    // After a new local service created (sync)
    serviceCreated(service) {
        console.log("Service created", service.name);
    },

    // Before a local service started (async)
    serviceStarting(service) {
        console.log("Service is starting", service.name);
    },

    // After a local service started (async)
    serviceStarted(service) {
        console.log("Service started", service.name);
    },

    // Before a local service stopping (async)
    serviceStopping(service) {
        console.log("Service is stopping", service.name);
    },

    // After a local service stopped (async)
    serviceStopped(service) {
        console.log("Service stopped", service.name);
    },

    // Called before registering a local service instance
    registerLocalService(next) {
        return (service) => {
            console.log("Registering local services");
            return next(service);
        };
    },

    // Called during local service creation (after mixins are applied, i.e, service schema is merged completely)
    serviceCreating(service, schema) {
        // Modify schema
        schema.myProp = "John";
    },

    // Called before sending a communication packet
    transitPublish(next) {
        return (packet) => {
            return next(packet);
        };
    },

    // Called before transit receives & parses an incoming message
    transitMessageHandler(next) {
        return (cmd, packet) => {
            return next(cmd, packet);
        };
    },

    // Called after serialization but before the transporter sends a communication packet
    transporterSend(next) {
        return (topic, data, meta) => {
            // Do something with data
            return next(topic, data, meta);
        };
    },

    // Called after transporter received a communication packet but before serialization
    transporterReceive(next) {
        return (cmd, data, s) => {
            // Do something with data
            return next(cmd, data, s);
        };
    },

    // After broker is created (async)
    created(broker) {
        console.log("Broker created");
    },

    // Before broker starting (async)
    starting(broker) {
        console.log("Broker is starting");
    },

    // After broker started (async)
    started(broker) {
        console.log("Broker started");
    },

    // Before broker stopping (async)
    stopping(broker) {
        console.log("Broker is stopping");
    },

    // After broker stopped (async)
    stopped(broker) {
        console.log("Broker stopped");
    }
}
```

## Wrapping handlers
Some hooks are wrappers. It means you must wrap the original handler and return a new Function.
Wrap hooks where the first parameter is `next`.

**Wrap local action handler**
```js
const MyDoSomethingMiddleware = {
    localAction(next, action) {
        if (action.myFunc) {
            // Wrap the handler
            return function(ctx) {
                doSomethingBeforeHandler(ctx);

                return handler(ctx)
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
        // So it won't cut down the performance at calling where the feature is disabled.
        return handler;
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

The `next` is the original handler or the following wrapped handler. The middleware should return either the original `handler` or a new wrapped handler. As you can see above, the middleware checks whether the action has a `params` property. If yes, it will return a wrapped handler which calls the validator module before calling the original `handler`. If the `params` property is not defined, it simply returns the original `handler` (skipped wrapping).

>If you don't call the original `next` in the middleware it will break the request. It can be used in cachers. For example, if it finds the requested data in the cache, it'll return the cached data instead of calling the `next`.

**Example cacher middleware**
```js
const MyCacher = {
    localAction(next, action) {
        return function cacherMiddleware(ctx) {
            const cacheKey = this.getCacheKey(action.name, ctx.params, action.cache.keys);
            const content = this.get(cacheKey);
            if (content != null) {
                // Found in the cache! Don't call next, return with the cached content
                ctx.cachedResult = true;
                return Promise.resolve(content);
            }

            // Call the next
            return next(ctx).then(result => {
                // Afterwards save the response to the cache
                this.set(cacheKey, result);

                return result;
            });
        }.bind(this);
    }
};
```
> The `next` always returns a `Promise`. So you can access to responses and manipulate them, as well.

### Decorate core modules (extend functionality)
Middleware functions can be used to add new features to `ServiceBroker` & `Service`.

**Decorate broker with a new `allCall` method**
```js
const broker = new ServiceBroker({
    middlewares: [
        {
            // After broker is created
            created(broker) {
                // Call action on all available nodes
                broker.allCall = function(action, params, opts = {}) {
                    const nodeIDs = this.registry.getNodeList({ onlyAvailable: true })
                        .map(node => node.id);

                    // Make direct call to the given Node ID
                    return Promise.all(nodeIDs.map(nodeID => broker.call(action, params, Object.assign({ nodeID }, opts))));
                }
            }
        }
    ]
});

await broker.start();

// Call `$node.health` on every nodes & collect results
const res = await broker.allCall("$node.health");
```


## Internal middlewares
Many integrated features have been exposed as internal middlewares. These middlewares are loaded by default when broker is created. However, they can be turned off by setting the `internalMiddlewares: false` in broker option. In this case you must explicitly specify the required middlewares in the `middlewares: []` broker option.  

**Internal middlewares**

| Class name | Type | Description |
| ---------- | ---- | ----------- |
| `ActionHook` | Optional | Action hooks handler. [Read more](actions.html#Action-hooks) |
| `Validator` | Optional | Parameter validation. [Read more](validating.html) |
| `Bulkhead` | Optional | Bulkhead feature. [Read more](fault-tolerance.html#Bulkhead) |
| `Cacher` | Optional | Cacher middleware. [Read more](caching.html) |
| `ContextTracker` | Optional | Context tracker feature. [Read more](actions.html#Context-tracking) |
| `CircuitBreaker` | Optional | Circuit Breaker feature. [Read more](fault-tolerance.html#Circuit-Breaker) |
| `Timeout` | Always | Timeout feature. [Read more](fault-tolerance.html#Timeout) |
| `Retry` | Always | Retry feature. [Read more](fault-tolerance.html#Retry) |
| `Fallback` | Always | Fallback feature. [Read more](fault-tolerance.html#Fallback) |
| `ErrorHandler` | Always | Error handling. |
| `Metrics` | Optional | Metrics feature. [Read more](metrics.html) |
| `Transmit.Encryption` | Optional | Transmission encryption middleware. [Read more](#Encryption) |
| `Transmit.Compression` | Optional | Transmission compression middleware. [Read more](#Compression) |
| `Debugging.TransitLogger` | Optional | Transit Logger. [Read more](#Transit-Logger)  |
| `Debugging.ActionLogger` | Optional | Action logger. [Read more](#Action-Logger) |

**Access to internal middlewares**
```js
const { Bulkhead, Retry } = require("moleculer").Middlewares;
```

### Transmission Middleware
#### Encryption
AES encryption middleware protects all inter-services communications that use the transporter module.
This middleware uses built-in Node [`crypto`](https://nodejs.org/api/crypto.html) lib.
```javascript
const { Middlewares } = require("moleculer");

// Create broker
const broker = new ServiceBroker({
  middlewares: [
    Middlewares.Transmit.Encryption("secret-password", "aes-256-cbc", initVector) // "aes-256-cbc" is the default
  ]
});
```
#### Compression
Compression middleware reduces the size of the messages that go through the transporter module.
This middleware uses built-in Node [`zlib`](https://nodejs.org/api/zlib.html) lib.
```javascript
const { Middlewares } = require("moleculer");

// Create broker
const broker = new ServiceBroker({
  middlewares: [
    Middlewares.Transmit.Compression("deflate") // or "deflateRaw" or "gzip"
  ]
});
```

### Debug Middleware
#### Transit Logger
Transit logger middleware allows to easily track the messages that are exchanged between services.

```javascript
const { Middlewares } = require("moleculer");

// Create broker
const broker = new ServiceBroker({
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
});
```

**Complete option list**

| Class name | Type | Default | Description |
| ---------- | ---------- | ---- | ----------- |
| `logger` | `Object` or `Function`| `null` | Logger class. [Read more](logging.html). |
| `logLevel` | `String`| `info` | Log level for built-in console logger. [Read more](logging.html). |
| `logPacketData` |`Boolean`| `false` | Logs packet parameters |
| `folder` |`Object`| `null` | Path do folder where logs will be written |
| `extension` |`String`| `.json`, | File extension of log file |
| `color.receive` |`String`| `grey` | Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `color.send` |`String`| `grey` |  Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `packetFilter` |`Array<String>`| `HEARTBEAT` | Type of [packets](protocol.html#Packets) to log |

#### Action Logger
Action Logger middleware tracks "how" service actions were executed.

```javascript
const { Middlewares } = require("moleculer");

// Create broker
const broker = new ServiceBroker({
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
});

```

**Complete option list**

| Class name | Type | Default | Description |
| ---------- | ---------- | ---- | ----------- |
| `logger` | `Object` or `Function` | `null` | Logger class. [Read more](logging.html). |
| `logLevel` | `String`| `info` | Log level for built-in console logger. [Read more](logging.html). |
| `logParams` |`Boolean`| `false` | Logs request parameters |
| `logMeta` |`Boolean`| `false` | Logs meta parameters |
| `folder` |`String`| `null` | Path do folder where logs will be written |
| `extension` |`String`| `.json`, | File extension of log file |
| `color.request` |`String`| `yellow` | Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `color.response` |`String`| `cyan` | Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `colors.error` |`String`| `red` | Supports all [Chalk colors](https://github.com/chalk/chalk#colors) |
| `whitelist` |`Array<String>`| `**` | Actions to log. Uses the same whitelisting mechanism as in [API Gateway](moleculer-web.html#Whitelist). |

### Loading & Extending
If you want to use the built-in middlewares use their names in `middlewares[]` option. Also, the middleware object can be easily extended with custom functions. 

**Load middleware by name**
```javascript
    const { Middlewares } = require("moleculer");

    // Extend with custom middleware
    Middlewares.MyCustom = {
        created(broker) {
            broker.logger.info("My custom middleware is created!");
        }
    };


    const broker = new ServiceBroker({
        logger: true,
        middlewares: [
            // Load middleware by name
            "MyCustom"
        ]
    });  
```

## Global view
<div align="center">
    <img src="assets/middlewares.svg" alt="Middlewares diagram" />
</div>