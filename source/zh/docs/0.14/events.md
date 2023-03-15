标题：事件（Events）
---
中介（Broker）内置事件总线，支持[事件驱动架构](http://microservices.io/patterns/data/event-driven-architecture.html)（Event-driven architecture），可将事件发送到本地和远程服务。

{% note info %}
需要注意的是，这些内建事件是即发即弃（发送出去就没了）的，假设给一个离线的服务发送事件，这个事件发送出去就会丢失。 关于持久化，想要实现耐用且可靠（不会丢失）的事件可以查看[moleculer-channels](https://github.com/moleculerjs/moleculer-channels)。
{% endnote %}

# 均衡事件（Balanced events）
事件监听器被分成了逻辑组（Groups）。 这意味着在每个组中只触发一个监听器。

> **示例：** 假设你拥有两个主要服务。 `用户` （users）& `支付`（payments）。 两个服务都订阅（subscribe）了`user.created`事件。 你启动了3个`用户`服务的实例和2个`支付`服务的实例。 当你发送一个`user.created`事件给这两个服务时，不论是`用户`服务还是`支付`服务，都只会有一个实例会接收到这个事件。

<div align="center">
    <img src="assets/balanced-events.gif" alt="Balanced events diagram" />
</div>

组名默认是服务名，但是你可以在服务中的事件定义里覆盖它。

**示例**
```js
module.exports = {
    name: "payment",
    events: {
        "order.created": {
            // 用“other”组替代默认的服务名“payment”组
            group: "other",
            handler(ctx) {
                console.log("Payload:", ctx.params);
                console.log("Sender:", ctx.nodeID);
                console.log("Metadata:", ctx.meta);
                console.log("被调用的事件名:", ctx.eventName);
            }
        }
    }
}
```

## 发送均衡事件
你可以使用`broker.emit` 方法发送均衡事件。 第一个参数是事件名，第二个参数是要发送的数据。 _如果要发送多个数据，可以把它们放进一个`Object`（对象）里。_

```js
// `user` 会被序列化成字符串后再传过去。
broker.emit("user.created", user);
```

指定接收事件的组或服务：
```js
// 只有`mail` 和 `payments` 服务能接收这个事件。
broker.emit("user.created", user, ["mail", "payments"]);
```

# 广播事件（Broadcast event）
与均衡事件不同的是，广播事件会发送到所有可以用的本地或者远程服务。 这些服务的每个实例都会接收到这个广播事件。

<div align="center">
    <img src="assets/broadcast-events.gif" alt="Broadcast events diagram" />
</div>

你可以使用`broker.broadcast`方法去发送一个广播事件。
```js
broker.broadcast("config.changed", config);
```

指定接收事件的组或服务：
```js
// 发送给 "mail" 服务的所有实例。
broker.broadcast("user.created", { user }, "mail");

// 发送给"user" 和 "purchase" 服务的所有实例。
broker.broadcast("user.created", { user }, ["user", "purchase"]);
```

## 本地广播事件
你可以使用`broker.broadcastLocal`方法将广播事件只发送给本地的所有服务。
```js
broker.broadcastLocal("config.changed", config);
```

# 订阅事件

`v0.14`版本支持基于上下文（Context）的事件处理器（Event handlers）。 如果你想在使用事件驱动架构的时候追踪你的事件，事件上下文会非常有用。 你要是熟悉[行为上下文](context.html)（Action Context）你会觉得很容易上手。 事件上下文和行为上下文非常相似，除了一些只有事件具有的相关属性（Properties）。 [Check the complete list of properties](context.html)

{% note info Legacy event handlers %}

You don't have to rewrite all existing event handlers as Moleculer still supports legacy signature `"user.created"(payload) { ... }`. It is capable to detect different signatures of event handlers:
- If it finds that the signature is `"user.created"(ctx) { ... }`, it will call it with Event Context.
- If not, it will call with old arguments & the 4th argument will be the Event Context, like `"user.created"(payload, sender, eventName, ctx) {...}`
- You can also force the usage of the new signature by setting `context: true` in the event declaration

{% endnote %}

**Context-based event handler & emit a nested event**
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
        },

        "user.removed": {
            // Force to use context based signature
            context: true,
            handler(other) {
                console.log(`${this.broker.nodeID}:${this.fullName}: Event '${other.eventName}' received. Payload:`, other.params, other.meta);
            }
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
Similar to action parameter validation, the event parameter validation is supported. Like in action definition, you should define `params` in event definition and the built-in `Validator` validates the parameters in events.

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

| Name           | Type      | 说明                               |
| -------------- | --------- | -------------------------------- |
| `localService` | `Boolean` | True if a local service changed. |

## `$circuit-breaker.opened`
The broker sends this event when the circuit breaker module change its state to `open`.

**Payload**

| 名称         | 类型       | 说明                |
| ---------- | -------- | ----------------- |
| `nodeID`   | `String` | Node ID           |
| `action`   | `String` | Action name       |
| `failures` | `Number` | Count of failures |


## `$circuit-breaker.half-opened`
The broker sends this event when the circuit breaker module change its state to `half-open`.

**Payload**

| 名称       | 类型       | 描述          |
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

| Name          | Type      | 描述               |
| ------------- | --------- | ---------------- |
| `node`        | `节点`      | Node info object |
| `reconnected` | `Boolean` | Is reconnected?  |

## `$node.updated`
The broker sends this event when it has received an INFO message from a node, (i.e. a service is loaded or destroyed).

**Payload**

| 名字     | Type | 描述               |
| ------ | ---- | ---------------- |
| `node` | `节点` | Node info object |

## `$node.disconnected`
The broker sends this event when a node disconnected (gracefully or unexpectedly).

**Payload**

| 名字           | Type      | 描述                                                                                  |
| ------------ | --------- | ----------------------------------------------------------------------------------- |
| `node`       | `节点`      | Node info object                                                                    |
| `unexpected` | `Boolean` | `true` - Not received heartbeat, `false` - Received `DISCONNECT` message from node. |

## `$broker.started`
The broker sends this event once `broker.start()` is called and all local services are started.

## `$broker.stopped`
The broker sends this event once `broker.stop()` is called and all local services are stopped.

## `$transporter.connected`
The transporter sends this event once the transporter is connected.

## `$transporter.disconnected`
The transporter sends this event once the transporter is disconnected.

## `$broker.error`
The broker emits this event when an error occurs in the [broker](broker.html). **Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "broker" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$transit.error`
The broker emits this event when an error occurs in the transit module. **Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$transporter.error`
The broker emits this event when an error occurs in the [transporter](networking.html#Transporters) module. **Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$cacher.error`
The broker emits this event when an error occurs in the [cacher](caching.html) module. **Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$discoverer.error`
The broker emits this event when an error occurs in the [discoverer](registry.html) module. **Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```


