title: Metrics
---

Starting from `v0.14` Moleculer has a built-in metrics module that collects a lot of internal Moleculer & process metric values. If enabled, the broker will emit metric events at every request. Moreover, you can easily define your custom metrics. There are several built-in metrics reporters like `Console`, [Prometheus](https://prometheus.io/), [Datadog](https://www.datadoghq.com/), etc.

{% note warn %}
If you want to use [legacy (<= v0.13) metrics](/modules.html#metrics) use `EventLegacy`. [More info](tracing.html#Event-legacy).
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
| `includes` | `String | Array<String>` | `null` | TODO |
| `excludes` | `String | Array<String>` | `null` |  TODO |
| `metricNamePrefix` | `String` | `null` | TODO |
| `metricNameSuffix` | `String` | `null` | TODO |
| `metricNameFormatter` | `Function` | `null` | TODO |
| `labelNameFormatter` | `Function` | `null` | TODO |

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
                    logger: null,
                    colors: true,
                    onlyChanges: true
                }
            }
        ]
    }
});
```

### CSV
Comma-Separated Values (CSV) reporter saves changes to a CSV file.

```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "CSV",
                options: {
                    folder: "./reports/metrics",
                    delimiter: ",",
                    rowDelimiter: "\n",
                    mode: MODE_METRIC, // MODE_METRIC, MODE_LABEL
                    types: null,
                    interval: 5 * 1000,
                    filenameFormatter: null,
                    rowFormatter: null,
                }
            }
        ]
    }
});
```
### Event
Event reporter sends Moleculer events with metric values.

 ```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Event",
                options: {
                    eventName: "$metrics.snapshot",
                    broadcast: false,
                    groups: null,
                    onlyChanges: false,
                    interval: 5 * 1000,
                }
            }
        ]
    }
});
```

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
                    }),
                    includes: ["moleculer.**"],
                    excludes: ["moleculer.transit.**"]
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

### StatsD
The StatsD reporter sends metric values to [StatsD](https://github.com/statsd/statsd) server via UDP.

```js
const broker = new ServiceBroker({
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "StatsD",
                options: {
                    protocol: "udp",
                    host: "localhost",
                    port: 8125,
                    maxPayloadSize: 1300,
                    prefix: null,
                    interval: 5 * 1000
                }
            }
        ]
    }
});
```

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



## Customizing
### New metric registration

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
