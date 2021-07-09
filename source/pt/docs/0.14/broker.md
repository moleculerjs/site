title: Broker
---
O `ServiceBroker` é o componente principal do Moleculer. Ele lida com serviços, chamadas de ações, emite eventos e se comunica com nós remotos. Você deve criar uma instância do `ServiceBroker` em cada nó.

<div align="center">
    <img src="assets/service-broker.svg" alt="Broker logical diagram" />
</div>

## Criar um ServiceBroker

{% note info %}
**Dica rápida:** Você não precisa criar manualmente o ServiceBroker no seu projeto. Use o [Moleculer Runner](runner.html) para criar e executar um Broker e carregar serviços. [Leia mais sobre o Moleculer Runner](runner.html).
{% endnote %}

**Criar Broker com as configurações padrão:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker();
```

**Criar Broker com as configurações padrão:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "my-node"
});
```

**Criar broker com transporter para se comunicar com nós remotos:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "node-1",
    transporter: "nats://localhost:4222",
    logLevel: "debug",
    requestTimeout: 5 * 1000
});
```


### Opções de Metadata
Use a propriedade `metadados` para armazenar valores personalizados. Pode ser útil para um [middleware](middlewares.html#Loading-amp-Extending) customizado ou [estratégia](balancing.html#Custom-strategy) customizada.

```js
const broker = new ServiceBroker({
    nodeID: "broker-2",
    transporter: "NATS",
    metadata: {
        region: "eu-west1"
    }
});
```
{% note info %}
A propriedade `metadados` pode ser obtida executando a ação `$node.list`.
{% endnote %}

{% note info %}
A propriedade `metadados` é transferida para outros nós.
{% endnote %}

## Ping
Para fazer um ping em nós remotos, use o método `broker.ping`. Pode fazer um ping em um nó ou em todos os nós disponíveis. Ele retorna uma `Promise` que contém as informações de ping recebidas (latência, diferença de tempo). Um timeout pode ser definido.

### Fazer um ping em um nó com 1 segundo de timeout
```js
broker.ping("node-123", 1000).then(res => broker.logger.info(res));
```

**Saída**
```js
{ 
    nodeID: 'node-123', 
    elapsedTime: 16, 
    timeDiff: -3 
}
```
> O valor `timeDiff` é a diferença do relógio de sistema entre esses dois nós.

### Fazer um ping em múltiplos nós
```js
broker.ping(["node-100", "node-102"]).then(res => broker.logger.info(res));
```

**Saída**
```js
{ 
    "node-100": { 
        nodeID: 'node-100', 
        elapsedTime: 10, 
        timeDiff: -2 
    },
    "node-102": { 
        nodeID: 'node-102', 
        elapsedTime: 250, 
        timeDiff: 850 
    } 
}
```

### Fazer um ping em todos os nós disponíveis
```js
broker.ping().then(res => broker.logger.info(res));
```

**Saída**
```js
{ 
    "node-100": { 
        nodeID: 'node-100', 
        elapsedTime: 10, 
        timeDiff: -2 
    } ,
    "node-101": { 
        nodeID: 'node-101', 
        elapsedTime: 18, 
        timeDiff: 32 
    }, 
    "node-102": { 
        nodeID: 'node-102', 
        elapsedTime: 250, 
        timeDiff: 850 
    } 
}
```

## Propriedades do ServiceBroker

| Nome                | Tipo                   | Descrição                             |
| ------------------- | ---------------------- | ------------------------------------- |
| `broker.options`    | `Object`               | Opções do broker.                     |
| `broker.Promise`    | `Promise`              | Promise da classe Bluebird.           |
| `broker.started`    | `Boolean`              | Estado do broker.                     |
| `broker.namespace`  | `String`               | Namespace.                            |
| `broker.nodeID`     | `String`               | ID do nó.                             |
| `broker.instanceID` | `String`               | ID da instância.                      |
| `broker.metadata`   | `Object`               | Metadados das opções do broker.       |
| `broker.logger`     | `Logger`               | Classe de Logger do ServiceBroker.    |
| `broker.cacher`     | `Cacher`               | Instância do cache                    |
| `broker.serializer` | `Serializer`           | Instância do serializador.            |
| `broker.validator`  | `Any`                  | Instância do validador de parâmetros. |
| `broker.services`   | `Array<Service>` | Serviços locais.                      |
| `broker.metrics`    | `MetricRegistry`       | Registro de Métricas integrado.       |
| `broker.tracer`     | `Tracer`               | Instância do Tracer.                  |

## Métodos de ServiceBroker

| Nome                                                      | Retorno               | Descrição                                                   |
| --------------------------------------------------------- | --------------------- | ----------------------------------------------------------- |
| `broker.start()`                                          | `Promise`             | Start broker.                                               |
| `broker.stop()`                                           | `Promise`             | Stop broker.                                                |
| `broker.repl()`                                           | -                     | Start REPL mode.                                            |
| `broker.errorHandler(err, info)`                          | -                     | Call the global error handler.                              |
| `broker.getLogger(module, props)`                         | `Logger`              | Get a child logger.                                         |
| `broker.fatal(message, err, needExit)`                    | -                     | Throw an error and exit the process.                        |
| `broker.loadServices(folder, fileMask)`                   | `Number`              | Load services from a folder.                                |
| `broker.loadService(filePath)`                            | `Service`             | Load a service from file.                                   |
| `broker.createService(schema, schemaMods)`                | `Service`             | Create a service from schema.                               |
| `broker.destroyService(service)`                          | `Promise`             | Destroy a loaded local service.                             |
| `broker.getLocalService(name)`                            | `Service`             | Get a local service instance by full name (e.g. `v2.posts`) |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise`             | Wait for services.                                          |
| `broker.call(actionName, params, opts)`                   | `Promise`             | Call a service.                                             |
| `broker.mcall(def)`                                       | `Promise`             | Multiple service calling.                                   |
| `broker.emit(eventName, payload, opts)`                   | -                     | Emit a balanced event.                                      |
| `broker.broadcast(eventName, payload, opts)`              | -                     | Broadcast an event.                                         |
| `broker.broadcastLocal(eventName, payload, opts)`         | -                     | Broadcast an event to local services only.                  |
| `broker.ping(nodeID, timeout)`                            | `Promise`             | Ping remote nodes.                                          |
| `broker.hasEventListener("eventName")`                    | `Boolean`             | Checks if broker is listening to an event.                  |
| `broker.getEventListeners("eventName")`                   | `Array<Object>` | Returns all registered event listeners for an event name.   |
| `broker.generateUid()`                                    | `String`              | Generate an UUID/token.                                     |
| `broker.callMiddlewareHook(name, args, opts)`             | -                     | Call an async hook in the registered middlewares.           |
| `broker.callMiddlewareHookSync(name, args, opts)`         | -                     | Call a sync hook in the registered middlewares.             |
| `broker.isMetricsEnabled()`                               | `Boolean`             | Check the metrics feature is enabled.                       |
| `broker.isTracingEnabled()`                               | `Boolean`             | Check the tracing feature is enabled.                       |

## Global error handler
The global error handler is generic way to handle exceptions. It catches the unhandled errors of action & event handlers.

**Catch, handle & log the error**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        // Handle the error
        this.logger.warn("Error handled:", err);
    }
});
```

**Catch & throw further the error**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        this.logger.warn("Log the error:", err);
        throw err; // Throw further
    }
});
```

{% note info %}
The `info` object contains the broker and the service instances, the current context and the action or the event definition.
{% endnote %}
