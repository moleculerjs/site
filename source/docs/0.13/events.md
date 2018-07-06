title: Events
---
Broker has a built-in event bus to support [Event-driven architecture](http://microservices.io/patterns/data/event-driven-architecture.html) and to send events to local and remote services. 

# Balanced events
The event listeners are arranged to logical groups. It means that only one listener is triggered in every group.

> **Example:** you have 2 main services: `users` & `payments`. Both subscribe to the `user.created` event. You start 3 instances from `users` service and 2 instances from `payments` service. When you emit the `user.created` event, only one `users` and one `payments` service instance will receive the event.

<div align="center">
![Balanced events diagram](assets/balanced-events.gif)
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
            handler(payload) {
                // ...
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

Specify which groups/services receive the event:
```js
// Only the `mail` & `payments` services receives it
broker.emit("user.created", user, ["mail", "payments"]);
```

# Broadcast event
The broadcast event is sent to all available local & remote services. It is not balanced, all service instances receive it.

<div align="center">
![Broadcast events diagram](assets/broadcast-events.gif)
</div>

Send broadcast events with `broker.broadcast` method.
```js
broker.broadcast("config.changed", config);
```

Specify which groups/services receive the event:
```js
// Send to all "mail" service instances
broker.broadcast("user.created", { user }, "mail");

// Send to all "user" & "purchase" service instances.
broker.broadcast("user.created", { user }, ["user", "purchase"]);
```

## Local broadcast event
Send broadcast events to only all local services with `broker.broadcastLocal` method.
```js
broker.broadcastLocal("config.changed", config);
```

### Subscribe to events
Subscribe to events in ['events' property of services](services.html#events). Use of Wildcards (`?`, `*`, `**`) are available in event names.

```js
module.exports = {
    events: {
        // Subscribe to `user.created` event
        "user.created"(user) {
            console.log("User created:", user));
        },

        // Subscribe to all `user` events
        "user.*"(user) {
            console.log("User event:", user));
        }

        // Subscribe to all internal events
        "$**"(payload, sender, event) {
            console.log(`Event '${event}' received from ${sender} node:`, payload));
        }
    }
}
```

## Internal events
The broker broadcasts some internal events. These events always starts with `$` prefix.

### `$services.changed`
The broker sends this event if the local node or a remote node loads or destroys services.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `localService ` | `Boolean` | True if a local service changed. |

### `$circuit-breaker.opened`
The broker sends this event when the circuit breaker module change its state to `open`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |
| `failures` | `Number` | Count of failures |


### `$circuit-breaker.half-opened`
The broker sends this event when the circuit breaker module change its state to `half-open`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |

### `$circuit-breaker.closed`
The broker sends this event when the circuit breaker module change its state to `closed`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |

### `$node.connected`
The broker sends this event when a node connected or reconnected.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |
| `reconnected` | `Boolean` | Is reconnected? |

### `$node.updated`
The broker sends this event when it has received an INFO message from a node, (i.e. a service is loaded or destroyed).

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |

### `$node.disconnected`
The broker sends this event when a node disconnected (gracefully or unexpectedly).

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `node` | `Node` | Node info object |
| `unexpected` | `Boolean` | `true` - Not received heartbeat, `false` - Received `DISCONNECT` message from node. |

### `$broker.started`
The broker sends this event once `broker.start()` is called and all local services are started.

### `$broker.stopped`
The broker sends this event once `broker.stop()` is called and all local services are stopped.

### `$transporter.connected`
The transporter sends this event once the transporter is connected.

### `$transporter.disconnected`
The transporter sends this event once the transporter is disconnected.

