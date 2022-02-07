title: 配置
---
## 服务管理器选项
这些选项可以在`ServiceBroker`构造函数或`moleculer.config.js`文件中使用。

**所有可用的服务管理器选项列表：**

* **`namespace`**: `String` - 节点的命名空间，用于在同一网络上细分您的节点（例如：“development”，“staging”，“production”） _Default:_ `""`
* **`nodeID`**: `String` - 节点标识符。 在命名空间中必须是唯一的。 否则，服务管理器会引发致命错误并停止该进程。 _Default: hostname + PID_
* **`logger`**: `Boolean | String | Object | Array` - 日志类。 默认情况下，将消息打印到 `console`。 [更多](logging.html). _Default: `"Console"`
* **`logLevel`**: `String | Object` - 日志级别 (trace, debug, info, warn, error, fatal). [更多](logging.html). _Default: `info`_
* **`transporter`**: `String | Object | Transporter` - 推送系统配置项 [更多](networking.html).  _Default: `null`_
* **`requestTimeout`**: `Number` - 在拒绝一个带有`RequestTimeout`错误的请求之前等待的毫秒数。 Disabled: `0` _Default: `0`_
* **`retryPolicy`**: `Object` - 重试策略配置项 [Read more](fault-tolerance.html#Retry).
* **`contextParamsCloning`**: `Boolean` - 若启用则会复制上下文的 `params` 。 _会影响性能。 请谨慎使用!_ _默认: `false`_
* **`dependencyInterval`**: 间隔时间(单位 `毫秒`) 用于配置服务等待其依赖服务。 _Default: `1000`_
* **`maxCallLevel`**: `Number` - 限制调用层级。 如果超出调用层级限制，broker 会抛出一个 `MaxCallLevelError` 错误。 _(无限制)_ _默认值： `0`_
* **`heartbeatInterval`**: `Number` - 向其他节点发送心跳包的间隔秒数。 _Default: `5`_
* **`heartbeatTimeout`**: `Number` - 在设置远程节点在注册表中不可用状态之前等待的秒数。 _Default: `15`_
* **`tracking`**: `Object` - 跟踪请求并等待请求运行后关闭. _(优雅停机)_ [更多](context.html#Context-tracking).
* **`disableBalancer`**: Boolean - 禁用内置的 request & emit 负载均衡。 _必须保证推送器具有 request & emit 负载均衡功能_ [Read more](networking.html#Disabled-balancer). _Default: `false`_
* **`registry`**: `Object` - 用于设置 [Service Registry](registry.html).
* **`circuitBreaker`**: `Object` - [熔断器](fault-tolerance.html#Circuit-Breaker)设置。
* **`bulkhead`**: `Object` - 用于设置 [bulkhead](fault-tolerance.html#Bulkhead).
* **`transit.maxQueueSize`**: `Number` - 请求过多时用于保护内存使用。 外部请求多于 _stated_ 时, 新请求将被拒绝并抛出 `QueueIsFullError`错误。 _Default: `50000`_
* **`transit.maxChunkSize`** `Number` - Maximum chunk size while streaming.  _Default: `256KB`_
* **`transit.disableReconnect`**: `Boolean` - Disables the reconnection logic while starting a broker. _Default: `false`_
* **`transit.disableVersionCheck`**: `Boolean` - Disable protocol version checking logic in Transit. _Default: `false`_
* **`transit.packetLogFilter`**: `Array` -过滤调试信息。 在调试时过滤 `HEARTBEAT` 数据包可能是有用的。 _Default: `[]`_
* **`uidGenerator`**: `Function` - 自定义 Context ID 生成器函数。
* **`errorHandler`**: `Function` - [全局错误处理](broker.html#Global-error-handler)。
* **`cacher`**: `String | Object | Cacher` - 缓存器设置。 [Read more](caching.html). _Default: `null`_
* **`serializer`**: `String | Serializer` - serializer 实例。 [Read more](networking.html). _默认： `JSONSerializer`_
* **`validator`**: `Boolean | Validator` - 启用默认或自定义的 [parameters validation](validating.html). _Default: `true`_
* **`errorRegenerator`**: `Regenerator` - Instance of error regenerator. [Read more](errors.html#Preserve-custom-error-classes-while-transferring-between-remote-nodes). _Default: `null`_
* **`metrics`**: `Boolean | Object` - 启用& 配置[metrics](metrics.html) 特性。 _Default: `false`_
* **`tracing`**: `Boolean | Object` - Enable & configure [tracing](tracing.html) feature. _Default: `false`_
* **`internalServices`**: `Boolean | Object` - Register [internal services](services.html#Internal-Services) at start. _Default: `true`_
* **`internalServices.$node`** - `Object` - Extend internal services with [custom actions](services.html#Extending). _Default: `null`_
* **`internalMiddlewares`**: `Boolean` - Register [internal middlewares](middlewares.html#Internal-middlewares). _Default: `true`_
* **`hotReload`**: `Boolean` - Watch the loaded services and hot reload if they changed. [Read more](services.html#Hot-Reloading-Services). _Default: `false`_
* **`middlewares`**: `Array<Object>` - Register custom middlewares. _Default: `null`_
* **`replDelimiter`**: `String` - Custom REPL commands delimiter. _Default: `mol $`_
* **`replCommands`**: `Array<Object>` - Register custom REPL commands. _Default: `null`_
* **`metadata`**: `Object` - Store custom values. _Default: `null`_
* **`skipProcessEventRegistration`**: Boolean - Skip the [default](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) graceful shutdown event handlers. In this case, you have to register them manually. _Default: `false`_
* **`maxSafeObjectSize`**: `Number` - Maximum size of objects that can be serialized. On serialization process, check each object property size (based on `length` or `size` property value) and trim it, if object size bigger than `maxSafeObjectSize` value. _Default: `null`_
* **`created`**: `Function` - Fired when the broker created. _Default: `null`_
* **`started`**: `Function` - Fired when the broker started _(all local services loaded & transporter is connected)_. _Default: `null`_
* **`stopped`**: `Function` - Fired when the broker stopped _(all local services stopped & transporter is disconnected)_. _Default: `null`_
* **`ServiceFactory`**: `ServiceClass` - Custom `Service` class. If not `null`, broker will use it when creating services by service schema. _Default: `null`_
* **`ContextFactory`**: `ContextClass` - Custom `Context` class. If not `null`, broker will use it when creating contexts for requests & events. _Default: `null`_

### 完整选项
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
    errorRegenerator: null,

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
    maxSafeObjectSize: null,

    ServiceFactory: null,
    ContextFactory: null,

    created(broker) {},

    started(broker) {},

    stopped(broker) {}
}
```
