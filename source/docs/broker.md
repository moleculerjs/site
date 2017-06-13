title: Service Broker
---
The `ServiceBroker` is the main component of Moleculer. It handles services & events, calls actions and communicates with remote nodes. You need to create an instance of `ServiceBroker` on every node.

## Create broker
Create broker with default settings
```js
let { ServiceBroker } = require("moleculer");
let broker = new ServiceBroker();
```

Create broker with custom settings
```js
let { ServiceBroker } = require("moleculer");
let broker = new ServiceBroker({
    logger: console,
    logLevel: "info"
});
```

Create broker with transporter
```js
let { ServiceBroker, NatsTransporter } = require("moleculer");
let broker = new ServiceBroker({
    nodeID: "node-1",
    transporter: new NatsTransporter(),
    logger: console,
    logLevel: "debug",
    requestTimeout: 5 * 1000,
    requestRetry: 3
});
```

Create broker with cacher
```js
let ServiceBroker = require("moleculer").ServiceBroker;
let MemoryCacher = require("moleculer").Cachers.Memory;
let broker = new ServiceBroker({
    cacher: new MemoryCacher(),
    logger: console,
    logLevel: {
        "*": "warn", // global log level for every modules
        "CACHER": "debug" // custom log level for cacher modules
    }
});    
```

