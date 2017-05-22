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
- multiple services on a node/server
- built-in caching solution (memory, Redis)
- multiple supported transporters (NATS, MQTT, Redis)
- multiple supported serializers (JSON, Avro, MsgPack, Protocol Buffer)
- load balanced requests (round-robin, random)
- every nodes are equal, no master/leader node
- auto discovery services
- parameter validation
- distributed timeout handling with fallback response
- health monitoring, metrics & statistics
- supports versioned services (run different versions of the service)

## Requirements

Source code of Moleculer is written in ES2015. So the minimum version of NodeJS is **v6.x.x**.

## How fast?

We [tested](https://github.com/icebob/microservices-benchmark) some other frameworks and measured the request times.
[![Result chart](https://cloud.highcharts.com/images/utideti/5/600.png)](http://cloud.highcharts.com/show/utideti)
[![Result chart](https://cloud.highcharts.com/images/abyfite/1/600.png)](http://cloud.highcharts.com/show/abyfite)