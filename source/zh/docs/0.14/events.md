title: Events
---
Broker has a built-in event bus to support [Event-driven architecture](http://microservices.io/patterns/data/event-driven-architecture.html) and to send events to local and remote services.

{% note info %}
Please note that built-in events are fire-and-forget meaning that if the service is offline, the event will be lost. For persistent, durable and reliable events please check [moleculer-channels](https://github.com/moleculerjs/moleculer-channels).
{% endnote %}

# Balanced events
The event listeners are arranged to logical groups. It means that only one listener is triggered in every group.

> **Example:** you have 2 main services: `users` & `payments`. Both subscribe to the `user.created` event. You start 3 instances of `users` service and 2 instances of `payments` service. When you emit the `user.created` event, only one `users` and one `payments` service instance will receive the event.

<div align="center">
    <img src="assets/balanced-events.gif" alt="Balanced events diagram" />
</div>

The group name comes from the service name, but it can be overwritten in event definition in services.

**示例**
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
Send balanced events with `broker.emit` function. The first parameter is the name of the event, the second parameter is the payload. _To send multiple values, wrap them into an `Object`._

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

The `v0.14` version supports Context-based event handlers. Event context is useful if you are using event-driven architecture and want to trace your events. If you are familiar with [Action Context](context.html) you will feel at home. The Event Context is very similar to Action Context, except for a few new event related properties. [Check the complete list of properties](context.html)

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


