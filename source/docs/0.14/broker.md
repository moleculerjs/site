title: Broker
---
The `ServiceBroker` is the main component of Moleculer. It handles services, calls actions, emits events and communicates with remote nodes. 
You must create a `ServiceBroker` instance on every node.

<div align="center">
    <img src="assets/service-broker.svg" alt="Broker logical diagram" />
</div>
<div><b>TODO: add tracing & metrics blocks</b></div>

## Create broker

{% note info %}
**Quick tip:** You don't need to create manually ServiceBroker in your project. Use the [Moleculer Runner](runner.html) to create and execute a broker and load services. [Read more about Moleculer Runner](runner.html).
{% endnote %}

**Create broker with default settings:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker();
```

**Create broker with custom settings:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "my-node"
});
```

**Create broker with transporter to communicate with remote nodes:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "node-1",
    transporter: "nats://localhost:4222",
    logLevel: "debug",
    requestTimeout: 5 * 1000
});
```

## Broker options
List of all available broker options:

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `namespace` | `String` | `""` | Namespace of nodes to segment your nodes on the same network (e.g.: "development", "staging", "production"). |
| `nodeID` | `String` | hostname + PID | Unique node identifier. Must be unique in a namespace. If not the broker will throw a fatal error and stop the process.|
| `logger` | `Boolean` or `String` `Object` or `Array<Object>` | `"Console"` | Logger class. By default, it prints message to the `console`. External logger can be used, e.g. [winston](https://github.com/winstonjs/winston) or [pino](https://github.com/pinojs/pino). [Read more](logging.html). |
| `logLevel` | `String` or `Object` | `info` | Log level for loggers (trace, debug, info, warn, error, fatal). [Read more](logging.html).|
| `transporter` | `String` or `Object` or `Transporter` | `null` | Transporter configuration. [Read more](networking.html).  |
| `requestTimeout` | `Number` | `0` | Number of milliseconds to wait before reject a request with a `RequestTimeout` error. Disabled: `0` |
| `retryPolicy` | `Object` | | Retry policy configuration. [Read more](fault-tolerance.html#Retry) |
| `contextParamsCloning` | `Boolean` | `false` | Cloning the `params` of context if enabled. ***High performance impact. Use it with caution*** |
| `maxCallLevel` | `Number` | `0` | Limit of calling level. If it reaches the limit, broker will throw an `MaxCallLevelError` error. _(Infinite loop protection)_ |
| `heartbeatInterval` | `Number` | `5` | Number of seconds to send heartbeat packet to other nodes. |
| `heartbeatTimeout` | `Number` | `15` | Number of seconds to wait before setting remote nodes to unavailable status in Registry. |
| `tracking` | `Object` | | Tracking requests and waiting for running requests before shutdowning. _(Graceful shutdown)_ [Read more](fault-tolerance.html) |
| `disableBalancer` | `Boolean` | `false` | Disable built-in request & emit balancer. _Transporter must support it, as well._ [Read more](networking.html#Disabled-balancer) |
| `registry` | `Object` | | Settings of [Service Registry](registry.html) |
| `circuitBreaker` | `Object` | | Settings of [Circuit Breaker](fault-tolerance.html#Circuit-Breaker) |
| `bulkhead` | `Object` | | Settings of [bulkhead](fault-tolerance.html#Bulkhead) |
| `transit.maxQueueSize` | `Number` | `50000` | A protection against inordinate memory usages when there are too many outgoing requests. If there are more than _stated_ outgoing live requests, the new requests will be rejected with `QueueIsFullError` error. |
| `transit.disableReconnect` | `Boolean` | `false` | Disables the reconnection logic while starting a broker. |
| `transit.disableVersionCheck` | `Boolean` | `false` | Disable protocol version checking logic in Transit |
| `transit.packetLogFilter` | `Array` | `empty` | Filters out the packets in debug log messages. It can be useful to filter out the `HEARTBEAT` packets while debugging. |
| `uidGenerator` | `Function` | | Custom UID generator function for Context ID. |
| `errorHandler` | `Function` | | [Global error handler](#Global-error-handler) function. |
| `cacher` | `String` or `Object` or `Cacher` | `null` | Cacher settings. [Read more](caching.html) |
| `serializer` | `String` or `Serializer` | `JSONSerializer` | Instance of serializer. [Read more](networking.html) |
| `validator` | `Boolean` or `Validator` | `true` | Enable the default or create custom [parameters validation](validating.html). |
| `metrics` | `Boolean` or `Object` | `false` | Enable & configure [metrics](metrics.html) feature. |
| `tracing` | `Boolean` or `Object` | `false` | Enable & configure [tracing](tracing.html) feature. |
| `internalServices` | `Boolean` or `Object` | `true` | Register [internal services](services.html#Internal-Services) at start. |
| `internalServices.$node` | `Object` | `null` | Extend internal services with [custom actions](services.html#Extending).|
| `internalMiddlewares` | `Boolean` | `true` | Register [internal middlewares](middlewares.html#Internal-middlewares). |
| `hotReload` | `Boolean` | `false` | Watch the loaded services and hot reload if they changed. [Read more](services.html#Hot-Reloading-Services). |
| `middlewares` | `Array<Object>` | `null` | Register custom middlewares. |
| `replCommands` | `Array<Object>` | `null` | Register custom REPL commands. |
| `metadata ` | `Object` | `null` | Store custom values. |
| `skipProcessEventRegistration` | `Boolean` | `false` | Skip the [default](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) graceful shutdown event handlers. In this case, you have to register them manually. |
| `created` | `Function` | `null` | Fired when the broker created. |
| `started` | `Function` | `null` | Fired when the broker started _(all local services loaded & transporter is connected)_. |
| `stopped` | `Function` | `null` | Fired when the broker stopped _(all local services stopped & transporter is disconnected)_. |
| `ServiceFactory` | `ServiceClass` | `null` | Custom `Service` class. If not `null`, broker will use it when creating services by service schema. |
| `ContextFactory` | `ContextClass` | `null` | Custom `Context` class. If not `null`, broker will use it when creating contexts for requests & events. |

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

    replCommands: [],

    metadata: {
        region: "eu-west1"
    },

    skipProcessEventRegistration: false,

    ServiceFactory: null,
    ContextFactory: null,

    created(broker) {
    },

    started(broker) {
    },

    stopped(broker) {
    }
}
```

