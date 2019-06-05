title: Metrics & Tracing
---

Moleculer has a built-in metrics feature that collects a lot of internal Moleculer & process metric values. If enabled, the broker will emit metrics events at every request. Moreover, you can easily define your custom metrics. There are several built-in metrics reporters like `Console`, [Prometheus](https://prometheus.io/), [Datadog](https://www.datadoghq.com/), etc.

{% note warn %}
If you want to use [legacy (<= v0.13) metrics & trace events](/modules.html#metrics) use `EventLegacy`. [More info](#Event-legacy)
{% endnote %}


**Enable metrics & define console reporter**
```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            "Console"
        ]
    }
});
```

## Metrics Reporters
Moleculer have several built-in reporters. All of them have the following options:

| Name | Type | Default | Description |
| ---- | ---- | --------| ----------- |
| `includes` | `TODO` | `null` | TODO |
| `excludes` | `TODO` | `null` |  TODO |
| `metricNamePrefix` | `TODO` | `null` | TODO |
| `metricNameSuffix` | `TODO` | `null` | TODO |
| `metricNameFormatter` | `TODO` | `null` | TODO |
| `labelNameFormatter` | `TODO` | `null` | TODO |

### Console
This is a debugging reporter which periodically prints the metrics to the console.

```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Console",
                options: {
                    interval: 5 * 1000,
                    logger: null
                }
            }
        ]
    },
    logLevel: "debug"
});
```

<!-- 
### CSV
>Not implemented yet.
-->


### Datadog
Datadog reporter sends metrics to the [Datadog server](https://www.datadoghq.com/).

```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Datadog",
                options: {
                    host: "my-host",
                    apiVersion: "v1",
                    path: "/series",
                    apiKey: process.env.DATADOG_API_KEY,
                    defaultLabels: (registry) => ({
                        namespace: registry.broker.namespace,
                        nodeID: registry.broker.nodeID
                    }),
                    interval: 10
                }
            }
        ]
    }
});
```

<!-- 
### Event
>Not implemented yet.
-->


### Prometheus
Prometheus reporter publishes metrics in Prometheus format. The [Prometheus](https://prometheus.io/) server can collect them. Default port is `3030`.

```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Prometheus",
                options: {
                    port: 3030,
                    path: "/metrics",
                    defaultLabels: registry => ({
                        namespace: registry.broker.namespace,
                        nodeID: registry.broker.nodeID
                    })
                }
            }
        ]
    }
});
```

<!-- 
### UDP
>Not implemented yet.
-->

## Supported Metric Types
### Counter
A counter is a cumulative metric that represents a single monotonically increasing counter whose value can only increase or be reset to zero. For example, you can use a counter to represent the number of requests served, tasks completed, or errors.

### Gauge
A gauge is a metric that represents a single numerical value that can arbitrarily go up and down. Gauges are typically used for measured values like current memory usage, but also "counts" that can go up and down, like the number of concurrent requests.

### Histogram
A histogram samples observations (usually things like request durations or response sizes) and counts them in configurable buckets. It also provides a sum of all observed values and calculates configurable quantiles over a sliding time window.

### Info
An info is a single string or number value like process arguments, hostname or version numbers.

## Built-in Internal Metrics
### Process metrics
- `process.arguments` (info)
- `process.pid` (info)
- `process.ppid` (info)
- `process.eventloop.lag.min` (gauge)
- `process.eventloop.lag.avg` (gauge)
- `process.eventloop.lag.max` (gauge)
- `process.eventloop.lag.count` (gauge)
- `process.memory.heap.size.total` (gauge)
- `process.memory.heap.size.used` (gauge)
- `process.memory.rss` (gauge)
- `process.memory.external` (gauge)
- `process.memory.heap.space.size.total` (gauge)
- `process.memory.heap.space.size.used` (gauge)
- `process.memory.heap.space.size.available` (gauge)
- `process.memory.heap.space.size.physical` (gauge)
- `process.memory.heap.stat.heap.size.total` (gauge)
- `process.memory.heap.stat.executable.size.total` (gauge)
- `process.memory.heap.stat.physical.size.total` (gauge)
- `process.memory.heap.stat.available.size.total` (gauge)
- `process.memory.heap.stat.used.heap.size` (gauge)
- `process.memory.heap.stat.heap.size.limit` (gauge)
- `process.memory.heap.stat.mallocated.memory` (gauge)
- `process.memory.heap.stat.peak.mallocated.memory` (gauge)
- `process.memory.heap.stat.zap.garbage` (gauge)
- `process.uptime` (gauge)
- `process.internal.active.handles` (gauge)
- `process.internal.active.requests` (gauge)
- `process.versions.node` (info)
- `process.gc.time` (gauge)
- `process.gc.total.time` (gauge)
- `process.gc.executed.total` (gauge)

### OS metrics
- `os.memory.free` (gauge)
- `os.memory.total` (gauge)
- `os.uptime` (gauge)
- `os.type` (info)
- `os.release` (info)
- `os.hostname` (info)
- `os.arch` (info)
- `os.platform` (info)
- `os.user.uid` (info)
- `os.user.gid` (info)
- `os.user.username` (info)
- `os.user.homedir` (info)
- `os.network.address` (info)
- `os.network.family` (info)
- `os.network.mac` (info)
- `os.datetime.unix` (gauge)
- `os.datetime.iso` (info)
- `os.datetime.utc` (info)
- `os.datetime.tz.offset` (gauge)
- `os.cpu.load.1` (gauge)
- `os.cpu.load.5` (gauge)
- `os.cpu.load.15` (gauge)
- `os.cpu.utilization` (gauge)
- `os.cpu.user` (gauge)
- `os.cpu.system` (gauge)
- `os.cpu.total` (gauge)
- `os.cpu.info.model` (info)
- `os.cpu.info.speed` (gauge)
- `os.cpu.info.times.user` (gauge)
- `os.cpu.info.times.sys` (gauge)


### Moleculer metrics
- `moleculer.metrics.common.collect.total` (counter)
- `moleculer.metrics.common.collect.time` (gauge)
- `moleculer.node.type` (info)
- `moleculer.node.versions.moleculer` (info)
- `moleculer.node.versions.protocol` (info)
- `moleculer.broker.namespace` (info)
- `moleculer.broker.started` (gauge)
- `moleculer.broker.local.services.total` (gauge)
- `moleculer.broker.middlewares.total` (gauge)
- `moleculer.registry.nodes.total` (gauge)
- `moleculer.registry.nodes.online.total` (gauge)
- `moleculer.registry.services.total` (gauge)
- `moleculer.registry.service.endpoints.total` (gauge)
- `moleculer.registry.actions.total` (gauge)
- `moleculer.registry.action.endpoints.total` (gauge)
- `moleculer.registry.events.total` (gauge)
- `moleculer.registry.event.endpoints.total` (gauge)
- `moleculer.request.bulkhead.inflight` (gauge)
- `moleculer.request.timeout.total` (counter)
- `moleculer.request.retry.attempts.total` (counter)
- `moleculer.request.fallback.total` (counter)
- `moleculer.request.total` (counter)
- `moleculer.request.active` (gauge)
- `moleculer.request.error.total` (counter)
- `moleculer.request.time` (histogram)
- `moleculer.request.levels` (counter)
- `moleculer.event.emit.total` (counter)
- `moleculer.event.broadcast.total` (counter)
- `moleculer.event.broadcast-local.total` (counter)
- `moleculer.event.received.total` (counter)
- `moleculer.transit.publish.total` (counter)
- `moleculer.transit.receive.total` (counter)
- `moleculer.transit.requests.active` (gauge)
- `moleculer.transit.streams.send.active` (gauge)
- `moleculer.transporter.packets.sent.total` (counter)
- `moleculer.transporter.packets.sent.bytes` (counter)
- `moleculer.transporter.packets.received.total` (counter)
- `moleculer.transporter.packets.received.bytes` (counter)

## Tracing Exporters

The tracing feature support several exporters, custom tracing spans and integration with instrumentation libraries (like [`dd-trace`](https://github.com/DataDog/dd-trace-js)). Set `tracing: true` in broker's options to enable tracing

**Enable tracing**
```js
const broker = new ServiceBroker({
    tracing: true
});
```

### Console
This is a debugging exporter which prints full local trace to the console.

{% note warn %}
Console exporter can't follow remote calls, only locals.
{% endnote %}

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Console",
                options: {
                    logger: null,
                    colors: true,
                    width: 100,
                    gaugeWidth: 40
                }
            }
        ]
    }
});
```

### Datadog
Datadog exporter sends tracing data to Datadog server via `dd-trace`. It is able to merge tracing spans of instrumented Node.js modules and Moleculer modules.

<!-- TODO screenshot -->

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Datadog",
                options: {
                    agentUrl: process.env.DD_AGENT_URL || "http://localhost:8126",
                    env: process.env.DD_ENVIRONMENT || null,
                    samplingPriority: "AUTO_KEEP",
                    defaultTags: null,
                    tracerOptions: null,
                }
            }
        ]
    }
});
```
{% note info %}
To use this exporter, install the `dd-trace` module with `npm install dd-trace --save` command.
{% endnote %}


### Event
Event exporter sends Moleculer events (`$tracing.spans`) with tracing data.

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Event",
                options: {
                    eventName: "$tracing.spans",

                    sendStartSpan: false,
                    sendFinishSpan: true,

                    broadcast: false,

                    groups: null,

                    /** @type {Number} Batch send time interval. */
                    interval: 5,

                    spanConverter: null,

                    /** @type {Object?} Default span tags */
                    defaultTags: null

                }
            }
        ]
    }
});
```

### Event (legacy)
This is another event exporter which sends legacy Moleculer events ([`metrics.trace.span.start`](#Legacy-Request-Started-Payload) & [`metrics.trace.span.finish`](#Legacy-Request-Finished-Payload)) at every request. These events are compatible the legacy (`<= v0.13`) [metrics & tracing solutions]().

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            "EventLegacy"
        ]
    }
});
```

