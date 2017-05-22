title: Context
---
When you call an action, the broker creates a `Context` instance which contains all request informations and pass to the action handler as argument.

**Available properties & methods of `Context`:**

| Name | Type |  Description |
| ------- | ----- | ------- |
| `ctx.id` | `String` | Context ID |
| `ctx.requestID` | `String` | Request ID. If you make sub-calls in a request, it will be the same ID |
| `ctx.parentID` | `String` | ID of parent context, if it's a sub-call |
| `ctx.broker` | `ServiceBroker` | Instance of broker |
| `ctx.action` | `Object` | Instance of action |
| `ctx.params` | `Any` | Params of request. *Second argument of `broker.call`* |
| `ctx.meta` | `Any` | Metadata of request. *It will be transferred in sub-calls* |
| `ctx.nodeID` | `String` | Node ID |
| `ctx.logger` | `Logger` | Logger module |
| `ctx.level` | `Number` | Level of request |
| `ctx.call()` | `Function` | You can make a sub-call. Same arguments like `broker.call` |
| `ctx.emit()` | `Function` | Emit an event, like `broker.emit` |
