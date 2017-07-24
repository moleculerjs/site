title: Context
---
When you call an action, the broker creates a `Context` instance which contains all request informations and pass it to the action handler as single argument.

**Available properties & methods of `Context`:**

| Name | Type |  Description |
| ------- | ----- | ------- |
| `ctx.id` | `String` | Context ID |
| `ctx.requestID` | `String` | Request ID. If you make sub-calls in a request, it will be the same ID. |
| `ctx.parentID` | `String` | ID of parent context (in case of sub-calls). |
| `ctx.broker` | `ServiceBroker` | Instance of broker. |
| `ctx.action` | `Object` | Instance of action definition. |
| `ctx.params` | `Any` | Params of request. *Second argument from `broker.call`.* |
| `ctx.meta` | `Any` | Metadata of request. *It will be transferred in sub-calls.* |
| `ctx.nodeID` | `String` | Node ID. It can be `null` at local request. |
| `ctx.level` | `Number` | Level of request (in case of sub-calls). First level is `1`. |
| `ctx.call()` | `Function` | You can make a sub-call. Same arguments like `broker.call` |
| `ctx.emit()` | `Function` | Emit an event, like `broker.emit` |
