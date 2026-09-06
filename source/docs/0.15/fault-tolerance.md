title: Fault tolerance
---

MoleculerJS incorporates a range of built-in fault-tolerance mechanisms — the standard resilience patterns of distributed systems: circuit breaker, retry with exponential backoff, timeout, bulkhead and fallback — designed to enhance the reliability and resilience of your microservices architecture. They are applied by the broker to every service call, so you don't have to wrap calls in a resilience library yourself. These features are configurable within the broker options, allowing you to enable or disable them based on your specific requirements and use cases.


## Circuit Breaker

Moleculer has a built-in circuit-breaker solution. It is a threshold-based implementation. It uses a time window to check the failed request rate. Once the threshold value is reached, it trips the circuit breaker.

{% note info What is the circuit breaker? %}
The Circuit Breaker can prevent an application from repeatedly trying to execute an operation that's likely to fail. Allowing it to continue without waiting for the fault to be fixed or wasting CPU cycles while it determines that the fault is long lasting. The Circuit Breaker pattern also enables an application to detect whether the fault has been resolved. If the problem appears to have been fixed, the application can try to invoke the operation.

Read more about circuit breaker on [Martin Fowler blog](https://martinfowler.com/bliki/CircuitBreaker.html) or on [Microsoft Azure Docs](https://docs.microsoft.com/azure/architecture/patterns/circuit-breaker).
{% endnote %}

If you enable it, all service calls will be protected by the circuit breaker.

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    circuitBreaker: {
        enabled: true,
        threshold: 0.5,
        minRequestCount: 20,
        windowTime: 60, // in seconds
        halfOpenTime: 5 * 1000, // in milliseconds
        check: err => err && err.code >= 500
    }
});
```

### Settings

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `enabled` | `Boolean` | `false` | Enable feature |
| `threshold` | `Number` | `0.5` | Threshold value. `0.5` means that 50% should be failed for tripping. |
| `minRequestCount` | `Number` | `20` | Minimum request count. Below it, CB does not trip. |
| `windowTime` | `Number` | `60` | Number of seconds for time window. |
| `halfOpenTime` | `Number` | `10000` | Number of milliseconds to switch from `open` to `half-open` state |
| `check` | `Function` | `err && err.code >= 500` | A function to check failed requests. |

> If the circuit-breaker state is changed, ServiceBroker will send [internal events](events.html#circuit-breaker-opened).

### How it works
The circuit breaker state is tracked by the **calling** broker, per endpoint, i.e. per `nodeID:actionName` pair. When a breaker trips, the affected endpoint is marked unavailable in the caller's registry, so the [balancer](balancing.html) skips that node and picks another instance of the service (if there is one). Other nodes calling the same action maintain their own, independent breakers. After `halfOpenTime` the breaker switches to `half-open` and lets a single probe request through: if it succeeds the breaker closes and the endpoint becomes available again; if it fails the endpoint stays blocked and the next probe is attempted after another `halfOpenTime`. Only errors that pass the `check` function *and* originate from the target node itself (or locally, e.g. a `RequestTimeoutError`) are counted as failures; errors propagated from a further downstream node called by the target are not.

These global options can be overridden in action definition, as well.
```js
// users.service.js
module.exports = {
    name: "users",
    actions: {
        create: {
            circuitBreaker: {
                // All CB options can be overwritten from broker options.
                threshold: 0.3,
                windowTime: 30
            },
            handler(ctx) {}
        }
    }
};
```

## Retry
There is an exponential backoff retry solution. It can recall failed requests with response [`MoleculerRetryableError`](errors.html#MoleculerRetryableError). It is disabled by default (`enabled: false`).

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    retryPolicy: {
        enabled: true,
        retries: 5,
        delay: 100,
        maxDelay: 1000,
        factor: 2,
        check: err => err && !!err.retryable
    }
});
```

### Settings

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `enabled` | `Boolean` | `false` | Enable feature. |
| `retries` | `Number` | `5` | Count of retries. |
| `delay` | `Number` | `100` | First delay in milliseconds. |
| `maxDelay` | `Number` | `1000` | Maximum delay in milliseconds. |
| `factor` | `Number` | `2` | Backoff factor for delay. `2` means exponential backoff. |
| `check` | `Function` | `err && !!err.retryable` | A function to check failed requests. |

**Overwrite the retries value in calling option** 
```js
broker.call("posts.find", {}, { retries: 3 });
```

