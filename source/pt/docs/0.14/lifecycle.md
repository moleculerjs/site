title: Ciclo de vida
---

## Ciclo de vida do Broker
Esta seção descreve o que acontece quando o broker está iniciando & parando.

### Lógica de inicialização
Ao iniciar, o broker tenta estabelecer uma conexão com o módulo de transporte. Quando terminado, ele não publica a lista de serviços local para nós remotos porque ainda não pode aceitar requisições. Ele inicia os serviços (chama cada [ manipulador de serviço `iniciado`](lifecycle.html#started-event-handler)). Depois que todos os serviços iniciaram com sucesso, o broker publica a lista de serviço local para nós remotos. Portanto, nós remotos só enviam requisições depois que todos os serviços locais forem inicializados corretamente.

<div align="center">
    <img src="assets/lifecycle/broker-start.svg" alt="Broker starting lifecycle diagram" />
</div>

{% note warn Avoid deadlocks %}
Os deadlocks podem ocorrer quando dois serviços esperam um pelo outro. Ex: O serviço `users` tem `dependencies: ["posts"]` e o serviço `posts` tem `dependencies: ["users"]`. Para evitar isso, remova o serviço em questão de `dependencies` e ao invés disso use o método `this.waitForServices` no método `started`.
{% endnote %}

### Lógica de parada
When you call `broker.stop` or stop the process, at first broker publishes an empty service list to remote nodes, so they will route the requests to other instances instead of services that are stopping. Next, the broker starts [stopping](#stopped-event-handler) all local services. After that, the transporter disconnects and process exits.

<div align="center">
    <img src="assets/lifecycle/broker-stop.svg" alt="Broker stopping lifecycle diagram" />
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

### `merged` event handler
This handler is called after the service schemas (including [mixins](services.html#Mixins)) has been merged but before service is registered. It means you can manipulate the merged service schema before it's processed.
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