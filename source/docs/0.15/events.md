title: Events
---
Broker has a built-in event bus to support [Event-driven architecture](http://microservices.io/patterns/data/event-driven-architecture.html) and to send events to local and remote services. 

{% note info %}
Please note that built-in events are fire-and-forget meaning that if the service is offline, the event will be lost. For persistent, durable and reliable events please check [moleculer-channels](https://github.com/moleculerjs/moleculer-channels).
{% endnote %}

# Balanced events
Even listeners are arrange into logical groups. It ensures that only one listener from each designated group receives an event. This approach is useful for scenarios where you want to distribute event handling among services while avoiding duplicate processing within a group.

Understanding Groups:

- Services are automatically assigned groups based on their names.
- You can override the default group assignment by specifying a group property within the event definition of a service. (See example below)

> **Example:** Consider two services: `users` and `payments`. Both subscribe to the `user.created` event. If you have three `users` instances and two `payments` instances, emitting `user.created` will trigger the event handler in exactly one `users` service and one `payments` service.

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

**Benefits of Balanced Events**:

- **Efficient Distribution**: Events are distributed fairly across service groups, preventing overloading of individual instances.
- **Scalability**: As you add or remove service instances, balanced events automatically adjust to maintain balanced distribution.
- **Coordination**: When multiple services need to react to an event but only specific actions are required within each group, balanced events promote coordination.


{% note Pro Tips: %}
- **Event Naming Conventions**: Establish clear naming conventions (e.g., snake_case, PascalCase) for events to enhance readability and maintainability.
- **Event Payload Structure**: Define a consistent structure for event payloads to ensure subscribers understand the received data.
- **Error Handling**: Implement error handling mechanisms for event publishing and handling to ensure robustness.
{% endnote %}

## Emit balanced events
Send balanced events with `broker.emit` function. 

**Using `broker.emit` for Balanced Events**:
- **Event Name**: The first parameter to `broker.emit` is the event name (string). This name should clearly describe the event and its purpose.
- **Payload (Optional)**: The second parameter is the event payload, an object containing data relevant to the event. If you don't need to send any data, you can omit this parameter.
- **Target Groups (Optional)**: By default, the event is delivered to the group named after the service that emits it. However, you can specify which groups should receive the event using the groups property within a third optional object. This object takes an array of service group names as its value.


```js
// The `user` will be serialized to transportation.
broker.emit("user.created", user);
```

Specify which groups/services shall receive the event:
```js
// Only the `mail` & `payments` services receives it
broker.emit("user.created", user, { groups: ["mail", "payments"] });
```

**Key Points**:

- Balanced events are ideal for distributing tasks among services while avoiding redundant processing within groups.
- Use clear and descriptive event names for better communication within your application.
- The `groups` option allows you to target specific service groups for event delivery.


# Broadcast event
The broadcast event is sent to all available local & remote services. It is not balanced, all service instances will receive it.
This approach is useful for situations where all services need to be informed about a specific event, invalidating caches, or updating configurations.

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


## Balanced vs Broadcast events
**Balanced Events**
- Purpose: Targeted communication for distributing tasks or messages fairly across designated service groups.
- Delivery: Delivered to only one listener from each designated group, preventing duplicate processing.
- Targeting: Services belong to groups by default (service name), or can be overridden by specifying a group property in the event definition.
Scalability: Automatically adjusts to maintain balanced distribution within groups as service instances are added or removed.

**Usage**:
- Distributing tasks like sending welcome emails to new users (one `users` service instance handles it).
- Handling events requiring specific processing within different groups (e.g., `payments` group processes new orders).

**Broadcast Events**
- Purpose: System-wide notification for informing all services about a specific event.
- Delivery: Delivered to all available local and remote service instances, regardless of group affiliation.
- Targeting (Optional): Can optionally target specific service names within an array, but generally discouraged for maintainability.

**Usage**:
- Notifying all services about configuration changes (e.g., config.updated event triggers service restarts).
- Broadcasting system-wide events like server maintenance windows.

**Key Differences**

- Delivery: Balanced events target specific groups, broadcasts reach all services.
- Redundancy: Balanced events prevent duplicate processing within groups, broadcasts might lead to redundant data processing.
- Scalability: Balanced events scale well with service instances, broadcasts can overload services if used frequently.

# Subscribe to events

Event context is useful if you are using event-driven architecture and want to trace your events. If you are familiar with [Action Context](context.html) you will feel at home. Event context is very similar to Action Context, except for a few new event related properties. [Check the complete list of properties](context.html). Overall, the event to allows you to trace events, understand their origin, and make informed decisions within your event handlers

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

## Wildcard event subscription
Subscribe to events in ['events' property of services](services.html#events). It is possible to subscribe to multiple events with a single handler using wildcards. 

Different wildcards are available for event name matching:
- `?`: Matches a single character within the event name.
- `*`: Matches any sequence of characters within the event name.
- `**`: Matches any event name (use with caution).

```js
module.exports = {
    events: {
        // Subscribe to `user.created` event
        "user.created"(ctx) {
            console.log("User created:", ctx.params);
        },

        // Subscribe to events that start with "user." have 3 any characters and end with "ated"
        "user.???ated"(ctx) {
            console.log("User event:", ctx.params);
        },


        // Subscribe to all `user` events, e.g. "user.created", or "user.removed"
        "user.*"(ctx) {
            console.log("User event:", ctx.params);
        }
        // Subscribe to every events
        // Legacy event handler signature with context
        "**"(ctx) {
            console.log(`Event '${event}' received from ${sender} node:`, payload);
        }
    }
}
```

## Event parameter validation
Similar to action parameter validation, event parameter validation allows you to define expected data structures for events, ensuring that the data received by event handlers is valid and consistent. By defining a validation schema for event parameters, you can enforce data integrity and prevent unexpected behavior within your event handlers.

Like in action definition, you should define `params` in event definition and the built-in `Validator` validates the parameters in events.

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    events: {
        "send.mail": {
            // Validation schema
            params: {
                from: "string|optional",  // Optional string parameter
                to: "email", // Required email parameter
                subject: "string" // Required string parameter
            },
            handler(ctx) {
                this.logger.info("Event received, parameters OK!", ctx.params);
                // ... send email logic
            }
        }
    }
};
```

### Handling Validation Errors:

The validation errors are not sent back to the caller, they are logged and you can catch them with the [global error handler](broker.html#Global-error-handler).


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

## `$broker.error`

Effective error handling is vital for maintaining the reliability of your MoleculerJS application. Moleculer emits various error events to alert you to issues during operation:



The broker emits this event when an error occurs in the [broker](broker.html) itself.
**Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "broker" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$transit.error`
The broker emits this event when an error occurs in the transit module, ie, during the message transportation between nodes.
**Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$transporter.error`
The broker emits this event when an error occurs in the [transporter](networking.html#Transporters) module. This signals a network error.
**Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$cacher.error`
The broker emits this event when an error occurs in the [cacher](caching.html) module.
**Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```

## `$discoverer.error`
The broker emits this event when an error occurs in the [discoverer](registry.html) module.
**Event payload**
```js
{
  "error": "<the error object with all properties>"
  "module": "transit" // Name of the module where the error happened
  "type": "error-type" // Type of error. Full of error types: https://github.com/moleculerjs/moleculer/blob/master/src/constants.js
}
```


Each event provides detailed information about the error, allowing you to diagnose and address issues promptly. Implementing error event listeners is recommended as it allows you to ensure the stability of your microservices application.
