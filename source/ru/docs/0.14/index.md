title: Что такое Moleculer?
---
Moleculer - это быстрый, современный и мощный микросервисный фреймворк для [Node.js](https://nodejs.org/en/). Он поможет вам построить эффективные, надежные и масштабируемые сервисы. Moleculer предоставляет множество возможностей для создания и управления микросервисами.

## Возможности

- Асинхронный код на базе промисов (async/await compatible)
- концепция запрос-ответ
- support event driven architecture with balancing
- встроенный реестр сервисов и их динамическое обнаружение
- load balanced requests & events (round-robin, random, cpu-usage, latency, sharding)
- устойчивость к отказам (Circuit Breaker, Bulkhead, Retry, Timeout, Fallback)
- система плагинов и middleware
- поддержка версионирования сервисов
- поддержка [потоков](https://nodejs.org/dist/latest-v10.x/docs/api/stream.html)
- поддержка миксинов на уровне сервисов
- built-in caching solution (Memory, MemoryLRU, Redis)
- подключаемые логгеры (Console, File, Pino, Bunyan, Winston, Debug, Datadog, Log4js)
- pluggable transporters (TCP, NATS, MQTT, Redis, NATS Streaming, Kafka, AMQP 0.9, AMQP 1.0)
- pluggable serializers (JSON, Avro, MsgPack, Protocol Buffer, Thrift)
- pluggable parameter validator
- несколько сервисов на узле/сервере
- master-less architecture, all nodes are equal
- валидация параметров [fastest-validator](https://github.com/icebob/fastest-validator)
- built-in metrics feature with reporters (Console, CSV, Datadog, Event, Prometheus, StatsD)
- built-in tracing feature with exporters (Console, Datadog, Event, Jaeger, Zipkin)
- официальный [API шлюз](https://github.com/moleculerjs/moleculer-web), [доступ к БД](https://github.com/moleculerjs/moleculer-db) и множество других модулей...

## Насколько быстро?

Мы потратили много часов, чтобы улучшить работу Moleculer и создать самый быстрый микросервис для Node.js.

[![Локальный Benchmark](../../../docs/0.14/assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti) [![Удаленный Benchmark](../../../docs/0.14/assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

Проверьте результаты на своем компьютере! Просто клонируйте [этот репозиторий](https://github.com/icebob/microservices-benchmark) и запустите `npm install && npm start`.

[Посмотрите наши результаты.](benchmark.html)

{% note info Versioning %}
До тех пор, пока Moleculer не достигнет релиза `1.0`, критические изменения будут выпускаться в новых минорных версиях. Например `0.13.1`, и `0.13.4` будут обратно совместимыми, но `0.14.0` будут иметь критические изменения.
{% endnote %}


{% note info Node.js support %}
Moleculer follows Node.js [release cycles](https://nodejs.org/en/about/releases/) meaning that the minimum required version is `10`.
{% endnote %}
