title: API网关（API Gateway）
---
## moleculer-web [![npm](https://img.shields.io/npm/v/moleculer-web.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-web)
[Moleculer-web](https://github.com/moleculerjs/moleculer-web)是Moleculer框架的官方API网关服务。 使用它将您的服务发布为RESTful API。

## 特性概览
* 支持 HTTP & HTTPS
* 提供静态文件服务
* 多样的路由
* 支持在全局级别、路由级别和别名级别使用类似于Connect的中间件。
* 路由别名（支持命名参数和REST路由）
* 白名单
* 多种Body Parsers （Json，Urlencoded）
* 跨域（CORS headers）
* 访问频率限制
* before & after 钩子（Hook）方法
* Buffer & Stream 处理
* 中间件（Middleware）模式（类似Express中间件）

{% note info Try it in your browser! %}
[![Edit moleculer-web](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/github/moleculerjs/sandbox-moleculer-api-routing/tree/master/?fontsize=14)
{% endnote %}

## 安装
```bash
npm i moleculer-web
```

## 使用

### 运行默认设置
这个示例使用默认设置的API Gateway服务。 您可以通过`http://localhost:3000/`访问所有服务（包括内部的`$node.`）。

```js
const { ServiceBroker } = require("moleculer");
const ApiService = require("moleculer-web");

const broker = new ServiceBroker();

// 加载 API 网关服务
broker.createService(ApiService);

// 启动服务器
broker.start();
```

**URLs 示例:**
- 调用`test.hello` action: `http://localhost:3000/test/hello`
- 使用参数调用`math.add` action: `http://localhost:3000/math/add?a=25&b=13`

- 获取节点的健康信息：`http://localhost:3000/~node/health`
- 列出所有Action：`http://localhost:3000/~node/actions`

## 白名单（Whitelist）
如果您不想发布所有的action，可以使用白名单选项进行过滤。 在列表中使用匹配字符串或正则表达式。 _要启用所有action，请使用` "**" `。_

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            path: "/api",

            whitelist: [
                // 访问 'posts' 服务中的任何操作
                "posts.*",
                // 仅访问 `users.list` 操作
                "users.list",
                // 访问 'math' 服务中的任何操作
                /^math\.\w+$/
            ]
        }]
    }
});
```

## 别名（Aliases）
你可以使用别名代替动作名称。 你也可以指定方法。 否则它将处理每一个方法类型。

可以在别名中使用命名参数。 命名参数是通过在参数名称前加冒号 (`:name`).来定义的。

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                // 使用 `GET /login` 或 `POST /login` 调用 `auth.login` 动作
                "login": "auth.login",

                // 限制请求方法
                "POST users": "users.create",

                // `name` 来自命名参数。 
                // 您可以在动作中使用 `ctx.params.name` 访问它。
                "GET greeter/:name": "test.greeter",
            }
        }]
    }
});
```

{% note info %}
命名参数使用[path-to-regexp](https://github.com/pillarjs/path-to-regexp) 模块来处理。 因此，您可以使用 [optional](https://github.com/pillarjs/path-to-regexp#optional) 和 [repeated](https://github.com/pillarjs/path-to-regexp#zero-or-more) 参数。
{% endnote %}

{% note info Aliases Action%}
API网关实现了 `listAliases` [action](actions.html) ，可以列出HTTP端点（如“GET users”）到动作映射。
{% endnote %}

你也可以创建RESTful API。
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "GET users": "users.list",
                "GET users/:id": "users.get",
                "POST users": "users.create",
                "PUT users/:id": "users.update",
                "DELETE users/:id": "users.remove"
            }
        }]
    }
});
```

对于REST路由，您还可以使用这个简单的简写别名：
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "REST users": "users"
            }
        }]
    }
});
```
{% note warn %}
要使用这个简写别名，需要创建一个具有 `list`, `get`, `create`, `update` 和`remove` 操作的服务。
{% endnote %}

