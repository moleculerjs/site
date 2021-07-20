title: Конфигурация
---
## Опции брокера
Эти опции могут использоваться в конструкторе `ServiceBroker` или в файле `moleculer.config.js`.

**Список всех доступных опций брокера:**

* **`namespace`**: `String` - Пространство имён узла для сегментации узлов в одной сети (например: "development", "staging", "production"). _По умолчанию: `""`_
* **`nodeID`**: `String` - Уникальный идентификатор узла. Должно быть уникальным в пространстве имен. Иначе брокер бросит фатальную ошибку и остановит процесс. _По умолчанию: имя хоста + PID_
* **`logger`**: `Boolean | String | Object | Array<Object>`  ) - класс Logger. По умолчанию выводит сообщения в `консоль`. [Подробнее](logging.html). _По умолчанию: `"Console"`
* **`logLevel`**: `String | Object` - Уровень ведения журнала (trace, debug, info, warn, error, fatal). [Подробнее](logging.html). _По умолчанию: `info`_
* **`transporter`**: `String | Object | Transporter` - Конфигурация транспорта. [Подробнее](networking.html).  _По умолчанию: `null`_
* **`requestTimeout`**: `Number` - Количество миллисекунд, чтобы подождать, прежде чем отклонить запрос с ошибкой `RequestTimeout`. Отключить: `0` _По умолчанию: `0`_
* **`retryPolicy`**: `Object` - Конфигурации политики повторных запросов. [Подробнее](fault-tolerance.html#Retry).
* **`contextParamsCloning`**: `Boolean` - Включить клонирование параметров `params` контекста. _Оказывает сильное влияние на производительность. Используйте его с осторожностью!_ _По умолчанию: `false`_
* **`dependencyInterval`**: Настраиваемый интервал (определён в `ms`) который используется сервисами, в ожидании обслуживания зависимостей. _По умолчанию: `1000`_
* **`maxCallLevel`**: `Number` - Ограничение уровня вложенных действий. Если он достигнет предела, брокер бросит ошибку `MaxCallLevelError`. _(Защита от бесконечного цикла)_ _По умолчанию: `0`_
* **`heartbeatInterval`**: `Number` - Период отправки пакета сердечного ритма, в секундах. _По умолчанию: `5`_
* **`heartbeatTimeout`**: `Number` - Число секунд ожидания перед установкой статуса недоступности удаленного узла в реестре. _По умолчанию: `15`_
* **`tracking`**: `Object` - Отслеживание запросов и ожидание выполнения запросов перед выключением. _(Плавное выключение)_ [Подробнее](context.html#Context-tracking).
* **`disableBalancer`**: Boolean - Отключить встроенный балансировщик действий и событий. _Транспорт должен поддерживать его._ [Подробнее](networking.html#Disabled-balancer). _По умолчанию: `false`_
* **`registry`**: `Object` - Настройки [Реестра сервиса](registry.html).
* **`circuitBreaker`**: `Object` - Настройки [Circuit Breaker](fault-tolerance.html#Circuit-Breaker).
* **`bulkhead`**: `Object` - Настройки [bulkhead](fault-tolerance.html#Bulkhead).
* **`transit.maxQueueSize`**: `Number` - Защита от чрезмерного потребления памяти, когда слишком много исходящих запросов. Если число запросов больше _указанного_, новые запросы будут отклонены с ошибкой `QueueIsFullError`. _По умолчанию: `50000`_
* **`transit.maxChunkSize`** `Number` - Максимальный размер чанка в потоке.  _По умолчанию: `256KB`_
* **`transit.disableReconconnect`**: `Boolean` - отключает логику переподключения при запуске брокера. _По умолчанию: `false`_
* **`transit.disableVersionCheck`**: `Boolean` - отключить логику проверки версии протокола при переходе. _По умолчанию: `false`_
* **`transit.packetLogFilter`**: `Array` - Фильтрует пакеты в отладочных сообщениях. Может быть полезно отфильтровать `HEARTBEAT` пакетов при отладке. _По умолчанию: `[]`_
* **`uidGenerator`**: ` Function ` - Пользовательская функция генерации UID для идентификатора контекста.
* **`errorHandler`**: ` Function ` - [Глобальный обработчик ошибок](broker.html#Global-error-handler) функции.
* **`cacher`**: `String | Object | Cacher` - Настройки кэша. [Подробнее](caching.html). _По умолчанию: `null`_
* **` serializer `**: ` String | Serializer ` - Экземпляр сериализатора. [Подробнее](networking.html). _По умолчанию: `JSONSerializer`_
* **`validator`**: `Boolean | Validator` - Включить по умолчанию или создать пользовательскую [валидацию параметров](validating.html). _По умолчанию: `true`_
* **`metrics`**: `Boolean | Object` - Включить & сконфигурировать [metrics](metrics.html) функционал. _По умолчанию: `false`_
* **`tracing`**: `Boolean | Object` - Включить & настроить [tracing](tracing.html) функционал. _По умолчанию: `false`_
* **`internalServices`**: `Boolean | Object` - Регистрировать [внутренние сервисы](services.html#Internal-Services) при старте. _По умолчанию: `true`_
* **`internalServices.$node`** - `Object` - Расширьте внутренние сервисы с [пользовательскими действиями](services.html#Extending). _По умолчанию: `null`_
* **`internalMiddlewares`**: `Boolean` - Регистрация [внутренних промежуточных функций](middlewares.html#Internal-middlewares). _По умолчанию: `true`_
* **`hotReload`**: `Boolean` - Отслеживать загруженные сервисы и перезагружать их при изменениях. [Подробнее](services.html#Hot-Reloading-Services). _По умолчанию: `false`_
* **`middlewares`**: `Array<Object>` - Регистрировать пользовательские промежуточные функции. _По умолчанию: `null`_
* **`replDelimiter`**: `String` - Custom REPL commands delimiter. _Default: `mol $`_
* **`replCommands`**: `Array<Object>` - Регистрировать пользовательские REPL команды. _По умолчанию: `null`_
* **`metadata`**: `Object` - Хранить пользовательские значения. _По умолчанию: `null`_
* **`skipProcessEventRegistration`**: Boolean - Пропустить [по умолчанию](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) обработчики событий плавного завершения. В этом случае необходимо зарегистрировать их вручную. _По умолчанию: `false`_
* **`created`**: `Function` - Выстреливает при создании брокера. _По умолчанию: `null`_
* **`начал`**: `Функция` - Выстреливает при запуске брокера _(все локальные сервисы загружены & траснпорт подключен)_. _По умолчанию: `null`_
* **`stopped`**: `Function` - Выстреливает при остановке брокера _(все локальные сервисы остановлены & транспорт отключен)_. _По умолчанию: `null`_
* **`ServiceFactory`**: `ServiceClass` - Пользовательский класс `Сервиса`. Если не `null`, брокер будет использовать его при создании сервисов с использованием схемы сервиса. _По умолчанию: `null`_
* **`ContextFactory`**: `ContextClass` - Пользовательский класс `Контекста`. Если не `null`, брокер будет использовать его при создании контекстов запросов & событий. _По умолчанию: `null`_

### Объект всех настроек
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

    replDelimiter: "mol $",
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
