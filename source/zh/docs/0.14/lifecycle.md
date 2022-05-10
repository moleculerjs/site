生命周期
---

## 服务管理器生命周期
本节描述服务管理器启动 & 停止时发生什么。

### 启动逻辑
启动时，服务器试图与 transporter 建立一个连接。 连接建立后，服务管理器此时还不能将本地服务列表发布到远程节点，因为此时它还不能接受任何请求。 服务管理器启动所有服务（通过调用所有[service 提供的`started`](lifecycle.html#started-event-handler)处理器）。 一旦所有服务成功启动，服务管理器就会向远程节点发布本地服务列表。 因此，远程节点仅在所有本地服务正常初始化和启动后发送请求。

<div align="center">
    <img src="assets/lifecycle/broker-start.svg" alt="Broker starting lifecycle diagram" />
</div>

{% note warn Avoid deadlocks %}
当两个服务相互等待对方，可能出现死锁。 例如： `users` 服务有 `dependencies:["posts"]` 和 `posts` 服务有 `dependencies:["users"]` 若要避免死锁，请从 `dependencies` 删除依赖，在 `started` 处理器中使用`this.waitForServices` 方法替代依赖项配置。
{% endnote %}

### 停止逻辑
当您调用 `broker.stop` 或停止进程时，服务管理器首先会向远程节点发布一个空的服务列表，因此它们会将请求路由到其他实例而不是正在停止的服务。 接着，服务管理器开始 [stopping](#stopped-event-handler) 所有本地服务。 而后，transporter 断开所有连接并退出进程。

<div align="center">
    <img src="assets/lifecycle/broker-stop.svg" alt="Broker stopping lifecycle diagram" />
</div>

## 服务生命周期
本节描述服务启动 & 停止时发生什么，以及您应如何使用生命周期事件处理器。

### `created` 事件处理器
当创建服务实例时触发此处理程序(例如， `broker.createService` 或 `broker.loadService`)。 您可以使用它来创建其它模块实例(例如http 服务器，数据库模块)，并将它们保存在 `this` 中。

```js
const http = require("http");

module.exports = {
    name: "www",
    created() {
        // Create HTTP server
        this.server = http.createServer(this.httpHandler);
    }
};
```

{% note info %}
这是一个同步事件处理器。 您 **无法** 返回 `Promise` 并且您 **不能** 使用 `async/await`。
{% endnote %}

### `started` 事件处理器
当调用 `broker.start` 并且经纪启动完所有本地服务时，触发此处理程序。 使用它来连接数据库、监听服务器...等。

```js
module.exports = {
    name: "users",
    async started() {
        try {
            await this.db.connect();
        } catch(e) {
            throw new MoleculerServerError("Unable to connect to database.", e.message);
        }
    }
};
```

{% note info %}
这是一个异步事件处理器。 可以返回 `Promise` 或者使用 `async/await`。
{% endnote %}

### `stopped` 事件处理器
当调用 `broker.stop` 并且服务管理器开始着手停止所有本地服务时，触发此处理程序。 使用它来关闭数据库连接，关闭套接字...等。

```js
module.exports = {
    name: "users",
    async stopped() {
        try {
            await this.db.disconnect();
        } catch(e) {
            this.logger.warn("Unable to stop database connection gracefully.", e);
        }
    }
};
```

{% note info %}
这是一个异步事件处理器。 可以返回 `Promise` 或者使用 `async/await`。
{% endnote %}

### `merged` 事件处理器
此处理器是在服务模式(包括 [mixins](services.html#Mixins)) 合并后调用的，但在服务注册之前调用。 这意味着您可以在处理之前操纵已合并的服务方案。
```js
// posts.service.js
module.exports = {
    name: "posts",

    settings: {},

    actions: {
        find: {
            params: {
                limit: "number"
            },
            handler(ctx) {
                // ...
            }
        }
    },

    merged(schema) {
        // Modify the service settings
        schema.settings.myProp = "myValue";
        // Modify the param validation schema in an action schema
        schema.actions.find.params.offset = "number";
    }
};
```