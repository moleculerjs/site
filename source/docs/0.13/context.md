title: Context
---
When you call an action, the broker creates a `Context` instance which contains all request information and passes it to the action handler as a single argument.

**Available properties & methods of `Context`:**

| Name | Type |  Description |
| ------- | ----- | ------- |
| `ctx.id` | `String` | Context ID |
| `ctx.broker` | `ServiceBroker` | Instance of the broker. |
| `ctx.action` | `Object` | Instance of action definition. |
| `ctx.nodeID` | `String` | Node ID. |
| `ctx.requestID` | `String` | Request ID. If you make nested-calls, it will be the same ID. |
| `ctx.parentID` | `String` | Parent context ID (in nested-calls). |
| `ctx.params` | `Any` | Request params. *Second argument from `broker.call`.* |
| `ctx.meta` | `Any` | Request metadata. *It will be also transferred to nested-calls.* |
| `ctx.callerNodeID` | `String` | Caller Node ID if it is requested from a remote node. |
| `ctx.level` | `Number` | Request level (in nested-calls). The first level is `1`. |
| `ctx.call()` | `Function` | You can make a sub-call. Same arguments like `broker.call` |
| `ctx.emit()` | `Function` | Emit an event, like `broker.emit` |
| `ctx.broadcast` | `Function` | Broadcast an event, like `broker.broadcast` |
