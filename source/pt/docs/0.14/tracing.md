title: Tracing
---
Moleculer has a built-in tracing module that collects tracing information inside a Moleculer application. Moreover, you can easily create your custom tracing spans. There are several built-in tracing exporter like [Zipkin](https://zipkin.apache.org/), [Jaeger](https://www.jaegertracing.io/), [Datadog](https://www.datadoghq.com/), etc.

**Enable tracing**
```js
// moleculer.config.js
module.exports = {
    tracing: true
};
```

**Enable tracing with options**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: "Console",
        events: true,
        stackTrace: true
    }
};
```

## Options

| Name          | Type                              | Default                                       | Description                                                                                             |
| ------------- | --------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `enabled`     | `Boolean`                         | `false`                                       | Enable tracing feature.                                                                                 |
| `exporter`    | `Object` or `Array<Object>` | `null`                                        | Tracing exporter configuration. [More info](#Tracing-Exporters)                                         |
| `sampling`    | `Object`                          |                                               | Sampling settings. [More info](#Sampling)                                                               |
| `actions`     | `Boolean`                         | `true`                                        | Tracing the service actions.                                                                            |
| `events`      | `Boolean`                         | `false`                                       | Tracing the service events.                                                                             |
| `errorFields` | `Array<String>`             | `["name", "message", "code", "type", "data"]` | Error object fields which are added into span tags.                                                     |
| `stackTrace`  | `Boolean`                         | `false`                                       | Add stack trace info into span tags in case of error.                                                   |
| `tags`        | `Object`                          | `null`                                        | Add custom span tags to all actions and events spans. [Mais informações](#Global-action-and-event-tags) |
| `defaultTags` | `Objeto`                          | `null`                                        | Default tags. It will be added to all spans.                                                            |

## Sampling
The Moleculer Tracer supports several sampling methods. The determination whether to sample or not is made on the root span and propagated to all child spans. This ensures that a complete trace is always exported regardless of the sample method or the rate selected.

### Constant sampling
This sampling method uses a constant sampling rate value from `0` to `1`. The `1` means all spans will be sampled, the `0` means none of them.

**Samples all spans**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            rate: 1.0
        }
    }
};
```

**Samples half of all spans**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            rate: 0.5
        }
    }
};
```

### Rate limiting sampling
This sampling method uses a rate limiter. You can configure how many spans will be sampled in a second.

**Samples 2 spans per second**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            tracesPerSecond: 2
        }
    }
};
```

**Samples 1 span per 10 seconds**
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        sampling: {
            tracesPerSecond: 0.1
        }
    }
};
```

## Tracing Exporters

The tracing module supports several exporters, custom tracing spans and integration with instrumentation libraries (like [`dd-trace`](https://github.com/DataDog/dd-trace-js)).

### Console
This is a debugging exporter which prints full local trace to the console.

![Console Trace Graph](assets/tracing/console.png#zoomable)

{% note warn %}
Console exporter can't follow remote calls, only locals.
{% endnote %}

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Console",
            options: {
                // Custom logger
                logger: null,
                // Using colors
                colors: true,
                // Width of row
                width: 100,
                // Gauge width in the row
                gaugeWidth: 40
            }
        }
    }
};
```

