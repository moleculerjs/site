title: What is Moleculer?
---
Moleculer is a fast, modern and powerful microservices framework for [Node.js](https://nodejs.org/en/). It helps you to build efficient, reliable & scalable services. Moleculer provides many features for building and managing your microservices.

## Features

- Promise-based solution (async/await compatible)
- request-reply concept
- support streams
- support event-driven architecture with balancing
- built-in service registry & dynamic service discovery
- load balanced requests & events (round-robin, random, cpu-usage, latency)
- many fault tolerance features (Circuit Breaker, Bulkhead, Retry, Timeout, Fallback)
- supports middlewares
- supports versioned services
- service mixins
- built-in caching solution (memory, Redis)
- pluggable transporters (TCP, NATS, MQTT, Redis, NATS Streaming, Kafka)
- pluggable serializers (JSON, Avro, MsgPack, Protocol Buffers, Thrift)
- pluggable validator
- multiple services on a node/server
- all nodes are equal, no master/leader node
- parameter validation with [fastest-validator](https://github.com/icebob/fastest-validator)
- built-in health monitoring & metrics
- official [API gateway module](https://github.com/moleculerjs/moleculer-web) and many other modules...

## How fast?

We spent a lot of hours to improve the performance of Moleculer and create the fastest microservices framework for Node.js.

[![Result chart](https://cloud.highcharts.com/images/utideti/6/600.png)](http://cloud.highcharts.com/show/utideti)
[![Result chart](https://cloud.highcharts.com/images/abyfite/1/600.png)](http://cloud.highcharts.com/show/abyfite)

You can check the results on your computer! Just clone [this repo](https://github.com/icebob/microservices-benchmark) and run `npm install && npm start`.

[Check out our benchmark results.](benchmark.html)
