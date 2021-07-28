title: 服务
---
`Service` 表示 Moleculer 框架中的微服务。 您可以在服务中定义动作和订阅事件。 要创建服务，您必须定义一个方案。 服务方案类似于 [VueJS](https://vuejs.org/v2/guide/components.html#What-are-Components) 的一个组件。

## Schema
方案有一些主要部件: `name`, `version`, `settings`, `actions`, `methods`, `events`.

### 定义有2个动作的简单服务方案
```js
// math.service.js
module.exports = {
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },

        sub(ctx) {
            return Number(ctx.params.a) - Number(ctx.params.b);
        }
    }
}
```

## 基本属性
服务方案中有一些基础属性。
```js
// posts.v1.service.js
module.exports = {
    name: "posts",
    version: 1
}
```
`name` 是一个必须定义的属性。 当你调用它时，它是动作名称的第一部分。

> 要禁用服务名称前缀, 请在服务设置中修改 `$noServiceNamePrefix: true` 。

`version` 是一个可选的属性。 使用它来运行来自同一服务的多个版本。 它也是动作名称中的前缀。 它可以是 `Number` 或 `String`。
```js
// posts.v2.service.js
module.exports = {
    name: "posts",
    version: 2,
    actions: {
        find() {...}
    }
}
```
在版本 `2` 上调用此服务的动作 `find`:
```js
broker.call("v2.posts.find");
```

{% note info REST call %}
通过[API Gateway](moleculer-web.html), 发出请求 `GET /v2/posts/find`.
{% endnote %}

> 要禁用服务名称前缀, 请在服务设置中修改 `$noVersionPrefix: true` 。

## 设置
`settings` 属性是一个静态存储属性，您可以在那里存储每个设置/选项到您的服务。 您可以通过服务内的 `this.settings` 操作它。

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    settings: {
        transport: "mailgun"
    },

    action: {
        send(ctx) {
            if (this.settings.transport == "mailgun") {
                ...
            }
        }
    }
}
```
> `settings` 也可以在远程节点上获得。 它在发现服务期间转移。

### 内部设置
核心模块使用了一些内部设置。 这些设置名称具有 `$` _(dollar sign)_ 前缀。

| Name                   | Type      | Default | 说明              |
| ---------------------- | --------- | ------- | --------------- |
| `$noVersionPrefix`     | `Boolean` | `false` | 在动作名称中禁用版本前缀。   |
| `$noServiceNamePrefix` | `Boolean` | `false` | 在动作名称中禁用名字前缀。   |
| `$dependencyTimeout`   | `Number`  | `0`     | 等待此服务的依赖服务超时时间。 |
| `$shutdownTimeout`     | `Number`  | `0`     | 超时关闭此等待的活动请求。   |
| `$secureSettings`      | `Array`   | `[]`    | 安全设置列表。         |

### 服务安全设置项
为了保护您的令牌 & API 密钥，在服务设置中定义 `$secureSettings: []` 属性并设置受保护的属性键。 受保护的设置不会被发布到其他节点，它不会出现在服务注册表中。 这些设置仅在服务函数内的 `this.settings` 下可用。

```js
// mail.service.js
module.exports = {
    name: "mailer",
    settings: {
        $secureSettings: ["transport.auth.user", "transport.auth.pass"],

        from: "sender@moleculer.services",
        transport: {
            service: 'gmail',
            auth: {
                user: 'gmail.user@gmail.com',
                pass: 'yourpass'
            }
        }
    }        
    // ...
};
```

## 混入
Mixins 是分配 Moleculer 服务的可重复使用功能的一种灵活的方式。 服务构造器将这些混入功能与当前服务方案合并。 当一个服务使用混入时，mixins 中存在的所有属性都将被“混入”到当前的服务中。

**以下示例扩展 `moleculer-web` 服务**

```js
// api.service.js
const ApiGwService = require("moleculer-web");

