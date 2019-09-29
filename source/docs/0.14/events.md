title: Events
---
Broker has a built-in event bus to support [Event-driven architecture](http://microservices.io/patterns/data/event-driven-architecture.html) and to send events to local and remote services. 

# Balanced events
The event listeners are arranged to logical groups. It means that only one listener is triggered in every group.

> **Example:** you have 2 main services: `users` & `payments`. Both subscribe to the `user.created` event. You start 3 instances of `users` service and 2 instances of `payments` service. When you emit the `user.created` event, only one `users` and one `payments` service instance will receive the event.

<div align="center">
    <img src="assets/balanced-events.gif" alt="Balanced events diagram" />
</div>

The group name comes from the service name, but it can be overwritten in event definition in services.

**Example**
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

## Emit balanced events
Send balanced events with `broker.emit` function. The first parameter is the name of the event, the second parameter is the payload. 
_To send multiple values, wrap them into an `Object`._

```js
// The `user` will be serialized to transportation.
broker.emit("user.created", user);
```

Specify which groups/services shall receive the event:
```js
// Only the `mail` & `payments` services receives it
broker.emit("user.created", user, ["mail", "payments"]);
```

# Broadcast event
The broadcast event is sent to all available local & remote services. It is not balanced, all service instances will receive it.

<div align="center">
    <img src="assets/broadcast-events.gif" alt="Broadcast events diagram" />
</div>

Send broadcast events with `broker.broadcast` method.
```js
broker.broadcast("config.changed", config);
```

Specify which groups/services shall receive the event:
```js
// Send to all "mail" service instances
broker.broadcast("user.created", { user }, "mail");

// Send to all "user" & "purchase" service instances.
broker.broadcast("user.created", { user }, ["user", "purchase"]);
```

## Local broadcast event
Send broadcast events only to all local services with `broker.broadcastLocal` method.
```js
broker.broadcastLocal("config.changed", config);
```

# Subscribe to events

The `v0.14` version supports Context-based event handlers. Event context is useful if you are using event-driven architecture and want to trace your events. If you are familiar with [Action Context](actions.html#Context) you will feel at home. The Event Context is very similar to Action Context, except for a few new event related properties. [Check the complete list of properties](events.html#Context)

{% note info Legacy event handlers %}

You don't have to rewrite all existing event handlers as Moleculer still supports legacy signature `"user.created"(payload) { ... }`. It is capable to detect different signatures of event handlers: 
- If it finds that the signature is `"user.created"(ctx) { ... }`, it will call it with Event Context. 
- If not, it will call with old arguments & the 4th argument will be the Event Context, like `"user.created"(payload, sender, eventName, ctx) {...}`

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

        // Subscribe to all `user` events
        "user.*"(ctx) {
            console.log("User event:", ctx.params);
        }

        // Legacy event handler signature with context
        "$**"(payload, sender, event, ctx) {
            console.log(`Event '${event}' received from ${sender} node:`, payload);
        }
    }
}
```
# Context
When you emit an event, the broker creates a `Context` instance which contains all request information and passes it to the event handler as a single argument.

**Available properties & methods of `Context`:**

| Name | Type |  Description |
| ------- | ----- | ------- |
| `ctx.id` | `String` | Context ID |
| `ctx.broker` | `ServiceBroker` | Instance of the broker. |
| `ctx.event` | `Object` | Instance of event definition. |
| `ctx.nodeID` | `String` | The caller or target Node ID. |
| `ctx.caller` | `String` | Action name of the caller. E.g.: `v3.myService.myAction` |
| `ctx.eventName` | `String` | Name of the event. |
| `ctx.eventType` | `String` | Type of the event (e.g. `emit` or `broadcast`). |
| `ctx.eventGroups` | `Array<String>` | Group of the events that should receive the event. |
| `ctx.params` | `Any` | Request params. *Second argument from `broker.call`.* |
| `ctx.meta` | `Any` | Request metadata. *It will be also transferred to nested-calls.* |
| `ctx.locals` | `Any` | Local data. *It will be also transferred to nested-calls.* |
| `ctx.level` | `Number` | Request level (in nested-calls). The first level is `1`. |
| `ctx.call()` | `Function` | Make nested-calls. Same arguments like in `broker.call` |
| `ctx.emit()` | `Function` | Emit an event, same as `broker.emit` |
| `ctx.broadcast()` | `Function` | Broadcast an event, same as `broker.broadcast` |

## Context tracking
If you want graceful service shutdowns, enable the Context tracking feature in broker options. If you enable it, all services will wait for all running contexts before shutdown. 
A timeout value can be defined with `shutdownTimeout` broker option. The default values is `5` seconds.

**Enable context tracking & change the timeout value.
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
broker.emit("posts.find", {}, { tracking: false });
```

# Internal events
The broker broadcasts some internal events. These events always starts with `$` prefix.

## `$services.changed`
The broker sends this event if the local node or a remote node loads or destroys services.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `localService ` | `Boolean` | True if a local service changed. |

## `$circuit-breaker.opened`
The broker sends this event when the circuit breaker module change its state to `open`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |
| `failures` | `Number` | Count of failures |


## `$circuit-breaker.half-opened`
The broker sends this event when the circuit breaker module change its state to `half-open`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |

## `$circuit-breaker.closed`
The broker sends this event when the circuit breaker module change its state to `closed`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |

## `$node.connected`
The broker sends this event when a node connected or reconnected.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |
| `reconnected` | `Boolean` | Is reconnected? |

## `$node.updated`
The broker sends this event when it has received an INFO message from a node, (i.e. a service is loaded or destroyed).

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |

## `$node.disconnected`
The broker sends this event when a node disconnected (gracefully or unexpectedly).

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |
| `unexpected` | `Boolean` | `true` - Not received heartbeat, `false` - Received `DISCONNECT` message from node. |

## `$broker.started`
The broker sends this event once `broker.start()` is called and all local services are started.

## `$broker.stopped`
The broker sends this event once `broker.stop()` is called and all local services are stopped.

## `$transporter.connected`
The transporter sends this event once the transporter is connected.

## `$transporter.disconnected`
The transporter sends this event once the transporter is disconnected.

