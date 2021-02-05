title: Actions
---

服务公开的可调用的方法称为动作或行为 (actions)。 动作通过RPC(远程过程调用) 来调用。它们就好像 HTTP 请求一样，具有请求参数并返回响应。 它有请求参数 & 返回响应，就像一个 HTTP 请求。

如果您有多个服务实例，服务管理器 (broker)  将负责均衡它们的请求。 [获取更多关于负载均衡的信息](balancing.html)。

<div align="center">
    <img src="assets/action-balancing.gif" alt="Action balancing diagram" />
</div>

## 服务调用
要调用服务，请使用 `broker.call` 方法。 服务管理者寻找具有指定动作的服务（和节点）并调用该动作。 调用后返回 `Promise`。

### 语法
```js
const res = await broker.call(actionName, params, opts);
```
这里，`actionName`是一个点分隔的字符串。 点之前是服务名称，点后面则是动作名称。 因此，如果您的 `posts` 服务有一个 `create` 动作，您可以这样调用 `posts.create`。

`params` 是一个对象，作为 [Context](context.html) 的一部分传递到该动作。 服务可以经由 `ctx.params` 访问它。 *params 是可选的。 如果您没有定义它，则为 `{}`*

`opts` 是一个要 设置/覆盖 某些请求参数的对象，例如`timeout`, `retryCount`。 *opts*也是可选的。

**可用的调用选项：**

