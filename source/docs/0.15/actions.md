title: Actions
---

The actions are the callable/public methods of the service. The action calling represents a remote-procedure-call (RPC). It has request parameters & returns response, like a HTTP request.

If you have multiple instances of services, the broker will load balance the request among instances. [Read more about balancing](balancing.html).

<div align="center">
    <img src="assets/action-balancing.gif" alt="Action balancing diagram" />
</div>

## Call services
To call a service use the `broker.call` method. The broker looks for the service (and a node) which has the given action and call it. The function returns a `Promise`.

### Syntax
```js
const res = await broker.call(actionName, params, opts);
```
The `actionName` is a dot-separated string. The first part of it is the service name, while the second part of it represents the action name. So if you have a `posts` service with a `create` action, you can call it as `posts.create`.

The `params` is an object which is passed to the action as a part of the [Context](context.html). The service can access it via `ctx.params`. *It is optional. If you don't define, it will be `{}`*.

The `opts` is an object to set/override some request parameters, e.g.: `timeout`, `retryCount`. *It is optional.*

**Available calling options:**

Moleculer provides various calling options to customize the behavior of service calls. These options include timeout, retries, fallback response, target nodeID, metadata, parent context, and request ID.

| Name | Type | Default | Description |
| ------- | ----- | ------- | ------- |
| `timeout` | `Number` | `null` | Timeout of request in milliseconds. If the request is timed out and you don't define `fallbackResponse`, broker will throw a `RequestTimeout` error. To disable set `0`. If it's not defined, the `requestTimeout` value from broker options will be used. [Read more](fault-tolerance.html#Timeout). |
| `retries` | `Number` | `null` | Count of retry of request. If the request is timed out, broker will try to call again. To disable set `0`. If it's not defined, the `retryPolicy.retries` value from broker options will be used. [Read more](fault-tolerance.html#Retry). |
| `fallbackResponse` | `Any` | `null` | Returns it, if the request has failed. [Read more](fault-tolerance.html#Fallback). |
| `nodeID` | `String` | `null` | Target nodeID. If set, it will make a direct call to the specified node. |
| `meta` | `Object` | `{}` | Metadata of request. Access it via `ctx.meta` in actions handlers. It will be transferred & merged at nested calls, as well. |
| `parentCtx` | `Context` | `null` | Parent `Context` instance. Use it to chain the calls.  |
| `requestID` | `String` | `null` | Request ID or Correlation ID. Use it for tracing. |


### Usages
**Call without params**
```js
const res = await broker.call("user.list");
```

**Call with params**
```js
const res = await broker.call("user.get", { id: 3 });
```

**Call with params and options**
```js
const res = await broker.call("user.recommendation", { limit: 5 }, {
    timeout: 500,
    retries: 3,
    fallbackResponse: defaultRecommendation
});
```

**Call with promise error handling**
```js
broker.call("posts.update", { id: 2, title: "Modified post title" })
    .then(res => console.log("Post updated!"))
    .catch(err => console.error("Unable to update Post!", err));    
```

**Direct call: get health info from the "node-21" node**
```js
const res = await broker.call("$node.health", null, { nodeID: "node-21" })
```

### Metadata
Metadata in Moleculer allows you to send additional information along with service calls. This metadata can be accessed in action handlers via `ctx.meta` and is useful for passing context-specific details or configuration parameters. Please note that in nested calls the `meta` is merged.


```js
broker.createService({
    name: "test",
    actions: {
        first(ctx) {
            return ctx.call("test.second", null, { meta: {
                b: 5
            }});
        },
        second(ctx) {
            console.log(ctx.meta);
            // Prints: { a: "John", b: 5 }
        }
    }
});

broker.call("test.first", null, { meta: {
    a: "John"
}});
```

The `meta` is sent back to the caller service. Use it to send extra meta information back to the caller. E.g.: send response headers back to API gateway or set resolved logged in user to metadata.

```js
broker.createService({
    name: "test",
    actions: {
        async first(ctx) {
            await ctx.call("test.second", null, { meta: {
                a: "John"
            }});

            console.log(ctx.meta);
            // Prints: { a: "John", b: 5 }
        },
        second(ctx) {
            // Modify meta
            ctx.meta.b = 5;
        }
    }
});
```

When making internal calls to actions (`this.actions.xy()`) you should set `parentCtx` to pass `meta` data.

**Internal calls**
```js
broker.createService({
  name: "mod",
  actions: {
    hello(ctx) {
      console.log(ctx.meta);
      // Prints: { user: 'John' }
      ctx.meta.age = 123
      return this.actions.subHello(ctx.params, { parentCtx: ctx });
    },

    subHello(ctx) {
      console.log("meta from subHello:", ctx.meta);
      // Prints: { user: 'John', age: 123 }
      return "hi!";
    }
  }
});

broker.call("mod.hello", { param: 1 }, { meta: { user: "John" } });
```

### Headers
Headers in Moleculer serve a similar purpose to HTTP headers, allowing you to attach additional information to service calls.


{% note info %}
Please note, header keys start with `$` means internal header keys (e.g. `$streamObjectMode`). We recommend to don't use this prefix for your keys to avoid conflicts.
{% endnote %}

**Setting headers in action calls**
```js
broker.call("posts.list", { limit: 100 }, {
  headers: {
    customProp: "customValue"
  }
});
```
{% note info %}
You can also set header when emitting or boradcasting events.
{% endnote %}

**Read headers inside action handler**
```js
// posts.service.js
module.exports = {
  name: "posts",
  actions: {
    list(ctx) {
      const customProp = ctx.headers.customProp;
    },
  },
};
```

### Metadata vs Headers
#### Metadata
- Purpose: Provides additional context or configuration parameters for service calls.
- Scope: Global within Moleculer, passed to all subsequent actions.
- Access: Accessed via `ctx.meta` within action handlers.

**Usage**:
- Sending context-specific details like authentication tokens.
- Propagating information across nested service calls.

#### Headers
- Purpose: Attaches metadata to individual service calls.
- Scope: Specific to each service call, not automatically propagated.
- Access: Accessed via `ctx.headers` within action handlers.

**Usage**

- Adding request-specific metadata like content type.
- Passing transient information for a single call.

#### Key Differences
- Scope: Metadata is global and passed to all subsequent actions, while headers are specific to each call.
- Propagation: Metadata is automatically propagated, headers need explicit passing.
- Merge: Metadata is merged in nested calls, headers are not.
- Accessibility: Metadata accessed via `ctx.meta`, headers via `ctx.headers`.

### Timeout

Timeouts define the maximum time a service call waits for a response from another service. This helps prevent applications from hanging indefinitely while waiting for unresponsive services.

Timeout Levels:
- **Global Broker Timeout**: This default timeout applies to all service calls unless overridden at lower levels. It's set using the [`requestTimeout`](fault-tolerance.html#Timeout) option in the broker configuration.
- **Action-Specific Timeout**: You can define a specific timeout for an individual action within its definition. This overrides the global broker timeout for that particular action.
- **Call-Level Timeout**: When calling a service, you can provide a `timeout` option directly within the call parameters. This overrides both the global and action-specific timeouts for that specific call.

**Example**
 ```js
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    requestTimeout: 3000 // Global timeout setting in milliseconds
};

 // greeter.service.js
module.exports = {
    name: "greeter",
    actions: {
        normal: {
            handler(ctx) {
                return "Normal";
            }
        },
         slow: {
            timeout: 5000, // Action-specific timeout setting (5 seconds)
            handler(ctx) {
                return "Slow";
            }
        }
    },
```
**Calling examples**
```js
// Using global timeout (3 seconds)
await broker.call("greeter.normal");

// Using action-specific timeout (5 seconds)
await broker.call("greeter.slow");

// Using call-level timeout (1 second)
await broker.call("greeter.slow", null, { timeout: 1000 });
```

### Multiple calls

#### Calling multiple actions
Moleculer.js allows you to execute multiple service calls simultaneously using the `broker.mcall` or `ctx.mcall` methods. This is useful for scenarios where you need data from different services to build a final response or perform actions in parallel.

**Call Definition formats**:
- `Array` of Objects: Each object in the array represents a single call with the following properties:
    - `action`: (Required) The name of the service action to be called.
    - `params`: (Optional) An object containing parameters to be passed to the action.
    - `options`: (Optional) An object containing additional options for the specific call (e.g., timeout).
- `Object` with Nested Properties: Here, the object itself acts as a container for multiple calls. Each key represents the service name, and the value is another object defining the action and parameters for that service.

**Common Options**:
You can optionally provide a second argument to `mcall` to specify common options that apply to all calls within the request. This object can include properties like `meta` or `timeout`.

**`mcall` with Array \<Object\>**

```js
await broker.mcall(
    [
        { action: 'posts.find', params: { author: 1 }, options: { /* Calling options for this call. */} },
        { action: 'users.find', params: { name: 'John' } }
    ],
    {
        // Common calling options for all calls.
        meta: { token: '63f20c2d-8902-4d86-ad87-b58c9e2333c2' }
    }
);
```

**`mcall` with Object and options.meta**
```js
await broker.mcall(
    {
        posts: { action: 'posts.find', params: { author: 1 }, options: { /* Calling options for this call. */} },
        users: { action: 'users.find', params: { name: 'John' } }
    }, 
    {
        // Common calling options for all calls.
        meta: { token: '63f20c2d-8902-4d86-ad87-b58c9e2333c2' }
    }
);
```

#### Response handling
The `mcall` method offers a `settled` option that allows you to receive detailed information about the results of each call, including their success or failure status. With `settled: true`, `mcall` always resolves as a `Promise`, and the response contains an array with objects for each call. Each object has a status property ("fulfilled" for success, "rejected" for failure) and a `value` property containing the response data (for successful calls) or the error reason (for failed calls). Note that, without this option you won't know how many (and which) calls were rejected.

**Example**
```js
const res = await broker.mcall([
    { action: "posts.find", params: { limit: 2, offset: 0 },
    { action: "users.find", params: { limit: 2, sort: "username" } },
    { action: "service.notfound", params: { notfound: 1 } }
], { settled: true });
console.log(res);
```

The `res` will be something similar to

```js
[
    { status: "fulfilled", value: [/*... response of `posts.find`...*/] },
    { status: "fulfilled", value: [/*... response of `users.find`...*/] },
    { status: "rejected", reason: {/*... Rejected response/Error`...*/} }
]
```

## Streaming
Stream handling enables efficient transfer of data streams between services. This feature is particularly useful for processing large files, encoding/decoding streams, or compressing/decompressing data on the fly. The stream instance is passed as a calling options, so you can use `params` as a normal action call.

### Examples

**Send a file to a service as a stream**
```js
const stream = fs.createReadStream(fileName);
ctx.call("file.save", { filename: "as.txt" }, { stream: fs.createReadStream() });
```

{% note info Object Mode Streaming%}
[Object Mode Streaming](https://nodejs.org/api/stream.html#stream_object_mode) is also supported. In order to enable it set `$streamObjectMode: true` in [`meta`](actions.html#Metadata).
{% endnote %}

Please note, the `params` should be a stream, you cannot add any additional variables to the `params`. Use the `meta` property to transfer additional data.

**Receiving a stream in a service**
```js
// file.service.js
module.exports = {
    name: "file",
    actions: {
        save(ctx) {
            // The stream is in Context directly
            const stream = ctx.stream;
            const s = fs.createWriteStream(ctx.params.filename);
            stream.pipe(s);
        }
    }
};
```

**Return a stream as response in a service**
```js
module.exports = {
    name: "storage",
    actions: {
        get: {
            params: {
                filename: "string"
            },
            handler(ctx) {
                return fs.createReadStream(`/tmp/${ctx.params.filename}`);
            }
        }
    }
};
```

**Process received stream on the caller side**
```js
const filename = "avatar-123.jpg";
broker.call("storage.get", { filename })
    .then(stream => {
        const s = fs.createWriteStream(`./${filename}`);
        stream.pipe(s);
        s.on("close", () => broker.logger.info("File has been received"));
    })
