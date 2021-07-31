title: Configuration
---
## Broker options
These options can be used in `ServiceBroker` constructor or in `moleculer.config.js` file.

**List of all available broker options:**

* **`namespace`**: `String` - Namespace of nodes to segment your nodes on the same network (e.g.: "development", "staging", "production"). _Default: `""`_
* **`nodeID`**: `String` - Unique node identifier. Must be unique in a namespace. If not the broker will throw a fatal error and stop the process. _Default: hostname + PID_
* **`logger`**: `Boolean | String | Object | Array<Object>`  ) - Logger class. By default, it prints message to the `console`. [Read more](logging.html). _Default: `"Console"`
* **`logLevel`**: `String | Object` - Log level for loggers (trace, debug, info, warn, error, fatal). [Read more](logging.html). _Default: `info`_
* **`transporter`**: `String | Object | Transporter` - Transporter configuration. [Read more](networking.html).  _Default: `null`_
* **`requestTimeout`**: `Number` - Number of milliseconds to wait before reject a request with a `RequestTimeout` error. Disabled: `0` _Default: `0`_
* **`retryPolicy`**: `Object` - Retry policy configuration. [Read more](fault-tolerance.html#Retry).
* **`contextParamsCloning`**: `Boolean` - Cloning the `params` of context if enabled. _High performance impact. Use it with caution!_ _Default: `false`_
* **`dependencyInterval`**: Configurable interval (defined in `ms`) that's used by the services while waiting for dependency services. _Default: `1000`_
* **`maxCallLevel`**: `Number` - Limit of calling level. If it reaches the limit, broker will throw an `MaxCallLevelError` error. _(Infinite loop protection)_ _Default: `0`_
* **`heartbeatInterval`**: `Number` - Number of seconds to send heartbeat packet to other nodes. _Default: `5`_
* **`heartbeatTimeout`**: `Number` - Number of seconds to wait before setting remote nodes to unavailable status in Registry. _Default: `15`_
* **`tracking`**: `Object` - Tracking requests and waiting for running requests before shutdowning. _(Graceful shutdown)_ [Read more](context.html#Context-tracking).
* **`disableBalancer`**: Boolean - Disable built-in request & emit balancer. _Transporter must support it, as well._ [Read more](networking.html#Disabled-balancer). _Default: `false`_
* **`registry`**: `Object` - Settings of [Service Registry](registry.html).
* **`circuitBreaker`**: `Object` - Settings of [Circuit Breaker](fault-tolerance.html#Circuit-Breaker).
* **`bulkhead`**: `Object` - Settings of [bulkhead](fault-tolerance.html#Bulkhead).
* **`transit.maxQueueSize`**: `Number` - A protection against inordinate memory usages when there are too many outgoing requests. If there are more than _stated_ outgoing live requests, the new requests will be rejected with `QueueIsFullError` error. _Default: `50000`_
* **`transit.maxChunkSize`** `Number` - Maximum chunk size while streaming.  _Default: `256KB`_
* **`transit.disableReconnect`**: `Boolean` - Disables the reconnection logic while starting a broker. _Default: `false`_
* **`transit.disableVersionCheck`**: `Boolean` - Disable protocol version checking logic in Transit. _Default: `false`_
* **`transit.packetLogFilter`**: `Array` - Filters out the packets in debug log messages. It can be useful to filter out the `HEARTBEAT` packets while debugging. _Default: `[]`_
* **`uidGenerator`**: `Function` - Custom UID generator function for Context ID.
* **`errorHandler`**: `Function` - [Global error handler](broker.html#Global-error-handler) function.
* **`cacher`**: `String | Object | Cacher` - Cacher settings. [Read more](caching.html). _Default: `null`_
* **`serializer`**: `String | Serializer` - Instance of serializer. [Read more](networking.html). _Default: `JSONSerializer`_
* **`validator`**: `Boolean | Validator` - Enable the default or create custom [parameters validation](validating.html). _Default: `true`_
* **`metrics`**: `Boolean | Object` - Enable & configure [metrics](metrics.html) feature. _Default: `false`_
* **`tracing`**: `Boolean | Object` - Enable & configure [tracing](tracing.html) feature. _Default: `false`_
* **`internalServices`**: `Boolean | Object` - Register [internal services](services.html#Internal-Services) at start. _Default: `true`_
* **`internalServices.$node`** - `Object` - Extend internal services with [custom actions](services.html#Extending). _Default: `null`_
* **`internalMiddlewares`**: `Boolean` - Register [internal middlewares](middlewares.html#Internal-middlewares). _Default: `true`_
* **`hotReload`**: `Boolean` - Watch the loaded services and hot reload if they changed. [Read more](services.html#Hot-Reloading-Services). _Default: `false`_
* **`middlewares`**: `Array<Object>` - Register custom middlewares. _Default: `null`_
* **`replDelimiter`**: `String` - Custom REPL commands delimiter. _Default: `mol $`_
* **`replCommands`**: `Array<Object>` - Register custom REPL commands. _Default: `null`_
* **`metadata`**: `Object` - Store custom values. _Default: `null`_
* **`skipProcessEventRegistration`**: Boolean - Skip the [default](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) graceful shutdown event handlers. In this case, you have to register them manually. _Default: `false`_
* **`created`**: `Function` - Fired when the broker created. _Default: `null`_
* **`started`**: `Function` - Fired when the broker started _(all local services loaded & transporter is connected)_. _Default: `null`_
* **`stopped`**: `Function` - Fired when the broker stopped _(all local services stopped & transporter is disconnected)_. _Default: `null`_
* **`ServiceFactory`**: `ServiceClass` - Custom `Service` class. If not `null`, broker will use it when creating services by service schema. _Default: `null`_
* **`ContextFactory`**: `ContextClass` - Custom `Context` class. If not `null`, broker will use it when creating contexts for requests & events. _Default: `null`_

### Full options object
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

    contextParamsCloning: false,
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
        maxQueueSize: 50 * 1000,
        disableReconnect: false,
        disableVersionCheck: false,
        packetLogFilter: ["HEARTBEAT"]
    },

    uidGenerator: null,

    errorHandler: null,

    cacher: "MemoryLRU",
    serializer: "JSON",

    validator: true,

    metrics: {
        enabled: true,
        reporter: [
            "Console"
        ]
    },

    tracing: {
        enabled: true,
        exporter: [
            "Console"
        ]
    },

    internalServices: true,
    internalMiddlewares: true,

    hotReload: true,

    middlewares: ["MyMiddleware"],

    replDelimiter: "mol $",
    replCommands: [],

    metadata: {
        region: "eu-west1"
    },

    skipProcessEventRegistration: false,

    ServiceFactory: null,
    ContextFactory: null,

    created(broker) {},

    started(broker) {},

    stopped(broker) {}
}
```