#### Legacy Request Started Payload
The broker emits an `metrics.trace.span.start` event when a new request is started.
The payload looks like the following:
```js
{
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: '6858979d-3298-4a7b-813a-ffb417da822b',
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // Is it a remote call
    remoteCall: false,
    // Called action
    action: {
        name: 'users.get'
    },
    // Called service
    service: {
        name: "users"
    },
    // Params
    params: {
        id: 5
    },
    // Meta
    meta: {},
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's requested from a remote node
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: null
}
```

#### Legacy Request Finished Payload
The broker emits an `metrics.trace.span.finish` event when the call/request is finished.
The payload looks like the following:
```js
{
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: '6858979d-3298-4a7b-813a-ffb417da822b',
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // End time
    endTime: 1493903164731.3684,
    // Duration of request
    duration: 5.368304,
    // Is it a remote call
    remoteCall: false,
    // Is it resolved from cache
    fromCache: false,
    // Called action
    action: {
        name: 'users.get'
    },
    // Called service
    service: {
        name: "users"
    },
    // Params
    params: {
        id: 5
    },
    // Meta
    meta: {},   
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's a remote call
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: null,
    // Error if the call returned with error
    error: {
        name: "ValidationError",
        message: "Invalid incoming parameters"
    }
}
```

### Jaeger
Jaeger exporter sends tracing spans information to a [Jaeger](https://www.jaegertracing.io) server.

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Jaeger",
                options: {
                    /** @type {String?} HTTP Reporter endpoint. If set, HTTP Reporter will be used. */
			        endpoint: null,
                    /** @type {String} UDP Sender host option. */
                    host: "127.0.0.1",
                    /** @type {Number?} UDP Sender port option. */
                    port: 6832,

                    /** @type {Object?} Sampler configuration. */
                    sampler: {
                        /** @type {String?} Sampler type */
                        type: "Const",

                        /** @type: {Object?} Sampler specific options. */
                        options: {}
                    },

                    /** @type {Object?} Additional options for `Jaeger.Tracer` */
                    tracerOptions: {},

                    /** @type {Object?} Default span tags */
                    defaultTags: null
                }
            }
        ]
    }
});
```
{% note info %}
To use this exporter, install the `jaeger-client` module with `npm install jaeger-client --save` command.
{% endnote %}


### Zipkin
Zipkin exporter sends tracing spans information to a [Zipkin](https://zipkin.apache.org/) server.

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Zipkin",
                options: {
                    /** @type {String} Base URL for Zipkin server. */
                    baseURL: process.env.ZIPKIN_URL || "http://localhost:9411",

                    /** @type {Number} Batch send time interval. */
                    interval: 5,

                    /** @type {Object} Additional payload options. */
                    payloadOptions: {

                        /** @type {Boolean} Set `debug` property in v2 payload. */
                        debug: false,

                        /** @type {Boolean} Set `shared` property in v2 payload. */
                        shared: false
                    },

                    /** @type {Object?} Default span tags */
                    defaultTags: null
                }
            }
        ]
    }
});
```

