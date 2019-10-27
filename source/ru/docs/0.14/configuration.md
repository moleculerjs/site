title: Конфигурация
---
## Опции брокера
Эти опции могут использоваться в конструкторе `ServiceBroker` или в файле `moleculer.config.js`.

**Список всех доступных опций брокера:**

* **`namespace`**: `String` - Пространство имён узла для сегментации узлов в одной сети (например: "development", "staging", "production"). _По умолчанию: `""`_
* **`nodeID`**: `String` - Уникальный идентификатор узла. Должно быть уникальным в пространстве имен. Иначе брокер бросит фатальную ошибку и остановит процесс. _По умолчанию: имя хоста + PID_
* **`logger`**: `Boolean | String | Object | Array<Object>`  ) - класс Logger. По умолчанию выводит сообщения в `консоль`. [Читать далее](logging.html). _По умолчанию: `"Console"`
* **`logLevel`**: `String | Object` - Уровень ведения журнала (trace, debug, info, warn, error, fatal). [Читать далее](logging.html). _По умолчанию: `info`_
* **`transporter`**: `String | Object | Transporter` - Конфигурация транспорта. [Читать далее](networking.html).  _По умолчанию: `null`_
* **`requestTimeout`**: `Number` - Количество миллисекунд, чтобы подождать, прежде чем отклонить запрос с ошибкой `RequestTimeout`. Отключить: `0` _По умолчанию: `0`_
* **`retryPolicy`**: `Object` - Конфигурации политики повторных запросов. [Читать далее](fault-tolerance.html#Retry).
* **`contextParamsCloning`**: `Boolean` - Включить клонирование параметров `params` контекста. _Оказывает сильное влияние на производительность. Используйте его с осторожностью!_ _По умолчанию: `false`_
* **`maxCallLevel`**: `Number` - Ограничение уровня вложенных действий. Если он достигнет предела, брокер бросит ошибку `MaxCallLevelError`. _(Защита от бесконечного цикла)_ _По умолчанию: `0`_
* **`heartbeatInterval`**: `Number` - Период отправки пакета сердечного ритма, в секундах. _По умолчанию: `5`_
* **`heartbeatTimeout`**: `Number` - Число секунд ожидания перед установкой статуса недоступности удаленного узла в реестре. _По умолчанию: `15`_
* **`tracking`**: `Object` - Отслеживание запросов и ожидание выполнения запросов перед выключением. _(Вежливое выключение)_ [Читать далее](fault-tolerance.html).
* **`disableBalancer`**: Boolean - Отключить встроенный балансировщик действий и событий. _Транспорт должен поддерживать его._ [Читать далее](networking.html#Disabled-balancer). _По умолчанию: `false`_
* **`registry`**: `Object` - Настройки [Реестра сервиса](registry.html).
* **`circuitBreaker`**: `Object` - Настройки [Circuit Breaker](fault-tolerance.html#Circuit-Breaker).
* **`bulkhead`**: `Object` - Настройки [bulkhead](fault-tolerance.html#Bulkhead).
* **`transit.maxQueueSize`**: `Number` - Защита от чрезмерного потребления памяти, когда слишком много исходящих запросов. If there are more than _stated_ outgoing live requests, the new requests will be rejected with `QueueIsFullError` error. _Default: `50000`_
* **`transit.disableReconnect`**: `Boolean` - Disables the reconnection logic while starting a broker. _Default: `false`_
* **`transit.disableVersionCheck`**: `Boolean` - Disable protocol version checking logic in Transit. _Default: `false`_
* **`transit.packetLogFilter`**: `Array` - Filters out the packets in debug log messages. It can be useful to filter out the `HEARTBEAT` packets while debugging. _Default: `[]`_
* **`uidGenerator`**: `Function` - Custom UID generator function for Context ID.
* **`errorHandler`**: `Function` - [Global error handler](broker.html#Global-error-handler) function.
* **`cacher`**: `String | Object | Cacher` - Cacher settings. [Read more](caching.html). _Default: `null`_
* **`serializer`**: `String | Serializer` - Instance of serializer. [Read more](networking.html). _Default: `JSONSerializer`_
* **`validator`**: `Boolean | Validator` - Enable the default or create custom [parameters validation](validating.html). _Default: `true`_
* **`metrics`**: `Boolean | Object` - Enable & configure [metrics](metrics.html) feature. _Default: `false`_
* **`tracing`**: `Boolean | Object` - Enable & configure [tracing](tracing.html) feature. _Default: `false`_
* **`internalServices`**: `Boolean | Object` - Register [internal services](services.html#Internal-Services) at start. _Default: `true`_
* **`internalServices.$node`** - `Object` - Extend internal services with [custom actions](services.html#Extending). _Default: `null`_
* **`internalMiddlewares`**: `Boolean` - Register [internal middlewares](middlewares.html#Internal-middlewares). _Default: `true`_
* **`hotReload`**: `Boolean` - Watch the loaded services and hot reload if they changed. [Read more](services.html#Hot-Reloading-Services). _Default: `false`_
* **`middlewares`**: `Array<Object>` - Register custom middlewares. _Default: `null`_
* **`replCommands`**: `Array<Object>` - Register custom REPL commands. _Default: `null`_
* **`metadata`**: `Object` - Store custom values. _Default: `null`_
* **`skipProcessEventRegistration`**: Boolean - Skip the [default](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) graceful shutdown event handlers. In this case, you have to register them manually. _Default: `false`_
* **`created`**: `Function` - Fired when the broker created. _Default: `null`_
* **`started`**: `Function` - Fired when the broker started _(all local services loaded & transporter is connected)_. _Default: `null`_
* **`stopped`**: `Function` - Fired when the broker stopped _(all local services stopped & transporter is disconnected)_. _Default: `null`_
* **`ServiceFactory`**: `ServiceClass` - Custom `Service` class. If not `null`, broker will use it when creating services by service schema. _Default: `null`_
* **`ContextFactory`**: `ContextClass` - Custom `Context` class. If not `null`, broker will use it when creating contexts for requests & events. _Default: `null`_

### Full options object
```js
{
    namespace: "dev",
    nodeID: "node-25",

    logger: true,
    logLevel: "info",
    logFormatter: "default",
    logObjectPrinter: null,

    transporter: "nats://localhost:4222",

    requestTimeout: 5000,
    retryPolicy: {
        enabled: true,
        retries: 5,
        delay: 100,
        maxDelay: 1000,
        factor: 2,
        check: err => err && !!err.retryable
    },

    contextParamsCloning: false,
    maxCallLevel: 100,
    heartbeatInterval: 5,
    heartbeatTimeout: 15,

    tracking: {
        enabled: true,
        shutdownTimeout: 5000,
    },

    disableBalancer: false,

    registry: {
        strategy: "RoundRobin",
        preferLocal: true
    },

    circuitBreaker: {
        enabled: true,
        threshold: 0.5,
        windowTime: 60,
        minRequestCount: 20,
        halfOpenTime: 10 * 1000,
        check: err => err && err.code >= 500
    },   

    bulkhead: {
        enabled: true,
        concurrency: 10,
        maxQueueSize: 100,
    },

    transit: {
        maxQueueSize: 50 * 1000,
        disableReconnect: false,
        disableVersionCheck: false,
        packetLogFilter: ["HEARTBEAT"]
    },

    uidGenerator: null,

    errorHandler: null,

    cacher: "MemoryLRU",
    serializer: "JSON",

    validator: true,

    metrics: {
        enabled: true,
        reporter: [
            "Console"
        ]
    },

    tracing: {
        enabled: true,
        exporter: [
            "Console"
        ]
    },

    internalServices: true,
    internalMiddlewares: true,

    hotReload: true,

    middlewares: ["MyMiddleware"],

    replCommands: [],

    metadata: {
        region: "eu-west1"
    },

    skipProcessEventRegistration: false,

    ServiceFactory: null,
    ContextFactory: null,

    created(broker) {},

    started(broker) {},

    stopped(broker) {}
}
```
