title: Lifecycle
---

## Broker lifecycle
This section describes what happens when the broker is starting & stopping.

### Starting logic
When starting, the broker tries to establish a connection with the transporter. When it's done, it doesn't publish the local service list to remote nodes because it can't accept request yet. It starts all services (calls every [service `started` handler](lifecycle.html#started-event-handler)). Once all services started successfully, broker publishes the local service list to remote nodes. Hence, remote nodes only send requests after all local services are properly initialized and started.

<div align="center">
    <img src="../../../docs/0.14/assets/lifecycle/broker-start.svg" alt="Broker starting lifecycle diagram" />
</div>

{% note warn Avoid deadlocks %}
Deadlocks can occur when two services wait for each other. E.g.: `users` service has `dependencies: ["posts"]` and `posts` service has `dependencies: ["users"]`. To avoid it, remove the concerned service from `dependencies` and use `this.waitForServices` method in `started` handler instead.
{% endnote %}

### Stopping logic
When you call `broker.stop` or stop the process, at first broker publishes an empty service list to remote nodes, so they will route the requests to other instances instead of services that are stopping. Next, the broker starts [stopping](#stopped-event-handler) all local services. After that, the transporter disconnects and process exits.

<div align="center">
    <img src="../../../docs/0.14/assets/lifecycle/broker-stop.svg" alt="Broker stopping lifecycle diagram" />
</div>

## Service lifecycle
This section describes what happens when a service is starting & stopping and how you should use the lifecycle event handler.

### `created` event handler
This handler is triggered when the service instance is created (e.g.: at `broker.createService` or `broker.loadService`). You can use it to create other module instances (e.g. http server, database modules) and store them in `this`.

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
This is a sync event handler. You **cannot** return a `Promise` and you **cannot** use `async/await`.
{% endnote %}

### `started` event handler
This handler is triggered when the `broker.start` is called and the broker starts all local services. Use it to connect to database, listen servers...etc.

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
This is an async event handler. A `Promise` can be returned or use `async/await`.
{% endnote %}

### `stopped` event handler
This handler is triggered when the `broker.stop` is called and the broker starts stopping all local services. Use it to close database connections, close sockets...etc.

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
This is an async event handler. A `Promise` can be returned or use `async/await`.
{% endnote %}