## Customizing
### Custom Metrics

You can easily create custom metrics. 
```js
// posts.service.js
module.exports = {
    name: "posts",

    actions: {
        get(ctx) {
            // Update metrics
            this.broker.metrics.increment("posts.get.total");
            return posts;
        }
    },

    created() {
        // Register new custom metrics
        this.broker.metrics.register({ type: "counter", name: "posts.get.total" });
    }
};
```
### Custom Tracing

#### Multiple Spans per Action
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        async find(ctx) {
            const span1 = ctx.startSpan("get data from DB", {
                tags: {
                    ...ctx.params
                }
            }); 
            const data = await this.getDataFromDB(ctx.params);
            span1.finish();

            const span2 = ctx.startSpan("populating");
            const res = await this.populate(data);
            span2.finish();

            return res;
        }
    }
};
```

#### Fields Filtering

**Example**
```js
// Action definition
{
    tracing: { 
        tags: [
            // tag for ctx.params
            "name",
            // Starts with # the tag if for ctx.meta params.
            // The actual # is ignored
            "#loggedIn.username" 
        ],
    }
}

// Request params
broker.call("user.create", { name: "John" }, { meta: { loggedIn: { username: "Doe" } } });

// Span payload
{
    params: { name: "John" },
    meta: { 
        loggedIn: {
            username: "Doe"
        }
    }
}
```
#### Custom Handler

```js
// Action definition
{
    tracing: {
        tags: ctx => {
            return {
                params: ctx.params,
                meta: ctx.meta,
                custom: {
                    a: 5
                }
            };
        }
    }
}

// Request params
broker.call("user.create", { name: "John", lastname: "Doe" }, { meta: { user } });

// Span payload
{
    params: { name: "John", lastname: "Doe" },
    meta: {
        user: {
            // ...
        }
    },
    custom: {
        a: 5
    }
}
```