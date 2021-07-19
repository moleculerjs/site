title: Eventos
---
O broker possui um barramento de eventos integrado para atender a uma [Arquitetura baseada em eventos](http://microservices.io/patterns/data/event-driven-architecture.html) e enviar eventos para serviços locais e remotos.

# Eventos balanceados
Os assinantes de eventos são agrupados em grupos lógicos. Significa que apenas um assinante é acionado em cada grupo.

> **Exemplo:** você tem 2 serviços principais: `users` & `payments`. Ambos se inscrevem para o evento `user.created`. Você inicia 3 instâncias do serviço `users` e 2 instâncias do serviço `payments`. Quando você emite o evento `user.created`, apenas uma instância do serviço `users` e uma de `payments` receberá o evento.

<div align="center">
    <img src="assets/balanced-events.gif" alt="Balanced events diagram" />
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
O evento de transmissão é enviado para todos os serviços locais & remotos disponíveis. Não é balanceado, todas as instâncias de serviços o receberão.

<div align="center">
    <img src="assets/broadcast-events.gif" alt="Broadcast events diagram" />
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


Subscribe to events in ['events' property of services](services.html#events). Use of wildcards (`?`, `*`, `**`) is available in event names.

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

## Event parameter validation
Similar to action parameter validation, the event parameter validation is supported. Like in action definition, you should define `params` in even definition and the built-in `Validator` validates the parameters in events.

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
> The validation errors are not sent back to the caller, they are logged or you can catch them with the new [global error handler](broker.html#Global-error-handler).

# Internal events
The broker broadcasts some internal events. These events always starts with `$` prefix.

## `$services.changed`
The broker sends this event if the local node or a remote node loads or destroys services.

**Payload**

| Name           | Type      | Description                      |
| -------------- | --------- | -------------------------------- |
| `localService` | `Boolean` | True if a local service changed. |

## `$circuit-breaker.opened`
The broker sends this event when the circuit breaker module change its state to `open`.

**Payload**

| Name       | Type     | Description       |
| ---------- | -------- | ----------------- |
| `nodeID`   | `String` | Node ID           |
| `action`   | `String` | Action name       |
| `failures` | `Number` | Count of failures |


## `$circuit-breaker.half-opened`
The broker sends this event when the circuit breaker module change its state to `half-open`.

**Payload**

| Name     | Type     | Description |
| -------- | -------- | ----------- |
| `nodeID` | `String` | Node ID     |
| `action` | `String` | Action name |

## `$circuit-breaker.closed`
The broker sends this event when the circuit breaker module change its state to `closed`.

**Payload**

| Name     | Type     | Description |
| -------- | -------- | ----------- |
| `nodeID` | `String` | Node ID     |
| `action` | `String` | Action name |

## `$node.connected`
The broker sends this event when a node connected or reconnected.

**Payload**

| Name          | Type      | Description      |
| ------------- | --------- | ---------------- |
| `node`        | `Node`    | Node info object |
| `reconnected` | `Boolean` | Is reconnected?  |

## `$node.updated`
The broker sends this event when it has received an INFO message from a node, (i.e. a service is loaded or destroyed).

**Payload**

| Name   | Type   | Description      |
| ------ | ------ | ---------------- |
| `node` | `Node` | Node info object |

## `$node.disconnected`
The broker sends this event when a node disconnected (gracefully or unexpectedly).

**Payload**

| Name         | Type      | Description                                                                         |
| ------------ | --------- | ----------------------------------------------------------------------------------- |
| `node`       | `Node`    | Node info object                                                                    |
| `unexpected` | `Boolean` | `true` - Not received heartbeat, `false` - Received `DISCONNECT` message from node. |

## `$broker.started`
The broker sends this event once `broker.start()` is called and all local services are started.

## `$broker.stopped`
The broker sends this event once `broker.stop()` is called and all local services are stopped.

## `$transporter.connected`
The transporter sends this event once the transporter is connected.

## `$transporter.disconnected`
The transporter sends this event once the transporter is disconnected.

