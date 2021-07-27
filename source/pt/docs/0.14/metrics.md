title: Métricas
---

Moleculer possui um módulo de métricas integrado que coleta muitos valores de métricas internos do Moleculer e de processos. Além disso, você pode definir facilmente suas métricas personalizadas. Existem vários geradores de métricas integrados como `Console`, [Prometheus](https://prometheus.io/), [Datadog](https://www.datadoghq.com/), etc.

{% note warn %}
Se você deseja usar as métricas [legacy (<= v0.13)](/modules.html#metrics) use `EventLegacy` como exportador de rastreamento. [Mais informações](tracing.html#Event-legacy).
{% endnote %}

**Habilitar métricas & definir gerador para console**
```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            "Console"
        ]
    }
};
```

## Opções

| Nome                    | Tipo                              | Valor padrão | Descrição                                                                                                    |
| ----------------------- | --------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| `enabled`               | `Boolean`                         | `false`      | Ativar recurso de rastreamento.                                                                              |
| `reporter`              | `Object` or `Array<Object>` | `null`       | Configuração de gerador métrico. [Mais informações](#Metrics-Reporters)                                      |
| `collectProcessMetrics` | `Boolean`                         |              | Colete métricas relacionadas ao processo & ao sistema operacional. Padrão: `process.env.NODE_ENV !== "test"` |
| `collectInterval`       | `Number`                          | `5`          | Período de tempo para coleta em segundos.                                                                    |
| `defaultBuckets`        | `Array<Number>`             |              | Valores padrão para histogramas. Default: `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]`        |
| `defaultQuantiles`      | `Array<Number>`             |              | Valores padrão para histogramas. Default: `[0.5, 0.9, 0.95, 0.99, 0.999]`                                    |
| `defaultMaxAgeSeconds`  | `Number`                          | `60`         | Tempo máximo para o cálculo da quantidade.                                                                   |
| `defaultAgeBuckets`     | `Number`                          | `10`         | Número de buckets para cálculo da quantidade.                                                                |
| `defaultAggregator`     | `String`                          | `sum`        | Método para agregador de valor.                                                                              |

## Geradores de Métricas
Moleculer possui vários geradores integrados. Todos eles têm as seguintes opções:

| Nome                  | Tipo                              | Valor padrão | Descrição                                                                                       |
| --------------------- | --------------------------------- | ------------ | ----------------------------------------------------------------------------------------------- |
| `includes`            | `String` or `Array<String>` | `null`       | Lista de métricas a serem exportadas. [Métricas padrão](metrics.html#Built-in-Internal-Metrics) |
| `excludes`            | `String` or `Array<String>` | `null`       | Lista de métricas a serem excluídas. [Métricas padrão](metrics.html#Built-in-Internal-Metrics)  |
| `metricNamePrefix`    | `String`                          | `null`       | Prefixo a ser adicionado a nomes de métricas                                                    |
| `metricNameSuffix`    | `String`                          | `null`       | Sufixo a ser adicionado aos nomes das métricas                                                  |
| `metricNameFormatter` | `Function`                        | `null`       | Formatador para nome da métrica                                                                 |
| `labelNameFormatter`  | `Function`                        | `null`       | Formatador para nome da tag                                                                     |


**Exemplo de opções métricas**
```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Console",
                options: {
                    includes: ["moleculer.**.total"],
                    excludes: ["moleculer.broker.**","moleculer.request.**"],

                    metricNamePrefix: "mol:", // Original "moleculer.node.type". With prefix: "mol:moleculer.node.type" 
                    metricNameSuffix: ".value", // Original "moleculer.node.type". With prefix: "moleculer.node.type.value"

                    metricNameFormatter: name => name.toUpperCase().replace(/[.:]/g, "_"),
                    labelNameFormatter: name => name.toUpperCase().replace(/[.:]/g, "_")
                }
            }
        ]
    }
};
```

### Console
Este é um gerador para debug que exibe periodicamente as métricas no console.

```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Console",
                options: {
                    // Printing interval in seconds
                    interval: 5,
                    // Custom logger.
                    logger: null,
                    // Using colors
                    colors: true,
                    // Prints only changed metrics, not the full list.
                    onlyChanges: true
                }
            }
        ]
    }
};
```

### CSV
O gerador (CSV) salva as interações em um arquivo CSV.

```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "CSV",
                options: {
                    // Folder of CSV files.
                    folder: "./reports/metrics",
                    // CSV field delimiter
                    delimiter: ",",
                    // CSV row delimiter
                    rowDelimiter: "\n",
                    // Saving mode. 
                    //   - "metric" - save metrics to individual files
                    //   - "label" - save metrics by labels to individual files
                    mode: "metric",
                    // Saved metrics types.
                    rowFormatter: null,
                }
            }
        ]
    }
};
                    types: null,
                    // Saving interval in seconds
                    interval: 5,
                    // Custom filename formatter
                    filenameFormatter: null,
                    // Custom CSV row formatter.
```
### Event
O gerador Event envia eventos Moleculer com valores de métricas.

 ```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Event",
                options: {
                    // Event name
                    eventName: "$metrics.snapshot",
                    // Broadcast or emit
                    broadcast: false,
                    // Event groups
                    groups: null,
                    // Send only changed metrics
                    onlyChanges: false,
                    // Sending interval in seconds
                    interval: 5,
                }
            }
        ]
    }
};
```

### Datadog
Gerador para Datadog envia métricas para o [Servidor Datadog](https://www.datadoghq.com/).

```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Datadog",
                options: {
                    // Hostname
                    host: "my-host",
                    // Base URL
                    baseUrl: "https://api.datadoghq.eu/api/", // Default is https://api.datadoghq.com/api/
                    // API version
                    apiVersion: "v1",
                    // Server URL path
                    path: "/series",
                    // Datadog API Key
                    apiKey: process.env.DATADOG_API_KEY,
                    // Default labels which are appended to all metrics labels
                    defaultLabels: (registry) => ({
                        namespace: registry.broker.namespace,
                        nodeID: registry.broker.nodeID
                    }),
                    // Sending interval in seconds
                    interval: 10
                }
            }
        ]
    }
};
```

### Prometheus
O gerador para Prometheus publica métricas em formato Prometheus. O servidor [Prometheus](https://prometheus.io/) pode coletá-los. A porta padrão é `3030`.

```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "Prometheus",
                options: {
                    // HTTP port
                    port: 3030,
                    // HTTP URL path
                    path: "/metrics",
                    // Default labels which are appended to all metrics labels
                    defaultLabels: registry => ({
                        namespace: registry.broker.namespace,
                        nodeID: registry.broker.nodeID
                    })
                }
            }
        ]
    }
};
```

### StatsD
O gerador StatsD envia valores de métricas para o servidor [StatsD](https://github.com/statsd/statsd) via UDP.

```js
// moleculer.config.js
module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            {
                type: "StatsD",
                options: {
                    // Server host
                    host: "localhost",
                    // Server port
                    port: 8125,
                    // Maximum payload size.
                    maxPayloadSize: 1300
                }
            }
        ]
    }
};
```

### Gerador personalizado
Um módulo de métricas personalizadas pode ser criado. Recomendamos copiar o código fonte do [Console Reporter](https://github.com/moleculerjs/moleculer/blob/master/src/metrics/reporters/console.js) e implementar os métodos `init`, `stop`, `metricChanged`.

**Criar métricas personalizadas**
```js
const BaseReporter = require("moleculer").MetricReporters.Base;

class MyMetricsReporter extends BaseReporter {
    init() { /*...*/ }
    stop() { /*...*/ }
    metricChanged() { /*...*/ }
}
```

**Usar métricas personalizadas**
```js
// moleculer.config.js
const MyMetricsReporter = require("./my-metrics-reporter");

module.exports = {
    metrics: {
        enabled: true,
        reporter: [
            new MyMetricsReporter(),
        ]
    }
};
```

## Tipos de métricas suportados

### Counter
Um contador é uma métrica acumulativa que representa um único contador aumentando sistematicamente cujo valor só pode aumentar ou ser reposto a zero. Por exemplo, você pode usar um contador para representar o número de requisições atendidas, tarefas concluídas ou erros. Pode também fornecer uma taxa de minuto.

### Gauge
Gauge é uma métrica que representa um único valor numérico que pode arbitrariamente subir e cair. Gauges são usados tipicamente para valores medidos como o uso de memória atual, mas também "contagens" que podem subir e baixar, como o número de requisições simultâneas. Pode também fornecer uma taxa de minuto.

### Histogram
Um histograma apresenta observações (geralmente coisas como durações de requisições ou tamanhos de resposta) e as agrupam em buckets configuráveis. Também fornece uma soma de todos os valores observados e calcula quantidades configuráveis ao longo de um período de tempo. Pode também fornecer uma taxa de minuto.

### Info
Uma info é uma única string ou valor de número, como argumentos de processo, nome de host ou números de versão.

## Métricas internas integradas

### Métricas de processo
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

### Métricas do Sistema Operacional
- `os.memory.free` (gauge)
- `os.memory.total` (gauge)
- `os.memory.used` (gauge)
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


### Métricas Moleculer
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
- `moleculer.request.bulkhead.queue.size` (gauge)
- `moleculer.event.bulkhead.inflight` (gauge)
- `moleculer.event.bulkhead.queue.size` (gauge)
- `moleculer.event.received.time` (histogram)
- `moleculer.event.received.error.total`(counter)
- `moleculer.event.received.active` (gauge)
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



## Personalizando

### Registro de novas métricas

Você pode facilmente criar novas métricas.

**Criar counter**
```js
// posts.service.js
module.exports = {
    name: "posts",

    actions: {
        // Get posts.
        get(ctx) {
            // Increment metric
            this.broker.metrics.increment("posts.get.total", 1);

            return this.posts;
        }
    },

    created() {
        // Register new counter metric
        this.broker.metrics.register({ 
            type: "counter", 
            name: "posts.get.total", 
            description: "Number of requests of posts", 
            unit: "request",
            rate: true // calculate 1-minute rate
        });
    }
};
```

**Criar gauge com tags**
```js
// posts.service.js
module.exports = {
    name: "posts",

    actions: {
        // Create a new post
        create(ctx) {
            // Update metrics
            this.broker.metrics.increment("posts.total", { userID: ctx.params.author }, 1);
            return posts;
        },

        // Remove a new post
        remove(ctx) {
            // Update metrics
            this.broker.metrics.decrement("posts.total", { userID: ctx.params.author }, 1);
            return posts;
        },

    },

    created() {
        // Register new gauge metric
        this.broker.metrics.register({ 
            type: "gauge", 
            name: "posts.total", 
            labelNames: ["userID"]
            description: "Number of posts by user",
            unit: "post"
        });
    }
};
```

**Criar histogram com buckets & quantidades**
```js
// posts.service.js
module.exports = {
    name: "posts",

    actions: {
        // Create a new post
        create(ctx) {
            // Measure the post creation time
            const timeEnd = this.broker.metrics.timer("posts.creation.time");
            const post = await this.adapter.create(ctx.params);
            const duration = timeEnd();

            this.logger.debug("Post created. Elapsed time: ", duration, "ms");
            return post;
        }
    },

    created() {
        // Register new histogram metric
        this.broker.metrics.register({ 
            type: "histogram", 
            name: "posts.creation.time", 
            description: "Post creation time",
            unit: "millisecond",
            linearBuckets: {
                start: 0,
                width: 100,
                count: 10
            },
            quantiles: [0.5, 0.9, 0.95, 0.99],
            maxAgeSeconds: 60,
            ageBuckets: 10
        });
    }
};
```
