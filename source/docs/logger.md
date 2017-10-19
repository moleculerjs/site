title: Logger
---
In Moleculer project every main modules have a custom logger instance. They inherit from the broker logger instance in which you can set the [options of broker](broker.html#Constructor-options).

It supports also external loggers ([Pino](http://getpino.io/), [Bunyan](https://github.com/trentm/node-bunyan), [Winston](https://github.com/winstonjs/winston), ...etc)

## Built-in logger
The Moleculer has a built-in console logger. You can enable it with `logger: console` or `logger: true` options.

**Built-in console logger:**
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
[2017-08-18T12:37:25.714Z] INFO  dev-pc/POSTS: Log message via Service logger
[2017-08-18T12:37:25.718Z] INFO  dev-pc/BROKER: Log message via Broker logger
[2017-08-18T12:37:25.720Z] INFO  dev-pc/BROKER: Broker stopped.
```

### Custom log levels
You can change the log level with `logLevel` option in broker options. _You can use it with built-in console logger only._

```js
let broker = new ServiceBroker({
    logger: true, // the `true` is same as `console`
    logLevel: "warn" // only logs the 'warn' & 'error' entries to the console
});
```

> Available log levels: `fatal`, `error`, `warn`, `info`, `debug`, `trace`

### Custom log formats
You can set a custom log formatter function for the built-in logger.

```js
const broker = new ServiceBroker({ 
    logger: console, 
    logFormatter(level, args, bindings) {
        return level.toUpperCase() + " " + bindings.nodeID + ": " + args.join(" ");
    }
});
broker.logger.warn("Warn message");
broker.logger.error("Error message");
```
Output:
```
WARN dev-pc: Warn message
ERROR dev-pc: Error message
```

## External loggers
You can use external loggers with Moleculer. In this case you can set a creator function to `logger`. The ServiceBroker will call it when a new module request a new logger instance.

### **[Pino](http://getpino.io/)**
```js
const pino = require("pino")({ level: "info" });
const broker = new ServiceBroker({ 
    logger: bindings => pino.child(bindings)
});
```

### **[Bunyan](https://github.com/trentm/node-bunyan)**
```js
const bunyan = require("bunyan");
const logger = bunyan.createLogger({ name: "moleculer", level: "info" });
const broker = new ServiceBroker({ 
    logger: bindings => logger.child(bindings)
});
```

### **[Winston](https://github.com/winstonjs/winston)**
```js
const broker = new ServiceBroker({ 
    logger: bindings => new winston.Logger({
        transports: [
            new (winston.transports.Console)({
                timestamp: true,
                colorize: true,
                prettyPrint: true
            })
        ]
    })
});
```

### **[Winston context](https://github.com/citrix-research/node-winston-context)**
```js
const WinstonContext = require("winston-context");
const winston = require("winston");
const broker = createBroker({ 
    logger: bindings => new WinstonContext(winston, "", bindings)
});
```

> Some external loggers have not `trace` & `fatal` log methods (e.g.: winston). In this case you have to extend your logger.

```js
const WinstonContext = require("winston-context");
const winston = require("winston");
const { extend } = require("moleculer").Logger;
const broker = createBroker({ 
    logger: bindings => extend(new WinstonContext(winston, "", bindings))
});
```

The `bindings` contains the following properties:
- `ns` - namespace
- `nodeID` - nodeID
- `mod` - type of core module: `broker`, `cacher`, `transit`, `transporter`
- `svc` - service name
- `ver` - service version

{% note info Please note %}
**Avoid to use these bindings property names when you log an `Object`.**
For example: the `broker.logger.error({ mod: "peanut" })` overrides the original `mod` value!
{% endnote %}