```

## Action visibility
Action `visibility` determines the accessibility and invocation permissions of service actions. By defining visibility levels, developers can control who can invoke actions and under what circumstances.

**Functionality**
- **Public Access**: Actions with `published` or `null` visibility are considered public and can be invoked locally, remotely, and published via API Gateway.
- **Remote Invocation**: `public` actions can be called both locally and remotely but are not exposed via API Gateway publication.
- **Local Access Only**: Actions with `protected` visibility are restricted to services located on the same node, ensuring they cannot be called remotely.
- **Internal Use Only**: `private` actions are exclusively callable internally within the service, via `this.actions.xy()` syntax.

**Change visibility**
```js
module.exports = {
    name: "posts",
    actions: {
        // It's published by default
        find(ctx) {},
        clean: {
            // Callable only via `this.actions.clean`
            visibility: "private",
            handler(ctx) {}
        }
    },
    methods: {
        cleanEntities() {
            // Call the action directly
            return this.actions.clean();
        }
    }
}
```

> The default values is `null` (means `published`) due to backward compatibility.

## Action hooks
Action hooks allow you to inject middleware functions into the request-response lifecycle of service actions. These hooks can execute `before`, `after`, or on `errors` during action invocation, enabling tasks like parameter validation, response manipulation, and error handling. A hook is either a `Function` or a `String`. In case of a `String` it must be equal to service's [method](services.html#Methods) name.

### Before hooks
In before hooks, it receives the `ctx`, it can manipulate the `ctx.params`, `ctx.meta`, or add custom variables into `ctx.locals` what you can use in the action handlers.
If there are any problem, it can throw an `Error`. _Please note, you can't break/skip the further executions of hooks or action handler._

**Main usages:** 
- parameter sanitization
- parameter validation
- entity finding
- authorization

### After hooks
In after hooks, it receives the `ctx` and the `response`. It can manipulate or completely change the response. 
In the hook, it has to return the response.

**Main usages:** 
- property populating
- remove sensitive data.
- wrapping the response into an `Object`
- convert the structure of the response

### Error hooks
The error hooks are called when an `Error` is thrown during action calling. It receives the `ctx` and the `err`. It can handle the error and return another response (fallback) or throws further the error.

**Main usages:** 
- error handling
- wrap the error into another one
- fallback response

### Service level declaration
Hooks can be assigned to a specific action (by indicating action `name`), all actions (`*`) in service or by indicating a wildcard (e.g., `create-*`). The latter will be applied to all actions whose name starts with `create-`. Action names can also be combined using a pipe symbol (e.g., `create|update`)

{% note warn%}
Please notice that hook registration order matter as it defines sequence by which hooks are executed. For more information take a look at [hook execution order](#Execution-order).
{% endnote %}

**Before hooks**

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "posts",
    mixins: [DbService]
    hooks: {
        before: {
            // Define a global hook for all actions
            // The hook will call the `resolveLoggedUser` method.
            "*": "resolveLoggedUser",

            // Define multiple hooks for action `remove`
            remove: [
                function isAuthenticated(ctx) {
                    if (!ctx.user)
                        throw new Error("Forbidden");
                },
                function isOwner(ctx) {
                    if (!this.checkOwner(ctx.params.id, ctx.user.id))
                        throw new Error("Only owner can remove it.");
                }
            ],
            // Applies to all actions that start with "create-"
            "create-*": [
                async function (ctx){}
            ],
            // Applies to all actions that end with "-user"
            "*-user": [
                async function (ctx){}
            ],
            // Applies to all actions that start with "create-" or end with "-user"
            "create-*|*-user": [
                async function (ctx){}
            ],
        }
    },

    methods: {
        async resolveLoggedUser(ctx) {
            if (ctx.meta.user)
                ctx.user = await ctx.call("users.get", { id: ctx.meta.user.id });
        }
    }
}
```

