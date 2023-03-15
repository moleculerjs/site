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

`v0.14`版本支持基于上下文（Context）的事件处理器（Event handlers）。 如果你想在使用事件驱动架构的时候追踪你的事件，事件上下文会非常有用。 你要是熟悉[行为上下文](context.html)（Action Context）你会觉得很容易上手。 事件上下文和行为上下文非常相似，除了一些只有事件具有的相关属性（Properties）。 [查看事件属性的完整列表](context.html)

{% note info Legacy event handlers %} 过时的事件处理器

你没必要去重写所有已有的事件处理器，因为Moleculer仍然支持过时的事件处理写法`"user.created"(payload) { ... }`. Moleculer 能够识别事件处理器不同的写法：
- 如果它发现是`"user.created"(ctx) { ... }`这样的写法, 它将会使用事件上下文调用它。
- 相反，如果是`"user.created"(payload, sender, eventName, ctx) {...}`这样的写法，它会使用旧的参数形式调用它，旧的参数里第4个参数会变成事件上下文。
- 你也可以在事件声明的地方，通过设置`context: true`强制使用新的写法。

{% endnote %}

**基于上下文的事件处理器& 发送一个嵌套事件**
```js
module.exports = {
    name: "accounts",
    events: {
        "user.created"(ctx) {
            console.log("Payload:", ctx.params);
            console.log("Sender:", ctx.nodeID);
            console.log("Metadata:", ctx.meta);
            console.log("被调用的事件名:", ctx.eventName);

            ctx.emit("accounts.created", { user: ctx.params.user });
        },

        "user.removed": {
            // 强制使用基于上下文的写法
            context: true,
            handler(other) {
                console.log(`${this.broker.nodeID}:${this.fullName}: Event '${other.eventName}' received. Payload:`, other.params, other.meta);
            }
        }
    }
};
```


在[服务的'events'属性](services.html#events)里订阅事件。 事件名可以使用通配符(`?`, `*`, `**`)。

```js
module.exports = {
    events: {
        // 订阅 `user.created` 事件
        "user.created"(ctx) {
            console.log("User created:", ctx.params);
        },

        // 订阅所有`user`事件，例如"user.created"或者"user.removed"
        "user.*"(ctx) {
            console.log("User event:", ctx.params);
        }
        // 订阅所有事件
        // 带有上下文的过时写法
        "**"(payload, sender, event, ctx) {
            console.log(`Event '${event}' received from ${sender} node:`, payload);
        }
    }
}
```

## 事件参数验证（Event parameter validation）
与操作参数验证相似，事件也支持参数验证。 如同行为定义一样，你应该在事件定义中定义`params`，并且通过内置的`Validator`在事件中验证参数。

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    events: {
        "send.mail": {
            // 验证 schema
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
> 验证错误不会发送给调用者，它们会被写进日志，或者你也可以通过[全局错误处理器](broker.html#Global-error-handler)（global error handler）捕获这些错误。

# 内置事件（Internal events）
中介可以广播一些内置事件。 这些内置事件都以`$`前缀开头。

## `$services.changed`
中介会在本地或远程节点销毁和加载服务的时候发送这个事件。

**参数**

| Name           | Type      | 说明               |
| -------------- | --------- | ---------------- |
| `localService` | `Boolean` | 当本地服务改变的时候为True。 |

## `$circuit-breaker.opened`
中介会在熔断器（Circuit Breaker）模块状态变成`open`的时候发送这个事件。

**参数**

| 名称         | 类型       | 说明        |
| ---------- | -------- | --------- |
| `nodeID`   | `String` | Node ID   |
| `action`   | `String` | Action 名称 |
| `failures` | `Number` | 失败次数      |


## `$circuit-breaker.half-opened`
中介会在熔断器（Circuit Breaker）模块状态变成`half-open`的时候发送这个事件。

**参数**

| 名称       | 类型       | 描述        |
| -------- | -------- | --------- |
| `nodeID` | `String` | Node ID   |
| `action` | `String` | Action 名称 |

## `$circuit-breaker.closed`
中介会在熔断器（Circuit Breaker）模块状态变成`closed`的时候发送这个事件。

**参数**

| Name     | Type     | Description |
| -------- | -------- | ----------- |
| `nodeID` | `String` | Node ID     |
| `action` | `String` | Action 名称   |

## `$node.connected`
中介会在节点连接成功和重连成功的时候发送这个事件。

**参数**

| Name          | Type      | 描述          |
| ------------- | --------- | ----------- |
| `node`        | `节点`      | 节点信息的Object |
| `reconnected` | `Boolean` | 是不是重连？      |

## `$node.updated`
当经纪收到来自节点的 INFO 消息时(即服务已加载或销毁)，它会发送此事件。

**参数**

| 名字     | Type | 描述          |
| ------ | ---- | ----------- |
| `node` | `节点` | 节点信息的Object |

## `$node.disconnected`
中介会在节点断开连接时（不论正常或者异常）发送这个事件。

**参数**

| 名字           | Type      | 描述                                                               |
| ------------ | --------- | ---------------------------------------------------------------- |
| `node`       | `节点`      | 节点信息的Object                                                      |
| `unexpected` | `Boolean` | `true` - 没有接收到心跳（Heartbeat）, `false` - 接收到从节点发出的`DISCONNECT` 消息。 |

## `$broker.started`
中介会在所有本地服务启动（started）并且调用`broker.start()`时，只发送一次这个事件。

## `$broker.stopped`
中介会在所有本地服务停止（stopped）并且调用`broker.stop()`时，只发送一次这个事件。

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


