title: События
---
У брокера есть встроенная шина событий для поддержки [управляемой событиями архитектуры](http://microservices.io/patterns/data/event-driven-architecture.html) и для отправки событий локальным и удаленным сервисам.

# Сбалансированные события
Прослушиватели событий расположены в логических группах. Это означает, что в каждой группе вызывается только один слушатель.

> **Пример:** у вас есть 2 основных сервиса: `users` & `payments`. Оба подписываются на cобытие `user.created`. Вы запускаете 3 экземпляра сервиса `users` и 2 экземпляра сервиса `payments`. Когда вы выдаете событие `user.created`, только один экземпляр сервиса `users` и один экземпляр сервиса `payments` получит событие.

<div align="center">
    <img src="assets/balanced-events.gif" alt="Balanced events diagram" />
</div>

Название группы происходит от имени сервиса, но оно может быть перезаписано в определении события в сервисах.

**Пример**
```js
module.exports = {
    name: "payment",
    events: {
        "order.created": {
            // Регистрация обработчика в группу "other" вместо группы "payment".
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

## Выдача сбалансированного события
Отправлять сбалансированные события с помощью функции `broker.emit`. Первый параметр — это название события, второй параметр — это полезная нагрузка. _Чтобы отправить несколько значений, оберните их в `Object`._

```js
// `user` будет сериализован к транспорту.
broker.emit("user.created", user);
```

Укажите, какие группы/сервисы должны получить событие:
```js
// Только `mail` & `payments` сервисы принимают его
broker.emit("user.created", user, ["mail", "payments"]);
```

# Широковещательное событие
Штроковещательное событие отправляется всем доступным локальным & удаленным сервисам. Оно не сбалансировано, все экземпляры сервиса получат его.

<div align="center">
    <img src="assets/broadcast-events.gif" alt="Broadcast events diagram" />
</div>

Отправка широковещательного события выполняется с помощью метода `broker.broadcast`.
```js
broker.broadcast("config.changed", config);
```

Укажите, какие группы/сервисы должны получить событие:
```js
// Отправляем во все экземпляры сервиса "mail"
broker.broadcast("user.created", { user }, "mail");

// Отправляем всем "user" & "purchase" экземплярам сервиса.
broker.broadcast("user.created", { user }, ["user", "purchase"]);
```

## Локальное широковещательное событие
Для отправки события только всем локальным службам используется метод `broker.broadcastLocal`.
```js
broker.broadcastLocal("config.changed", config);
```

# Подписка на события

Версия `v0.14` поддерживает обработчики событий на основе контекста. Контекст событий полезен, если вы используете архитектуру под управлением событий и хотите отслеживать ваши события. Если вы знакомы с [Action Context](context.html), вы будете чувствовать себя как дома. Контекст события очень похож на контекст действий, за исключением нескольких новых свойств относящихся к событиям. [Посмотреть полный список всех свойств](context.html)

{% note info Legacy event handlers %}

Вам не нужно переписывать все существующие обработчики событий, так как Moleculer все еще поддерживает старую сигнатуру `"user.created"(payload) { ... }`. Он способен обнаружить различные сигнатуры обработчиков событий:
- Если найдена сигнатура `"user.created"(ctx) { ... }`, то вызов выполнится с контекстом событий.
- Если нет, вызов выполнится со старыми аргументами & 4-й аргумент будет контекст события, например `"user.created"(payload, отправитель, eventName, ctx) {...}`

{% endnote %}

**Обработчик событий на основе контекста & выпуск вложенного события**
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


Подписка на события осуществляется в ['events' свойстве сервиса](services.html#events). Допускается использование масок (`?`, `*`, `**`) в именах событий.

```js
module.exports = {
    events: {
        // Подписка на событие `user.created`
        "user.created"(ctx) {
            console.log("User created:", ctx.params);
        },

        // Подписака на все собтия `user`, например "user.created" или "user.removed"
        "user.*"(ctx) {
            console.log("User event:", ctx.params);
        }
        // Подписка на каждое событие
        // Используется сигнатура устаревшего обработчика событий с контекстом
        "**"(payload, sender, event, ctx) {
            console.log(`Event '${event}' received from ${sender} node:`, payload);
        }
    }
}
```

## Валидация параметров события
Аналогично проверке параметра действия, поддерживается проверка параметров события. Like in action definition, you should define `params` in even definition and the built-in `Validator` validates the parameters in events.

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

| Название       | Type      | Описание                         |
| -------------- | --------- | -------------------------------- |
| `localService` | `Boolean` | True if a local service changed. |

## `$circuit-breaker.opened`
The broker sends this event when the circuit breaker module change its state to `open`.

**Payload**

| Название   | Type     | Описание          |
| ---------- | -------- | ----------------- |
| `nodeID`   | `String` | Node ID           |
| `action`   | `String` | Action name       |
| `failures` | `Number` | Count of failures |


## `$circuit-breaker.half-opened`
The broker sends this event when the circuit breaker module change its state to `half-open`.

**Payload**

| Название | Type     | Описание    |
| -------- | -------- | ----------- |
| `nodeID` | `String` | Node ID     |
| `action` | `String` | Action name |

## `$circuit-breaker.closed`
The broker sends this event when the circuit breaker module change its state to `closed`.

**Payload**

| Название | Type     | Описание    |
| -------- | -------- | ----------- |
| `nodeID` | `String` | Node ID     |
| `action` | `String` | Action name |

## `$node.connected`
The broker sends this event when a node connected or reconnected.

**Payload**

| Название      | Type      | Описание         |
| ------------- | --------- | ---------------- |
| `node`        | `Node`    | Node info object |
| `reconnected` | `Boolean` | Is reconnected?  |

## `$node.updated`
The broker sends this event when it has received an INFO message from a node, (i.e. a service is loaded or destroyed).

**Payload**

| Название | Type   | Описание         |
| -------- | ------ | ---------------- |
| `node`   | `Node` | Node info object |

## `$node.disconnected`
The broker sends this event when a node disconnected (gracefully or unexpectedly).

**Payload**

| Название     | Type      | Описание                                                                            |
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

