title: Eventos
---
O broker possui um barramento de eventos integrado para atender a uma [Arquitetura baseada em eventos](http://microservices.io/patterns/data/event-driven-architecture.html) e enviar eventos para serviços locais e remotos.

# Eventos balanceados
Os assinantes de eventos são agrupados em grupos lógicos. Significa que apenas um assinante é acionado em cada grupo.

> **Exemplo:** você tem 2 serviços principais: `users` & `payments`. Ambos se inscrevem para o evento `user.created`. Você inicia 3 instâncias do serviço `users` e 2 instâncias do serviço `payments`. Quando você emite o evento `user.created`, apenas uma instância do serviço `users` e uma de `payments` receberá o evento.

<div align="center">
    <img src="assets/balanced-events.gif" alt="Diagrama de eventos balanceados" />
</div>

O nome do grupo vem do nome do serviço, mas ele pode ser substituído na definição do evento em serviços.

**Exemplo**
```js
module.exports = {
    name: "payment",
    events: {
        "order.created": {
            // Register handler to the "other" group instead of "payment" group.
            group: "other",
            handler(ctx) {
                console.log("Payload:", ctx.params);
                console.log("Sender:", ctx.nodeID);
                console.log("Metadata:", ctx.meta);
                console.log("The called event name:", ctx.eventName);
            }
        }
    }
}
```

## Emitir eventos balanceados
Emita eventos balanceados com a função `broker.emit`. O primeiro parâmetro é o nome do evento, o segundo parâmetro é o payload. _Para enviar múltiplos valores, envolva-os em um `Object`._

```js
// The `user` will be serialized to transportation.
broker.emit("user.created", user);
```

Especifique quais grupos/serviços receberão o evento:
```js
// Only the `mail` & `payments` services receives it
broker.emit("user.created", user, ["mail", "payments"]);
```

# Evento de transmissão
O evento de transmissão é emitido para todos os serviços locais & remotos disponíveis. Não é balanceado, todas as instâncias de serviços o receberão.

<div align="center">
    <img src="assets/broadcast-events.gif" alt="Diagrama de transmissão de eventos" />
</div>

Emita eventos de transmissão usando o método `broker.broadcast`.
```js
broker.broadcast("config.changed", config);
```

Especifique quais grupos/serviços receberão o evento:
```js
// Send to all "mail" service instances
broker.broadcast("user.created", { user }, "mail");

// Send to all "user" & "purchase" service instances.
broker.broadcast("user.created", { user }, ["user", "purchase"]);
```

## Evento de transmissão local
Emita eventos de transmissão apenas para todos os serviços locais com o método `broker.broadcastLocal`.
```js
broker.broadcastLocal("config.changed", config);
```

# Inscrever-se para eventos

A versão `v0.14` suporta manipuladores de eventos baseados em Contextos. O context do evento é útil se você estiver usando uma arquitetura orientada a eventos e deseja rastrear seus eventos. Se você estiver familiarizado com [Context de Ação](context.html) você vai se sentir em casa. O Context de Evento é muito semelhante ao Context de Ação, exceto para algumas novas propriedades relacionadas a eventos. [Verifique a lista completa de propriedades](context.html)

{% note info Legacy event handlers %}

Você não precisa reescrever todos os manipuladores de eventos existentes já que Moleculer ainda suporta assinatura legada `"user.created"(payload) { ... }`. Ele é capaz de detectar diferentes assinaturas de manipuladores de eventos:
- Se a assinatura encontrada for `"user.created"(ctx) { ... }`, ele vai chamar com Context de eventos.
- Se não, ele será chamado com argumentos antigos & o quarto argumento será o Context de Evento, como `"user.created"(payload, sender, eventName, ctx) {...}`

{% endnote %}

**Manipulador de eventos com base em context & emissão de evento aninhado**
```js
module.exports = {
    name: "accounts",
    events: {
        "user.created"(ctx) {
            console.log("Payload:", ctx.params);
            console.log("Sender:", ctx.nodeID);
            console.log("Metadata:", ctx.meta);
            console.log("The called event name:", ctx.eventName);

            ctx.emit("accounts.created", { user: ctx.params.user });
        }
    }
};
```


Inscreva-se aos eventos na propriedade ['eventos' dos serviços](services.html#events). O uso de caracteres curinga (`?`, `*`, `**`) está disponível nos nomes dos eventos.

```js
module.exports = {
    events: {
        // Subscribe to `user.created` event
        "user.created"(ctx) {
            console.log("User created:", ctx.params);
        },

        // Subscribe to all `user` events, e.g. "user.created", or "user.removed"
        "user.*"(ctx) {
            console.log("User event:", ctx.params);
        }
        // Subscribe to every events
        // Legacy event handler signature with context
        "**"(payload, sender, event, ctx) {
            console.log(`Event '${event}' received from ${sender} node:`, payload);
        }
    }
}
```

## Validação de parâmetros do evento
Semelhante à validação do parâmetro de ação, a validação do parâmetro de evento é suportada. Como na definição de ação, você deve definir `params` na mesma definição e o `Validator` integrado valida os parâmetros nos eventos.

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    events: {
        "send.mail": {
            // Validation schema
            params: {
                from: "string|optional",
                to: "email",
                subject: "string"
            },
            handler(ctx) {
                this.logger.info("Event received, parameters OK!", ctx.params);
            }
        }
    }
};
```
> Os erros de validação não são enviados de volta para o requisitante, eles são logados ou você pode capturá-los com o novo [manipulador de erros global](broker.html#Global-error-handler).

# Eventos internos
O broker transmite alguns eventos internos. Esses eventos sempre começam com prefixo `$`.

## `$services.changed`
O broker emite este evento se o nó local ou um nó remoto carrega ou destrói serviços.

**Payload**

| Nome           | Tipo      | Descrição                             |
| -------------- | --------- | ------------------------------------- |
| `localService` | `Boolean` | Verdadeiro se um serviço local mudou. |

## `$circuit-breaker.opened`
O broker emite este evento quando o módulo do circuit breaker altera seu estado para `aberto`.

**Payload**

| Nome       | Tipo     | Descrição          |
| ---------- | -------- | ------------------ |
| `nodeID`   | `String` | ID do nó           |
| `action`   | `String` | Nome da ação       |
| `failures` | `Number` | Contagem de falhas |


## `$circuit-breaker.half-opened`
O broker emite este evento quando o módulo do circuit breaker altera seu estado para `meio-aberto`.

**Payload**

| Nome     | Tipo     | Descrição    |
| -------- | -------- | ------------ |
| `nodeID` | `String` | ID do nó     |
| `action` | `String` | Nome da ação |

## `$circuit-breaker.closed`
O broker emite este evento quando o módulo do circuit breaker altera seu estado para `fechado`.

**Payload**

| Nome     | Tipo     | Descrição    |
| -------- | -------- | ------------ |
| `nodeID` | `String` | ID do nó     |
| `action` | `String` | Nome da ação |

## `$node.connected`
O broker emite este evento quando um nó se conecta ou desconecta.

**Payload**

| Nome          | Tipo      | Descrição                    |
| ------------- | --------- | ---------------------------- |
| `node`        | `Node`    | Objeto com informações do nó |
| `reconnected` | `Boolean` | Está reconectado?            |

## `$node.updated`
O broker emite este evento quando recebe uma mensagem INFO de um nó (ou seja, um serviço é carregado ou destruído).

**Payload**

| Nome   | Tipo   | Descrição                    |
| ------ | ------ | ---------------------------- |
| `node` | `Node` | Objeto com informações do nó |

## `$node.disconnected`
O broker emite este evento quando um nó é desconectado (de forma elegante ou inesperada).

**Payload**

| Nome         | Tipo      | Descrição                                                                              |
| ------------ | --------- | -------------------------------------------------------------------------------------- |
| `node`       | `Node`    | Objeto com informações do nó                                                           |
| `unexpected` | `Boolean` | `true` - Não recebido sinal de vida, `false` - Recebido a mensagem `DISCONNECT` do nó. |

## `$broker.started`
O broker emite este evento uma vez que `broker.start()` é chamado e todos os serviços locais são iniciados.

## `$broker.stopped`
O broker emite este evento uma vez que `broker.stop()` é chamado e todos os serviços locais são desconectados.

## `$transporter.connected`
O módulo de transporte emite este evento assim que o transporter estiver conectado.

## `$transporter.disconnected`
O módulo de transporte emite este evento assim que o transporter for desconectado.

