title: Tracing
---
## Tracing Exporters

The tracing module supports several exporters, custom tracing spans and integration with instrumentation libraries (like [`dd-trace`](https://github.com/DataDog/dd-trace-js)). Set `tracing: true` in broker's options to enable tracing

**Enable tracing**
```js
const broker = new ServiceBroker({
    tracing: true
});
```

### Console
This is a debugging exporter which prints full local trace to the console.

{% note warn %}
Console exporter can't follow remote calls, only locals.
{% endnote %}

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Console",
                options: {
                    logger: null,
                    colors: true,
                    width: 100,
                    gaugeWidth: 40
                }
            }
        ]
    }
});
```

### Datadog
Datadog exporter sends tracing data to Datadog server via `dd-trace`. It is able to merge tracing spans of instrumented Node.js modules and Moleculer modules.

<!-- TODO screenshot -->

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Datadog",
                options: {
                    agentUrl: process.env.DD_AGENT_URL || "http://localhost:8126",
                    env: process.env.DD_ENVIRONMENT || null,
                    samplingPriority: "AUTO_KEEP",
                    defaultTags: null,
                    tracerOptions: null,
                }
            }
        ]
    }
});
```
{% note info %}
To use this exporter, install the `dd-trace` module with `npm install dd-trace --save` command.
{% endnote %}


### Event
Event exporter sends Moleculer events (`$tracing.spans`) with tracing data.

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Event",
                options: {
                    eventName: "$tracing.spans",

                    sendStartSpan: false,
                    sendFinishSpan: true,

                    broadcast: false,

                    groups: null,

                    /** @type {Number} Batch send time interval. */
                    interval: 5,

                    spanConverter: null,

                    /** @type {Object?} Default span tags */
                    defaultTags: null

                }
            }
        ]
    }
});
```

### Event (legacy)
Legacy event exporter sends Moleculer events ([`metrics.trace.span.start`](#Legacy-Request-Started-Payload) & [`metrics.trace.span.finish`](#Legacy-Request-Finished-Payload)) at every request. These events are also used to generate metrics in [legacy (`<= v0.13`) metrics solutions](/modules.html#metrics).

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            "EventLegacy"
        ]
    }
});
```

#### Legacy Request Started Payload
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

#### Legacy Request Finished Payload
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

### Jaeger
Jaeger exporter sends tracing spans information to a [Jaeger](https://www.jaegertracing.io) server.

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Jaeger",
                options: {
                    /** @type {String?} HTTP Reporter endpoint. If set, HTTP Reporter will be used. */
			        endpoint: null,
                    /** @type {String} UDP Sender host option. */
                    host: "127.0.0.1",
                    /** @type {Number?} UDP Sender port option. */
                    port: 6832,

                    /** @type {Object?} Sampler configuration. */
                    sampler: {
                        /** @type {String?} Sampler type */
                        type: "Const",

                        /** @type: {Object?} Sampler specific options. */
                        options: {}
                    },

                    /** @type {Object?} Additional options for `Jaeger.Tracer` */
                    tracerOptions: {},

                    /** @type {Object?} Default span tags */
                    defaultTags: null
                }
            }
        ]
    }
});
```
{% note info %}
To use this exporter, install the `jaeger-client` module with `npm install jaeger-client --save` command.
{% endnote %}


### Zipkin
Zipkin exporter sends tracing spans information to a [Zipkin](https://zipkin.apache.org/) server.

```js
const broker = new ServiceBroker({
    tracing: {
        enabled: true,
        exporter: [
            {
                type: "Zipkin",
                options: {
                    /** @type {String} Base URL for Zipkin server. */
                    baseURL: "http://localhost:9411",

                    /** @type {Number} Batch send time interval. */
                    interval: 5,

                    /** @type {Object} Additional payload options. */
                    payloadOptions: {

                        /** @type {Boolean} Set `debug` property in v2 payload. */
                        debug: false,

                        /** @type {Boolean} Set `shared` property in v2 payload. */
                        shared: false
                    },

                    /** @type {Object?} Default span tags */
                    defaultTags: null
                }
            }
        ]
    }
});
```

## Customizing
### Multiple Spans per Action
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        async find(ctx) {
            const span1 = ctx.startSpan("get data from DB", {
                tags: {
                    ...ctx.params
                }
            }); 
            const data = await this.getDataFromDB(ctx.params);
            span1.finish();

            const span2 = ctx.startSpan("populating");
            const res = await this.populate(data);
            span2.finish();

            return res;
        }
    }
};
```

### Adding Context Values
You can customize what context `params` or `meta` values are added to span tags.

**Default**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                // Add all params without meta
                tags: {
                    params: true,
                    meta: false,
            },
            async handler(ctx) {
                // ...
            }
        }
    }
});
```


 **Custom params example**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                // Add `ctx.params.id` and `ctx.meta.loggedIn.username` values
                // to tracing span tags.
                tags: {
                    params: ["id"],
                    meta: ["loggedIn.username"],
            },
            async handler(ctx) {
                // ...
            }
        }
    }
});
```

**Example with custom function**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                tags: ctx => {
                    return {
                        params: ctx.params,
                        meta: ctx.meta,
                        custom: {
                            a: 5
                        }
                    };
                }
            },
            async handler(ctx) {
                // ...
            }
        }
    }
});
```