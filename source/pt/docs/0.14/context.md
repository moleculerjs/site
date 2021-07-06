title: Context
---

Quando você chama uma ação ou emite um evento, o broker cria uma instância de `context` que contém todas as informações da requisição e a passa para o handler da ação/evento como um único argumento.

## Propriedades de Context

| Nome              | Tipo                  | Descrição                                                            |
| ----------------- | --------------------- | -------------------------------------------------------------------- |
| `ctx.id`          | `String`              | ID do contexto                                                       |
| `ctx.broker`      | `ServiceBroker`       | Instância do broker.                                                 |
| `ctx.nodeID`      | `String`              | O ID do nó do requisitante ou do destino.                            |
| `ctx.action`      | `Object`              | Instância da definição de ação.                                      |
| `ctx.event`       | `Object`              | Instância da definição do evento.                                    |
| `ctx.eventName`   | `Object`              | Nome do evento emitido.                                              |
| `ctx.eventType`   | `String`              | Tipo de evento ("emit" ou "broadcast").                              |
| `ctx.eventGroups` | `Array<String>` | Grupos de eventos.                                                   |
| `ctx.caller`      | `String`              | Nome completo do serviço do requisitante. Ex.: `v3.myService`        |
| `ctx.requestID`   | `String`              | ID da Requisição. Se você fizer chamadas aninhadas, será o mesmo ID. |
| `ctx.parentID`    | `String`              | ID do contexto pai (em chamadas aninhadas).                          |
| `ctx.params`      | `Any`                 | Parâmetros da requisição. *Second argument from `broker.call`.*      |
| `ctx.meta`        | `Any`                 | Request metadata. *It will be also transferred to nested-calls.*     |
| `ctx.locals`      | `Any`                 | Local data.                                                          |
| `ctx.level`       | `Number`              | Request level (in nested-calls). The first level is `1`.             |
| `ctx.span`        | `Span`                | Current active span.                                                 |

## Methods of Context

| Name                        | Response  | Description                                            |
| --------------------------- | --------- | ------------------------------------------------------ |
| `ctx.call()`                | `Promise` | Make nested-call. Same arguments like in `broker.call` |
| `ctx.emit()`                | `void`    | Emit an event, same as `broker.emit`                   |
| `ctx.broadcast()`           | `void`    | Broadcast an event, same as `broker.broadcast`         |
| `ctx.startSpan(name, opts)` | `Span`    | Creates a new child span.                              |
| `ctx.finishSpan(span)`      | `void`    | Finishes a span.                                       |
| `ctx.toJSON()`              | `Object`  | Convert `Context` to a printable JSON.                 |
|  `ctx.copy()`               |  `this`   |  Create a copy of the `Context` instance.              |

## Context tracking
If you want graceful service shutdowns, enable the Context tracking feature in broker options. If you enable it, all services will wait for all running contexts before shutdown. A timeout value can be defined with `shutdownTimeout` broker option. The default values is `5` seconds.

**Enable context tracking & change the timeout value**
```js
const broker = new ServiceBroker({
    nodeID: "node-1",
    tracking: {
        enabled: true,
        shutdownTimeout: 10 * 1000
    }
});
```

> The shutdown timeout can be overwritten by `$shutdownTimeout` property in service settings.

**Disable tracking in calling option**

```js
await broker.call("posts.find", {}, { tracking: false });
```