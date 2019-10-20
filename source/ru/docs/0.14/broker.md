title: Брокер
---
`ServiceBroker` является основным компонентом Moleculer. Он обрабатывает действия и события сервиса, а так же общается с удаленными узлами. Экземпляр `ServiceBroker` должен быть запущен на каждом узле.

<div align="center">
    <img src="assets/service-broker.svg" alt="Broker logical diagram" />
</div>

## Создание ServiceBroker

{% note info %}
**Подсказка:** Вам не нужно создавать вручную ServiceBroker в вашем проекте. Используйте [Moleculer Runner](runner.html) для создания брокера и загрузки сервисов. [Подробнее о Moleculer Runner](runner.html).
{% endnote %}

**Создание брокера с настройками по умолчанию:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker();
```

**Создание брокера с пользовательскими настройками:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "my-node"
});
```

**Создание брокера с транспортом к удаленными узлами:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "node-1",
    transporter: "nats://localhost:4222",
    logLevel: "debug",
    requestTimeout: 5 * 1000
});
```


### Опции метаданных
Используйте свойство `metadata` для передачи пользовательских данных. Это может быть полезно для пользовательских [middleware](middlewares.html#Loading-amp-Extending) или [strategy](balancing.html#Custom-strategy) стратегии.

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
Свойство `metadata` можно получить запустив действие `$node.list`.
{% endnote %}

{% note info %}
Свойство `metadata` передается другим узлам.
{% endnote %}

## Пинг
Для пинга удаленных узлов используется метод `broker.ping`. Вы можете пинговать конкретный узел или все доступные узлы. Он возвращает `Promise` который содержит принятый ответ (задержка, разница времени). Можно задать значение таймаута.

### Пинговать узел с таймаутом в 1 секунду
```js
broker.ping("node-123", 1000).then(res => broker.logger.info(res));
```

**Вернет**
```js
{ 
    nodeID: 'node-123', 
    elapsedTime: 16, 
    timeDiff: -3 
}
```
> Значение `timeDiff` является разницей системных часов между этими узлами.

### Пинг нескольких узлов
```js
broker.ping(["node-100", "node-102"]).then(res => broker.logger.info(res));
```

**Вернет**
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

### Пинг всех доступных узлов
```js
broker.ping().then(res => broker.logger.info(res));
```

**Вернет**
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

## Свойства ServiceBroker

| Имя                 | Тип                    | Описание                                 |
| ------------------- | ---------------------- | ---------------------------------------- |
| `broker.options`    | `Object`               | Опции брокера.                           |
| `broker.Promise`    | `Promise`              | Класс Bluebird Promise.                  |
| `broker.started`    | `Boolean`              | Состояние брокера.                       |
| `broker.namespace`  | `String`               | Пространство имён.                       |
| `broker.nodeID`     | `String`               | Идентификатор узла.                      |
| `broker.instanceID` | `String`               | Идентификатор экземпляра.                |
| `broker.metadata`   | `Object`               | Метаданные из опций брокера.             |
| `broker.logger`     | `Logger`               | Класс логгера из ServiceBroker.          |
| `broker.cacher`     | `Cacher`               | Экземпляр кеша                           |
| `broker.serializer` | `Serializer`           | Экземпляр сериализатора.                 |
| `broker.validator`  | `Any`                  | Экземпляр валидатора входных параметров. |
| `broker.services`   | `Array<Service>` | Локальные сервисы.                       |
| `broker.metrics`    | `MetricRegistry`       | Встроенный реестр метрик.                |
| `broker.tracer`     | `Tracer`               | Встроенный экземпляр трекера.            |

## Методы ServiceBroker

| Имя                                                       | Ответ                 | Описание                                                    |
| --------------------------------------------------------- | --------------------- | ----------------------------------------------------------- |
| `broker.start()`                                          | `Promise`             | Запустить брокер.                                           |
| `broker.stop()`                                           | `Promise`             | Остановить брокер.                                          |
| `broker.repl()`                                           | -                     | Запустить режим REPL.                                       |
| `broker.errorHandler(err, info)`                          | -                     | Вызов глобального обработчика ошибок.                       |
| `broker.getLogger(module, props)`                         | `Logger`              | Get a child logger.                                         |
| `broker.fatal(message, err, needExit)`                    | -                     | Throw an error and exit the process.                        |
| `broker.loadServices(folder, fileMask)`                   | `Number`              | Load services from a folder.                                |
| `broker.loadService(filePath)`                            | `Service`             | Load a service from file.                                   |
| `broker.createService(schema, schemaMods)`                | `Service`             | Create a service from schema.                               |
| `broker.destroyService(service)`                          | `Promise`             | Destroy a loaded local service.                             |
| `broker.getLocalService(name)`                            | `Service`             | Get a local service instance by full name (e.g. `v2.posts`) |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise`             | Дождаться сервиса.                                          |
| `broker.call(actionName, params, opts)`                   | `Promise`             | Вызвать действие сервиса.                                   |
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
