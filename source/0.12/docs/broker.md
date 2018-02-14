title: Service Broker
---
The `ServiceBroker` is the main component of Moleculer. It handles services & events, calls actions and communicates with remote nodes. You need to create an instance of `ServiceBroker` on every node.

## Create broker
Create broker with default settings:
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker();
```

Create broker with custom settings:
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    logger: console,
    logLevel: "info"
});
```

Create broker with NATS transporter:
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "node-1",
    transporter: "nats://localhost:4222",
    logger: console,
    logLevel: "debug",
    requestTimeout: 5 * 1000,
    requestRetry: 3
});
```

Create broker with cacher:
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    cacher: "memory",
    logger: console
});   
```

### Broker options
All available options within the constructor:
```js
{
    namespace: "staging",
    nodeID: "node-25",

    logger: true,
    logLevel: "info",
    logFormatter: "default",

    transporter: "nats://localhost:4222",
    requestTimeout: 0,
    requestRetry: 0,
    maxCallLevel: 100,
    heartbeatInterval: 5,
    heartbeatTimeout: 15,

    disableBalancer: false,

    registry: {
        strategy: Moleculer.Strategies.RoundRobinStrategy,
        preferLocal: true
    },

    circuitBreaker: {
        enabled: true,
        maxFailures: 3,
        halfOpenTime: 10 * 1000,
        failureOnTimeout: true,
        failureOnReject: true
    },    

    cacher: "memory",
    serializer: null,

    validation: true,
    validator: null,

    metrics: false,
    metricsRate: 1,
    statistics: false,
    internalServices: true,

    hotReload: true,

    ServiceFactory: null,
    ContextFactory: null,

    // Add middlewares
    middlewares: [myMiddleware()],

    // Fired when the broker created
    created(broker) {
    },

    // Fired when the broker started
    started(broker) {
        // You can return Promise
        return broker.Promise.resolve();
    },

    // Fired when the broker stopped
    stopped(broker) {
        // You can return Promise
        return broker.Promise.resolve();
    }
}
```

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `namespace` | `String` | `""` | Namespace of nodes. With it you can segment your nodes. |
| `nodeID` | `String` | Computer name + process PID | When `nodeID` didn't define in broker options, the broker generated it from hostname (`os.hostname()`). It could cause problem for new users when they tried to start multiple instances on the same computer. Therefore, the broker generates `nodeID` from hostname ** and process PID**. The newly generated nodeID looks like `server-6874` where `server` is the hostname and `6874` is the PID. |
| `logger` | `Boolean` or `Object` or `Function` | `null` | Logger class. During development you can set to `console` or `true`. In production you can use an external logger e.g. [winston](https://github.com/winstonjs/winston) or [pino](https://github.com/pinojs/pino). [Read more](logger.html) |
| `logLevel` | `String` or `Object` | `info` | Log level for built-in console logger (trace, debug, info, warn, error, fatal). |
| `logFormatter` | `String` or `Function` | `default` | Log formatting for built-in console logger. Values: `default`, `simple`. It can be also Function. |
| `transporter` | `String` or `Object` or `Transporter` | `null` | Transporter settings. Required if you have 2 or more nodes. [Read more](transporters.html)  |
| `requestTimeout` | `Number` | `0` | Number of milliseconds to wait before returning a `RequestTimeout` error when it takes too long to return a value. Disable: 0 |
| `requestRetry` | `Number` | `0` | Count of retries. If the request is timed out, broker will try to call again. |
| `maxCallLevel` | `Number` | `0` | Limit of call level. If it reaches the limit, broker will throw an `MaxCallLevelError` error. |
| `heartbeatInterval` | `Number` | `5` | Number of seconds to send heartbeat packet to other nodes |
| `heartbeatTimeout` | `Number` | `15` | Number of seconds to wait before setting the node to unavailable status |
| `disableBalancer` | `Boolean` | `false` | Disable built-in request & emit balancer. _Only if the transporter support it._ |
| `registry` | `Object` | | Settings of [Service Registry](service-registry.html) |
| `circuitBreaker` | `Object` | | Settings of [Circuit Breaker](circuit-breaker.html) |
| `cacher` | `String` or `Object` or `Cacher` | `null` | Cacher settings. [Read more](#cachers.html) |
| `serializer` | `String` or `Serializer` | `JSONSerializer` | Instance of serializer. [Read more](serializers.html) |
| `validation` | `Boolean` | `true` | Enable [parameters validation](validation.html). |
| `validator` | `Validator` | `null` | Custom Validator class for validation. |
| `metrics` | `Boolean` | `false` | Enable [metrics](metrics.html) function. |
| `metricsRate` | `Number` | `1` | Rate of metrics calls. `1` means 100% (measure every request) |
| `statistics` | `Boolean` | `false` | Enable broker [statistics](statistics.html). Collect the requests count & latencies |
| `internalServices` | `Boolean` | `true` | Register [internal services](#Internal-services) for metrics & statistics functions |
| `hotReload` | `Boolean` | `false` | Enable to watch the loaded services and hot reload if they changed. [Read more](service.html#Hot-reloading-services) |
| `ServiceFactory` | `Class` | `null` | Custom Service class. If not `null`, broker will use it when creating services |
| `ContextFactory` | `Class` | `null` | Custom Context class. If not `null`, broker will use it when creating contexts |
| `middlewares` | `List` | `null` | Add Middlewares |
| `created` | `Function` | `null` | Fired when the broker created |
| `started` | `Function` | `null` | Fired when the broker started, and you can return Promise |
| `stopped` | `Function` | `null` | Fired when the broker stopped, and you can return Promise |

{% note info Moleculer runner %}
You don't need to create ServiceBroker in your project. You can use our new [Moleculer Runner](runner.html) to execute a broker and load services. [Read more about Moleculer Runner](runner.html).
{% endnote %}

## Call services
You can call service by calling the `broker.call` method. The broker searches the service (and the node) that has the given action and call it. The function returns a `Promise`.

### Syntax
```js
let promise = broker.call(actionName, params, opts);
```
The `actionName` is a dot-separated string. The first part of it is the service name, while the second part of it represents the action name. So if you have a `posts` service which has a `create` action, you'll need to use `posts.create` as the `actionName` to call it.

The `params` is an object which is passed to the action as a part of the [Context](context.html). *It is optional.*

The `opts` is an object. With this, you can set/override some request parameters, e.g.: `timeout`, `retryCount`. *It is optional.*

**Available call options:**

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `timeout` | `Number` | `requestTimeout` of broker | Timeout of request in milliseconds. If the request is timed out and you don't define `fallbackResponse`, broker will throw a `RequestTimeout` error. Disable: `0` or `null`|
| `retryCount` | `Number` | `requestRetry` of broker | Count of retry of request. If the request timed out, broker will try to call again. |
| `fallbackResponse` | `Any` | `null` | Returns with it, if the request has failed. [More info](#Request-timeout-amp-fallback-response) |
| `nodeID` | `String` | `null` | Target nodeID. If set, it will make a direct call. |
| `meta` | `Object` | `null` | Metadata of request. It will be transferred in sub-calls as well. |


### Usage
```js
// Call without params
broker.call("user.list")
    .then(res => console.log("User list: ", res));

// Call with params
broker.call("user.get", { id: 3 })
    .then(res => console.log("User: ", res));

// Call with options
broker.call("user.recommendation", { limit: 5 }, {
    timeout: 500,
    retry: 3,
    fallbackResponse: defaultRecommendation
}).then(res => console.log("Result: ", res));

// Call with error handling
broker.call("posts.update", { id: 2, title: "Modified post title" })
    .then(res => console.log("Post updated!"))
    .catch(err => console.error("Unable to update Post!", err));    

// Direct call: get health info from the "node-21" node
broker.call("$node.health", {}, { nodeID: "node-21" })
    .then(res => console.log("Result: ", res));    
```

### Request timeout & fallback response
If you call the action with `timeout` and the request is timed out, broker will throw a `RequestTimeoutError` error.
But if you set `fallbackResponse` in calling options, broker won't throw error. Instead, it will return with this given value. The `fallbackResponse` can be an `Object`, `Array`...etc.

The `fallbackResponse` can also be a `Function`, which returns a `Promise`. In this case, the broker passes the current `Context` & `Error` objects to this function as arguments.

```js
broker.call("user.recommendation", { limit: 5 }, {
    timeout: 500,
    fallbackResponse(ctx, err) {
        // Return a common response from cache
        return broker.cacher.get("user.commonRecommendation");
    }
}).then(res => console.log("Result: ", res));
```

### Distributed timeouts
Moleculer uses [distributed timeouts](https://www.datawire.io/guide/traffic/deadlines-distributed-timeouts-microservices/). In case of chained calls, the timeout value is decremented with the elapsed time. If the timeout value is less or equal than 0, the next calls is skipped (`RequestSkippedError`) because the first call has been already rejected.

### Retries
If you set the `retryCount` property in calling options and the request returns with a `MoleculerRetryableError` error, broker will recall the action with the same parameters as long as `retryCount` is greater than `0`.
```js
broker.call("user.list", { limit: 5 }, { timeout: 500, retryCount: 3 })
    .then(res => console.log("Result: ", res));
```
### Metadata

At requests, `ctx.meta` is sent back to the caller service. You can use it to send extra meta information back to the caller. E.g.: send response headers back to API gateway or set resolved logged in user to metadata.

** Export & download a file with API gateway: **
```js
// Export data
export(ctx) {
    const rows = this.adapter.find({});

    // Set response headers to download it as a file
    ctx.meta.headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Content-Disposition": 'attachment; filename=\"book.json\"'
    }

    return rows;
}
```
** Authenticate: **
```js
auth(ctx) {
    let user = this.getUserByJWT(ctx.params.token);
    if (ctx.meta.user) {
        ctx.meta.user = user;

        return true;
    }

    throw new Forbidden();
}
```
## Emit events
Broker has a built-in balanced event bus to support [Event-driven architecture](http://microservices.io/patterns/data/event-driven-architecture.html). You can send events to the local and remote services.

### Balanced emit with grouping
You can send balanced events with `emit` functions. In this case, only one instance per service receives the event.
> **Example:** you have 2 main services: `users` & `payments`. Both subscribe to the `user.created` event. You start 3 instances from `users` service and 2 instances from `payments` service. If you emit the `user.created` event, only one `users` and one `payments` service will receive the event.

The first parameter is the name of the event, the second parameter is the payload. If you want to send multiple values, you should wrap them in an object.

```js
// The `user` will be serialized to transportation.
broker.emit("user.created", user);
```

You can specify which services receives the event:
```js
// Only the `mail` & `payments` services receives it
broker.emit("user.created", user, ["mail", "payments"]);
```

### Broadcast event
With `broker.broadcast` method you can send events to all local remote services. It is not balanced.
```js
broker.broadcast("config.changed", config);
```

The `broker.broadcast` function has a third `groups` argument similar to `broker.emit`.
```js
// Send to all "mail" service instances
broker.broadcast("user.created", { user }, "mail");

// Send to all "user" & "purchase" service instances.
broker.broadcast("user.created", { user }, ["user", "purchase"]);
```

### Local broadcast event
With `broker.broadcastLocal` method you can send events to all **local** services. It is not balanced and not transferred.
```js
broker.broadcastLocal("$services.changed");
```

### Local events
Every local event must start with `$` _(dollar sign)_. E.g.: `$node.connected`.
If you publish these events with `emit` or `broadcast`, only local services will receive them.

### Subscribe to events
You can only subscribe to events in ['events' property of services](service.html#events).
_In event names you can use wildcards too._

```js
module.exports = {
    events: {
        // Subscribe to `user.created` event
        "user.created"(user) {
            console.log("User created:", user));
        },

        // Subscribe to all `user` events
        "user.*"(user) {
            console.log("User event:", user));
        }

        // Subscribe to all events
        "**"(payload, sender, event) {
            console.log(`Event '${event}' received from ${sender} node:`, payload));
        }
    }
}
```

## Start & Stop

## Starting logic

The broker starts transporter connecting but it doesn't publish the local service list to remote nodes. When it's done, it starts all services (calls service `started` handlers). Once all services start successfully, broker publishes the local service list to remote nodes. Hence other nodes send requests only after all local service started properly.

>Please note: you can make dead-locks when two services wait for each other. E.g.: `users` service has `dependencies: [posts]` and `posts` service has `dependencies: [users]`. To avoid it remove the concerned service from `dependencies` and use `waitForServices` method out of `started` handler instead.

## Stoping logic

The broker sends to remote nodes that local services is `stopped`, then starting stopping all local services. The broker starts transporter disconnecting .

## Middlewares
Broker supports middlewares. You can add your custom middleware, and it will be called before every local request. The middleware is a `Function` that returns a wrapped action handler.

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

The `handler` is the request handler of action, which is defined in [Service](service.html) schema. The `action` is the action object from Service schema. The middleware should return with the original `handler` or a new wrapped handler. As you can see above, we check whether the action has a `params` props. If yes, we'll return a wrapped handler which will call the validator module before calling the original `handler`.
If the `params` property is not defined, we will return the original `handler` (skipped wrapping).

>If you don't call the original `handler` in the middleware it will break the request. You can use it in cachers. For example, if it finds the requested data in the cache, it'll return the cached data instead of calling the `handler`.

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

## Wait for services
The broker has a `waitForServices` method. With it, you can wait for services with a `Promise`.

**Parameters**

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `services` | `String` or `Array` | - | Service list to waiting |
| `timeout` | `Number` | `0` | Waiting timeout. `0` means no timeout. If reached, the broker throw a `MoleculerServerError` |
| `interval` | `Number` | `1000` | Delay between watches in milliseconds |

**Example**
```js
broker.waitForServices(["posts", "users"]).then(() => {
    // Call it after the `posts` & `users` services are available
});
```

```js
broker.waitForServices("accounts", 10 * 1000, 500).then(() => {
    // Call it after `accounts` service is available in 10 seconds
});
```

## Internal services
The broker contains some internal services to check the node health or get broker statistics. You can disable it with the `internalServices: false` broker option within the constructor.

### List of nodes
This actions lists all connected nodes.
```js
broker.call("$node.list").then(res => console.log(res));
```

### List of services
This action lists all registered services (local & remote).
```js
broker.call("$node.services").then(res => console.log(res));
```
It has some options which you can declare within `params`.

**Options**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `onlyLocal` | `Boolean` | `false` | If `true`, lists only local services. |
| `skipInternal` | `Boolean` | `false` | If `true`, skips the internal services (`$node`). |
| `withActions` | `Boolean` | `false` | If `true`, lists also the actions of services. |

### List of local actions
This action lists all registered actions.
```js
broker.call("$node.actions").then(res => console.log(res));
```
It has some options which you can declare within `params`.

**Options**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `onlyLocal` | `Boolean` | `false` | If `true`, lists only local actions. |
| `skipInternal` | `Boolean` | `false` | If `true`, skips the internal actions (`$node`). |
| `withEndpoints` | `Boolean` | `false` | If `true`, lists also the endpoints _(nodes)_ of actions. |

### List of local events
This action lists all event subscriptions.
```js
broker.call("$node.events").then(res => console.log(res));
```
It has some options which you can declare within `params`.

**Options**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `onlyLocal` | `Boolean` | `false` | If `true`, lists only local subscriptions. |
| `skipInternal` | `Boolean` | `false` | If `true`, skips the internal event subscriptions `$`. |
| `withEndpoints` | `Boolean` | `false` | If `true`, lists also the endpoints _(nodes)_ of subscription. |

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
    "client": {
        "type": "nodejs",
        "version": "0.11.0",
        "langVersion": "v6.11.3"
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

## Internal events
The broker emits some internal local events.

### `$services.changed`
The broker sends this event if some node loads or destroys services after `broker.start`.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `localService ` | `Boolean` | True if a local service changed. |

### `$circuit-breaker.open`
The broker sends this event when the circuit breaker module change its state to `open`.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action  name |
| `failures` | `Number` | Count of failures |


### `$circuit-breaker.half-open`
The broker sends this event when the circuit breaker module change its state to `half-open`.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action  name |

### `$circuit-breaker.close`
The broker sends this event when the circuit breaker module change its state to `closed`.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action  name |

### `$node.connected`
The broker sends this event when a node connected or reconnected.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |
| `reconnected` | `Boolean` | Is reconnected? |

### `$node.updated`
The broker sends this event when it has received an INFO message from a node, i.e. changed the service list on the node.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |

### `$node.disconnected`
The broker sends this event when a node disconnected.

**Parameters**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |
| `unexpected` | `Boolean` | `true` - Not received heartbeat, `false` - Received `DISCONNECT` message from node. |
