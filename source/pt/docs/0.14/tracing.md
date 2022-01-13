title: Tracing
---
O Moleculer possui um módulo de rastreamento integrado que coleta informações de rastreamento dentro de uma aplicação Moleculer. Além disso, você pode definir facilmente seus módulos de rastreamento personalizados. Existem vários geradores de rastreamento integrados como [Zipkin](https://zipkin.apache.org/), [Jaeger](https://www.jaegertracing.io/), [Datadog](https://www.datadoghq.com/), etc.

**Habilitar rastreamento**
```js
// moleculer.config.js
module.exports = {
    tracing: true
};
```

**Habilitar rastreamento com opções**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: "Console",
        events: true,
        stackTrace: true
    }
};
```

## Opções

| Nome          | Tipo                              | Padrão                                        | Descrição                                                                                                                     |
| ------------- | --------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `enabled`     | `Boolean`                         | `false`                                       | Ativar recurso de rastreamento.                                                                                               |
| `exporter`    | `Object` or `Array<Object>` | `null`                                        | Configuração do gerador de rastreamento. [Mais informações](#Tracing-Exporters)                                               |
| `sampling`    | `Object`                          |                                               | Configurações de amostragem. [Mais informações](#Sampling)                                                                    |
| `actions`     | `Boolean`                         | `true`                                        | Rastreando as ações do serviço.                                                                                               |
| `events`      | `Boolean`                         | `false`                                       | Rastreando os eventos do serviço.                                                                                             |
| `errorFields` | `Array<String>`             | `["name", "message", "code", "type", "data"]` | Campos de objetos de erro que foram adicionados em tags span.                                                                 |
| `stackTrace`  | `Boolean`                         | `false`                                       | Adicione informações sobre rastreamento de pilha em span tags em caso de erro.                                                |
| `tags`        | `Object`                          | `null`                                        | Adicione tags personalizadas de span para todas as ações e eventos de spam. [Mais informações](#Global-action-and-event-tags) |
| `defaultTags` | `Objeto`                          | `null`                                        | Tags padrão. Será adicionado a todas as spans.                                                                                |

## Amostragem
O módulo de rastreamento do Moleculer suporta vários métodos de amostragem. A determinação de amostrar ou não é feita no span raiz e propagada a todas as spans dependentes. Isso garante que um rastreamento completo seja sempre exportado, independentemente do método de amostra ou da taxa selecionada.

### Amostragem constante
Este método de amostragem usa um valor de taxa de amostragem constante de `0` para `1`. O `1` significa que todos os spans serão amostrais, o `0` significa nenhum deles.

**Amostras de todas as spans**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            rate: 1.0
        }
    }
};
```

**Amostras de metade de todas as spans**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            rate: 0.5
        }
    }
};
```

### Taxa de limitação de amostragem
Este método de amostragem usa uma taxa de limitação. Você pode configurar quantas spans serão distribuídas em um segundo.

**Amostragem com 2 spans por segundo**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            tracesPerSecond: 2
        }
    }
};
```

**Amostragem com 1 spans a cada 10 segundos**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            tracesPerSecond: 0.1
        }
    }
};
```

## Geradores de Rastreamento

O módulo de rastreamento suporta vários geradores, spans personalizadas de rastreamento e integração com bibliotecas de instrumentação (como [`dd-trace`](https://github.com/DataDog/dd-trace-js)).

### Console
Este é um gerador para debug que imprime o rastreamento local completo no console.

![Gráfico de Console](assets/tracing/console.png#zoomable)

{% note warn %}
O gerador do console não pode rastrear chamadas remotas, apenas locais.
{% endnote %}

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Console",
            options: {
                // Custom logger
                logger: null,
                // Using colors
                colors: true,
                // Width of row
                width: 100,
                // Gauge width in the row
                gaugeWidth: 40
            }
        }
    }
};
```