您可以在别名声明中使用自定义函数。 在这种情况下，处理程序的写法是 `function (req, res) {...}`。

{% note info %}
请注意，Moleculer使用原生的Node.js [HTTP server](https://nodejs.org/api/http.html)。
{% endnote %}

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "POST upload"(req, res) {
                    this.parseUploadedFile(req, res);
                },
                "GET custom"(req, res) {
                    res.end('hello from custom handler')
                }
            }
        }]
    }
});
```

{% note info %}
`req` & `res` 对象中有一些内部引用：
* `req.$ctx` 指向请求上下文。
* `req.$service` 和 `res.$service` 指向此服务实例。
* `req.$route` 和 `res.$route` 指向已解析的路由定义。
* `req.$params` 指向已解析的参数（来自Query String和POST Body）。
* `req.$alias` 指向已解析的别名定义。
* `req.$action` 指向已解析的动作。
* `req.$endpoint` 指向已解析的动作端点。
* 如果请求来自ExpressJS，则`req.$next` 指向`next()`处理程序。

例如：要访问broker，请使用`req.$service.broker`。
{% endnote %}

### 映射策略（Mapping policy）
`route`有一个 `mappingPolicy` 属性，用于处理没有别名的路由。

**可用选项：**
- `all` - 允许请求所有带或不带别名的路由（默认值）
- `restrict` - 仅允许请求带有别名的路由。

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            mappingPolicy: "restrict",
            aliases: {
                "POST add": "math.add"
            }
        }]
    }
});
```
你无法请求`/math.add` 或 `/math/add` URL，只能请求`POST /add`。

