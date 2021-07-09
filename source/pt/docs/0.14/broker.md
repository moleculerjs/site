title: Broker
---
O `ServiceBroker` é o componente principal do Moleculer. Ele lida com serviços, chamadas de ações, emite eventos e se comunica com nós remotos. Você deve criar uma instância do `ServiceBroker` em cada nó.

<div align="center">
    <img src="assets/service-broker.svg" alt="Diagrama lógico do broker" />
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

| Nome                                                      | Retorno               | Descrição                                                                        |
| --------------------------------------------------------- | --------------------- | -------------------------------------------------------------------------------- |
| `broker.start()`                                          | `Promise`             | Iniciar broker.                                                                  |
| `broker.stop()`                                           | `Promise`             | Parar broker.                                                                    |
| `broker.repl()`                                           | -                     | Iniciar modo REPL.                                                               |
| `broker.errorHandler(err, info)`                          | -                     | Chamar o handler global de erros.                                                |
| `broker.getLogger(module, props)`                         | `Logger`              | Acessar um logger filho.                                                         |
| `broker.fatal(message, err, needExit)`                    | -                     | Lançar um erro e abortar o processo.                                             |
| `broker.loadServices(folder, fileMask)`                   | `Number`              | Carregar serviços de uma pasta.                                                  |
| `broker.loadService(filePath)`                            | `Service`             | Carregar serviços de um arquivo.                                                 |
| `broker.createService(schema, schemaMods)`                | `Service`             | Criar um serviço a partir de um esquema.                                         |
| `broker.destroyService(service)`                          | `Promise`             | Destruir um serviço local carregado.                                             |
| `broker.getLocalService(name)`                            | `Service`             | Obter uma instância do serviço local com nome completo (por exemplo, `v2.posts`) |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise`             | Esperar por serviços.                                                            |
| `broker.call(actionName, params, opts)`                   | `Promise`             | Chamar um serviço.                                                               |
| `broker.mcall(def)`                                       | `Promise`             | Chamar múltiplos serviços.                                                       |
| `broker.emit(eventName, payload, opts)`                   | -                     | Emitir um evento.                                                                |
| `broker.broadcast(eventName, payload, opts)`              | -                     | Transmitir um evento em formato broadcast.                                       |
| `broker.broadcastLocal(eventName, payload, opts)`         | -                     | Transmitir um evento apenas para os serviços locais.                             |
| `broker.ping(nodeID, timeout)`                            | `Promise`             | Fazer um ping em nós remotos.                                                    |
| `broker.hasEventListener("eventName")`                    | `Boolean`             | Verifica se o broker está escutando um evento.                                   |
| `broker.getEventListeners("eventName")`                   | `Array<Object>` | Retorna todos os ouvintes registrados para o nome de um evento.                  |
| `broker.generateUid()`                                    | `String`              | Gerar um UUID/token.                                                             |
| `broker.callMiddlewareHook(name, args, opts)`             | -                     | Chamar um hook assíncrono nos middlewares registrados.                           |
| `broker.callMiddlewareHookSync(name, args, opts)`         | -                     | Chamar um hook síncrono nos middlewares registrados.                             |
| `broker.isMetricsEnabled()`                               | `Boolean`             | Verificar se o recurso de métricas está habilitado.                              |
| `broker.isTracingEnabled()`                               | `Boolean`             | Verificar se o recurso de rastreamento está habilitado.                          |

## Gerenciador de erros global
O gerenciador de erros global é uma maneira genérica de lidar com exceções. Ele captura os erros não tratados de ações & manipuladores de eventos.

**Capturar, manipular & registrar o erro**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        // Handle the error
        this.logger.warn("Error handled:", err);
    }
});
```

**Capturar & lançar o erro de volta**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        this.logger.warn("Log the error:", err);
        throw err; // Throw further
    }
});
```

{% note info %}
O objeto `info` contém o broker e as instâncias dos serviços, o contexto atual e as definições de ações e eventos.
{% endnote %}
