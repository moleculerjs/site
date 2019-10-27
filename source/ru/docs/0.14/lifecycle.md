title: Жизненный цикл
---

## Жизненный цикл брокера
Этот раздел описывает, что происходит, когда брокер запускается и останавливается.

### Логика запуска
When starting, the broker tries to establish a connection with the transporter. When it's done, it doesn't publish the local service list to remote nodes because it can't accept request yet. It starts all services (calls every [service `started` handler](lifecycle.html#started-event-handler)). Once all services started successfully, broker publishes the local service list to remote nodes. Hence, remote nodes only send requests after all local services are properly initialized and started.

<div align="center">
    <img src="assets/lifecycle/broker-start.svg" alt="Диаграмма жизненного цикла запуска брокера" />
</div>

{% note warn Avoid deadlocks %}
Deadlocks can occur when two services wait for each other. E.g.: `users` service has `dependencies: ["posts"]` and `posts` service has `dependencies: ["users"]`. To avoid it, remove the concerned service from `dependencies` and use `this.waitForServices` method in `started` handler instead.
{% endnote %}

### Логика остановки
When you call `broker.stop` or stop the process, at first broker publishes an empty service list to remote nodes, so they will route the requests to other instances instead of services that are stopping. Next, the broker starts [stopping](#stopped-event-handler) all local services. After that, the transporter disconnects and process exits.

<div align="center">
    <img src="assets/lifecycle/broker-stop.svg" alt="Диаграмма жизненного цикла останова брокера" />
</div>

## Жизненный цикл сервиса
Этот раздел описывает, что происходит, когда сервис запускается и останавливается, и как вам следует использовать обработчики событий жизненного цикла.

### Обработчик `created`
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
Это синхронный обработчик событий. **Нельзя** возвращать `Promise` и **нельзя** использовать `async/await`.
{% endnote %}

### Обработчик `started`
Этот обработчик запускается, когда вызывается `broker.start` и брокер запустил все локальные сервисы. Используйте его для подключения к базе данных, открытия сокетов... и т.д.

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
Это асинхронный обработчик событий. Можно вернуть `Promise` или использовать `async/await`.
{% endnote %}

### Обработчик `stopped`
Этот обработчик запускается, когда вызывается `broker.stop` и брокер начинает останавливать все локальные сервисы. Используйте его для закрытия соединений с базой данных, закрытия сокетов...и т.д.

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
Это асинхронный обработчик событий. Можно вернуть `Promise` или использовать `async/await`.
{% endnote %}
