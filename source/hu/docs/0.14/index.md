Mi az a Moleculer?
---
A Moleculer egy gyors, modern és hatékony mikroszolgáltatási keretrendszer [Node.js](https://nodejs.org/en/)-hez. Segít, hogy hatékony, megbízható és könnyen skálázható alkalmazásokat hozz létre. A Moleculer rengeteg funkciót tartalmaz, hogy mikroszolgáltatásokat készíts és menedzselj.

## Funkciók

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

Rengeteg órát töltöttünk a Moleculer teljesítményének javításával és a leggyorsabb mikroszolgáltatási keretrendszer létrehozásával a Node.js számára.

[![Helyi teljesítmény teszt](assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti) [![Távoli teljesítmény teszt](assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

Ellenőrizd az eredményeket a saját számítógépeden! Csak klónozd le a[repót](https://github.com/icebob/microservices-benchmark) és futtasd az `npm install && npm start` parancsokat.

[Nézd meg a teljesítmény teszt eredményeket.](benchmark.html)

{% note info Verziószámok %}
Amíg a Moleculer nem éri el a `1.0` verziószámú kiadást, addig minden breaking change változtatás minor verzióként lesz kiadva. Például a `0.13.1`, és `0.13.4` verziók visszafelé kompatibilisek, viszont a `0.14.0` már tartalmaz nem kompatibilis (breaking change) változásokat.
{% endnote %}


{% note info Node.js support %}
Moleculer követi a Node.js [kiadási ciklusokat](https://nodejs.org/en/about/releases/), ezért a minimálisan szükséges verzió a `10`-es.
{% endnote %}