module.exports = {
    name: "api",
    mixins: [ApiGwService]
    settings: {
        // Change port setting
        port: 8080
    },
    actions: {
        myAction() {
            // Add a new action to apiGwService service
        }
    }
}
```
上面的示例创建一个 `api` 服务，继承来自 `ApiGwService` 的所有属性，但覆盖端口设置并通过新的 `myAction` 动作扩展。

### 合并算法
合并算法取决于属性类型。

| Property                        | Algorithm                                                                                              |
| ------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `name`, `version`               | 合并 & 覆盖。                                                                                               |
| `settings`                      | 在 [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep) 的情况下深度扩展。                                |
| `metadata`                      | 在 [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep) 的情况下深度扩展。                                |
| `actions`                       | 在 [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep) 的情况下深度扩展。 _如果您在服务中设置为 `fals` 您可以禁用混入行为。_ |
| `hooks`                         | 在 [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep) 的情况下深度扩展。                                |
| `methods`                       | 合并 & 覆盖。                                                                                               |
| `events`                        | 连接侦听器。                                                                                                 |
| `created`, `started`, `stopped` | 连接侦听器。                                                                                                 |
| `mixins`                        | 合并 & 覆盖。                                                                                               |
| `dependencies`                  | 合并 & 覆盖。                                                                                               |
| _any custom_                    | 合并 & 覆盖。                                                                                               |

{% note info Merge algorithm examples %}
__合并 & 覆盖__: 如果 serviceA 有 `a: 5`, `b: 8` 且 serviceB 有`c: 10` `b: 15`, 混合服务将有 `a: 5`, `b: 15` and `c: 10` __Concatenate__: 如果 serviceA & serviceB 订阅 `users.created` 事件，当 `users.created` 事件发出时，两个事件处理程序都会被调用。
{% endnote %}

## Actions
服务公开的可调用的方法称为活动或动作或行为 (actions, 以后不加区分)。 他们可以使用 `broker.call` 或 `ctx.call` 来调用。 该动作可以是 `Function` (简写为 handler) 或一个对象具有 `handler` 属性及更多属性。 该动作应该放置在方案中的 `actions` 下. 参见 [actions documentation](actions.html).

```js
// math.service.js
module.exports = {
    name: "math",
    actions: {
        // Shorthand definition, only a handler function
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },

        // Normal definition with other properties. In this case
        // the `handler` function is required!
        mult: {
            cache: false,
            params: {
                a: "number",
                b: "number"
            },
            handler(ctx) {
                // The action properties are accessible as `ctx.action.*`
                if (!ctx.action.cache)
                    return Number(ctx.params.a) * Number(ctx.params.b);
            }
        }
    }
};
```
您可以这样调用上述动作
```js
const res = await broker.call("math.add", { a: 5, b: 7 });
const res = await broker.call("math.mult", { a: 10, b: 31 });
```

在动作中，您可以使用 `ctx.call` 方法在其他服务中调用其他嵌套动作。 它是 `broker.call`的一个别名，但它将自己设置为父 context (由于正确的追踪链)。
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        async get(ctx) {
            // Find a post by ID
            let post = posts[ctx.params.id];

            // Populate the post.author field through "users" service
            // Call the "users.get" action with author ID
            const user = await ctx.call("users.get", { id: post.author });
            if (user) {
                // Replace the author ID with the received user object
                post.author = user;
            }

            return post;
        }
    }
};
```
> 动作处理器的 `this` 总是指向 Service 实例。


## Events
您可以在 `events` 中订阅事件。 参见 [events documentation](events.html).

```js
// report.service.js
module.exports = {
    name: "report",

    events: {
        // Subscribe to "user.created" event
        "user.created"(ctx) {
            this.logger.info("User created:", ctx.params);
            // Do something
        },

        // Subscribe to all "user.*" events
        "user.*"(ctx) {
            console.log("Payload:", ctx.params);
            console.log("Sender:", ctx.nodeID);
            console.log("Metadata:", ctx.meta);
            console.log("The called event name:", ctx.eventName);
        }

        // Subscribe to a local event
        "$node.connected"(ctx) {
            this.logger.info(`Node '${ctx.params.id}' is connected!`);
        }
    }
};
```
> 动作处理器的 `this` 总是指向 Service 实例。

### Grouping
服务管理器按群组名称将事件监听器分组。 默认情况下，群组名称是服务名称。 但你可以在事件定义中覆盖它。

