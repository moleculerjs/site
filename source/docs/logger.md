title: Logger
---
In Moleculer project every main modules have a custom logger instance. It is inherited from the broker logger instance what you can set in [options of broker](broker.html#Constructor-options).
Every modules add a prefix to the log messages. You can identify the modules by this prefix.

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
            this.logger.info("Log message via Service logger");
        }
    }
});

broker.call("posts.get").then(() => broker.logger.info("Log message via Broker logger"));
```
Console messages:
```
[BROKER] posts service registered!
[POSTS-SVC] Log message via Service logger
[BROKER] Log message via Broker logger
```
> [Try it on Runkit!](https://runkit.com/icebob/58b1f93be302c300142e2aae)

## Custom log levels
You can change the log level with `logLevel` option in broker options.

> Available log levels: `fatal`, `error`, `warn`, `info`, `debug`, `trace`

```js
let broker = new ServiceBroker({
    logger: console,
    logLevel: "warn" // only logs the 'warn' & 'error' entries to the console
});
```

You can set custom log levels to every module by prefixes.
```js
let broker = new ServiceBroker({
    logger: console,
    logLevel: {
        "*": "warn",            // global settings
        "BROKER": "info",       // Broker logger
        "CACHER": "warn",       // Cacher logger
        "TRANSIT": "trace",     // Transit logger
        "TX": "info",           // Transporter logger
        "POSTS-SVC": "error"    // Service logger. Generated from name of service with '-SVC' suffix
        "USERS-SVC": false      // Disable logger in the specified module
    }
});
```