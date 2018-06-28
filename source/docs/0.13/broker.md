title: Broker
---
The `ServiceBroker` is the main component of Moleculer. It handles services, calls actions, emit events and communicates with remote nodes. 
You need to create a `ServiceBroker` instance for every node.

<div align="center">
![Broker logical diagram](assets/service-broker.svg)
</div>

## Create broker
**Create broker with default settings:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker();
```

**Create broker with custom settings:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    logger: console,
    logLevel: "info"
});
```

**Create broker with transporter to communicate with remote nodes:**
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

## Broker options
List of all available broker options:

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `namespace` | `String` | `""` | Namespace of nodes. With it you can segment your nodes on the same network. |
| `nodeID` | `String` | hostname + PID | Unique node identifier. Must be unique in a namespace. |
| `logger` | `Boolean` or `Object` or `Function` | `console` | Logger class. By default, it prints message to the `console`. You can use an external logger e.g. [winston](https://github.com/winstonjs/winston) or [pino](https://github.com/pinojs/pino). [Read more](logging.html). |
| `logLevel` | `String` | `info` | Log level for built-in console logger (trace, debug, info, warn, error, fatal). |
| `logFormatter` | `String` or `Function` | `"default"` | Log formatter for built-in console logger. Values: `default`, `simple`, `short`. It can be also a `Function`. |
| `logObjectPrinter` | `Function` | `null` | Custom object & array printer for built-in console logger. |
| `transporter` | `String` or `Object` or `Transporter` | `null` | Transporter settings. [Read more](networking.html).  |
| `requestTimeout` | `Number` | `0` | Number of milliseconds to wait before reject a request with a `RequestTimeout` error. Disabled: `0` |
| `retryPolicy` | `Object` | | Retry policy settings. [Read more](fault-tolerance.html) |
| `maxCallLevel` | `Number` | `0` | Limit of calling level. If it reaches the limit, broker will throw an `MaxCallLevelError` error. _(Infinite loop protection)_ |
| `heartbeatInterval` | `Number` | `5` | Number of seconds to send heartbeat packet to other nodes. |
| `heartbeatTimeout` | `Number` | `15` | Number of seconds to wait before setting node to unavailable status. |
| `tracking` | `Object` | | Tracking requests and waiting for running requests before shutdowning. [Read more](fault-tolerance.html) |
| `disableBalancer` | `Boolean` | `false` | Disable built-in request & emit balancer. _Transporter must support it as well._ |
| `registry` | `Object` | | Settings of [Service Registry](registry.html) |
| `circuitBreaker` | `Object` | | Settings of [Circuit Breaker](fault-tolerance.html) |
| `cacher` | `String` or `Object` or `Cacher` | `null` | Cacher settings. [Read more](caching.html) |
| `serializer` | `String` or `Serializer` | `JSONSerializer` | Instance of serializer. [Read more](networking.html) |
| `validation` | `Boolean` | `true` | Enable [parameters validation](validating.html). |
| `validator` | `Validator` | `null` | Custom Validator class for validation. |
| `metrics` | `Boolean` | `false` | Enable [metrics](metrics.html) function. |
| `metricsRate` | `Number` | `1` | Rate of metrics calls. `1` means to measure every request. |
| `internalServices` | `Boolean` | `true` | Register [internal services](services.html#Internal-services). |
| `internalServices` | `Boolean` | `true` | Register [internal middlewares](middlewares.html#Internal-middlewares). |
| `hotReload` | `Boolean` | `false` | Watch the loaded services and hot reload if they changed. [Read more](services.html#Hot-reloading-services). |
| `middlewares` | `Array<Function>` | `null` | Register middlewares. _Useful when you use Moleculer Runner._ |
| `replCommands` | `Array<Object>` | `null` | Register custom REPL commands. |
| `created` | `Function` | `null` | Fired when the broker created. _Useful when you use Moleculer Runner._ |
| `started` | `Function` | `null` | Fired when the broker started. _Useful when you use Moleculer Runner._ |
| `stopped` | `Function` | `null` | Fired when the broker stopped. _Useful when you use Moleculer Runner._ |
| `ServiceFactory` | `ServiceClass` | `null` | Custom Service class. If not `null`, broker will use it when creating services. |
| `ContextFactory` | `ContextClass` | `null` | Custom Context class. If not `null`, broker will use it when creating contexts. |

### Full options oject
```js
{
    namespace: "dev",
    nodeID: "node-25",

    logger: true,
    logLevel: "info",
    logFormatter: "default",
    logObjectPrinter: null,

    transporter: "nats://localhost:4222",

    requestTimeout: 5000,
    retryPolicy: {
        enabled: true,
        retries: 5,
        delay: 100,
        maxDelay: 1000,
        factor: 2,
        check: err => err && !!err.retryable
    },

    maxCallLevel: 100,
    heartbeatInterval: 5,
    heartbeatTimeout: 15,
    
    tracking: {
        enabled: true,
        shutdownTimeout: 5000,
    },

    disableBalancer: false,

    registry: {
        strategy: "RoundRobin",
        preferLocal: true
    },

    circuitBreaker: {
        enabled: true,
        threshold: 0.5,
        windowTime: 60,
        minRequestCount: 20,
        halfOpenTime: 10 * 1000,
        check: err => err && err.code >= 500
    },   

    bulkhead: {
        enabled: true,
        concurrency: 10,
        maxQueueSize: 100,
    },

    transit: {
        maxQueueSize: 50 * 1000
    },     

    cacher: "memory",
    serializer: null,

    validation: true,
    validator: null,

    metrics: true,
    metricsRate: 1,

    internalServices: true,
    internalMiddlewares: true,

    hotReload: true,

    ServiceFactory: null,
    ContextFactory: null,

    middlewares: [myMiddleware()],

    replCommands: [],

    created(broker) {
    },

    started(broker) {
    },

    stopped(broker) {
    }
}
```

{% note info Moleculer runner %}
You don't need to create manually ServiceBroker in your project. You can use the [Moleculer Runner](runner.html) to create and execute a broker and load services. [Read more about Moleculer Runner](runner.html).
{% endnote %}


## Ping
TODO

## Methods
TODO

## Properties
TODO