```js
// payment.service.js
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

## Methods
若要在服务中创建私有方法，请将您的函数放在 `methods` 中。 这些函数是私有的，无法与 `broker.call` 一起调用。 但你可以在服务中调用它(来自操作处理器、事件处理器和生命周期事件处理器)。

**用例**
```js
// mailer.service.js
module.exports = {
    name: "mailer",
    actions: {
        send(ctx) {
            // Call the `sendMail` method
            return this.sendMail(ctx.params.recipients, ctx.params.subject, ctx.params.body);
        }
    },

    methods: {
        // Send an email to recipients
        sendMail(recipients, subject, body) {
            return new Promise((resolve, reject) => {
                ...
            });
        }
    }
};
```
If you want to wrap a method with a [middleware](middlewares.html#localMethod-next-method) use the following notation:

```js
// posts.service.js
module.exports = {
    name: "posts",

    methods: {
        list: {
            async handler(count) {
                // Do something
                return posts;
            }
        }
    }
};
```


> 方法名称不能是 `name`, `version`, `settings`, `metadata`, `schema`, `broker`, `actions`, `logger`, 因为在方案中这些名字是保留的。

> 方法中的 `this` 总是指向 Service 实例。

## 生命周期事件
有一些生命周期服务事件，将由服务管理器触发。 它们放置服务方案中。

```js
// www.service.js
module.exports = {
    name: "www",
    actions: {...},
    events: {...},
    methods: {...},

    created() {
        // Fired when the service instance created (with `broker.loadService` or `broker.createService`)
    },

    merged() {
        // Fired after the service schemas merged and before the service instance created
    },

    async started() {
        // Fired when broker starts this service (in `broker.start()`)
    }

    async stopped() {
        // Fired when broker stops this service (in `broker.stop()`)
    }
};
```
## 依赖关系
如果您的服务依赖于其他服务，请使用方案中的 `dependencies` 属性。 服务在调用 `started` 事件之前会等待它的依赖服务处理完毕。

```js
// posts.service.js
module.exports = {
  name: "posts",
  settings: {
      $dependencyTimeout: 30000 // Default: 0 - no timeout
  },
  dependencies: [
      "likes", // shorthand w/o version
      "v2.auth", // shorthand w version
      { name: "users", version: 2 }, // with numeric version
      { name: "comments", version: "staging" } // with string version
  ],
  async started() {
      this.logger.info("It will be called after all dependent services are available.");
      const users = await this.broker.call("users.list");
  }
  ....
}
```
一旦 `likes`, `v2.auth`, `v2.users`, `staging.comments` (无论以上服务在本地还是远程节点) 变得可用，服务立即执行 `started` 处理器。

### 等待通过 ServiceBroker 提供的服务
可以使用 `ServiceBroker` 的方法 `waitForServices` 来等待服务。 所有定义的服务可用 & 启动后, 它返回的 `Promise` 将被解决。

**Parameters**

| Parameter  | Type                | Default | Description                                         |
| ---------- | ------------------- | ------- | --------------------------------------------------- |
| `services` | `String` or `Array` | -       | 等待服务列表                                              |
| `timeout`  | `Number`            | `0`     | 等待超时。 `0` 意味着没有超时。 如果超时，引发 `MoleculerServerError` 。 |
| `interval` | `Number`            | `1000`  | 以毫秒为单位的监视频率                                         |

**示例**
```js
broker.waitForServices(["posts", "v2.users"]).then(() => {
    // Called after the `posts` & `v2.users` services are available
});
```

**设置超时 & 间隔**
```js
broker.waitForServices("accounts", 10 * 1000, 500).then(() => {
    // Called if `accounts` service becomes available in 10 seconds
}).catch(err => {
    // Called if service is not available in 10 seconds
});
```

## 元数据

`Service` 方案有一个 `metadata` 属性。 您可以在此存储任何关于服务的元信息。 您可以在服务函数内用 `this.metadata` 访问它。 _Moleculer 核心模块不使用它, 你可以用它存储任何东西。_

```js
module.exports = {
    name: "posts",
    settings: {},
    metadata: {
        scalable: true,
        priority: 5
    },

    actions: { ... }
};
```
> `metadata` 也可以在远程节点上获得。 它在服务发现期间转移。

## ServiceBroker 属性
在服务函数中， `this` 始终指向服务实例。 它有一些属性 & 方法可以用于您的服务函数。

| Name                   | Type                 | Description                                                 |
| ---------------------- | -------------------- | ----------------------------------------------------------- |
| `this.name`            | `String`             | Name of service (from schema)                               |
| `this.version`         | `Number` or `String` | Version of service (from schema)                            |
| `this.fullName`        | `String`             | Name of version prefix                                      |
| `this.settings`        | `Object`             | Settings of service (from schema)                           |
| `this.metadata`        | `Object`             | Metadata of service (from schema)                           |
| `this.schema`          | `Object`             | Schema definition of service                                |
| `this.broker`          | `ServiceBroker`      | Instance of broker                                          |
| `this.Promise`         | `Promise`            | Class of Promise (Bluebird)                                 |
| `this.logger`          | `Logger`             | Logger instance                                             |
| `this.actions`         | `Object`             | Actions of service. _Service can call own actions directly_ |
| `this.waitForServices` | `Function`           | Link to `broker.waitForServices` method                     |
| `this.currentContext`  | `Context`            | Get or set the current Context object.                      |

## 服务创建
创建和加载服务有几种方式。

### broker.createService()
想要用于测试、开发或查看原型，使用 `broker.createService` 方法加载 & 通过 schema 创建的服务。 这是最简单 & 最快的方法。

```js
broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});
```

### 从文件载入服务
推荐的方式是将您的服务代码放入一个文件并加载到服务管理器。

**math.service.js**
```js
// Export the schema of service
module.exports = {
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },
        sub(ctx) {
            return Number(ctx.params.a) - Number(ctx.params.b);
        }
    }
}
```

**用服务管理器加载它：**
```js
// Create broker
const broker = new ServiceBroker();

