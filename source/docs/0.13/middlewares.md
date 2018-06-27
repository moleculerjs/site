title: Middlewares
---

Moleculer supports middlewares. The middleware is an `Object` with hooks & wrapper functions. You can add wrap the action handlers, event handlers, broker methods and hook lifecycle events.

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
		return function(payload, sender, eventName) {
			// Change payload or something
			return next(payload, sender, eventName);
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
Some methods should be wrapper functions. It means, you need to wrap the original handler and return with a new `Function`.

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

The `next` is the original handler or the following wrapped handler. The middleware should return either the original `handler` or a new wrapped handler. As you can see above, we check whether the action has a `params` props. If yes, we'll return a wrapped handler which calls the validator module before calling the original `handler`.
If the `params` property is not defined, we will return the original `handler` (skipped wrapping).

>If you don't call the original `next` in the middleware it will break the request. You can use it in cachers. For example, if it finds the requested data in the cache, it'll return the cached data instead of calling the `next`.

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
> The `next` always returns a `Promise`. It means that you can access to responses and manipulate them, as well.

### Decorate core modules (extend functionality)
With other hooks are help you to add new features to `ServiceBroker` & `Service`.

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
Many integrated features have been exposed to internal middlewares. These middlewares are loaded by default when broker is created. You can turn off it with the `internalMiddlewares: false` broker option. In this case you have to add what you need in the `middlewares: []` broker option.  

**Internal middlewares**

| Class name | Type | Description |
| ---------- | ---- | ----------- |
| `ActionHook` | Optional | Action hooks handler |
| - | Optional | Parameter validation |
| `Bulkhead` | Optional | Bulkhead feature |
| - | Optional | Cacher middleware |
| `ContextTracker` | Optional | Context tracker feature |
| `CircuitBreaker` | Optional | Circuit Breaker feature |
| `Timeout` | Always | Timeout feature |
| `Retry` | Always | Retry feature|
| `Fallback` | Always | Fallback feature |
| `ErrorHandler` | Always | Error handling |
| `Metrics` | Optional | Metrics feature |

**TODO: links to features**

**Access to internal middlewares**
```js
const { Bulkhead, Retry } = require("moleculer").Middlewares;
```


<div align="center">
![Middlewares diagram](assets/middlewares.svg)
</div>