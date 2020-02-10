Mi az a Moleculer?
---
Moleculer is a fast, modern and powerful microservices framework for [Node.js](https://nodejs.org/en/). Segít, hogy hatékony, megbízható és könnyen skálázható alkalmazásokat hozz létre. A Moleculer rengeteg funkciót tartalmaz, hogy mikroszolgáltatásokat készíts és menedzselj.

## Funkciók

- Promise-based solution (async/await compatible)
- request-reply concept
- all nodes are equal, no master/leader node
- multiple services on a node/server
- support event-driven architecture with balancing
- built-in service registry & dynamic service discovery
- load balanced requests & events (round-robin, random, cpu-usage, latency, shard)
- many fault tolerance features (Circuit Breaker, Bulkhead, Retry, Timeout, Fallback)
- plugin/middleware system
- support versioned services
- service mixins
- support [Stream](https://nodejs.org/dist/latest-v10.x/docs/api/stream.html)s
- built-in caching solution (memory, MemoryLRU, Redis)
- pluggable loggers (Console, File, Pino, Bunyan, Winston, Debug, Datadog, Log4js)
- pluggable transporters (TCP, NATS, MQTT, Redis, AMQP, NATS Streaming, Kafka)
- pluggable serializers (JSON, Avro, MsgPack, Protocol Buffers, Thrift)
- pluggable validator
- built-in metrics with reporters (CSV, Prometheus, Datadog, StatsD, Events)
- built-in tracing support with exporters (Zipkin, Jaeger, Datadog, Events)
- parameter validation with [fastest-validator](https://github.com/icebob/fastest-validator)
- official [API gateway](https://github.com/moleculerjs/moleculer-web), [Database access](https://github.com/moleculerjs/moleculer-db) and many other modules...

## How fast?

We spent a lot of hours to improve the performance of Moleculer and create the fastest microservices framework for Node.js.

[![Benchmark local](assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti) [![Benchmark remote](assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

Check the results on your computer! Just clone [this repo](https://github.com/icebob/microservices-benchmark) and run `npm install && npm start`.

[Check out our benchmark results.](benchmark.html)

{% note info Versioning %}
Until Moleculer reaches a `1.0` release, breaking changes will be released with a new minor version. For example `0.13.1`, and `0.13.4` will be backward compatible, but `0.14.0` will have breaking changes.
{% endnote %}


{% note info Node.js support %}
Moleculer follows Node.js [release cycles](https://nodejs.org/en/about/releases/) meaning that the minimum required version is `10`.
{% endnote %}
