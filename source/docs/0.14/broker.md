title: Broker
---
The `ServiceBroker` is the main component of Moleculer. It handles services, calls actions, emits events and communicates with remote nodes. 
You must create a `ServiceBroker` instance for every node.

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
    logLevel: "info"
});
```

**Create broker with transporter to communicate with remote nodes:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "node-1",
    transporter: "nats://localhost:4222",
    logLevel: "debug",
    requestTimeout: 5 * 1000,
    requestRetry: 3
});
```

## Broker options
List of all available broker options:

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `namespace` | `String` | `""` | Namespace of nodes to segment your nodes on the same network. |
| `nodeID` | `String` | hostname + PID | Unique node identifier. Must be unique in a namespace. |
| `logger` | `Boolean` or `Object` or `Function` | `console` | Logger class. By default, it prints message to the `console`. External logger can be used, e.g. [winston](https://github.com/winstonjs/winston) or [pino](https://github.com/pinojs/pino). [Read more](logging.html). |
| `logLevel` | `String` | `info` | Log level for built-in console logger (trace, debug, info, warn, error, fatal). |
| `logFormatter` | `String` or `Function` | `"default"` | Log formatter for built-in console logger. Values: `default`, `simple`, `short`. It can be also a `Function`. |
| `logObjectPrinter` | `Function` | `null` | Custom object & array printer for built-in console logger. |
| `transporter` | `String` or `Object` or `Transporter` | `null` | Transporter settings. [Read more](networking.html).  |
| `requestTimeout` | `Number` | `0` | Number of milliseconds to wait before reject a request with a `RequestTimeout` error. Disabled: `0` |
| `retryPolicy` | `Object` | | Retry policy settings. [Read more](fault-tolerance.html#Retry) |
| `maxCallLevel` | `Number` | `0` | Limit of calling level. If it reaches the limit, broker will throw an `MaxCallLevelError` error. _(Infinite loop protection)_ |
| `heartbeatInterval` | `Number` | `5` | Number of seconds to send heartbeat packet to other nodes. |
| `heartbeatTimeout` | `Number` | `15` | Number of seconds to wait before setting node to unavailable status. |
| `tracking` | `Object` | | Tracking requests and waiting for running requests before shutdowning. [Read more](fault-tolerance.html) |
| `disableBalancer` | `Boolean` | `false` | Disable built-in request & emit balancer. _Transporter must support it, as well._ |
| `registry` | `Object` | | Settings of [Service Registry](registry.html) |
| `circuitBreaker` | `Object` | | Settings of [Circuit Breaker](fault-tolerance.html#Circuit-Breaker) |
| `bulkhead` | `Object` | | Settings of [bulkhead](fault-tolerance.html#Bulkhead) |
| `transit.maxQueueSize` | `Number` | `50000` | A protection against inordinate memory usages when there are too many outgoing requests. If there are more than _stated_ outgoing live requests, the new requests will be rejected with `QueueIsFullError` error. |
| `transit.disableReconnect` | `Boolean` | `false` | Disables the reconnection logic while starting a broker|
| `transit.packetLogFilter` | `Array` | `empty` | Filters out the packets in debug logs |
| `cacher` | `String` or `Object` or `Cacher` | `null` | Cacher settings. [Read more](caching.html) |
| `serializer` | `String` or `Serializer` | `JSONSerializer` | Instance of serializer. [Read more](networking.html) |
| `skipProcessEventRegistration` | `Boolean` | `false` | Skip the [default](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) graceful shutdown event handlers. In this case you have to register them manually. |
| `validator` | `Validator` | `null` | Custom Validator class for [parameters validation](validating.html). |
| `metrics` | `Boolean` | `false` | Enable [metrics](metrics.html) function. |
| `metricsRate` | `Number` | `1` | Rate of metrics calls. `1` means to measure every request. |
| `internalServices` | `Boolean` | `true` | Register [internal services](services.html#Internal-services). |
| `internalMiddlewares` | `Boolean` | `true` | Register [internal middlewares](middlewares.html#Internal-middlewares). |
| `hotReload` | `Boolean` | `false` | Watch the loaded services and hot reload if they changed. [Read more](services.html#Hot-reloading-services). |
| `middlewares` | `Array<Function>` | `null` | Register middlewares. _Useful when you use Moleculer Runner._ |
| `replCommands` | `Array<Object>` | `null` | Register custom REPL commands. |
| `created` | `Function` | `null` | Fired when the broker created. _Useful when you use Moleculer Runner._ |
| `started` | `Function` | `null` | Fired when the broker started. _Useful when you use Moleculer Runner._ |
| `stopped` | `Function` | `null` | Fired when the broker stopped. _Useful when you use Moleculer Runner._ |
| `ServiceFactory` | `ServiceClass` | `null` | Custom Service class. If not `null`, broker will use it when creating services. |
| `ContextFactory` | `ContextClass` | `null` | Custom Context class. If not `null`, broker will use it when creating contexts. |

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
        packetLogFilter: []
    },     

    cacher: "memory",
    serializer: null,

    skipProcessEventRegistration: false

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
You don't need to create manually ServiceBroker in your project. Use the [Moleculer Runner](runner.html) to create and execute a broker and load services. [Read more about Moleculer Runner](runner.html).
{% endnote %}


## Ping
To ping remote nodes, use `broker.ping` method. You can ping a node, or all available nodes. It returns a `Promise` which contains the received ping information (latency, time difference). A timeout value can be defined.

### Ping a node with 1 second timeout
```js
broker.ping("node-123", 1000).then(res => broker.logger.info(res));
```

**Output**
```js
{ 
    nodeID: 'node-123', 
    elapsedTime: 16, 
    timeDiff: -3 
}
```
> The `timeDiff` value is the difference of the system clock between these two nodes.

### Ping multiple nodes
```js
broker.ping(["node-100", "node-102"]).then(res => broker.logger.info(res));
```

**Output**
```js
{ 
    "node-100": { 
        nodeID: 'node-100', 
        elapsedTime: 10, 
        timeDiff: -2 
    },
    "node-102": { 
        nodeID: 'node-102', 
        elapsedTime: 250, 
        timeDiff: 850 
    } 
}
```

### Ping all available nodes
```js
broker.ping().then(res => broker.logger.info(res));
```

**Output**
```js
{ 
    "node-100": { 
        nodeID: 'node-100', 
        elapsedTime: 10, 
        timeDiff: -2 
    } ,
    "node-101": { 
        nodeID: 'node-101', 
        elapsedTime: 18, 
        timeDiff: 32 
    }, 
    "node-102": { 
        nodeID: 'node-102', 
        elapsedTime: 250, 
        timeDiff: 850 
    } 
}
```

## Properties

| Name | Type |  Description |
| ------- | ----- | ------- |
| `broker.nodeID` | `String` | Node ID. |
| `broker.Promise` | `Promise` | Bluebird Promise class. |
| `broker.namespace` | `String` | Namespace. |
| `broker.logger` | `Logger` | Logger class of ServiceBroker. |
| `broker.cacher` | `String` | Request ID. If you make nested-calls, it will be the same ID. |
| `broker.serializer` | `String` | Parent context ID (in nested-calls). |
| `broker.validator` | `Any` | Request params. *Second argument from `broker.call`.* |
| `broker.options` | `Object` | Broker options. |

## Methods

| Name | Response |  Description |
| ------- | ----- | ------- |
| `broker.start()` | `Promise` | Start broker. |
| `broker.stop()` | `Promise` | Stop broker. |
| `broker.repl()` | - | Start REPL mode. |
| `broker.getLogger(module, props)` | `Logger` | Get a child logger. |
| `broker.fatal(message, err, needExit)` | - | Throw an error and exit the process. |
| `broker.loadServices(folder, fileMask)` | `Number` | Load services from a folder. |
| `broker.loadService(filePath)` | `Service` | Load a service from file. |
| `broker.createService(schema, schemaMods)` | `Service` | Create a service from schema. |
| `broker.destroyService(service)` | `Promise` | Destroy a loaded local service. |
| `broker.getLocalService(name, version)` | `Service` | Get a local service instance by name & version. |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise` | Wait for services. |
| `broker.call(actionName, params, opts)` | `Promise` | Call a service. |
| `broker.mcall(def)` | `Promise` | Multiple service calling. |
| `broker.emit(eventName, payload, groups)` | - | Emit a balanced event. |
| `broker.broadcast(eventName, payload, groups)` | - | Broadcast an event. |
| `broker.broadcastLocal(eventName, payload, groups)` | - | Broadcast an event to local services. |
| `broker.ping(nodeID, timeout)` | `Promise` | Ping remote nodes. |