### Datadog
O gerador para Datadog envia dados de rastreamento para o servidor [Datadog](https://www.datadoghq.com/) via `dd-trace`. 
<!-- It is able to merge tracing spans of instrumented Node.js modules and Moleculer modules. -->

![Gráfico Datadog](assets/tracing/datadog-trace-graph.png#zoomable)

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Datadog",
            options: {
                // Datadog Agent URL
                agentUrl: process.env.DD_AGENT_URL || "http://localhost:8126",
                // Environment variable
                env: process.env.DD_ENVIRONMENT || null,
                // Sampling priority. More info: https://docs.datadoghq.com/tracing/guide/trace_sampling_and_storage/?tab=java#sampling-rules
                samplingPriority: "AUTO_KEEP",
                // Default tags. They will be added into all span tags.
                defaultTags: null,
                // Custom Datadog Tracer options. More info: https://datadog.github.io/dd-trace-js/#tracer-settings
                tracerOptions: null,
            }
        }
    }
};
```
{% note info %}
Para usar este gerador, instale o módulo `dd-trace` com o comando `npm install dd-trace --save`.
{% endnote %}


### Event
O gerador para eventos do Moleculer envia eventos (`$tracing.spans`) com dados de rastreamento.

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Event",
            options: {
                // Name of event
                eventName: "$tracing.spans",
                // Send event when a span started
                sendStartSpan: false,
                // Send event when a span finished
                sendFinishSpan: true,
                // Broadcast or emit event
                broadcast: false,
                // Event groups
                groups: null,
                // Sending time interval in seconds
                interval: 5,
                // Custom span object converter before sending
                spanConverter: null,
                // Default tags. They will be added into all span tags.
                defaultTags: null
            }
        }
    }
};
```

### Event (legacy)
O gerador para evento legado envia eventos métricos legados do Moleculer ([`metrics.trace.span.start`](#Legacy-Request-Started-Payload) & [`metrics.trace.span.finish`](#Legacy-Request-Finished-Payload)) a cada requisição. Esses eventos também são usados para gerar métricas na solução legada (`<= v0.13`) de [métricas](/modules.html#metrics).

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: "EventLegacy"
    }
};
```

#### Payload de início de Requisição legada
O broker emite um evento `metrics.trace.span.start` quando uma nova requisição é iniciada. O payload se parece com o seguinte:
```js
{
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: '6858979d-3298-4a7b-813a-ffb417da822b',
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // Is it a remote call
    remoteCall: false,
    // Called action
    action: {
        name: 'users.get'
    },
    // Called service
    service: {
        name: "users"
    },
    // Params
    params: {
        id: 5
    },
    // Meta
    meta: {},
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's requested from a remote node
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: null
}
```

#### Payload de conclusão de Requisição legada
O broker emite um evento `metrics.trace.span.end` quando a chamada/requisição for finalizada. O payload se parece com o seguinte:
```js
{
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: '6858979d-3298-4a7b-813a-ffb417da822b',
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // End time
    endTime: 1493903164731.3684,
    // Duration of request
    duration: 5.368304,
    // Is it a remote call
    remoteCall: false,
    // Is it resolved from cache
    fromCache: false,
    // Called action
    action: {
        name: 'users.get'
    },
    // Called service
    service: {
        name: "users"
    },
    // Params
    params: {
        id: 5
    },
    // Meta
    meta: {},   
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's a remote call
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: null,
    // Error if the call returned with error
    error: {
        name: "ValidationError",
        message: "Invalid incoming parameters"
    }
}
```

### Jaeger
O gerador para Jaeger envia informações de rastreamento para um servidor [Jaeger](https://www.jaegertracing.io).

![Gráfico Jaeger](assets/tracing/jaeger.png#zoomable)

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Jaeger",
            options: {
                // HTTP Reporter endpoint. If set, HTTP Reporter will be used.
                endpoint: null,
                // UDP Sender host option.
                host: "127.0.0.1",
                // UDP Sender port option.
                port: 6832,
                // Jaeger Sampler configuration.
                sampler: {
                    // Sampler type. More info: https://www.jaegertracing.io/docs/1.14/sampling/#client-sampling-configuration
                    type: "Const",
                    // Sampler specific options.
                    options: {}
                },
                // Additional options for `Jaeger.Tracer`
                tracerOptions: {},
                // Default tags. They will be added into all span tags.
                defaultTags: null
            }
        }
    }
};
```
{% note info %}
Para usar esse gerador, instale o módulo `jaeger-client` com o comando `npm install jaeger-client --save`.
{% endnote %}