### 文件上传别名
API 网关已实现文件上传功能。 您可以将文件上传为多重表单（Multipart Form）数据（感谢[busboy](https://github.com/mscdex/busboy) 库）或原始请求体（request body）。 在两种情况下，文件都作为`Stream`传输到action中。 在多重表单数据模式下，您也可以上传多个文件。

**示例**
```js
const ApiGateway = require("moleculer-web");

module.exports = {
    mixins: [ApiGateway],
    settings: {
        path: "/upload",

        routes: [
            {
                path: "",

                aliases: {
                    // 从 HTML 多重表单上传文件
                    "POST /": "multipart:file.save",

                    // 从 AJAX 或 cURL 上传文件
                    "PUT /:id": "stream:file.save",

                    // 从 HTML 表单上传文件并覆盖 busboy 配置
                    "POST /multi": {
                        type: "multipart",
                        // action级别的 busboy 配置
                        busboyConfig: {
                            limits: { files: 3 }
                        },
                        action: "file.save"
                    }
                },

                // 路由级别的 busboy 配置。
                // 更多信息：https://github.com/mscdex/busboy#busboy-methods
                busboyConfig: {
                    limits: { files: 1 }
                    // 可以定义 limit 事件处理程序
                    // `onPartsLimit`, `onFilesLimit` 或 `onFieldsLimit`
                },

                mappingPolicy: "restrict"
            }
        ]
    }
});
```
**多重参数（Multipart parameters）**

关于多重参数，为了访问通过多重表单传递的文件，可以在操作内部使用以下特定字段：
- `ctx.params` 是包含传递到端点的文件的可读流。
- `ctx.meta.$params` 包含 URL 查询字符串（querystring）的参数。
- `ctx.meta.$multipart` 包含在_其他文件字段_之前必须发送的附加文本表单数据字段。

### 自动别名（Auto-alias）
自动别名功能允许您直接在服务中声明路由别名。 网关将从服务架构动态构建完整的路由。

{% note info %}
网关将在每次服务加入或离开网络时重新生成路由。
{% endnote %}

使用`whitelist` 参数来指定网关应追踪和构建路由的服务。

**示例**
```js
// api.service.js
module.exports = {
    mixins: [ApiGateway],

    settings: {
        routes: [
            {
                path: "/api",

                whitelist: [
                    "v2.posts.*",
                    "test.*"
                ],

                aliases: {
                    "GET /hi": "test.hello"
                },

                autoAliases: true
            }
        ]
    }
};
```

```js
// posts.service.js
module.exports = {
    name: "posts",
    version: 2,

    settings: {
        // 基础路径
        // rest: "posts/" // 如果您想更改基础路径
        // 例如更改为“/api/posts”
        // 可以取消注释rest: "posts/"行。
    },

    actions: {
        list: {
            // 暴露为 "/api/v2/posts/"
            rest: "GET /",
            handler(ctx) {}
        },

        get: {
            // 暴露为 "/api/v2/posts/:id"
            rest: "GET /:id",
            handler(ctx) {}
        },

        create: {
            rest: "POST /",
            handler(ctx) {}
        },

        update: {
            rest: "PUT /:id",
            handler(ctx) {}
        },

        remove: {
            rest: "DELETE /:id",
            handler(ctx) {}
        }
    }
};
```

**最终生成的别名**

```bash
    GET     /api/hi             => test.hello
    GET     /api/v2/posts       => v2.posts.list
    GET     /api/v2/posts/:id   => v2.posts.get
    POST    /api/v2/posts       => v2.posts.create
    PUT     /api/v2/posts/:id   => v2.posts.update
    DELETE  /api/v2/posts/:id   => v2.posts.remove
```

**服务层次Rest参数**

- **fullPath**, 用一个新的自定义路径覆盖所有生成的路径
- **basePath**, 服务的路径， 默认是在 `settings.rest`中声明的路径。
- **path**, action的路径
- **method**, 访问action的方法

path被附加到basePath之后 path+basePath的组合与使用fullPath不同。 例如：

```js
// posts.service.js
module.exports = {
    name: "posts",
    version: 2,

    settings: {
        // Base path
        rest: "posts/"
    },

    actions: {
        tags: {
            // 作为“/tags”公开，而不是“/api/v2/posts/tags”
            rest: [{
                method: "GET",
                fullPath: "/tags"
            }, {
                method: "GET",
                basePath: "/my/awesome"
            }],
            handler(ctx) {}
        }
    }
};
```

这将创建这些端点：

```bash
    GET     /tags
    GET     /api/my/awesome/tags
```

fullPath忽略了API网关中应用的前缀！

*rest* 参数也可以是一个数组，其中包含与之前讨论的结构相同的元素。 它们可以应用于settings和action级别。 例如：

```js
// posts.service.js
module.exports = {
  name: "posts",
  settings: {
    rest: 'my/awesome/posts'
  },
  actions: {
    get: {
      rest: [
        "GET /:id",
        { method: 'GET', fullPath: '/posts' }
        { method: 'GET', path: '/' }, 
        { method: 'GET', path: '/:id', basePath: 'demo_posts' }
    ],
      handler(ctx) {}
    },
  }
};
```

这将生成下列端点：

```bash
    GET     /api/my/awesome/posts/:id/  => posts.get
    GET     /posts                      => posts.get
    GET     /api/my/awesome/posts/      => posts.get
    POST    /api/demo_posts/:id         => posts.get
```

## Parameters
API网关从URL查询字符串（querystring）、请求参数（params）和请求正文（body ）中收集参数并合并它们。 结果放在`req.$params`种。

### 禁用合并
在路由setting中设置 `mergeParams: false` 来禁用参数合并。 在这种情况下参数会被分开。

**示例**
```js
broker.createService({
    mixins: [ApiService],
    settings: {
        routes: [{
            path: "/",
            mergeParams: false
        }]
    }
});
```

**未被合并到`req.$params`:**
```js
{
    // 查询字符串参数（Querystring ）
    query: {
        category: "general",
    }

    // 请求正文内容（Request body）
    body: {
        title: "Hello",
        content: "...",
        createdAt: 1530796920203
    },

    // 请求参数（params）
    params: {
        id: 5
    }
}
```

### 查询字符串参数（Query string parameters）
More information: https://github.com/ljharb/qs

**数组形式的参数** URL: `GET /api/opt-test?a=1&a=2`
```js
a: ["1", "2"]
```

**嵌套对象和数组** URL: `GET /api/opt-test?foo[bar]=a&foo[bar]=b&foo[baz]=c`
```js
foo: { 
    bar: ["a", "b"], 
    baz: "c" 
}
```

## 中间件
It supports Connect-like middlewares in global-level, route-level & alias-level. Signature: `function(req, res, next) {...}`. For more info check [express middleware](https://expressjs.com/en/guide/using-middleware.html)

**示例**
```js
broker.createService({
    mixins: [ApiService],
    settings: {
        // Global middlewares. Applied to all routes.
        use: [
            cookieParser(),
            helmet()
        ],

        routes: [
            {
                path: "/",

                // Route-level middlewares.
                use: [
                    compression(),

                    passport.initialize(),
                    passport.session(),

                    serveStatic(path.join(__dirname, "public"))
                ],

                aliases: {
                    "GET /secret": [
                        // Alias-level middlewares.
                        auth.isAuthenticated(),
                        auth.hasRole("admin"),
                        "top.secret" // Call the `top.secret` action
                    ]
                }
            }
        ]
    }
});
```
Use [swagger-stats UI](https://swaggerstats.io/) for quick look on the "health" of your API (TypeScript)
```ts
import { Service, ServiceSchema } from "moleculer";
import ApiGatewayService from "moleculer-web";
const swStats = require("swagger-stats");

const swMiddleware = swStats.getMiddleware();

broker.createService({
    mixins: [ApiGatewayService],
    name: "gw-main",

    settings: {
        cors: {
            methods: ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"],
            origin: "*",
        },

        routes: [
            // ...
        ],

        use: [swMiddleware],
    },

    async started(this: Service): Promise<void> {
        this.addRoute({
            path: "/",
            use: [swMiddleware],
        });
    },
} as ServiceSchema);
```

### Error-handler middleware
There is support to use error-handler middlewares in the API Gateway. So if you pass an `Error` to the `next(err)` function, it will call error handler middlewares which have signature as `(err, req, res, next)`.

```js
broker.createService({
    mixins: [ApiService],
    settings: {
        // Global middlewares. Applied to all routes.
        use: [
            cookieParser(),
            helmet()
        ],

        routes: [
            {
                path: "/",

                // Route-level middlewares.
                use: [
                    compression(),

                    passport.initialize(),
                    passport.session(),

                    function(err, req, res, next) {
                        this.logger.error("Error is occured in middlewares!");
                        this.sendError(req, res, err);
                    }
                ],
```

## Serve static files
It serves assets with the [serve-static](https://github.com/expressjs/serve-static) module like ExpressJS.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        assets: {
            // Root folder of assets
            folder: "./assets",

            // Further options to `serve-static` module
            options: {}
        }       
    }
});
```

## Calling options
The `route` has a `callOptions` property which is passed to `broker.call`. So you can set `timeout`, `retries` or `fallbackResponse` options for routes. [Read more about calling options](actions.html#Call-services)

{% note info %}
Please note that you can also set the timeout for an action directly in its [definition](actions.html#Timeout)
{% endnote %}

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{

            callOptions: {
                timeout: 500,
                retries: 3,
                fallbackResponse(ctx, err) { ... }
            }

        }]
    }
});
```

