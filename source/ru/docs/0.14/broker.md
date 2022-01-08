title: Брокер
---
`ServiceBroker` является основным компонентом Moleculer. Он обрабатывает действия и события сервиса, а так же общается с удаленными узлами. Экземпляр `ServiceBroker` должен быть запущен на каждом узле.

<div align="center">
    <img src="assets/service-broker.svg" alt="Диаграмма логики работы брокера" />
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

| Название                  | Тип                    | Описание                          |
| ------------------------- | ---------------------- | --------------------------------- |
| `broker.options`          | `Object`               | Опции брокера.                    |
| `broker.Promise`          | `Promise`              | Класс Bluebird Promise.           |
| `broker.started`          | `Boolean`              | Состояние брокера.                |
| `broker.namespace`        | `String`               | Пространство имён.                |
| `broker.nodeID`           | `String`               | Идентификатор узла.               |
| `broker.instanceID`       | `String`               | Идентификатор экземпляра.         |
| `broker.metadata`         | `Object`               | Метаданные из опций брокера.      |
| `broker.logger`           | `Logger`               | Класс логгера из ServiceBroker.   |
| `broker.cacher`           | `Cacher`               | Экземпляр кэша                    |
| `broker.serializer`       | `Serializer`           | Экземпляр сериализатора.          |
| `broker.validator`        | `Any`                  | Экземпляр валидатора параметров.  |
| `broker.services`         | `Array<Service>` | Локальные сервисы.                |
| `broker.metrics`          | `MetricRegistry`       | Встроенный реестр метрик.         |
| `broker.tracer`           | `Tracer`               | Встроенный экземпляр трассировки. |
| `broker.errorRegenerator` | `Regenerator`          | Built-in Regenerator instance.    |

## Методы ServiceBroker

| Название                                                  | Ответ                 | Описание                                                                     |
| --------------------------------------------------------- | --------------------- | ---------------------------------------------------------------------------- |
| `broker.start()`                                          | `Promise`             | Запустить брокер.                                                            |
| `broker.stop()`                                           | `Promise`             | Остановить брокер.                                                           |
| `broker.repl()`                                           | -                     | Запустить режим REPL.                                                        |
| `broker.errorHandler(err, info)`                          | -                     | Вызов глобального обработчика ошибок.                                        |
| `broker.getLogger(module, props)`                         | `Logger`              | Получить дочерний логгер.                                                    |
| `broker.fatal(message, err, needExit)`                    | -                     | Бросить ошибку и выйти из процесса.                                          |
| `broker.loadServices(folder, fileMask)`                   | `Number`              | Загрузить сервисы из папки.                                                  |
| `broker.loadService(filePath)`                            | `Service`             | Загрузить сервис из файла.                                                   |
| `broker.createService(schema, schemaMods)`                | `Service`             | Создать сервис из схемы.                                                     |
| `broker.destroyService(service)`                          | `Promise`             | Уничтожьте загруженный локальный сервис.                                     |
| `broker.getLocalService(name)`                            | `Service`             | Получить экземпляр локального сервиса по полному имени (например `v2.posts`) |
| `broker.waitForServices(serviceNames, timeout, interval)` | `Promise`             | Дождаться сервиса.                                                           |
| `broker.call(actionName, params, opts)`                   | `Promise`             | Вызвать действие из сервиса.                                                 |
| `broker.mcall(def)`                                       | `Promise`             | Вызов нескольких действий одновременно.                                      |
| `broker.emit(eventName, payload, opts)`                   | -                     | Отправить событие через балансировщик.                                       |
| `broker.broadcast(eventName, payload, opts)`              | -                     | Отправить широковещательное событие.                                         |
| `broker.broadcastLocal(eventName, payload, opts)`         | -                     | Отправить широковещательное событие только локальным сервисам.               |
| `broker.ping(nodeID, timeout)`                            | `Promise`             | Пинг удаленных узлов.                                                        |
| `broker.hasEventListener("eventName")`                    | `Boolean`             | Проверить наличие слушателей события.                                        |
| `broker.getEventListeners("eventName")`                   | `Array<Object>` | Получить всех зарегистрированных слушателей указанного события.              |
| `broker.generateUid()`                                    | `String`              | Создать UUID токен.                                                          |
| `broker.callMiddlewareHook(name, args, opts)`             | -                     | Вызвать асинхронный хук в зарегистрированных middlewares.                    |
| `broker.callMiddlewareHookSync(name, args, opts)`         | -                     | Вызвать синхронный хук в зарегистрированных middlewares.                     |
| `broker.isMetricsEnabled()`                               | `Boolean`             | Проверить, что функция сбора метрик включена.                                |
| `broker.isTracingEnabled()`                               | `Boolean`             | Проверить, что функция трассировки включена.                                 |

## Глобальный обработчик ошибок
Глобальный обработчик ошибок является основным способом обработки исключений. Он выявляет ошибки в обработчиках действий и событий.

**Поймать, обработать и записать в лог**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        // обработка ошибки
        this.logger.warn("Error handled:", err);
    }
});
```

**Поймать и бросить исключение дальше**
```js
const broker = new ServiceBroker({
    errorHandler(err, info) {
        this.logger.warn("Log the error:", err);
        throw err; // передать дальше
    }
});
```

{% note info %}
Объект `info` содержит экземпляры брокера и сервиса, текущий context и определение действия или события.
{% endnote %}
