title: Ciclo de vida
---

## Ciclo de vida do Broker
Esta seção descreve o que acontece quando o broker está iniciando & parando.

### Lógica de inicialização
Ao iniciar, o broker tenta estabelecer uma conexão com o módulo de transporte. Quando terminado, ele não publica a lista de serviços local para nós remotos porque ainda não pode aceitar requisições. Ele inicia os serviços (chama cada [ manipulador de serviço `iniciado`](lifecycle.html#started-event-handler)). Depois que todos os serviços iniciaram com sucesso, o broker publica a lista de serviço local para nós remotos. Portanto, nós remotos só enviam requisições depois que todos os serviços locais forem inicializados corretamente.

<div align="center">
    <img src="assets/lifecycle/broker-start.svg" alt="Diagrama de ciclo de vida da inicialização do broker" />
</div>

{% note warn Avoid deadlocks %}
Os deadlocks podem ocorrer quando dois serviços esperam um pelo outro. Ex: O serviço `users` tem `dependencies: ["posts"]` e o serviço `posts` tem `dependencies: ["users"]`. Para evitar isso, remova o serviço em questão de `dependencies` e ao invés disso use o método `this.waitForServices` no método `started`.
{% endnote %}

### Lógica de parada
Quando você chamar o `broker.stop` ou parar o processo, inicialmente o broker publica uma lista de serviços vazia para os nós remotos, portanto, irão encaminhar as requisições para outras instâncias em vez de serviços que estão sendo desligados. Em seguida, o broker inicia a [parada](#stopped-event-handler) de todos os serviços locais. Depois disso, o módulo de transporte desconecta e processa o encerramento.

<div align="center">
    <img src="assets/lifecycle/broker-stop.svg" alt="Diagrama de ciclo de vida de parada do broker" />
</div>

## Ciclo de vida do serviço
Esta seção descreve o que acontece quando um serviço está iniciando & parando e como você deve usar o manipulador de eventos do ciclo de vida.

### Manipulador de eventos `created`
Este manipulador é acionado quando a instância do serviço é criada (por exemplo: em `broker.createService` ou `broker.loadService`). Você pode usá-lo para criar instâncias de outros módulos (por exemplo, servidor http, banco de dados) e armazená-los em `this`.

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
Este é um manipulador de eventos síncrono. Você **não pode** retornar uma `Promise` e você **não pode** usar `async/await`.
{% endnote %}

### Manipulador de eventos `started`
Este manipulador é acionado ao chamar `broker.start` e o broker inicia todos os serviços locais. Use-o para conectar ao banco de dados, se registrar a servidores... etc.

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
Este é um manipulador de eventos assíncrono. Uma `Promise` pode ser retornada ou use `async/await`.
{% endnote %}

### Manipulador de eventos `stopped`
Este manipulador é acionado ao chamar `broker.stop` e o broker inicia o desligamento de todos os serviços locais. Use-o para fechar conexões do banco de dados, encerrar sockets...etc.

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
Este é um manipulador de eventos assíncrono. Uma `Promise` pode ser retornada ou use `async/await`.
{% endnote %}

### Manipulador de eventos `merged`
Este manipulador é chamado após os esquemas de serviço (incluindo [mixins](services.html#Mixins)) forem mesclados, mas antes que o serviço seja registrado. Isso significa que você pode manipular o esquema de serviço mesclado antes dele ser processado.
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