// Load service
broker.loadService("./math.service");

// Start broker
broker.start();
```

在服务文件中，您也可以创建服务实例。 在这种情况下，您必须导出返回 [Service](#service) 实例的函数。
```js
const { Service } = require("moleculer");

// Export a function, the `loadService` will call it with the ServiceBroker instance.
module.exports = function(broker) {
    return new Service(broker, {
        name: "math",
        actions: {
            add(ctx) {
                return Number(ctx.params.a) + Number(ctx.params.b);
            },
            sub(ctx) {
                return Number(ctx.params.a) - Number(ctx.params.b);
            }
        }
    });
}
```

或者创建一个以服务模式返回的函数
```js
// Export a function, the `loadService` will call with the ServiceBroker instance.
module.exports = function() {
    let users = [....];

    return {
        name: "math",
        actions: {
            create(ctx) {
                users.push(ctx.params);
            }
        }
    };
}
```

### 从文件夹加载多个服务
如果您有许多服务(而且您必将会有)我们建议将它们放到 `services` 文件夹中，使用 `broker.loadServices` 方法加载它们。

**Syntax**
```js
broker.loadServices(folder = "./services", fileMask = "**/*.service.js");
```

**示例**
```js
// Load every *.service.js file from the "./services" folder (including subfolders)
broker.loadServices();

// Load every *.service.js file from the current folder (including subfolders)
broker.loadServices("./");

// Load every user*.service.js file from the "./svc" folder
broker.loadServices("./svc", "user*.service.js");
```

### (推荐) 使用 Moleculer Runner 加载
我们建议使用 [Moleculer Runner](runner.html) 启动一个 ServiceBroker 并加载服务。 [阅读更多关于 Moleculer Runner 的内容](runner.html)。 这是启动节点最容易的办法。

## 服务热重载
Moleculer 具有内置的热重载功能。 在开发过程中，它可能非常有用，因为当您修改它时它会重新加载您的服务。 您可以在服务管理器选项或 [Moleculer Runner](runner.html) 中启用它。 [视频演示它如何工作。](https://www.youtube.com/watch?v=l9FsAvje4F4)

**在服务管理器选项中启用**

```js
const broker = new ServiceBroker({
    hotReload: true
});

broker.loadService("./services/test.service.js");
```

**在 Moleculer Runner 中启用**

使用 `--hot` 或 `-H` 打开它。

```bash
$ moleculer-runner --hot ./services/test.service.js
```

{% note info %}
热重载功能仅适用于 Moleculer Runner ，或者如果您使用 `broker.loadService` 或 `broker.loadServices` 加载您的服务。 `broker.createService` 不起作用。
{% endnote %}

{% note info %}
热重载机制监视服务文件及其依赖。 每次检测到文件更改时，热重载机制将跟踪依赖它的服务并重新启动它们。
{% endnote %}

## 本地变量
如果您想要在您的服务中使用本地属性/变量，在 `created` 事件方法中声明它们。

**本地变量示例**
```js
const http = require("http");