| 名称                 | 类型        | 默认值    | 说明                                                                                                                                                                  |
| ------------------ | --------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `timeout`          | `Number`  | `null` | 请求超时，单位为毫秒。 如果请求超时且您没有定义`fallbackResponse`, broker 将抛出一个`RequestTimeout`错误。 设为 `0` 表示禁用。 不设置此项，将使用 broker 选项的`requestTimeout`值。 [更多](fault-tolerance.html#Timeout). |
| `retries`          | `Number`  | `null` | 重试次数. 如果请求超时，broker 会重试调用。 设为 `0` 表示禁用。 不设置此项，将使用 broker 选项的`retryPolicy.retries`值。 [更多](fault-tolerance.html#Retry).                                               |
| `fallbackResponse` | `Any`     | `null` | 如果请求失败，返回此替代响应。 [更多](fault-tolerance.html#Fallback).                                                                                                                |
| `nodeID`           | `String`  | `null` | 目标节点。 直接调用指定节点的动作。                                                                                                                                                  |
| `meta`             | `Object`  | `{}`   | 请求元数据。 在动作处理器中通过 `ctx.mete` 来访问它。 它会在嵌套调用中传输 & 合并.                                                                                                                  |
| `parentCtx`        | `Context` | `null` | 父 `Context` 实例。 Use it to chain the calls.                                                                                                                          |
| `requestID`        | `String`  | `null` | Request ID 或 Correlation ID. 用于跟踪。                                                                                                                                  |


### 用例
**无参数调用**
```js
const res = await broker.call("user.list");
```

**带参数调用**
```js
const res = await broker.call("user.get", { id: 3 });
```

**使用调用选项**
```js
const res = await broker.call("user.recommendation", { limit: 5 }, {
    timeout: 500,
    retries: 3,
    fallbackResponse: defaultRecommendation
});
```

**带 promise 错误处理**
```js
broker.call("posts.update", { id: 2, title: "Modified post title" })
    .then(res => console.log("Post updated!"))
    .catch(err => console.error("Unable to update Post!", err));    
```

**直接调用: get health info from the "node-21" node**
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

`meta` 会被回传给服务调用者。 使用它来向调用者回送额外的元信息。 例如：将响应头回送到API网关或解析登录用户的元数据。

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

当服务内部调用动作 (`this.actions.xy()`)时，您应该设置 `meta` 的 `parentCtx` 字段以传递数据。

**内部调用**
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

### 超时

最好在动作声明中设定超时。 它覆盖全局服务管理者的 [`requestTimeout` 选项](fault-tolerance.html#Timeout)，但不会覆盖调用选项中的`timeout`。

**示例**
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
**调用示例**
```js
// It uses the global 3000 timeout
await broker.call("greeter.normal");
 // It uses the 5000 timeout from action definition
await broker.call("greeter.slow");
 // It uses 1000 timeout from calling option
await broker.call("greeter.slow", null, { timeout: 1000 });
```
### 多个调用

同时调用多个动作也是可能的。 要做到这一点，请使用 `broker.mcall` 或 `ctx.mcall`。

**`mcall` 使用 Object 数组**
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

**`mcall` 使用 Object**
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

## 流
Moleculer 支持 Node.js 流作为请求 `params` 和响应。 使用它从网关传入文件、编码/解码或压缩/解压流。

### 示例

**将文件作为流发送到服务**
```js
const stream = fs.createReadStream(fileName);

broker.call("storage.save", stream, { meta: { filename: "avatar-123.jpg" }});
```

{% note info Object Mode Streaming%}
还支持[对象模式流](https://nodejs.org/api/stream.html#stream_object_mode)。 为了启用它，在 [`meta`](actions.html#Metadata) 中设置 `$streamObjectMode：true` 。
{% endnote %}

请注意，现在`params`应该是一个流，您不能在`params`添加任何其他变量。 使用`meta`属性来传输额外数据。

**在服务中接收流**
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

**在服务中返回响应流**
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

**调用方收到流**
```js
const filename = "avatar-123.jpg";
broker.call("storage.get", { filename })
    .then(stream => {
        const s = fs.createWriteStream(`./${filename}`);
        stream.pipe(s);
        s.on("close", () => broker.logger.info("File has been received"));
    })
```

**AES 编码/解码服务示例**
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

## 动作的可见性
动作有一个 `visibility` 属性，用来控制服务动作的可见性和可调用性。

**可用值：**
- `published` 或 `null`: 公开的动作。 它可以被本地调用，远程调用，并可以通过 API 网关发布
- `public`: 公开动作可以在本地调用 & 远程调用，但不能通过 API GW 发布
- `protected`：只能本地调用(从本地服务)
- `private`：只能在服务内部调用 ( `this.actions.xy()`)

**更改可见性**
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
 
Text
Xpath: /pre[19]/code
```

> 为了后向兼容性，默认值是 `null` (意为`published`)。

## 动作钩子
动作钩子是可插入和可重用的 middleware 功能，可以在服务动作中注册`before`, `after` 或`errors`钩子。 钩子可以是 `Function`或`String`。 在`String`的情况下，它必须是服务的[method](services.html#Methods)名称。

### Before hooks
Before hooks 会接收 `ctx`, 取决于你的需求, 它可以操纵 `ctx.params`, `ctx. eta`, 或将自定义变量添加到 `ctx.locals` 。 如果有任何错误，它会抛出 `Error`。 _请注意，您不能 中断或跳过 hooks 或任何动作处理程序。_

**主要用法：**
- 清理参数
- 验证参数
- 查找实体
- 授权

### After hooks
After hooks 会收到 `ctx` 和 `response`. 在这里可以修改响应信息。

**主要用法：**
- 生成属性
- 清除敏感数据
- 将响应包装到一个 `Object`
- 转换响应的结构

### Error hooks
当动作调用过程中抛出 `Error` 时，错误钩子被调用。 它会收到 `ctx` 和 `err`. 它可以处理错误并返回另一个响应 (fallback) 或重新抛出错误。

**主要用法：**
- 处理错误
- 包装成另一个错误
- 响应回退

### 声明在服务上
可以把钩子设在服务的某个动作上(通过指派 `name`)，也可以应用到所有动作(通过指派`*`)。

{% note warn%}
请注意钩子注册顺序很重要，因为它定义了执行钩子的顺序。 欲了解更多信息，参见 [hook execution order](#Execution-order)。
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

### 声明在动作上
钩子也可以注册在动作中。

{% note warn%}
请注意，挂钩注册顺序很重要，因为它定义了执行钩子的顺序。 欲了解更多信息，参见 [hook execution order](#Execution-order)。
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
### 执行顺序
请记住，钩子有指定的执行顺序。 这对理解多个钩子在不同级别注册时特别重要([service](#Service-level-declaration) 和/或 [动作](#Action-level-declaration)) 。  总的来说，钩子有以下执行逻辑：

- `before` hooks: global (`*`) `->` service level `->` action level.

- `after` hooks: action level `->` service level `->` global (`*`).

**以下示例 global, service & action 级别钩子的执行链**
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
**以下为 global, service & action 级别的钩子输出**
```bash
INFO  - Before all hook
INFO  -   Before hook
INFO  -     Before action hook
INFO  -       Action handler
INFO  -     After action hook
INFO  -   After hook
INFO  - After all hook
```

### 重用
重用钩子的最有效方式是在单独的文件中将钩子作为服务方法并使用 [mixin](services.html#Mixins) 机制导入。 这样，单个钩子可以轻松地在多个操作中共享。

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
### 本地存储
`Context` 的 `locals` 属性对象是一个简单的存储库，可用来存储一些额外的数据并传递到操作处理器。 `locals` 属性和钩子组合使用:

**在 before 钩子中设置 `ctx.locals`**
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