## Multiple routes
You can create multiple routes with different prefix, whitelist, alias, calling options & authorization.

{% note info %}
When using multiple routes you should explicitly set the body parser(s) for each route.
{% endnote %}

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [
            {
                path: "/admin",

                authorization: true,

                whitelist: [
                    "$node.*",
                    "users.*",
                ],

                bodyParsers: {
                    json: true
                }
            },
            {
                path: "/",

                whitelist: [
                    "posts.*",
                    "math.*",
                ],

                bodyParsers: {
                    json: true
                }
            }
        ]
    }
});
```

## Response type & status code
When the response is received from an action handler, the API gateway detects the type of response and set the `Content-Type` in the `res` headers. The status code is `200` by default. Of course you can overwrite these values, moreover, you can define custom response headers, too.

To define response headers & status code use `ctx.meta` fields:

**Available meta fields:**
* `ctx.meta.$statusCode` - set `res.statusCode`.
* `ctx.meta.$statusMessage` - set `res.statusMessage`.
* `ctx.meta.$responseType` - set `Content-Type` in header.
* `ctx.meta.$responseHeaders` - set all keys in header.
* `ctx.meta.$location` - set `Location` key in header for redirects.

**示例**
```js
module.exports = {
    name: "export",
    actions: {
        // Download response as a file in the browser
        downloadCSV(ctx) {
            ctx.meta.$responseType = "text/csv";
            ctx.meta.$responseHeaders = {
                "Content-Disposition": `attachment; filename="data-${ctx.params.id}.csv"`
            };

            return csvFileStream;
        },

        // Redirect the request
        redirectSample(ctx) {
            ctx.meta.$statusCode = 302;
            ctx.meta.$location = "/login";

            return;
        }
    }
}
```

## Authorization
You can implement authorization. Do 2 things to enable it.
1. Set `authorization: true` in your routes
2. Define the `authorize` method in service.

**Example authorization**
```js
const E = require("moleculer-web").Errors;

broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            // First thing
            authorization: true
        }]
    },

    methods: {
        // Second thing
        authorize(ctx, route, req, res) {
            // Read the token from header
            let auth = req.headers["authorization"];
            if (auth && auth.startsWith("Bearer")) {
                let token = auth.slice(7);

                // Check the token
                if (token == "123456") {
                    // Set the authorized user entity to `ctx.meta`
                    ctx.meta.user = { id: 1, name: "John Doe" };
                    return Promise.resolve(ctx);

                } else {
                    // Invalid token
                    return Promise.reject(new E.UnAuthorizedError(E.ERR_INVALID_TOKEN));
                }

            } else {
                // No token
                return Promise.reject(new E.UnAuthorizedError(E.ERR_NO_TOKEN));
            }
        }

    }
}
```

{% note info %}
You can find a more detailed role-based JWT authorization example in [full example](https://github.com/moleculerjs/moleculer-web/blob/master/examples/full/index.js#L239).
{% endnote %}

## Authentication
To enable the support for authentication, you need to do something similar to what is describe in the Authorization paragraph. Also in this case you have to:
1. Set `authentication: true` in your routes
2. Define your custom `authenticate` method in your service

The returned value will be set to the `ctx.meta.user` property. You can use it in your actions to get the logged in user entity.

**Example authentication**
```js
broker.createService({
    mixins: ApiGatewayService,

    settings: {
        routes: [{
            // Enable authentication
            authentication: true
        }]
    },

    methods: {
        authenticate(ctx, route, req, res) {
            let accessToken = req.query["access_token"];
            if (accessToken) {
                if (accessToken === "12345") {
                    // valid credentials. It will be set to `ctx.meta.user`
                    return Promise.resolve({ id: 1, username: "john.doe", name: "John Doe" });
                } else {
                    // invalid credentials
                    return Promise.reject();
                }
            } else {
                // anonymous user
                return Promise.resolve(null);
            }
        }
    }
});
```

## Route hooks
The `route` has before & after call hooks. You can use it to set `ctx.meta`, access `req.headers` or modify the response `data`.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [
            {
                path: "/",

                onBeforeCall(ctx, route, req, res) {
                    // Set request headers to context meta
                    ctx.meta.userAgent = req.headers["user-agent"];
                },

                onAfterCall(ctx, route, req, res, data) {
                    // Async function which return with Promise
                    return doSomething(ctx, res, data);
                }
            }
        ]
    }
});
```

