title: Documentation
---
Welcome to the Moleculer documentation. Navigate through the documentation to learn more. If you encounter any problems when using Moleculer, open an issue on [GitHub](https://github.com/ice-services/moleculer/issues) or write to us on [Gitter](https://gitter.im/ice-services/moleculer).

## What is Moleculer?

Moleculer is a fast and powerful microservices framework for [NodeJS](https://nodejs.org/en/). It helps you to build efficient, reliable & scalable services. Moleculer provides many features for building and managing your microservices.

## Features

- Promise-based solution
- request-reply concept
- event bus system
- supports middlewares
- service mixins
- multiple services on a node/server
- built-in caching solution (memory, Redis)
- pluggable transporters (NATS, MQTT, Redis)
- pluggable serializers (JSON, Avro, MsgPack, Protocol Buffer)
- load balanced requests (round-robin, random)
- every nodes are equal, no master/leader node
- auto discovery services
- parameter validation
- distributed timeout handling with fallback response
- health monitoring, metrics & statistics
- supports versioned services

{% note warn Requirements %}
Moleculer is written in ES2015. The minimum version of NodeJS is **v6.x.x**.
{% endnote %}

## How fast?

We spent a lot of hours to improve the performance of Moleculer and become the fastest microservices framework.

[![Result chart](https://cloud.highcharts.com/images/utideti/5/600.png)](http://cloud.highcharts.com/show/utideti)
[![Result chart](https://cloud.highcharts.com/images/abyfite/1/600.png)](http://cloud.highcharts.com/show/abyfite)

You can check it. Just clone [this repo](https://github.com/icebob/microservices-benchmark) and run `npm install && npm start`.

[Check out outher benchmark results](benchmark.html)