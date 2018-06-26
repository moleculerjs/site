title: Lifecycle
---

## Broker lifecycle
This section describes what happens when the broker is starting & stopping.

### Starting logic
The broker starts transporter connecting but it doesn't publish the local service list to remote nodes. When it's done, it starts all services (calls service `started` handler). Once all services start successfully, broker publishes the local service list to remote nodes. Hence remote nodes send requests only after all local service are started properly.

{% note warn Avoid deadlocks %}
You can make dead-locks when two services wait for each other. E.g.: `users` service has `dependencies: ["posts"]` and `posts` service has `dependencies: ["users"]`. To avoid it, remove the concerned service from `dependencies` and use `this.waitForServices` method out of `started` handler instead.
{% endnote %}

### Stopping logic

When you call `broker.stop` or stop the process, at first broker publishes an empty service list to remote nodes, so they can route the requests to other instances instead of services under stopping. Next, the broker starts stopping all local services. After that, the transporter disconnects.

## Service lifecycle
This section describes what happens when a service is starting & stopping and how you should use the lifecycle event handler.

## `created` event handler
It is triggered when the service instance is created (e.g.: at `broker.createService` or `broker.loadService`).
Use it to create other module instances (e.g. http server, database modules) and store them in `this`. 

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

> This is a sync event handler. You **cannot** return a `Promise` or you **cannot** use `async/await`.

## `started` event handler
It is triggered when the `broker.start` is called and the broker starts all local services. Use it to connect to database, listen servers...etc.

> This is an async event handler. You can return a `Promise` or you can use `async/await`.

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

## `stopped` event handler
It is triggered when the `broker.stop` is called and the broker starts stopping all local services. Use it to close database connections, close sockets...etc.

> This is an async event handler. You can return a `Promise` or you can use `async/await`.

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