> In previous versions of Moleculer Web, you couldn't manipulate the `data` in `onAfterCall`. Now you can, but you must always return the new or original `data`.


## Error handlers
You can add route-level & global-level custom error handlers.
> In handlers, you must call the `res.end`. Otherwise, the request is unhandled.

```js
broker.createService({
    mixins: [ApiService],
    settings: {

        routes: [{
            path: "/api",

            // Route error handler
            onError(req, res, err) {
                res.setHeader("Content-Type", "application/json; charset=utf-8");
                res.writeHead(500);
                res.end(JSON.stringify(err));
            }
        }],

        // Global error handler
        onError(req, res, err) {
            res.setHeader("Content-Type", "text/plain");
            res.writeHead(501);
            res.end("Global error: " + err.message);
        }       
    }
}
```

### Error formatter
API gateway implements a helper function that formats the error. You can use it to filter out the unnecessary data.

```js
broker.createService({
    mixins: [ApiService],
    methods: {
        reformatError(err) {
            // Filter out the data from the error before sending it to the client
            return _.pick(err, ["name", "message", "code", "type", "data"]);
        },
    }
}
```

## CORS headers
You can use [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) headers in Moleculer-Web service.

**用例**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {

        // Global CORS settings for all routes
        cors: {
            // Configures the Access-Control-Allow-Origin CORS header.
            origin: "*",
            // Configures the Access-Control-Allow-Methods CORS header. 
            methods: ["GET", "OPTIONS", "POST", "PUT", "DELETE"],
            // Configures the Access-Control-Allow-Headers CORS header.
            allowedHeaders: [],
            // Configures the Access-Control-Expose-Headers CORS header.
            exposedHeaders: [],
            // Configures the Access-Control-Allow-Credentials CORS header.
            credentials: false,
            // Configures the Access-Control-Max-Age CORS header.
            maxAge: 3600
        },

        routes: [{
            path: "/api",

            // Route CORS settings (overwrite global settings)
            cors: {
                origin: ["http://localhost:3000", "https://localhost:4000"],
                methods: ["GET", "OPTIONS", "POST"],
                credentials: true
            },
        }]
    }
});
```

## Rate limiter
The Moleculer-Web has a built-in rate limiter with a memory store.

**用例**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {
        rateLimit: {
            // How long to keep record of requests in memory (in milliseconds). 
            // Defaults to 60000 (1 min)
            window: 60 * 1000,

            // Max number of requests during window. Defaults to 30
            limit: 30,

            // Set rate limit headers to response. Defaults to false
            headers: true,

            // Function used to generate keys. Defaults to: 
            key: (req) => {
                return req.headers["x-forwarded-for"] ||
                    req.connection.remoteAddress ||
                    req.socket.remoteAddress ||
                    req.connection.socket.remoteAddress;
            },
            //StoreFactory: CustomStore
        }
    }
});
```

### Custom Store example
```js
class CustomStore {
    constructor(clearPeriod, opts) {
        this.hits = new Map();
        this.resetTime = Date.now() + clearPeriod;

        setInterval(() => {
            this.resetTime = Date.now() + clearPeriod;
            this.reset();
        }, clearPeriod);
    }

    /**
     * Increment the counter by key
     *
     * @param {String} key
     * @returns {Number}
     */
    inc(key) {
        let counter = this.hits.get(key) || 0;
        counter++;
        this.hits.set(key, counter);
        return counter;
    }

    /**
     * Reset all counters
     */
    reset() {
        this.hits.clear();
    }
}
```

## ETag

