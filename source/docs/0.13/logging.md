title: Logging
---
In Moleculer framework all core modules have a custom logger instance. They are inherited from the broker logger instance which can be configured in the [broker options](broker.html#Broker-options).

## Built-in logger
The Moleculer has a built-in console logger. It is the default logger.

**Built-in console logger:**
```js
const { ServiceBroker } = require("moleculer");
const broker = new ServiceBroker({
    nodeID: "node-100",
    // logger: true,
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

broker.start()
    .then(() => broker.call("posts.get"))
    .then(() => broker.logger.info("Log message via Broker logger"));
```

**Console messages:**
```
[2018-06-26T11:38:06.728Z] INFO  node-100/POSTS: Log message via Service logger
[2018-06-26T11:38:06.728Z] INFO  node-100/BROKER: Log message via Broker logger
[2018-06-26T11:38:06.730Z] INFO  node-100/BROKER: ServiceBroker is stopped. Good bye.
```

### Custom log levels
You can change the log level with `logLevel` option in broker options. _You can use it with built-in console logger only._

```js
const broker = new ServiceBroker({
    logger: true, // the `true` is same as `console`
    logLevel: "warn" // only logs the 'warn' & 'error' entries to the console
});
```

> Available log levels: `fatal`, `error`, `warn`, `info`, `debug`, `trace`

#### Fine-tuned log levels
The log level can be set for every Moleculer module. Wildcard usage is allowed.
```js
const broker = new ServiceBroker({
    logLevel: {
        "MY.**": false,         // Disable log
        "TRANS": "warn",        // Only 'warn ' and 'error' log entries
        "*.GREETER": "debug",   // All log entries
        "**": "info",           // All other modules use this level
    }
});
```

>This settings are evaluated from top to bottom, so the `**` level need to be the last item.

>Internal modules: `BROKER`, `TRANS`, `TX` as transporter, `CACHER`, `REGISTRY`.

>For services, the name comes from the service name. E.g. POSTS. If version is defined it is used as prefix. E.g. V2.POSTS

### Log formats
There are some built-in log formatter.

| Name | Output |
|----------|-----------|
| `default` | `[2018-06-26T13:36:05.761Z] INFO  node-100/BROKER: Message` |
| `simple`  | `INFO  - Message` |
| `short`   | `[13:36:30.968Z] INFO  BROKER: Message` |

#### Custom log formatter
You can set a custom log formatter function for the built-in console logger.

```js
const broker = new ServiceBroker({ 
    logFormatter(level, args, bindings) {
        return level.toUpperCase() + " " + bindings.nodeID + ": " + args.join(" ");
    }
});
broker.logger.warn("Warn message");
broker.logger.error("Error message");
```
**Output:**
```
WARN dev-pc: Warn message
ERROR dev-pc: Error message
```

### Custom object & array printing formatter
You can set a custom formatter function to print object & arrays. The default function prints the objects & arrays to a single line in order to be easy to process with an external log tool. But when you are developing, it would be useful to print objects to a human-readable multi-line format. For this purpose, overwrite the `logObjectPrinter` function in the broker options.

**Output with default function**
```
[2017-08-18T12:37:25.720Z] INFO  dev-pc/BROKER: { name: 'node', lts: 'Carbon', sourceUrl: 'https://nodejs.org/download/release/v8.10.0/node-v8.10.0.tar.gz', headersUrl: 'https://nodejs.org/download/release/v8.10.0/node-v8.10.0-headers.tar.gz' }
```

**Switch to multi-line printing & increment depth**
```js
const util = require("util");

const broker = new ServiceBroker({  
    logObjectPrinter: o => util.inspect(o, { depth: 4, breakLength: 100 })
});
broker.logger.warn(process.release);
```
**Output:**
```
[2017-08-18T12:37:25.720Z] INFO  dev-pc/BROKER: { name: 'node',
  lts: 'Carbon',
  sourceUrl: 'https://nodejs.org/download/release/v8.10.0/node-v8.10.0.tar.gz',
  headersUrl: 'https://nodejs.org/download/release/v8.10.0/node-v8.10.0-headers.tar.gz' }
```

## External loggers
You can use external loggers with Moleculer. In this case you can set a creator function to `logger`. The ServiceBroker will call it when a new module inherits a new logger instance.

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
const winston = require("winston");
const broker = new ServiceBroker({ 
    logger: bindings => extend(winston.createLogger({
        format: winston.format.combine(
            winston.format.label({ label: bindings }),
            winston.format.timestamp(),
            winston.format.json(),
        ),
        transports: [
            new winston.transports.Console()
        ]
    }))
});
```
> Some external loggers have not `trace` & `fatal` log methods (e.g.: winston). In this case you have to extend your logger.

### Bindings
The `bindings` object contains the following properties:
- `ns` - namespace
- `nodeID` - nodeID
- `mod` - type of core module: `broker`, `cacher`, `transit`, `transporter`
- `svc` - service name
- `ver` - service version

{% note info Please note %}
**Avoid using these bindings property names when you log an `Object`.**
For example: the `broker.logger.error({ mod: "peanut" })` overrides the original `mod` value!
{% endnote %}
