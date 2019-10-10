title: Context
---

When you call an action or emit an event, the broker creates a `Context` instance which contains all request information and passes it to the action/event handler as a single argument.

## Properties of Context

| Name              | Type                  | Description                                                      |
| ----------------- | --------------------- | ---------------------------------------------------------------- |
| `ctx.id`          | `String`              | Context ID                                                       |
| `ctx.broker`      | `ServiceBroker`       | Instance of the broker.                                          |
| `ctx.nodeID`      | `String`              | The caller or target Node ID.                                    |
| `ctx.action`      | `Object`              | Instance of action definition.                                   |
| `ctx.event`       | `Object`              | Instance of event definition.                                    |
| `ctx.eventName`   | `Object`              | The emitted event name.                                          |
| `ctx.eventType`   | `String`              | Type of event ("emit" or "broadcast").                           |
| `ctx.eventGroups` | `Array<String>` | Groups of event.                                                 |
| `ctx.caller`      | `String`              | Service full name of the caller. E.g.: `v3.myService`            |
| `ctx.requestID`   | `String`              | Request ID. If you make nested-calls, it will be the same ID.    |
| `ctx.parentID`    | `String`              | Parent context ID (in nested-calls).                             |
| `ctx.params`      | `Any`                 | Request params. *Second argument from `broker.call`.*            |
| `ctx.meta`        | `Any`                 | Request metadata. *It will be also transferred to nested-calls.* |
| `ctx.locals`      | `Any`                 | Local data.                                                      |
| `ctx.level`       | `Number`              | Request level (in nested-calls). The first level is `1`.         |
| `ctx.span`        | `Span`                | Current active span.                                             |

## Methods of Context

| Название                    | Response  | Описание                                               |
| --------------------------- | --------- | ------------------------------------------------------ |
| `ctx.call()`                | `Promise` | Make nested-call. Same arguments like in `broker.call` |
| `ctx.emit()`                | `void`    | Emit an event, same as `broker.emit`                   |
| `ctx.broadcast()`           | `void`    | Broadcast an event, same as `broker.broadcast`         |
| `ctx.startSpan(name, opts)` | `Span`    | Creates a new child span.                              |
| `ctx.finishSpan(span)`      | `void`    | Finishes a span.                                       |
| `ctx.toJSON()`              | `Object`  | Convert `Context` to a printable JSON.                 |

## Context tracking
If you want graceful service shutdowns, enable the Context tracking feature in broker options. If you enable it, all services will wait for all running contexts before shutdown. A timeout value can be defined with `shutdownTimeout` broker option. The default values is `5` seconds.

**Enable context tracking & change the timeout value**
```js
const broker = new ServiceBroker({
    nodeID: "node-1",
    tracking: {
        enabled: true,
        shutdownTimeout: 10 * 1000
    }
});
```

> The shutdown timeout can be overwritten by `$shutdownTimeout` property in service settings.

**Disable tracking in calling option**

```js
await broker.call("posts.find", {}, { tracking: false });
```