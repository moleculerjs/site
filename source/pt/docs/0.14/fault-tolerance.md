title: Tolerância a falhas
---

Moleculer tem vários mecanismos integrados de tolerância a falhas. Eles podem ser habilitados ou desabilitados nas opções de broker.

## Circuit Breaker

Moleculer tem uma solução integrada que aplica o padrão circuit-breaker. Trata-se de uma implementação baseada em limites. Ele usa uma janela do tempo para verificar a taxa de falha das requisições. Uma vez que o limite é atingido, ele aciona o disjuntor.

{% note info O que é circuit breaker? %}
O Circuit Breaker pode impedir que um aplicativo tente repetidamente executar uma operação que provavelmente falhará. Allowing it to continue without waiting for the fault to be fixed or wasting CPU cycles while it determines that the fault is long lasting. The Circuit Breaker pattern also enables an application to detect whether the fault has been resolved. If the problem appears to have been fixed, the application can try to invoke the operation.

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

| Name              | Type       | Default                             | Description                                                          |
| ----------------- | ---------- | ----------------------------------- | -------------------------------------------------------------------- |
| `enabled`         | `Boolean`  | `false`                             | Enable feature                                                       |
| `threshold`       | `Number`   | `0.5`                               | Threshold value. `0.5` means that 50% should be failed for tripping. |
| `minRequestCount` | `Number`   | `20`                                | Minimum request count. Below it, CB does not trip.                   |
| `windowTime`      | `Number`   | `60`                                | Number of seconds for time window.                                   |
| `halfOpenTime`    | `Number`   | `10000`                             | Number of milliseconds to switch from `open` to `half-open` state    |
| `check`           | `Function` | `err && err.code >= 500` | A function to check failed requests.                                 |

> If the circuit-breaker state is changed, ServiceBroker will send [internal events](events.html#circuit-breaker-opened).

These global options can be overridden in action definition, as well.
```js
// users.service.js
module.export = {
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
There is an exponential backoff retry solution. It can recall failed requests.

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    retryPolicy: {
        enabled: true,
        retries: 5,
        delay: 100,
        maxDelay: 2000,
        factor: 2,
        check: err => err && !!err.retryable
    }
});
```

### Settings

| Name       | Type       | Default                          | Description                                              |
| ---------- | ---------- | -------------------------------- | -------------------------------------------------------- |
| `enabled`  | `Boolean`  | `false`                          | Enable feature.                                          |
| `retries`  | `Number`   | `5`                              | Count of retries.                                        |
| `delay`    | `Number`   | `100`                            | First delay in milliseconds.                             |
| `maxDelay` | `Number`   | `2000`                           | Maximum delay in milliseconds.                           |
| `factor`   | `Number`   | `2`                              | Backoff factor for delay. `2` means exponential backoff. |
| `check`    | `Function` | `err && !!err.retryable` | A function to check failed requests.                     |

**Overwrite the retries value in calling option**
```js
broker.call("posts.find", {}, { retries: 3 });
```

**Overwrite the retry policy values in action definitions**
```js
// users.service.js
module.export = {
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
Timeout can be set for service calling. It can be set globally in broker options, or in calling options. If the timeout is defined and request is timed out, broker will throw a `RequestTimeoutError` error.

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
Moleculer uses [distributed timeouts](https://www.datawire.io/guide/traffic/deadlines-distributed-timeouts-microservices/). In case of nested calls, the timeout value is decremented with the elapsed time. If the timeout value is less or equal than 0, the next nested calls will be skipped (`RequestSkippedError`) because the first call has already been rejected with a `RequestTimeoutError` error.

## Bulkhead
Bulkhead feature is implemented in Moleculer framework to control the concurrent request handling of actions.

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    bulkhead: {
        enabled: true,
        concurrency: 3,
        maxQueueSize: 10,
    }
});
```

### Global Settings

| Name           | Type      | Default | Description                    |
| -------------- | --------- | ------- | ------------------------------ |
| `enabled`      | `Boolean` | `false` | Enable feature.                |
| `concurrency`  | `Number`  | `3`     | Maximum concurrent executions. |
| `maxQueueSize` | `Number`  | `10`    | Maximum size of queue          |

The `concurrency` value restricts the concurrent request executions. If the `maxQueueSize` is bigger than `0`, broker stores the additional requests in a queue if all slots are taken. If the queue size reaches the `maxQueueSize` limit, broker will throw `QueueIsFull` exception for every addition requests.

### Action Settings

[Global settings](#Global-Settings) can be overridden in action definition.

**Overwrite the retry policy values in action definitions**
```js
// users.service.js
module.export = {
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