{% note info Retry and timeout %}
`RequestTimeoutError` (and `QueueIsFullError`) are retryable errors, so when the retry policy is enabled, a timed-out call is retried up to `retries` times, and every attempt gets a fresh `timeout` window. The worst-case duration of one `broker.call` is therefore roughly `(retries + 1) × timeout` plus the backoff delays.
{% endnote %}

**Overwrite the retry policy values in action definitions** 
```js
// users.service.js
module.exports = {
    name: "users",
    actions: {
        find: {
            retryPolicy: {
                // All Retry policy options can be overwritten from broker options.
                retries: 3,
                delay: 500
            },
            handler(ctx) {}
        },
        create: {
            retryPolicy: {
                // Disable retries for this action
                enabled: false
            },
            handler(ctx) {}
        }
    }
};
```

## Timeout
Timeout can be set for service calling. It can be set globally in broker options (`requestTimeout`, in milliseconds; the default is `0`, which means disabled), in the action definition (`timeout`), or in calling options. If the timeout is defined and request is timed out, broker will throw a `RequestTimeoutError` error.

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    requestTimeout: 5 * 1000 // in milliseconds
});
```

**Overwrite the timeout value in calling option** 
```js
broker.call("posts.find", {}, { timeout: 3000 });
```

### Distributed timeouts
Moleculer uses [distributed timeouts](https://www.getambassador.io/learn/service-mesh/resilience-for-distributed-systems/#:~:text=too%20many%20times.-,Deadlines,-In%20addition%20to). In case of nested calls, the timeout value is decremented with the elapsed time. If the timeout value is less or equal than 0, the next nested calls will be skipped (`RequestSkippedError`) because the first call has already been rejected with a `RequestTimeoutError` error.

## Bulkhead
Bulkhead feature is implemented in Moleculer framework to control the concurrent request handling of actions.

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    bulkhead: {
        enabled: true,
        concurrency: 10,
        maxQueueSize: 100,
    }
});
```

### Global Settings

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `enabled` | `Boolean` | `false` | Enable feature. |
| `concurrency` | `Number` | `10` | Maximum concurrent executions. |
| `maxQueueSize` | `Number` | `100` | Maximum size of queue |

The `concurrency` value restricts the concurrent request executions. If the `maxQueueSize` is bigger than `0`, broker stores the additional requests in a queue if all slots are taken. If the queue size reaches the `maxQueueSize` limit, broker will throw `QueueIsFull` exception for every addition requests.

### Action Settings

[Global settings](#Global-Settings) can be overridden in action definition.

**Overwrite the retry policy values in action definitions** 
```js
// users.service.js
module.exports = {
    name: "users",
    actions: {
        find: {
            bulkhead: {
                // Disable bulkhead for this action
                enabled: false
            },
            handler(ctx) {}
        },
        create: {
            bulkhead: {
                // Increment the concurrency value for this action
                concurrency: 10
            },
            handler(ctx) {}
        }
    }
};
```


### Events Settings
Event handlers also support [bulkhead](#Bulkhead) feature.

**Example**
```js
// my.service.js
module.exports = {
    name: "my-service",
    events: {
        "user.created": {
            bulkhead: {
                enabled: true,
                concurrency: 1
            },
            async handler(ctx) {
                // Do something.
            }
        }
    }
}
```

## Fallback
Fallback feature is useful, when you don't want to give back errors to the users. Instead, call an other action or return some common content. Fallback response can be set in calling options or in action definition. It should be a `Function` which returns a `Promise` with any content. The broker passes the current `Context` & `Error` objects to this function as arguments.

**Fallback response setting in calling options**
```js
const result = await broker.call("users.recommendation", { userID: 5 }, {
    timeout: 500,
    fallbackResponse(ctx, err) {
        // Return a common response from cache
        return broker.cacher.get("users.fallbackRecommendation:" + ctx.params.userID);
    }
});
```

### Fallback in action definition
Fallback response can be also defined in receiver-side, in action definition.
> Please note, this fallback response will only be used if the error occurs within action handler. If the request is called from a remote node and the request is timed out on the remote node, the fallback response is not be used. In this case, use the `fallbackResponse` in calling option.

**Fallback as a function**
```js
module.exports = {
    name: "recommends",
    actions: {
        add: {
            fallback: (ctx, err) => "Some cached result",
            handler(ctx) {
                // Do something
            }
        }
    }
};
```

**Fallback as method name string**
```js
module.exports = {
    name: "recommends",
    actions: {
        add: {
            // Call the 'getCachedResult' method when error occurred
            fallback: "getCachedResult",
            handler(ctx) {
                // Do something
            }
        }
    },

    methods: {
        getCachedResult(ctx, err) {
            return "Some cached result";
        }
    }
};
```
