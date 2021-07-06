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
| `ctx.params`      | `Any`                 | Parâmetros da requisição. *Segundo argumento do `broker.call`.*      |
| `ctx.meta`        | `Any`                 | Metadados da requisição. *Será transferido para chamadas aninhadas*  |
| `ctx.locals`      | `Any`                 | Dados locais.                                                        |
| `ctx.level`       | `Number`              | Nível da requisição (em chamadas aninhadas). O primeiro nível é `1`. |
| `ctx.span`        | `Span`                | Span atual ativo.                                                    |

## Métodos de context

| Nome                        | Retorno   | Descrição                                                         |
| --------------------------- | --------- | ----------------------------------------------------------------- |
| `ctx.call()`                | `Promise` | Fazer chamadas aninhadas. Mesmos argumentos como em `broker.call` |
| `ctx.emit()`                | `void`    | Emitir um evento, o mesmo que `broker.emit`                       |
| `ctx.broadcast()`           | `void`    | Emitir um evento, o mesmo que `broker.broadcast`                  |
| `ctx.startSpan(name, opts)` | `Span`    | Criar um novo span filho.                                         |
| `ctx.finishSpan(span)`      | `void`    | Finalizar um span.                                                |
| `ctx.toJSON()`              | `Object`  | Converter `Context` para um JSON formatado.                       |
|  `ctx.copy()`               |  `this`   |  Criar uma cópia da instância de `Context`.                       |

## Rastreamento de context
Se você quer desligamentos elegantes dos serviços, ative o recurso Context tracking nas opções do broker. Se você habilitá-lo, todos os serviços esperarão por todos os context em execução antes de desligar. Um valor de timeout pode ser definido com a opção `shutdownTimeout` no broker. O valor padrão é `5` segundos.

**Ativar context tracking & alterar o valor do timeout**
```js
const broker = new ServiceBroker({
    nodeID: "node-1",
    tracking: {
        enabled: true,
        shutdownTimeout: 10 * 1000
    }
});
```

> O timeout de desligamento pode ser substituído pela propriedade `$shutdownTimeout` nas configurações de serviço.

**Desativar tracking nas opções de chamada**

```js
await broker.call("posts.find", {}, { tracking: false });
```