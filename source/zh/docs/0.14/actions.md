title: 活动
---

服务公开的可调用的方法称为活动(actions)。 活动通过RPC(远程过程调用) 来调用。它们就好像 HTTP 请求一样，具有请求参数并返回响应。

如果您有多个服务实例，服务管理器(broker) 将负责均衡它们的请求。 [获取更多关于负载均衡的信息](balancing.html)。

<div align="center">
    <img src="assets/action-balancing.gif" alt="Action balancing diagram" />
</div>

## 服务调用
要调用服务，请使用 `broker.call` 方法。 服务管理者寻找具有指定活动的服务（和节点）并调用该活动。 调用后返回 `Promise`。

### 语法
```js
const res = await broker.call(actionName, params, opts);
```
这里，`actionName`是一个点分隔的字符串。 点之前是服务名称，点后面则是活动名称。 因此，如果您的 `posts` 服务有一个 `create` 活动，您可以这样调用 `posts.create`。

`params` 是一个对象，作为 [Context](context.html) 的一部分传递到该活动。 服务可以经由 `ctx.params` 访问它。 *params</0> 是可选的。 如果您没有定义它，则为 `{}`</p>

`opts` 是一个要 设置/覆盖 某些请求参数的对象，例如`timeout`, `retryCount`。 *opts 也是可选的。*

**可用的调用选项：**

| 名称                 | 类型        | 默认值    | 说明                                                                                                                                                                                                                                                                                                    |
| ------------------ | --------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `timeout`          | `Number`  | `null` | Timeout of request in milliseconds. If the request is timed out and you don't define `fallbackResponse`, broker will throw a `RequestTimeout` error. To disable set `0`. If it's not defined, the `requestTimeout` value from broker options will be used. [Read more](fault-tolerance.html#Timeout). |
| `retries`          | `Number`  | `null` | Count of retry of request. If the request is timed out, broker will try to call again. To disable set `0`. If it's not defined, the `retryPolicy.retries` value from broker options will be used. [Read more](fault-tolerance.html#Retry).                                                            |
| `fallbackResponse` | `Any`     | `null` | Returns it, if the request has failed. [Read more](fault-tolerance.html#Fallback).                                                                                                                                                                                                                    |
| `nodeID`           | `String`  | `null` | Target nodeID. If set, it will make a direct call to the specified node.                                                                                                                                                                                                                              |
| `meta`             | `Object`  | `{}`   | Metadata of request. Access it via `ctx.meta` in actions handlers. It will be transferred & merged at nested calls, as well.                                                                                                                                                                          |
| `parentCtx`        | `Context` | `null` | Parent `Context` instance. Use it to chain the calls.                                                                                                                                                                                                                                                 |
| `requestID`        | `String`  | `null` | Request ID or Correlation ID. Use it for tracing.                                                                                                                                                                                                                                                     |


### 用例
**Call without params**
```js
const res = await broker.call("user.list");
```

**Call with params**
```js
const res = await broker.call("user.get", { id: 3 });
```

**Call with calling options**
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

### 元数据
服务的 `meta` 属性负责发送元数据。 在活动处理器中通过 `ctx.mete` 来访问它。 注意，在嵌套调用中 `meta` 被合并。
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

`meta` 会被回传给服务调用者。 Use it to send extra meta information back to the caller. E.g.: send response headers back to API gateway or set resolved logged in user to metadata.

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

### Timeout

Timeout can be set in action definition, as well. It overwrites the global broker [`requestTimeout` option](fault-tolerance.html#Timeout), but not the `timeout` in calling options.

**Example**
 ```js
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    requestTimeout: 3000
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
            timeout: 5000, // 5 secs
            handler(ctx) {
                return "Slow";
            }
        }
    },
```
**Calling examples**
```js
// It uses the global 3000 timeout
await broker.call("greeter.normal");
 // It uses the 5000 timeout from action definition
await broker.call("greeter.slow");
 // It uses 1000 timeout from calling option
await broker.call("greeter.slow", null, { timeout: 1000 });
```
### Multiple calls

Calling multiple actions at the same time is also possible. To do it use `broker.mcall` or `ctx.mcall`.

**`mcall` with Array< Object >**
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

**`mcall` with Object**
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

## Streaming
Moleculer supports Node.js streams as request `params` and as response. Use it to transfer an incoming file from a gateway, encode/decode or compress/decompress streams.

### Examples

**Send a file to a service as a stream**
```js
const stream = fs.createReadStream(fileName);

broker.call("storage.save", stream, { meta: { filename: "avatar-123.jpg" }});
```

{% note info Object Mode Streaming%}
[Object Mode Streaming](https://nodejs.org/api/stream.html#stream_object_mode) is also supported. In order to enable it set `$streamObjectMode: true` in [`meta`](actions.html#Metadata).
{% endnote %}

Please note, the `params` should be a stream, you cannot add any additional variables to the `params`. Use the `meta` property to transfer additional data.

**Receiving a stream in a service**
```js
module.exports = {
    name: "storage",
    actions: {
        save(ctx) {
            // Save the received stream to a file
            const s = fs.createWriteStream(`/tmp/${ctx.meta.filename}`);
            ctx.params.pipe(s);
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

**AES encode/decode example service**
```js
const crypto = require("crypto");
const password = "moleculer";

module.exports = {
    name: "aes",
    actions: {
        encrypt(ctx) {
            const encrypt = crypto.createCipher("aes-256-ctr", password);
            return ctx.params.pipe(encrypt);
        },

        decrypt(ctx) {
            const decrypt = crypto.createDecipher("aes-256-ctr", password);
            return ctx.params.pipe(decrypt);
        }
    }
};
```

## Action visibility
The action has a `visibility` property to control the visibility & callability of service actions.

**Available values:**
- `published` or `null`: public action. It can be called locally, remotely and can be published via API Gateway
- `public`: public action, can be called locally & remotely but not published via API GW
- `protected`: can be called only locally (from local services)
- `private`: can be called only internally (via `this.actions.xy()` inside service)

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
Action hooks are pluggable and reusable middleware functions that can be registered `before`, `after` or on `errors` of service actions. A hook is either a `Function` or a `String`. In case of a `String` it must be equal to service's [method](services.html#Methods) name.

### Before hooks
In before hooks, it receives the `ctx`, it can manipulate the `ctx.params`, `ctx.meta`, or add custom variables into `ctx.locals` what you can use in the action handlers. If there are any problem, it can throw an `Error`. _Please note, you can't break/skip the further executions of hooks or action handler._

**Main usages:**
- parameter sanitization
- parameter validation
- entity finding
- authorization

### After hooks
In after hooks, it receives the `ctx` and the `response`. It can manipulate or completely change the response. In the hook, it has to return the response.

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
Hooks can be assigned to a specific action (by indicating action `name`) or all actions (`*`) in service.

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
            ]
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
            ]
        },
        error: {
            // Global error handler
            "*": function(ctx, err) {
                this.logger.error(`Error occurred when '${ctx.action.name}' action was called`, err);

                // Throw further the error
                throw err;
            }
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
The most efficient way of reusing hooks is by declaring them as service methods in a separate file and import them with the [mixin](services.html#Mixins) mechanism. This way a single hook can be easily shared across multiple actions.

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
The `locals` property of `Context` object is a simple storage that can be used to store some additional data and pass it to the action handler. `locals` property and hooks are a powerful combo:

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