**After & Error hooks**

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "users",
    mixins: [DbService]
    hooks: {
        after: {
            // Define a global hook for all actions to remove sensitive data
            "*": function(ctx, res) {
                // Remove password
                delete res.password;

                // Please note, must return result (either the original or a new)
                return res;
            },
            get: [
                // Add a new virtual field to the entity
                async function (ctx, res) {
                    res.friends = await ctx.call("friends.count", { query: { follower: res._id }});

                    return res;
                },
                // Populate the `referrer` field
                async function (ctx, res) {
                    if (res.referrer)
                        res.referrer = await ctx.call("users.get", { id: res._id });

                    return res;
                }
            ],
            // Applies to all actions that start with "create-"
            "create-*": [
                async function (ctx, res){}
            ],
            // Applies to all actions that end with "-user"
            "*-user": [
                async function (ctx, res){}
            ],
        },
        error: {
            // Global error handler
            "*": function(ctx, err) {
                this.logger.error(`Error occurred when '${ctx.action.name}' action was called`, err);

                // Throw further the error
                throw err;
            },
            // Applies to all actions that start with "create-"
            "create-*": [
                async function (ctx, err){}
            ],
            // Applies to all actions that end with "-user"
            "*-user": [
                async function (ctx, err){}
            ],
        }
    }
};
```

### Action level declaration
Hooks can be also registered inside action declaration.

{% note warn%}
Please note that hook registration order matter as it defines sequence by which hooks are executed. For more information take a look at [hook execution order](#Execution-order).
{% endnote %}

**Before & After hooks**

```js
broker.createService({
    name: "greeter",
    actions: {
        hello: {
            hooks: {
                before(ctx) {
                    broker.logger.info("Before action hook");
                },
                after(ctx, res) {
                    broker.logger.info("After action hook"));
                    return res;
                }
            },

            handler(ctx) {
                broker.logger.info("Action handler");
                return `Hello ${ctx.params.name}`;
            }
        }
    }
});
```
### Execution order
It is important to keep in mind that hooks have a specific execution order. This is especially important to remember when multiple hooks are registered at different ([service](#Service-level-declaration) and/or [action](#Action-level-declaration)) levels.  Overall, the hooks have the following execution logic:

- `before` hooks: global (`*`) `->` service level `->` action level.

- `after` hooks: action level `->` service level `->` global (`*`).

{% note info%}
When using several hooks it might be difficult visualize their execution order. However, you can set the [`logLevel` to `debug`](logging.html#Log-Level-Setting) to quickly check the execution order of global and service level hooks.
{% endnote %}

**Example of a global, service & action level hook execution chain**
```js
broker.createService({
    name: "greeter",
    hooks: {
        before: {
            "*"(ctx) {
                broker.logger.info(chalk.cyan("Before all hook"));
            },
            hello(ctx) {
                broker.logger.info(chalk.magenta("  Before hook"));
            }
        },
        after: {
            "*"(ctx, res) {
                broker.logger.info(chalk.cyan("After all hook"));
                return res;
            },
            hello(ctx, res) {
                broker.logger.info(chalk.magenta("  After hook"));
                return res;
            }
        },
    },

    actions: {
        hello: {
            hooks: {
                before(ctx) {
                    broker.logger.info(chalk.yellow.bold("    Before action hook"));
                },
                after(ctx, res) {
                    broker.logger.info(chalk.yellow.bold("    After action hook"));
                    return res;
                }
            },

            handler(ctx) {
                broker.logger.info(chalk.green.bold("      Action handler"));
                return `Hello ${ctx.params.name}`;
            }
        }
    }
});
```
**Output produced by global, service & action level hooks**
```bash
INFO  - Before all hook
INFO  -   Before hook
INFO  -     Before action hook
INFO  -       Action handler
INFO  -     After action hook
INFO  -   After hook
INFO  - After all hook
```

### Reusability

Ensuring hook reusability is crucial for maintaining clean and modular code. By defining hooks as standalone functions or [mixins](services.html#Mixins), you can easily share them across multiple actions and services, ensuring code efficiency and consistency.

```js
// authorize.mixin.js
module.exports = {
    methods: {
        checkIsAuthenticated(ctx) {
            if (!ctx.meta.user)
                throw new Error("Unauthenticated");
        },
        checkUserRole(ctx) {
            if (ctx.action.role && ctx.meta.user.role != ctx.action.role)
                throw new Error("Forbidden");
        },
        checkOwner(ctx) {
            // Check the owner of entity
        }
    }
}
```

```js
// posts.service.js
const MyAuthMixin = require("./authorize.mixin");

module.exports = {
    name: "posts",
    mixins: [MyAuthMixin]
    hooks: {
        before: {
            "*": ["checkIsAuthenticated"],
            create: ["checkUserRole"],
            update: ["checkUserRole", "checkOwner"],
            remove: ["checkUserRole", "checkOwner"]
        }
    },

    actions: {
        find: {
            // No required role
            handler(ctx) {}
        },
        create: {
            role: "admin",
            handler(ctx) {}
        },
        update: {
            role: "user",
            handler(ctx) {}
        }
    }
};
```
### Local Storage

Local storage in Moleculer provides a lightweight mechanism for storing temporary data within the context of a service action. This storage, accessible via `ctx.locals`, allows you to pass additional information to action handlers and maintain state across hook executions.

**Setting `ctx.locals` in before hook**
```js
module.exports = {
    name: "user",

    hooks: {
        before: {
            async get(ctx) {
                const entity = await this.findEntity(ctx.params.id);
                ctx.locals.entity = entity;
            }
        }
    },

    actions: {
        get: {
            params: {
                id: "number"
            },
            handler(ctx) {
                this.logger.info("Entity", ctx.locals.entity);
            }
        }
    }
}
```