### Zipkin
O gerador Zipkin envia informações de rastreamento para um servidor [Zipkin](https://zipkin.apache.org/).

![Gráfico Zipkin](assets/tracing/zipkin.png#zoomable)

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Zipkin",
            options: {
                // Base URL for Zipkin server.
                baseURL: "http://localhost:9411",
                // Sending time interval in seconds.
                interval: 5,
                // Additional payload options.
                payloadOptions: {
                    // Set `debug` property in payload.
                    debug: false,
                    // Set `shared` property in payload.
                    shared: false
                },
                // Default tags. They will be added into all span tags.
                defaultTags: null
            }
        }
    }
};
```

### NewRelic
O exportador NewRelic envia informações de rastreamento no formato Zipkin v2 para um servidor [NewRelic](https://newrelic.com/).

```js
// moleculer.config.js
{
    tracing: {
        enabled: true,
        events: true,
        exporter: [
            {
                type: 'NewRelic',
                options: {
                    // Base URL for NewRelic server
                    baseURL: 'https://trace-api.newrelic.com',
                    // NewRelic Insert Key
                    insertKey: 'my-secret-key',
                    // Sending time interval in seconds.
                    interval: 5,
                    // Additional payload options.
                    payloadOptions: {
                        // Set `debug` property in payload.
                        debug: false,
                        // Set `shared` property in payload.
                        shared: false,
                    },
                    // Default tags. They will be added into all span tags.
                    defaultTags: null,
                },
            },
        ],
    },    
}
```

### Gerador personalizado
Um módulo personalizado de rastreamento pode ser criado. Recomendamos copiar o código fonte do [Console](https://github.com/moleculerjs/moleculer/blob/master/src/tracing/exporters/console.js) e implementar os métodos `init`, `stop`, `spanStarted` e `spanFinished`.

**Criar métricas personalizadas**
```js
const TracerBase = require("moleculer").TracerExporters.Base;

class MyTracingExporters extends TracerBase {
    init() { /*...*/ }
    stop() { /*...*/ }
    spanStarted() { /*...*/ }
    spanFinished() { /*...*/ }
}
```

**Usar métricas personalizadas**
```js
// moleculer.config.js
const MyMetricsReporter = require("./my-tracing-exporter");

module.exports = {
    tracing: {
        enabled: true,
        exporter: [
            new MyTracingExporters(),
        ]
    }
};
```

## Múltiplos geradores
Você pode definir vários geradores de rastreamento.

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: [
            "Console",
            {
                type: "Zipkin",
                options: {
                    baseURL: "http://localhost:9411",
                }
            }
            {
                type: "Jaeger",
                options: {
                    host: "127.0.0.1",
                }
            }
        ]
    }
};
```

## Spans de rastreamento definidos pelo usuário
Para adicionar novos spans dentro de uma ação ou manipulador de eventos, basta chamar os métodos `ctx.startSpan` e `ctx.finishSpan`.

```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        async find(ctx) {
            const span1 = ctx.startSpan("get data from DB", {
                tags: {
                    ...ctx.params
                }
            }); 
            const data = await this.getDataFromDB(ctx.params);
            ctx.finishSpan(span1);

            const span2 = ctx.startSpan("populating");
            const res = await this.populate(data);
            ctx.finishSpan(span2);

            return res;
        }
    }
};
```

### Criar span sem context
Se o `Context` não estiver disponível, você pode criar spans via `broker.tracer`.

```js
// posts.service.js
module.exports = {
    name: "posts",
    started() {
        // Create a span to measure the initialization
        const span = this.broker.tracer.startSpan("initializing db", {
            tags: {
                dbHost: this.settings.dbHost
            }
        });

        await this.db.connect(this.settings.dbHost);

        // Create a sub-span to measure the creating tables.
        const span2 = span.startSpan("create tables");

        await this.createDatabaseTables();

        // Finish the sub-span.
        span2.finish();

        // Finish the main span.
        span.finish();
    }
};
```


## Connecting spans while using external communication module