The `etag` option value can be `false`, `true`, `weak`, `strong`, or a custom `Function`. For full details check the [code](https://github.com/moleculerjs/moleculer-web/pull/92).

```js
const ApiGateway = require("moleculer-web");

module.exports = {
    mixins: [ApiGateway],
    settings: {
        // Service-level option
        etag: false,
        routes: [
            {
                path: "/",
                // Route-level option.
                etag: true
            }
        ]
    }
}
```

**Custom `etag` Function**
```js
module.exports = {
    mixins: [ApiGateway],
    settings: {
        // Service-level option
        etag: (body) => generateHash(body)
    }
}
```

Please note, it doesn't work with stream responses. In this case, you should generate the `etag` by yourself.

**Custom `etag` for streaming**
```js
module.exports = {
    name: "export",
    actions: {
        // Download response as a file in the browser
        downloadCSV(ctx) {
            ctx.meta.$responseType = "text/csv";
            ctx.meta.$responseHeaders = {
                "Content-Disposition": `attachment; filename="data-${ctx.params.id}.csv"`,
                "ETag": '<your etag here>'
            };
            return csvFileStream;
        }
    }
}
```

## HTTP2 Server
API Gateway provides an experimental support for HTTP2. You can turn it on with `http2: true` in service settings. **示例**
```js
const ApiGateway = require("moleculer-web");

module.exports = {
    mixins: [ApiGateway],
    settings: {
        port: 8443,

        // HTTPS server with certificate
        https: {
            key: fs.readFileSync("key.pem"),
            cert: fs.readFileSync("cert.pem")
        },

        // Use HTTP2 server
        http2: true
    }
});
```

## ExpressJS middleware usage
You can use Moleculer-Web as a middleware in an [ExpressJS](http://expressjs.com/) application.

**用例**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {
        server: false // Default is "true"
    }
});

// Create Express application
const app = express();

// Use ApiGateway as middleware
app.use("/api", svc.express());

// Listening
app.listen(3000);

