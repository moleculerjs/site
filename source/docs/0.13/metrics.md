title: Metrics
---

Moleculer has a built-in metrics feature. It can be enabled within the [broker options](broker.html#Broker-options) with `metrics: true` option.
If it is enabled, the broker emits metrics events at every requests. You can subscribe to these events in your services and transfer them to your Tracer system (ZipKin, OpenTracing...etc).

## Context params & meta
You can customize that the broker puts some `ctx.meta` and `ctx.params` fields to the metrics events.

Define it in the action definition:
```js
module.exports = {
    name: "test",
    actions: {
        import: {
            cache: true,
            metrics: {
                // Don't add `ctx.params` to metrics payload. Default: false
                params: false,
                // Add `ctx.meta` to metrics payload. Default: true
                meta: true
            },
            handler(ctx) {
                // ...
            }
        }
    }
}
```

If the value is `true`, it adds all fields. If `Array`, it adds only the specified fields. If `Function`, it calls with `params` or `meta`and you need to return an `Object`.

### Examples

#### All fields

```js
// Action definition
{
    metrics: { params: true }
}

// Request params
broker.call("user.create", { name: "John", lastname: "Doe" });

// Metrics payload
{
    params: { name: "John", lastname: "Doe" }
}
```

#### Only selected fields

```js
// Action definition
{
    metrics: { 
        params: ["name"],
        meta: ["user"]
    }
}

// Request params
broker.call("user.create", { name: "John", lastname: "Doe" }, { meta: { user } });

// Metrics payload
{
    params: { name: "John" },
    meta: {
        user: {
            // ...
        }
    }
}
```

#### Custom mapping function
```js
// Action definition
{
    metrics: { 
        params: p => {
            return { 
                name: p.name + ' ' + p.lastname
            };
        }
    }
}

// Request params
broker.call("user.create", { name: "John", lastname: "Doe" });

// Metrics payload
{
  params: { name: "John Doe" }
}
```

## Request started event
The broker emits an `metrics.trace.span.start` event when a new request is started.
The payload looks like the following:
```js
{
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: '6858979d-3298-4a7b-813a-ffb417da822b',
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // Is it a remote call
    remoteCall: false,
    // Called action
    action: {
        name: 'users.get'
    },
    // Called service
    service: {
        name: "users"
    },
    // Params
    params: {
        id: 5
    },
    // Meta
    meta: {},
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's requested from a remote node
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: null
}
```

## Request finished event
The broker emits an `metrics.trace.span.finish` event when the call/request is finished.
The payload looks like the following:
```js
{
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: '6858979d-3298-4a7b-813a-ffb417da822b',
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // End time
    endTime: 1493903164731.3684,
    // Duration of request
    duration: 5.368304,
    // Is it a remote call
    remoteCall: false,
    // Is it resolved from cache
    fromCache: false,
    // Called action
    action: {
        name: 'users.get'
    },
    // Called service
    service: {
        name: "users"
    },
    // Params
    params: {
        id: 5
    },
    // Meta
    meta: {},   
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's a remote call
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: null,
    // Error if the call returned with error
    error: {
        name: "ValidationError",
        message: "Invalid incoming parameters"
    }
}
```

{% note info Find more metrics & tracing modules %}
[Check the modules page and find more metrics & tracing modules.](/modules.html#metrics)
{% endnote %}