title: 上下文（Context）
---

当你调用一个action或者发送一个event，broker会创建一个`Context`实例，Context包含了所有请求的信息，并作为一个参数传给action或event handler。

## Context的属性

| Name              | Type                  | 说明                             |
| ----------------- | --------------------- | ------------------------------ |
| `ctx.id`          | `String`              | Context ID                     |
| `ctx.broker`      | `服务管理者`               | Broker实例                       |
| `ctx.nodeID`      | `String`              | 调用者或目标节点的ID。                   |
| `ctx.action`      | `Object`              | Action定义的实例。                   |
| `ctx.event`       | `Object`              | Event定义的实例。                    |
| `ctx.eventName`   | `Object`              | 被发送的事件名。                       |
| `ctx.eventType`   | `String`              | Event类型（"emit" 或 "broadcast"）。 |
| `ctx.eventGroups` | `Array<String>` | Event的分组（Groups）。              |
| `ctx.caller`      | `String`              | 调用者的完整服务名。 例如：`v3.myService`   |
| `ctx.requestID`   | `String`              | 请求 ID。 如果你发起一个嵌套调用，它将是相同的ID。   |
| `ctx.parentID`    | `String`              | 父级 context ID (在嵌套调用时)。        |
| `ctx.params`      | `Any`                 | 请求参数 *来自 `broker.call`的第二个参数。* |
| `ctx.meta`        | `Any`                 | 请求的Metadata。 *它也将被传到嵌套调用中。*    |
| `ctx.locals`      | `Any`                 | 本地数据。                          |
| `ctx.level`       | `Number`              | 请求层级（在嵌套调用时）。 第一层级为`1`.        |
| `ctx.span`        | `Span`                | 当前激活的Span。                     |

## Context的方法

| 名称                          | 响应        | 说明                             |
| --------------------------- | --------- | ------------------------------ |
| `ctx.call()`                | `Promise` | 发起嵌调用。 和`broker.call`参数一致。     |
| `ctx.emit()`                | `void`    | 发送一个Event，同`broker.emit`。      |
| `ctx.broadcast()`           | `void`    | 广播一个Event，同`broker.broadcast`。 |
| `ctx.startSpan(name, opts)` | `Span`    | 创建一个新的子Span。                   |
| `ctx.finishSpan(span)`      | `void`    | 完成一个Span。                      |
| `ctx.toJSON()`              | `Object`  | 将`Context`转换成一个可以打印的JSON对象。    |
| `ctx.copy()`                |  `this`   | 复制并创建一个`Context`实例。            |

## Context 追踪
如果你想正常关闭一个服务，可以在broker的选项里启用上下文追踪（Context Tracking）功能。 如果你启用了它，所有服务将在关闭前等待所有正在运行的Context。 你也可以在Broker选项里设置一个超时参数`shutdownTimeout`， 默认值是`5`秒。

**启用context tracking并修改超时时间。**
```js
const broker = new ServiceBroker({
    nodeID: "node-1",
    tracking: {
        enabled: true,
        shutdownTimeout: 10 * 1000
    }
});
```

> 这里的`shutdownTimeout`时间可以被服务设置中的<0>$shutdownTimeout</0>属性覆盖。

**在调用选项中禁用追踪（Tracking）**

```js
await broker.call("posts.find", {}, { tracking: false });
```