### Constructor options
All available options:
```js
{
    nodeID: null,

    logger: null,
    logLevel: "info",

    transporter: null,
    requestTimeout: 0,
    requestRetry: 0,
    maxCallLevel: 500,
    heartbeatInterval: 10,
    heartbeatTimeout: 30,

    registry: {
        strategy: STRATEGY_ROUND_ROBIN,
        preferLocal: true
    },

    circuitBreaker: {
        enabled: true,
        maxFailures: 5,
        halfOpenTime: 10 * 1000,
        failureOnTimeout: true,
        failureOnReject: true
    },    

    cacher: null,
    serializer: null,

    validation: true,
    metrics: false,
    metricsRate: 1,
    statistics: false,
    internalActions: true
    
    ServiceFactory: null,
    ContextFactory: null
}
```

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `nodeID` | `String` | Computer name | This is the ID of node. It identifies a node in a cluster when there are many nodes. |
| `logger` | `Object` | `null` | Logger class. During development you can set to `console`. In production you can set an external logger e.g. [winston](https://github.com/winstonjs/winston) or [pino](https://github.com/pinojs/pino) |
| `logLevel` | `String` or `Object` | `info` | Level of logging (debug, info, warn, error). It can be a `String` or an `Object`. [Read more](logger.html) |
| `transporter` | `Transporter` | `null` | Instance of transporter. Required if you have 2 or more nodes. [Read more](transporters.html)  |
| `requestTimeout` | `Number` | `0` | Number of milliseconds to wait before returning a `RequestTimeout` error when it takes too long to return a value. Disable: 0 |
| `requestRetry` | `Number` | `0` | Count of retries. If the request is timed out, broker will try to call again. |
| `maxCallLevel` | `Number` | `0` | Limit of call level. If reach the limit, broker will throw an `MaxCallLevelError` error. |
| `heartbeatInterval` | `Number` | `10` | Number of seconds to send heartbeat packet to other nodes |
| `heartbeatTimeout` | `Number` | `30` | Number of seconds to wait before setting the node to unavailable status |
| `registry` | `Object` | | Settings of [Service Registry](service-registry.html) |
| `circuitBreaker` | `Object` | | Settings of [Circuit Breaker](circuit-breaker.html) |
| `cacher` | `Cacher` | `null` | Instance of cacher. [Read more](#cachers.html) |
| `serializer` | `Serializer` | `JSONSerializer` | Instance of serializer. [Read more](serializers.html) |
| `validation` | `Boolean` | `true` | Enable [parameters validation](validation.html). |
| `metrics` | `Boolean` | `false` | Enable [metrics](metrics.html) function. |
| `metricsRate` | `Number` | `1` | Rate of metrics calls. `1` means 100% (measure every request) |
| `statistics` | `Boolean` | `false` | Enable broker [statistics](statistics.html). Collect the requests count & latencies |
| `internalActions` | `Boolean` | `true` | Register [internal actions](#Internal-actions) for metrics & statistics functions |
| `ServiceFactory` | `Class` | `null` | Custom Service class. If not `null`, broker will use it when creating services |
| `ContextFactory` | `Class` | `null` | Custom Context class. If not `null`, broker will use it when creating contexts |

## Call services
You can call a service by calling the `broker.call` method. Broker will search the service (and the node) that has the given action and call it. The function will return a `Promise`.

### Syntax
```js
let promise = broker.call(actionName, params, opts);
```
The `actionName` is a dot-separated string. The first part of it is the service name. The seconds part of it is the action name. So if you have a `posts` service which has a `create` action, you need to use `posts.create` as `actionName` to call it.

The `params` is an object that will be passed to the action as part of the [Context](context.html). *It is optional.*

The `opts` is an object. With this, you can set/override some request parameters, e.g.: `timeout`, `retryCount`. *It is optional.*

**Available call options:**

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `timeout` | `Number` | `requestTimeout` of broker | Timeout of request in milliseconds. If the request is timed out and you don't define `fallbackResponse`, broker will throw a `RequestTimeout` error. Disable: `0` or `null`|
| `retryCount` | `Number` | `requestRetry` of broker | Count of retry of request. If the request timed out, broker will try to call again. |
| `fallbackResponse` | `Any` | `null` | Return with it, if the request is failed. [More info](#Request-timeout-amp-fallback-response) |


### Usage
```js
// Call without params
broker.call("user.list").then(res => console.log("User list: ", res));

// Call with params
broker.call("user.get", { id: 3 }).then(res => console.log("User: ", res));

// Call with options
broker.call("user.recommendation", { limit: 5 }, { timeout: 500, fallbackResponse: defaultRecommendation })
    .then(res => console.log("Result: ", res));

// Call with error handling
broker.call("posts.update", { id: 2, title: "Modified post title" })
    .then(res => console.log("Post updated!"))
    .catch(err => console.error("Unable to update Post!", err));    
```

### Request timeout & fallback response
If you call action with `timeout` and the request is timed out, broker will throw a `RequestTimeoutError` error.
But if you set `fallbackResponse` in calling options, broker won't throw error, instead will return with this given value. It can be an `Object`, `Array`...etc. 
This can be also a `Function`, which returns a `Promise`. In this case the broker will pass the current `Context` to this function as an argument.

Moleculer uses [distributed timeouts](https://www.datawire.io/guide/traffic/deadlines-distributed-timeouts-microservices/).In case of chained calls the timeout value will be decremented with the elapsed time. If the timeout value is less or equal than 0, next calls will be skipped (`RequestSkippedError`) because the first call is rejected any way.

## Emit events
Broker has an internal event bus. You can send events locally & globally. The local event will be received only by local services of broker. The global event that will be received by all services on all nodes (transferred via transporter).

### Send event
You can send events with `emit` and `emitLocal` functions. First parameter is the name of event, second parameter is the payload. 

```js
// Emit a local event that will be received only by local services
broker.emitLocal("service.started", { service: service, version: 1 });

// Emit a global event that will be received by all nodes. 
// The `user` will be serialized to transportation.
broker.emit("user.created", user);
```

### Subscribe to events
To subscribe for events use the `on` or `once` methods. Or in [Service](service.html) you can use the `events` property.
In event names you can use wildcards too.

```js
// Subscribe to `user.created` event
broker.on("user.created", user => console.log("User created:", user));

// Subscribe to `user` events
broker.on("user.*", user => console.log("User event:", user));

// Subscribe to all events
broker.on("**", (payload, sender) => console.log(`Event from ${sender || "local"}:`, payload));
```

To unsubscribe call the `off` method of broker.

## Middlewares
Broker supports middlewares. You can add your custom middleware, and it'll be called before every local request. The middleware is a `Function` that returns a wrapped action handler. 

**Example middleware from the validator modules**
```js
return function validatorMiddleware(handler, action) {
    // Wrap a param validator if `action.params` is defined
    if (_.isObject(action.params)) {
        return ctx => {
            this.validate(action.params, ctx.params);
            return handler(ctx);
        };
    }
    return handler;

}.bind(this);
```

The `handler` is the request handler of action, what is defined in [Service](service.html) schema. The `action` is the action object from Service schema. The middleware should return with the original `handler` or a new wrapped handler. As you can see above, we check whether the action has a `params` props. If yes we'll return a wrapped handler which will call the validator module before calling the original `handler`. 
If there is not defined the  `params` property we will return the original `handler` (skipped wrapping).

_If you don't call the original `handler` in the middleware it will break the request. You can use it in cachers. E.g.: If it find the requested data in the cache, it'll return the cached data instead of call the `handler`_

**Example code from cacher middleware**
```js
return (handler, action) => {
    return function cacherMiddleware(ctx) {
        const cacheKey = this.getCacheKey(action.name, ctx.params, action.cache.keys);
        const content = this.get(cacheKey);
        if (content != null) {
            // Found in the cache! Don't call handler, return with the cached content
            ctx.cachedResult = true;
            return Promise.resolve(content);
        }

        // Call the handler
        return handler(ctx).then(result => {
            // Afterwards save the response to the cache
            this.set(cacheKey, result);

            return result;
        });
    }.bind(this);
};
```

## Internal actions
The broker registers some internal actions to check the health of node or get broker statistics.

### List of services
This action lists all registered services (local & remote).
```js
broker.call("$node.services").then(res => console.log(res));
```
It has some options what you can set in `params`.

**Options**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `onlyLocal` | `Boolean` | `false` | If `true`, lists only local services. |
| `skipInternal` | `Boolean` | `false` | If `true`, skips the internal services (`$node`). |
| `withActions` | `Boolean` | `false` | If `true`, lists also the actions of services. |

### List of local actions
This action lists the local actions.
```js
broker.call("$node.actions").then(res => console.log(res));
```
It has some options what you can set in `params`.

**Options**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `onlyLocal` | `Boolean` | `false` | If `true`, lists only local actions. |
| `skipInternal` | `Boolean` | `false` | If `true`, skips the internal actions (`$node`). |
| `withEndpoints` | `Boolean` | `false` | If `true`, lists also the endpoints _(nodes)_ of actions. |

### List of nodes
This actions lists all connected nodes.
```js
broker.call("$node.list").then(res => console.log(res));
```

### Health of node
This action returns the health info of process & OS.
```js
broker.call("$node.health").then(res => console.log(res));
```

Example health info:
```js
{
    "cpu": {
        "load1": 0,
        "load5": 0,
        "load15": 0,
        "cores": 4,
        "utilization": 0
    },
    "mem": {
        "free": 1217519616,
        "total": 17161699328,
        "percent": 7.094400109979598
    },
    "os": {
        "uptime": 366733.2786046,
        "type": "Windows_NT",
        "release": "6.1.7601",
        "hostname": "Developer-PC",
        "arch": "x64",
        "platform": "win32",
        "user": {
            "uid": -1,
            "gid": -1,
            "username": "Developer",
            "homedir": "C:\\Users\\Developer",
            "shell": null
        }
    },
    "process": {
        "pid": 13096,
        "memory": {
            "rss": 47173632,
            "heapTotal": 31006720,
            "heapUsed": 22112024
        },
        "uptime": 25.447
    },
    "net": {
        "ip": [
            "192.168.2.100",
            "192.168.232.1",
            "192.168.130.1",
            "192.168.56.1",
            "192.168.99.1"
        ]
    },
    "time": {
        "now": 1487338958409,
        "iso": "2017-02-17T13:42:38.409Z",
        "utc": "Fri, 17 Feb 2017 13:42:38 GMT"
    }
}
```


### Statistics
This action returns the request statistics if the `statistics` is enabled in [options](broker.html#Constructor-options).
```js
broker.call("$node.stats").then(res => console.log(res));
```

Example statistics:
```js
{
  "requests": {
    // Total statistics
    "total": {

      // Count of requests
      "count": 45,

      // Count of error by code
      "errors": {},

      // Req/sec values
      "rps": {
        "current": 0.7999854548099126,
        // Last x values
        "values": [
          0,
          6.59868026394721,
          2.200440088017604
        ]
      },

      // Request latency values (ms)
      "latency": {
        "mean": 0.8863636363636364,
        "median": 0,
        "90th": 1,
        "95th": 5,
        "99th": 12,
        "99.5th": 12
      }
    },

    // Action-based statistics
    "actions": {
      "posts.find": {
        "count": 4,
        "errors": {},
        "rps": {
          "current": 0.599970001499925,
          "values": [
            1.7985611510791368,
            0.20004000800160032
          ]
        },
        "latency": {
          "mean": 7.5,
          "median": 5,
          "90th": 12,
          "95th": 12,
          "99th": 12,
          "99.5th": 12
        }
      }
    }
  }
}
```

## REPL mode
Broker has an interactive REPL mode to help the development & testing. With REPL you can load services, call actions, emit events, subscribe & unsubscribe events from your console. [Read more about it](repl.html)