It is possible to connect the spans even while communicating via external queue (e.g., [moleculer-channels](https://github.com/moleculerjs/moleculer-channels)). To do it you just need to pass the `parentID` and `requestID` to the handler and then use those IDs to start a custom span.

**Connecting spans**

```js
module.exports = {
    name: "trace",
    actions: {
        async extractTraces(ctx) {
            // Extract the parentID and the requestID from context
            const { parentID, requestID: traceID } = ctx;

            // Send parentID and traceID as payload via an external queue
            await this.broker.sendToChannel("trace.setSpanID", {
                // Send the IDs in the payload
                parentID,
                traceID,
            });
        },
    },

    // More info about channels here: https://github.com/moleculerjs/moleculer-channels
    channels: {
        "trace.setSpanID"(payload) {
            // Init custom span with the original parentID and requestID
            const span = this.broker.tracer.startSpan("my.span", payload);

            // ... logic goes here

            span.finish(); // Finish the custom span
        },
    },
};
```

## Personalizando
### Nomes de Span Personalizados
Você pode personalizar o nome do span de seu rastreamento. Nesse caso, você deve especificar o `spanName` que deve ser uma `String` estática ou uma `Function`.

**Criando um nome personalizado para um rastreamento via Function**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                spanName: ctx => `Get a post by ID: ${ctx.params.id}`
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

### Adicionando Tags do Context
Você pode personalizar quais valores de `params` ou `meta` são adicionados às tags span.

**Default** O comportamento padrão adiciona todas as propriedades de `ctx.params` apenas.
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                // Add all params without meta
                tags: {
                    params: true,
                    meta: false,
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

**Exemplo de parâmetros personalizados**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                tags: {
                    // Add `id` from `ctx.params`
                    params: ["id"],
                    // Add `loggedIn.username` value from `ctx.meta`
                    meta: ["loggedIn.username"],
                    // add tags from the action response.
                    response: ["id", "title"]
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

**Exemplo com função personalizada** Você pode definir uma `function` personalizada para preencher as tags de span do `Context`.

```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                tags(ctx, response) {
                    return {
                        params: ctx.params,
                        meta: ctx.meta,
                        custom: {
                            a: 5
                        },
                        response
                    };
                }
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

{% note info %}
Por favor, note que, quando usado com uma ação, a função será chamada duas vezes no caso de execução bem-sucedida. Primeiro com `ctx` e segunda vez com `ctx` & `response` como resposta da chamada da ação.
{% endnote %}

## Ações globais e tags de eventos

Tags de span personalizadas de ações e eventos podem ser definidas usando a propriedade `tags` nas [options](#Options) do gerador de rastreamento. Estas serão aplicadas a todas as ações e eventos a menos que sejam sobrescritas nas definições de eventos e ações no esquema do serviço. Todos os tipos de tags personalizados definidos [acima](#Customizing) são válidos. Quaisquer tags definidas na ação do esquema do serviço e as definições de eventos terão precedência, mas a mesclagem das definições de tags de `params`, `meta`, e `response` são superáveis, o que significa que é possível fazer coisas como definir tags com `meta` globalmente e com `response` localmente em cada serviço.

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        tags: {
            action: {
                // Never add params
                params: false,
                // Add `loggedIn.username` value from `ctx.meta`
                meta: ["loggedIn.username"],
                // Always add the response
                response: true,
            },
            event(ctx) {
                return {
                    params: ctx.params,
                    meta: ctx.meta,
                    // add the caller
                    caller: ctx.caller,
                    custom: {
                        a: 5
                    },
                };
            },            
        }
    }
};
```

{% note info %}
Tags personalizadas definidas usando a propriedade `tags` tem acesso a `ctx` e, se usado com uma ação, o `response`. As tags definidas em `defaultTags` devem ser um objeto estático ou uma função que aceita a instância do `tracer` e retorna um objeto. Ele também tem acesso à instância `broker` através da instância `tracer` mas não tem acesso a `ctx`.
{% endnote %}

**Exemplo de rastreamento de eventos** Você pode rastrear os eventos também. Para habilitar isso, defina `events: true` nas opções do broker.
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        events: true
    }
};
```

## safetyTags and Maximum call stack error

In general, sending non-serializable parameters (e.g. http request, socket instance, stream instance, etc.) in `ctx.params` or `ctx.meta` is not recommended. If tracing is enabled, the tracer exporter will try to recursively flatten these params (with [`flattenTags` method](https://github.com/moleculerjs/moleculer/blob/c48d5a05a4f4a1656075faaabc64085ccccf7ef9/src/tracing/exporters/base.js#L87-L101)) which will cause the `Maximum call stack error`.

To avoid this issue, you can use the `safetyTags` option in exporter options. If set to `true`, the exporters remove the cyclic properties before flattening the tags in the spans. This option is available in all built-in exporters.

{% note warn Performance impact%}
Please note, this option has a **significant** [impact in performance](https://github.com/moleculerjs/moleculer/issues/908#issuecomment-817806332). For this reason it's not enabled by default.
{% endnote %}

**Enabling globally the safetyTags**
```js
// moleculer.config.js
{
    tracing: {
        exporter: [{
            type: "Zipkin",
            options: {
                safetyTags: true,
                baseURL: "http://127.0.0.1:9411"
            }
        }]
    }
}
```


To avoid affecting all actions, you can enable this function at action-level. In this case, the remaining actions will be unaffected. **Enabling safetyTags at action-level**
```js
broker.createService({
    name: "greeter",
    actions: {
        hello: {
            tracing: {
                safetyTags: true
            },
            handler(ctx) {
                return `Hello!`;
            }
        }
    }
});
```