module.exports = {
    name: "www",

    settings: {
        port: 3000
    },

    created() {
        // Create HTTP server
        this.server = http.createServer(this.httpHandler);
    },

    started() {
        // Listening...
        this.server.listen(this.settings.port);
    },

    stopped() {
        // Stop server
        this.server.close();
    },

    methods() {
        // HTTP handler
        httpHandler(req, res) {
            res.end("Hello Moleculer!");
        }
    }
}
```
{% note warn Naming restriction %}
注意，你不能使用保留给服务的变量名称，或者与你的方法名冲突！ 例如： `this.name`, `this.version`, `this.settings`, `this.schema`...等。
{% endnote %}

## ES6 Classes
如果您喜欢ES6类而不是Moleculer服务模式，您可以在 ES6 类中写入您的服务。 这样做有两种方式。

### 具有schema解析的原生ES6类

定义 `actions` 和 `events` 方法作为类方法并调用 `parseServiceSchema` 构造函数中包含schema 定义的方法，处理程序指向这些类方法。
```js
const Service = require("moleculer").Service;

class GreeterService extends Service {

    constructor(broker) {
        super(broker);

        this.parseServiceSchema({
            name: "greeter",
            version: "v2",
            meta: {
                scalable: true
            },
            dependencies: [
                "auth",
                "users"
            ],

            settings: {
                upperCase: true
            },
            actions: {
                hello: this.hello,
                welcome: {
                    cache: {
                        keys: ["name"]
                    },
                    params: {
                        name: "string"
                    },
                    handler: this.welcome
                }
            },
            events: {
                "user.created": this.userCreated
            },
            created: this.serviceCreated,
            started: this.serviceStarted,
            stopped: this.serviceStopped,
        });
    }

    // Action handler
    hello() {
        return "Hello Moleculer";
    }

    // Action handler
    welcome(ctx) {
        return this.sayWelcome(ctx.params.name);
    }

    // Private method
    sayWelcome(name) {
        this.logger.info("Say hello to", name);
        return `Welcome, ${this.settings.upperCase ? name.toUpperCase() : name}`;
    }

    // Event handler
    userCreated(user) {
        this.broker.call("mail.send", { user });
    }

    serviceCreated() {
        this.logger.info("ES6 Service created.");
    }

    serviceStarted() {
        this.logger.info("ES6 Service started.");
    }

    serviceStopped() {
        this.logger.info("ES6 Service stopped.");
    }
}

module.exports = GreeterService;
```

### 使用装饰器
感谢 [@ColonelBundy](https://github.com/ColonelBundy), 你也可以使用 ES7/TS 装饰符: [moleculer-decorators](https://github.com/ColonelBundy/moleculer-decorators)

{% note info Need a compiler %}
注意，您必须使用 Typescript 或 Babel 来编译装饰器。
{% endnote %}

**服务示例**
```js
const { ServiceBroker } = require('moleculer');
const { Service, Action, Event, Method } = require('moleculer-decorators');
const web = require('moleculer-web');
const broker = new ServiceBroker();

@Service({
    mixins: [web],
    settings: {
        port: 3000,
        routes: [
            //...
        ]
    }
})
class MyService {
    @Action()
    Login(ctx) {
        //...
    }

    // With options
    @Action({
        cache: false,
        params: {
            a: "number",
            b: "number"
        }
    })
    Login2(ctx) {
        //...
    }

    @Event
    'event.name'(payload, sender, eventName) {
        //...
    }

    @Method
    authorize(ctx, route, req, res) {
        //...
    }

    hello() { // Private
        //...
    }

    started() { // Reserved for moleculer, fired when started
        //...
    }

    created() { // Reserved for moleculer, fired when created
        //...
    }

    stopped() { // Reserved for moleculer, fired when stopped
        //...
    }
}

