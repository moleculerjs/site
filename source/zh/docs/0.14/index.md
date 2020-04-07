title: What is Moleculer?
---
Moleculer是基于[Node.js](https://nodejs.org/en/)的快速、多功能的现代微服务框架。 它能帮助您建立高效的、可靠的可伸缩服务。 Moleculer提供了许多构建和管理您的微服务的特性。

## 特性概览

- 基于'承诺'(Promise)的解决方案(与 async/await 兼容)
- 请求-响应模式
- 事件驱动和负载均衡支持
- 内置的服务注册和动态服务发现
- 请求与事件负载均衡(round-robin, random, cpu-usage, latency, sharding)
- 多容错特性(Circuit Breaker, Bulkhead, Retry, Timeout, Fallback)
- 插件与中间件系统
- 服务版本支持
- 流支持
- 服务 mixins
- 内建缓存解决方案 (Memory, MemoryLRU, Redis)
- 可插拔的日志模块 (Console, File, Pino, Bunyan, Winston, Debug, Datadog, Log4js)
- 可插拔的推送系统 (TCP, NATS, MQTT, Redis, NATS Streaming, Kafka, AMQP 0.9, AMQP 1.0)
- 可插拔的序列化器(JSON, Avro, MsgPack, Protocol Buffer, Thrift)
- 可插拔的参数验证器
- 每节点/服务器可承载多个服务
- 去中心化结构，所有的节点都是平等的
- 使用[fastest-validator](https://github.com/icebob/fastest-validator)的参数验证
- 内置计量与记录(Console, CSV, Datadog, Event, Prometheus, StatsD)
- 内置性能跟踪导出特性 (Console, Datadog, Event, Jaeger, Zipkin)
- 内建官方[API 网关](https://github.com/moleculerjs/moleculer-web), [数据库访问](https://github.com/moleculerjs/moleculer-db) 等其他模块...

## 超快

我们花了很多时间来提高Moleculer的性能，致力于为Node.js创建最快的微服务框架。

[![Benchmark local](assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti) [![Benchmark remote](assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

想要在您的计算机上检验结果! 只需克隆[此仓库](https://github.com/icebob/microservices-benchmark)并运行 `npm install && npm start`。

[或查看我们的基准测试。](benchmark.html)

{% note info Versioning %}
在Moleculer达到`1.0`之前，重大更改仅通过次要版本发布。 例如，`0.13.1 `和`0.13.4 `将是后向兼容的，但`0.14.0`将会发生重大变化。
{% endnote %}


{% note info Node.js support %}
Moleculer 跟随Node.js [发布周期](https://nodejs.org/en/about/releases/) 意味着最低要求版本是 `10`。
{% endnote %}
