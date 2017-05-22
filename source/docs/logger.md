title: Logger
---
In Services every modules have a custom logger instance. It is inherited from the broker logger instance and you can set in [options of broker](#constructor-options).
Every modules add a prefix to the log messages. Using that prefix you can identify the module.

```js
let { ServiceBroker } = require("moleculer");
let broker = new ServiceBroker({
    logger: console,
    logLevel: "info"
});

broker.createService({
    name: "posts",
    actions: {
        get(ctx) {
            ctx.logger.info("Log message via Context logger");
        }
    },
    created() {
        this.logger.info("Log message via Service logger");
    }
});

broker.call("posts.get").then(() => broker.logger.info("Log message via Broker logger"));
```
Console messages:
```
[BROKER] posts service registered!
[POSTS-SVC] Log message via Service logger
[CTX] Log message via Context logger
[BROKER] Log message via Broker logger
```
[Try it on Runkit](https://runkit.com/icebob/58b1f93be302c300142e2aae)

## Custom log levels
If you want to change log level you need to set `logLevel` in broker options.
Available log levels: `fatal`, `error`, `warn`, `info`, `debug`, `trace`

```js
let broker = new ServiceBroker({
    logger: console,
    logLevel: "warn" // only print the 'warn' & 'error' log entries
});
```

You can set custom log levels to every module by prefix.
```js
let broker = new ServiceBroker({
    logger: console,
    logLevel: {
        "*": "warn", // global settings
        "BROKER": "info",       // Broker logger
        "CTX": "debug",         // Context logger
        "CACHER": "warn",       // Cacher logger
        "TRANSIT": "trace",     // Transit logger
        "TX": "info",           // Transporter logger
        "POSTS-SVC": "error"    // Service logger. Generated from name of service
        "USERS-SVC": false      // No logger
    }
});
```