// Start server
broker.start();
```


## Full service settings
List of all settings of Moleculer Web service:

```js
settings: {

    // Exposed port
    port: 3000,

    // Exposed IP
    ip: "0.0.0.0",

    // HTTPS server with certificate
    https: {
        key: fs.readFileSync("ssl/key.pem"),
        cert: fs.readFileSync("ssl/cert.pem")
    },

    // Used server instance. If null, it will create a new HTTP(s)(2) server
    // If false, it will start without server in middleware mode
    server: true,

    // Exposed global path prefix
    path: "/api",

    // Global-level middlewares
    use: [
        compression(),
        cookieParser()
    ],

    // Logging request parameters with 'info' level
    logRequestParams: "info",

    // Logging response data with 'debug' level
    logResponseData: "debug",

    // Use HTTP2 server (experimental)
    http2: false,

    // Override HTTP server default timeout
    httpServerTimeout: null,

    // Optimize route & alias paths (deeper first).
    optimizeOrder: true,

    // Options passed on to qs
    qsOptions: {},

    // Routes
    routes: [
        {
            // Path prefix to this route  (full path: /api/admin )
            path: "/admin",

            // Whitelist of actions (array of string mask or regex)
            whitelist: [
                "users.get",
                "$node.*"
            ],

            // Call the `this.authorize` method before call the action
            authorization: true,

            // Merge parameters from querystring, request params & body 
            mergeParams: true,

            // Route-level middlewares
            use: [
                helmet(),
                passport.initialize()
            ],

            // Action aliases
            aliases: {
                "POST users": "users.create",
                "health": "$node.health"
            },

            mappingPolicy: "all",

            // Use bodyparser module
            bodyParsers: {
                json: true,
                urlencoded: { extended: true }
            }
        },
        {
            // Path prefix to this route  (full path: /api )
            path: "",

            // Whitelist of actions (array of string mask or regex)
            whitelist: [
                "posts.*",
                "file.*",
                /^math\.\w+$/
            ],

            // No authorization
            authorization: false,

            // Action aliases
            aliases: {
                "add": "math.add",
                "GET sub": "math.sub",
                "POST divide": "math.div",
                "GET greeter/:name": "test.greeter",
                "GET /": "test.hello",
                "POST upload"(req, res) {
                    this.parseUploadedFile(req, res);
                }
            },

            mappingPolicy: "restrict",

            // Use bodyparser module
            bodyParsers: {
                json: false,
                urlencoded: { extended: true }
            },

            // Calling options
            callOptions: {
                timeout: 3000,
                retries: 3,
                fallbackResponse: "Static fallback response"
            },

            // Call before `broker.call`
            onBeforeCall(ctx, route, req, res) {
                ctx.meta.userAgent = req.headers["user-agent"];
            },

            // Call after `broker.call` and before send back the response
            onAfterCall(ctx, route, req, res, data) {
                res.setHeader("X-Custom-Header", "123456");
                return data;
            },

            // Route error handler
            onError(req, res, err) {
                res.setHeader("Content-Type", "text/plain");
                res.writeHead(err.code || 500);
                res.end("Route error: " + err.message);
            }
        }
    ],

    // Folder to server assets (static files)
    assets: {
        // Root folder of assets
        folder: "./examples/www/assets",

        // Options to `server-static` module
        options: {}
    },

    // Global error handler
    onError(req, res, err) {
        res.setHeader("Content-Type", "text/plain");
        res.writeHead(err.code || 500);
        res.end("Global error: " + err.message);
    }    
}
```
## Service Methods
### `addRoute`
This service [method](services.html#Methods) (`this.addRoute(opts, toBottom = true)`) add/replace a route. For example, you can call it from your mixins to define new routes (e.g. swagger route, graphql route, etc.).

> Please note that if a route already exists this method will replace previous route configuration with a new one.

### `removeRoute`
Service method removes the route by path (`this.removeRoute("/admin")`).

## 示例
- [Simple](https://github.com/moleculerjs/moleculer-web/blob/master/examples/simple/index.js)
    - simple gateway with default settings.

- [SSL server](https://github.com/moleculerjs/moleculer-web/blob/master/examples/ssl/index.js)
    - open HTTPS server
    - whitelist handling

- [WWW with assets](https://github.com/moleculerjs/moleculer-web/blob/master/examples/www/index.js)
    - serve static files from the `assets` folder
    - whitelist
    - aliases
    - multiple body-parsers

- [Authorization](https://github.com/moleculerjs/moleculer-web/blob/master/examples/authorization/index.js)
    - simple authorization demo
    - set the authorized user to `Context.meta`

- [REST](https://github.com/moleculerjs/moleculer-web/blob/master/examples/rest/index.js)
    - simple server with RESTful aliases
    - example `posts` service with CRUD actions

- [Express](https://github.com/moleculerjs/moleculer-web/blob/master/examples/express/index.js)
    - webserver with Express
    - use moleculer-web as a middleware

- [Socket.io](https://github.com/moleculerjs/moleculer-web/blob/master/examples/socket.io/index.js)
    - start socket.io websocket server
    - call action and send back the response via websocket
    - send Moleculer events to the browser via websocket

- [Full](https://github.com/moleculerjs/moleculer-web/blob/master/examples/full/index.js)
    - SSL
    - static files
    - middlewares
    - multiple routes with different roles
    - role-based authorization with JWT
    - whitelist
    - aliases with named params
    - multiple body-parsers
    - before & after hooks
    - metrics, statistics & validation from Moleculer
    - custom error handlers

- [Webpack](https://github.com/moleculerjs/moleculer-web/blob/master/examples/webpack)
    - Webpack development environment for client-side developing
    - webpack config file
    - compression
    - static file serving

- [Webpack-Vue](https://github.com/moleculerjs/moleculer-web/blob/master/examples/webpack-vue)
    - Webpack+Vue development environment for VueJS client developing
    - webpack config file
    - Hot-replacement
    - Babel, SASS, SCSS, Vue SFC
