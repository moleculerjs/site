title: Broker
---
The `ServiceBroker` is the main component of Moleculer. It handles services, calls actions, emits events and communicates with remote nodes. You must create a `ServiceBroker` instance on every node.

<div align="center">
    <img src="assets/service-broker.svg" alt="Broker logical diagram" />
</div>

## Create a ServiceBroker

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


### Metadata option
Use `metadata` property to store custom values. It can be useful for a custom [middleware](middlewares.html#Loading-amp-Extending) or [strategy](balancing.html#Custom-strategy).

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

| Name                | Type                   | Description                    |
| ------------------- | ---------------------- | ------------------------------ |
| `broker.options`    | `Object`               | Broker options.                |
| `broker.Promise`    | `Promise`              | Bluebird Promise class.        |
| `broker.started`    | `Boolean`              | Broker state.                  |
| `broker.namespace`  | `String`               | Namespace.                     |
| `broker.nodeID`     | `String`               | Node ID.                       |
| `broker.instanceID` | `String`               | Instance ID.                   |
| `broker.metadata`   | `Object`               | Metadata from broker options.  |
| `broker.logger`     | `Logger`               | Logger class of ServiceBroker. |
| `broker.cacher`     | `Cacher`               | Cacher instance                |
| `broker.serializer` | `Serializer`           | Serializer instance.           |
| `broker.validator`  | `Any`                  | Parameter Validator instance.  |
| `broker.services`   | `Array<Service>` | Local services.                |
| `broker.metrics`    | `MetricRegistry`       | Built-in Metric Registry.      |
| `broker.tracer`     | `Tracer`               | Built-in Tracer instance.      |

## Methods of ServiceBroker

| Name                                                      | Response              | Description                                                 |
| --------------------------------------------------------- | --------------------- | ----------------------------------------------------------- |
| `broker.start()`                                          | `Promise`             | Start broker.                                               |
| `broker.stop()`                                           | `Promise`             | Stop broker.                                                |
| `broker.repl()`                                           | -                     | Start REPL mode.                                            |
| `broker.errorHandler(err, info)`                          | -                     | Call the global error handler.                              |
| `broker.getLogger(module, props)`                         | `Logger`              | Get a child logger.                                         |
| `broker.fatal(message, err, needExit)`                    | -                     | Throw an error and exit the process.                        |
| `broker.loadServices(folder, fileMask)`                   | `Number`              | Load services from a folder.                                |
| `broker.loadService(filePath)`                            | `Service`             | Load a service from file.                                   |
| `broker.createService(schema, schemaMods)`                | `Service`             | Create a service from schema.                               |
| `broker.destroyService(service)`                          | `Promise`             | Destroy a loaded local service.                             |
| `broker.getLocalService(name)`                            | `Service`             | Get a local service instance by full name (e.g. `v2.posts`) |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise`             | Wait for services.                                          |
| `broker.call(actionName, params, opts)`                   | `Promise`             | Call a service.                                             |
| `broker.mcall(def)`                                       | `Promise`             | Multiple service calling.                                   |
| `broker.emit(eventName, payload, opts)`                   | -                     | Emit a balanced event.                                      |
| `broker.broadcast(eventName, payload, opts)`              | -                     | Broadcast an event.                                         |
| `broker.broadcastLocal(eventName, payload, opts)`         | -                     | Broadcast an event to local services only.                  |
| `broker.ping(nodeID, timeout)`                            | `Promise`             | Ping remote nodes.                                          |
| `broker.hasEventListener("eventName")`                    | `Boolean`             | Checks if broker is listening to an event.                  |
| `broker.getEventListeners("eventName")`                   | `Array<Object>` | Returns all registered event listeners for an event name.   |
| `broker.generateUid()`                                    | `String`              | Generate an UUID/token.                                     |
| `broker.callMiddlewareHook(name, args, opts)`             | -                     | Call an async hook in the registered middlewares.           |
| `broker.callMiddlewareHookSync(name, args, opts)`         | -                     | Call a sync hook in the registered middlewares.             |
| `broker.isMetricsEnabled()`                               | `Boolean`             | Check the metrics feature is enabled.                       |
| `broker.isTracingEnabled()`                               | `Boolean`             | Check the tracing feature is enabled.                       |

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