### Metadata option
You can use `metadata` property to store custom values. It can be useful for a custom [middleware](middlewares.html#Loading-amp-Extending) or [strategy](balancing.html#Custom-strategy).

```js
const broker = new ServiceBroker({
    nodeID: "broker-2",
    transporter: "NATS",
    metadata: {
        region: "eu-west1"
    }
});
```
{% note info %}
The `metadata` property can be obtained by running `$node.list` action.
{% endnote %}

{% note info %}
The `metadata` property is transferred to other nodes.
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

## Properties of ServiceBroker

| Name | Type |  Description |
| ------- | ----- | ------- |
| `broker.options` | `Object` | Broker options. |
| `broker.Promise` | `Promise` | Bluebird Promise class. |
| `broker.started` | `Boolean` | Broker state. |
| `broker.namespace` | `String` | Namespace. |
| `broker.nodeID` | `String` | Node ID. |
| `broker.instanceID` | `String` | Instance ID. |
| `broker.metadata` | `Object` | Metadata from broker options. |
| `broker.logger` | `Logger` | Logger class of ServiceBroker. |
| `broker.cacher` | `Cacher` | Cacher instance |
| `broker.serializer` | `Serializer` | Serializer instance. |
| `broker.validator` | `Any` | Parameter Validator instance. |
| `broker.services` | `Array<Service>` | Local services. |
| `broker.metrics` | `MetricRegistry` | Built-in Metric Registry. |
| `broker.tracer` | `Tracer` | Built-in Tracer instance. |

## Methods of ServiceBroker

| Name | Response |  Description |
| ------- | ----- | ------- |
| `broker.start()` | `Promise` | Start broker. |
| `broker.stop()` | `Promise` | Stop broker. |
| `broker.repl()` | - | Start REPL mode. |
| `broker.errorHandler(err, info)` | - | Call the global error handler. |
| `broker.getLogger(module, props)` | `Logger` | Get a child logger. |
| `broker.fatal(message, err, needExit)` | - | Throw an error and exit the process. |
| `broker.loadServices(folder, fileMask)` | `Number` | Load services from a folder. |
| `broker.loadService(filePath)` | `Service` | Load a service from file. |
| `broker.createService(schema, schemaMods)` | `Service` | Create a service from schema. |
| `broker.destroyService(service)` | `Promise` | Destroy a loaded local service. |
| `broker.getLocalService(name)` | `Service` | Get a local service instance by full name (e.g. `v2.posts`) |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise` | Wait for services. |
| `broker.call(actionName, params, opts)` | `Promise` | Call a service. |
| `broker.mcall(def)` | `Promise` | Multiple service calling. |
| `broker.emit(eventName, payload, opts)` | - | Emit a balanced event. |
| `broker.broadcast(eventName, payload, opts)` | - | Broadcast an event. |
| `broker.broadcastLocal(eventName, payload, opts)` | - | Broadcast an event to local services only. |
| `broker.ping(nodeID, timeout)` | `Promise` | Ping remote nodes. |
| `broker.hasEventListener("eventName")` | `Boolean` | Checks if broker is listening to an event. |
| `broker.getEventListeners("eventName")` | `Array<Object>` | Returns all registered event listeners for an event name. |
| `broker.generateUid()` | `String` | Generate an UUID/token. |
| `broker.callMiddlewareHook(name, args, opts)` | - | Call an async hook in the registered middlewares. |
| `broker.callMiddlewareHookSync(name, args, opts)` | - | Call a sync hook in the registered middlewares. |
| `broker.isMetricsEnabled()` | `Boolean` | Check the metrics feature is enabled. |
| `broker.isTracingEnabled()` | `Boolean` | Check the tracing feature is enabled. |

## Global error handler
The global error handler is generic way to handle exceptions. It catches the unhandled errors of action & event handlers.

**Catch, handle & log the error**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        // Handle the error
        this.logger.warn("Error handled:", err);
    }
});
```

**Catch & throw further the error**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        this.logger.warn("Log the error:", err);
        throw err; // Throw further
    }
});
```

{% note info %}
The `info` object contains the broker and the service instances, the current context and the action or the event definition.
{% endnote %}
