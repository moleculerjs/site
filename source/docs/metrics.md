title: Metrics
---
Moleculer has a metrics feature. You can enable it within the [broker options](broker.html#Constructor-options) with `metrics: true` option.
If enabled, the broker emits metrics events with every `broker.call`. You can catch these events in your services and transfer to your Tracer system (ZipKin, OpenTracing...etc).

## Request started event
The broker emits an `metrics.trace.span.start` event when a new call/request is started.
The payload looks like the following:
```js
{ 
    // Context ID
    id: '4563b09f-04cf-4891-bc2c-f26f80c3f91e',
    // Request ID
    requestID: null,
    // Level of call
    level: 1,
    // Start time
    startTime: 1493903164726,
    // Is it a remote call
    remoteCall: false,
    // Called action
    action: { 
        name: 'users.get' 
    }
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's requested from a remote node
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: '123456'
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
    requestID: null,
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
    }
    // Node ID
    nodeID: "node-1",
    // Caller nodeID if it's a remote call
    callerNodeID: "node-2",
    // Parent context ID if it is a sub-call
    parentID: '123456'

    // Error if the call returned with error
    error: {
        name: "ValidationError",
        message: "Invalid incoming parameters"
    }
}
```

## Circuit-breaker events

### `metrics.circuit-breaker.open`
The broker sends this event when the circuit breaker module changed its state to `open`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |
| `failures` | `Number` | Count of failures |


### `metrics.circuit-breaker.half-open`
The broker sends this event when the circuit breaker module changed its state to `half-open`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |

### `metrics.circuit-breaker.close`
The broker sends this event when the circuit breaker module changed its state to `closed`.

**Payload**

| Name | Type | Description |
| ---- | ---- | ----------- |
| `nodeID` | `String` | Node ID |
| `action` | `String` | Action name |
