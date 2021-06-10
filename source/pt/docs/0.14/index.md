title: O que é o Moleculer?
---
Moleculer é uma estrutura de microserviços rápida, moderna e poderosa para [Node.js](https://nodejs.org/en/). Crie serviços eficientes, confiáveis & escaláveis na sua aplicação. O Moleculer fornece muitas funcionalidades para a construção e gerenciamento de seus microserviços.

## Funcionalidades

- solução baseada em Promises (compatível com async/await)
- conceito de request-response
- arquitetura conduzida por eventos com balanceamento
- registro de serviços integrado & descoberta de serviços dinâmico
- requisições & eventos com balanceamento de carga (round-robin, aleatório, uso de cpu, latência, sharding)
- muitos recursos de tolerância a falhas (Circuit Breaker, Bulkhead, Retry, Timeout, Fallback)
- sistema de plugin/middleware
- suporte a serviços versionados
- suporte a [Stream](https://nodejs.org/dist/latest-v10.x/docs/api/stream.html)s
- mixins de serviço
- solução de cache integrada (Memory, MemoryLRU, Redis)
- loggers plugáveis (Console, File, Pino, Bunyan, Winston, Debug, Datadog, Log4js)
- transporters plugáveis (TCP, NATS, MQTT, Redis, NATS Streaming, Kafka, AMQP 0.9, AMQP 1.0)
- serializadores plugáveis (JSON, Avro, MsgPack, Protocol Buffer, Thrift)
- validadores de parâmetros plugáveis
- vários serviços em um nó/servidor
- arquitetura sem mestre, todos os nós são iguais
- validação de parâmetros com [fastest-validator](https://github.com/icebob/fastest-validator)
- funcionalidade de métricas embutidas com reporters (Console, CSV, Datadog, Event, Prometheus, StatsD)
- recurso de rastreamento embutido com exporters (Console, Datadog, Event, Jaeger, Zipkin)
- [API gateway oficial](https://github.com/moleculerjs/moleculer-web), [Acesso a banco de dados](https://github.com/moleculerjs/moleculer-db) e muitos outros módulos...

## Quão rápido?

Passamos muitas horas para melhorar o desempenho do Moleculer e criar o mais rápido framework de microserviços para Node.js.

[![Benchmark local](assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti) [![Benchmark remoto](assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

Veja os resultados no seu computador! Basta clonar [este repositório](https://github.com/icebob/microservices-benchmark) e executar `npm install && npm start`.

[Confira os resultados de nossos benchmarks.](benchmark.html)

{% note info Versioning %}
Até que a Moleculer alcance a versão `1.0`, breaking changes serão lançada com uma minor version. Por exemplo, `0.13.1` e `0.13.4` serão compatíveis com retrocessos, mas `0.14.0` terá breaking changes.
{% endnote %}


{% note info Node.js support %}
Moleculer follows Node.js [release cycles](https://nodejs.org/en/about/releases/) meaning that the minimum required version is `12`.
{% endnote %}
