title: What is Moleculer?
---
Moleculer is a fast, modern and powerful microservices framework for [Node.js](https://nodejs.org/en/). It helps you to build efficient, reliable & scalable services. Moleculer provides many features for building and managing your microservices.

## Features

- Promise-based solution (async/await compatible)
- request-reply concept
- support event driven architecture with balancing
- built-in service registry & dynamic service discovery
- load balanced requests & events (round-robin, random, cpu-usage, latency, sharding)
- many fault tolerance features (Circuit Breaker, Bulkhead, Retry, Timeout, Fallback)
- plugin/middleware system
- support versioned services
- support [Stream](https://nodejs.org/dist/latest-v10.x/docs/api/stream.html)s
- service mixins
- built-in caching solution (Memory, MemoryLRU, Redis)
- pluggable loggers (Console, File, Pino, Bunyan, Winston, Debug, Datadog, Log4js)
- pluggable transporters (TCP, NATS, MQTT, Redis, NATS Streaming, Kafka, AMQP 0.9, AMQP 1.0)
- pluggable serializers (JSON, Avro, MsgPack, Protocol Buffer, Thrift)
- pluggable parameter validator
- multiple services on a node/server
- master-less architecture, all nodes are equal
- parameter validation with [fastest-validator](https://github.com/icebob/fastest-validator)
- built-in metrics feature with reporters (Console, CSV, Datadog, Event, Prometheus, StatsD)
- built-in tracing feature with exporters (Console, Datadog, Event, Jaeger, Zipkin)
- official [API gateway](https://github.com/moleculerjs/moleculer-web), [Database access](https://github.com/moleculerjs/moleculer-db) and many other modules...

## How fast?

We spent a lot of hours to improve the performance of Moleculer and create the fastest microservices framework for Node.js.

[![Benchmark local](assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti)
[![Benchmark remote](assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

Check the results on your computer! Just clone [this repo](https://github.com/icebob/microservices-benchmark) and run `npm install && npm start`.

[Check out our benchmark results.](benchmark.html)

{% note info Versioning %}
Until Moleculer reaches a `1.0` release, breaking changes will be released with a new minor version. For example `0.13.1`, and `0.13.4` will be backward compatible, but `0.14.0` will have breaking changes.
{% endnote %}


{% note info Node.js support %}
Moleculer follows Node.js [release cycles](https://nodejs.org/en/about/releases/) meaning that the minimum required version is `10`.
{% endnote %}