### Datadog
Datadog exporter sends tracing data to [Datadog](https://www.datadoghq.com/) server via `dd-trace`. 
<!-- It is able to merge tracing spans of instrumented Node.js modules and Moleculer modules. -->

![Datadog Trace Graph](assets/tracing/datadog-trace-graph.png#zoomable)

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Datadog",
            options: {
                // Datadog Agent URL
                agentUrl: process.env.DD_AGENT_URL || "http://localhost:8126",
                // Environment variable
                env: process.env.DD_ENVIRONMENT || null,
                // Sampling priority. More info: https://docs.datadoghq.com/tracing/guide/trace_sampling_and_storage/?tab=java#sampling-rules
                samplingPriority: "AUTO_KEEP",
                // Default tags. They will be added into all span tags.
                defaultTags: null,
                // Custom Datadog Tracer options. More info: https://datadog.github.io/dd-trace-js/#tracer-settings
                tracerOptions: null,
            }
        }
    }
};
```
{% note info %}
To use this exporter, install the `dd-trace` module with `npm install dd-trace --save` command.
{% endnote %}


### Event
Event exporter sends Moleculer events (`$tracing.spans`) with tracing data.

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Event",
            options: {
                // Name of event
                eventName: "$tracing.spans",
                // Send event when a span started
                sendStartSpan: false,
                // Send event when a span finished
                sendFinishSpan: true,
                // Broadcast or emit event
                broadcast: false,
                // Event groups
                groups: null,
                // Sending time interval in seconds
                interval: 5,
                // Custom span object converter before sending
                spanConverter: null,
                // Default tags. They will be added into all span tags.
                defaultTags: null
            }
        }
    }
};
```

### Event (legacy)
Legacy event exporter sends Moleculer legacy metric events ([`metrics.trace.span.start`](#Legacy-Request-Started-Payload) & [`metrics.trace.span.finish`](#Legacy-Request-Finished-Payload)) at every request. These events are also used to generate metrics in [legacy (`<= v0.13`) metrics solutions](/modules.html#metrics).

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: "EventLegacy"
    }
};
```

#### Legacy Request Started Payload
The broker emits an `metrics.trace.span.start` event when a new request is started. The payload looks like the following:
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
The broker emits an `metrics.trace.span.finish` event when the call/request is finished. The payload looks like the following:
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

![Jaeger Trace Graph](assets/tracing/jaeger.png#zoomable)

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Jaeger",
            options: {
                // HTTP Reporter endpoint. If set, HTTP Reporter will be used.
                endpoint: null,
                // UDP Sender host option.
                host: "127.0.0.1",
                // UDP Sender port option.
                port: 6832,
                // Jaeger Sampler configuration.
                sampler: {
                    // Sampler type. More info: https://www.jaegertracing.io/docs/1.14/sampling/#client-sampling-configuration
                    type: "Const",
                    // Sampler specific options.
                    options: {}
                },
                // Additional options for `Jaeger.Tracer`
                tracerOptions: {},
                // Default tags. They will be added into all span tags.
                defaultTags: null
            }
        }
    }
};
```
{% note info %}
To use this exporter, install the `jaeger-client` module with `npm install jaeger-client --save` command.
{% endnote %}


### Zipkin
Zipkin exporter sends tracing spans information to a [Zipkin](https://zipkin.apache.org/) server.

![Zipkin Trace Graph](assets/tracing/zipkin.png#zoomable)

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: {
            type: "Zipkin",
            options: {
                // Base URL for Zipkin server.
                baseURL: "http://localhost:9411",
                // Sending time interval in seconds.
                interval: 5,
                // Additional payload options.
                payloadOptions: {
                    // Set `debug` property in payload.
                    debug: false,
                    // Set `shared` property in payload.
                    shared: false
                },
                // Default tags. They will be added into all span tags.
                defaultTags: null
            }
        }
    }
};
```

### NewRelic
NewRelic exporter sends tracing spans information in Zipkin v2 format to a [NewRelic](https://newrelic.com/) server.

```js
// moleculer.config.js
{
    tracing: {
        enabled: true,
        events: true,
        exporter: [
            {
                type: 'NewRelic',
                options: {
                    // Base URL for NewRelic server
                    baseURL: 'https://trace-api.newrelic.com',
                    // NewRelic Insert Key
                    insertKey: 'my-secret-key',
                    // Sending time interval in seconds.
                    interval: 5,
                    // Additional payload options.
                    payloadOptions: {
                        // Set `debug` property in payload.
                        debug: false,
                        // Set `shared` property in payload.
                        shared: false,
                    },
                    // Default tags. They will be added into all span tags.
                    defaultTags: null,
                },
            },
        ],
    },    
}
```

## Multiple exporters
You can define multiple tracing exporters.

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        exporter: [
            "Console",
            {
                type: "Zipkin",
                options: {
                    baseURL: "http://localhost:9411",
                }
            }
            {
                type: "Jaeger",
                options: {
                    host: "127.0.0.1",
                }
            }
        ]
    }
};
```