broker.createService(MyService);
broker.start();
```

## 内置服务
`ServiceBroker` 包含一些内部服务来检查节点健康状况或获取一些注册表信息。 您可以通过设置服务管理器选项 `internalServices: false` 来禁用他们。

### 节点列表
它列出所有已知节点(包括本地节点)。
```js
broker.call("$node.list").then(res => console.log(res));
```

**Parameters**

| Name            | Type      | Default | Description                |
| --------------- | --------- | ------- | -------------------------- |
| `withServices`  | `Boolean` | `false` | List with services.        |
| `onlyAvailable` | `Boolean` | `false` | List only available nodes. |

### 服务列表
它列出所有注册的服务(本地 & 远程)。
```js
broker.call("$node.services").then(res => console.log(res));
```

**Parameters**

| 名字              | Type      | 默认设置    | 描述                                    |
| --------------- | --------- | ------- | ------------------------------------- |
| `onlyLocal`     | `Boolean` | `false` | List only local services.             |
| `skipInternal`  | `Boolean` | `false` | Skip the internal services (`$node`). |
| `withActions`   | `Boolean` | `false` | List with actions.                    |
| `onlyAvailable` | `Boolean` | `false` | List only available services.         |

### 本地动作列表
它列出所有注册的动作(本地 & 远程)。
```js
broker.call("$node.actions").then(res => console.log(res));
```
它有一些您可以在 `params` 中声明的选项。

**Options**

| 名字              | Type      | 默认设置    | 描述                                   |
| --------------- | --------- | ------- | ------------------------------------ |
| `onlyLocal`     | `Boolean` | `false` | List only local actions.             |
| `skipInternal`  | `Boolean` | `false` | Skip the internal actions (`$node`). |
| `withEndpoints` | `Boolean` | `false` | List with endpoints _(nodes)_.       |
| `onlyAvailable` | `Boolean` | `false` | List only available actions.         |

### 本地事件列表
它列出所有事件订阅。
```js
broker.call("$node.events").then(res => console.log(res));
```
它有一些您可以在 `params` 中声明的选项。

**Options**

| 名字              | Type      | 默认设置    | 描述                                         |
| --------------- | --------- | ------- | ------------------------------------------ |
| `onlyLocal`     | `Boolean` | `false` | List only local subscriptions.             |
| `skipInternal`  | `Boolean` | `false` | Skip the internal event subscriptions `$`. |
| `withEndpoints` | `Boolean` | `false` | List with endpoints _(nodes)_.             |
| `onlyAvailable` | `Boolean` | `false` | List only available subscriptions.         |

### 性能指标列表
它列出了所有衡量标准。
```js
broker.call("$node.metrics").then(res => console.log(res));
```
它有一些您可以在 `params` 中声明的选项。

**Options**

| 名字         | Type                | 默认设置   | 描述                                                                             |
| ---------- | ------------------- | ------ | ------------------------------------------------------------------------------ |
| `types`    | `String` or `Array` | `null` | [Type](metrics.html#Supported-Metric-Types) of metrics to include in response. |
| `includes` | `String` or `Array` | `null` | List of metrics to be included in response.                                    |
| `excludes` | `String` or `Array` | `null` | List of metrics to be excluded from the response.                              |

### 获取服务管理器选项
它返回服务管理器选项。
```js
broker.call("$node.options").then(res => console.log(res));
```

### 节点健康值
它返回本地节点的健康信息(包括 process & OS 信息)。
```js
broker.call("$node.health").then(res => console.log(res));
```

健康信息示例：
```js
{
    "cpu": {
        "load1": 0,
        "load5": 0,
        "load15": 0,
        "cores": 4,
        "utilization": 0
    },
    "mem": {
        "free": 1217519616,
        "total": 17161699328,
        "percent": 7.094400109979598
    },
    "os": {
        "uptime": 366733.2786046,
        "type": "Windows_NT",
        "release": "6.1.7601",
        "hostname": "Developer-PC",
        "arch": "x64",
        "platform": "win32",
        "user": {
            "uid": -1,
            "gid": -1,
            "username": "Developer",
            "homedir": "C:\\Users\\Developer",
            "shell": null
        }
    },
    "process": {
        "pid": 13096,
        "memory": {
            "rss": 47173632,
            "heapTotal": 31006720,
            "heapUsed": 22112024
        },
        "uptime": 25.447
    },
    "client": {
        "type": "nodejs",
        "version": "0.12.0",
        "langVersion": "v8.9.4"
    },
    "net": {
        "ip": [
            "192.168.2.100",
            "192.168.232.1",
            "192.168.130.1",
            "192.168.56.1",
            "192.168.99.1"
        ]
    },
    "time": {
        "now": 1487338958409,
        "iso": "2018-02-17T13:42:38.409Z",
        "utc": "Fri, 17 Feb 2018 13:42:38 GMT"
    }
}
```
{% note info %}
注意，内部服务动作作未被追踪。
{% endnote %}

### 扩展
内部服务可以通过自定义功能轻松扩展。 要做到这一点，您必须定义一个 mixin schema `internalServices` 选项。

```javascript
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    logger: true,
    internalServices: {
        $node: {
            actions: {
                // Call as `$node.hello`
                hello(ctx) {
                    return `Hello Moleculer!`;
                }
            }
        }
    }
};
```