## User-defined tracing spans
To add new spans inside an action or event handler, just call the `ctx.startSpan` and `ctx.finishSpan` methods.

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
            ctx.finishSpan(span1);

            const span2 = ctx.startSpan("populating");
            const res = await this.populate(data);
            ctx.finishSpan(span2);

            return res;
        }
    }
};
```

### Create span without context
If `Context` is not available, you can create spans via `broker.tracer`.

```js
// posts.service.js
module.exports = {
    name: "posts",
    started() {
        // Create a span to measure the initialization
        const span = this.broker.tracer.startSpan("initializing db", {
            tags: {
                dbHost: this.settings.dbHost
            }
        });

        await this.db.connect(this.settings.dbHost);

        // Create a sub-span to measure the creating tables.
        const span2 = span.startSpan("create tables");

        await this.createDatabaseTables();

        // Finish the sub-span.
        span2.finish();

        // Finish the main span.
        span.finish();
    }
};
```

## Customizing
### Custom Span Names
You can customize the span name of you traces. In this case, you must specify the `spanName` that must be a static `String` or a `Function`.

**Creating a custom name for a trace via Function**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                spanName: ctx => `Get a post by ID: ${ctx.params.id}`
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

### Adding Tags from Context
You can customize what context `params` or `meta` values are added to span tags.

**Default** The default behaviour is that add all properties from `ctx.params` only.
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
};
```

**Custom params example**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                tags: {
                    // Add `id` from `ctx.params`
                    params: ["id"],
                    // Add `loggedIn.username` value from `ctx.meta`
                    meta: ["loggedIn.username"],
                    // add tags from the action response.
                    response: ["id", "title"]
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

**Example with custom function** You can define a custom `Function` to fill the span tags from the `Context`.

```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        get: {
            tracing: {
                tags(ctx, response) {
                    return {
                        params: ctx.params,
                        meta: ctx.meta,
                        custom: {
                            a: 5
                        },
                        response
                    };
                }
            },
            async handler(ctx) {
                // ...
            }
        }
    }
};
```

{% note info %}
Please note, when used with an action the function will be called two times in case of successful execution. First with `ctx` and the second time with `ctx` & `response` as the response of the action call.
{% endnote %}

## Global action and event tags

Custom action and event span tags can be defined using the `tags` property in the tracer [options](#Options). These will be applied to all action and event spans unless overridden in the service schema's action and event definitions. All custom tag types defined [above](#Customizing) are valid. Any tags defined in the service schema's action and event definitions will take precendence but the merge of `params`, `meta`, and `response` tag definitions are shallow, meaning that it is possible to do things like define `meta` tags globally and `response` tags locally in each service.

```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        tags: {
            action: {
                // Never add params
                params: false,
                // Add `loggedIn.username` value from `ctx.meta`
                meta: ["loggedIn.username"],
                // Always add the response
                response: true,
            },
            event(ctx) {
                return {
                    params: ctx.params,
                    meta: ctx.meta,
                    // add the caller
                    caller: ctx.caller,
                    custom: {
                        a: 5
                    },
                };
            },            
        }
    }
};
```

{% note info %}
Custom tags defined using the `tags` property have access to `ctx` and if used with an action the `response`. The tags defined in `defaultTags` must either be a static object or a function that accepts the `tracer` instance and returns an object. It also has access to the `broker` instance via the `tracer` instance but does not have access to `ctx`.
{% endnote %}

**Example of Event tracing** You can tracing the events, as well. To enable it, set `events: true` in tracing broker options.
```js
// moleculer.config.js
module.exports = {
    tracing: {
        enabled: true,
        events: true
    }
};
```