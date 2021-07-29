title: Log
---
Todos os módulos principais do Moleculer têm uma instância de logger personalizada. Elas são herdadas da instância do broker que pode ser configurada nas [opções do broker](configuration.html#Broker-options).

{% note warn %}
A versão `v0.14` contém alterações significativas. Isso significa que você não pode usar a maneira antiga de configurar o logger. Se você estiver usando o logger padrão do console, esta mudança não afeta você. Para mais informações verifique o [Guia de Migração](https://github.com/moleculerjs/moleculer/blob/next/docs/MIGRATION_GUIDE_0.14.md).
{% endnote %}


## Loggers integrados

### Console (padrão)
Este logger imprime todas as mensagens de log no `console`. Ele suporta vários formatadores integrados ou você pode usar o seu formatador personalizado.

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Console",
};

// moleculer.config.js
module.exports = {
    // Enable console logger
    logger: true,
};
```

**Configuração completa**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            // Logging level
            level: "info",
            // Using colors on the output
            colors: true,
            // Print module names with different colors (like docker-compose for containers)
            moduleColors: false,
            // Line formatter. It can be "json", "short", "simple", "full", a `Function` or a template string like "{timestamp} {level} {nodeID}/{mod}: {msg}"
            formatter: "full",
            // Custom object printer. If not defined, it uses the `util.inspect` method.
            objectPrinter: null,
            // Auto-padding the module name in order to messages begin at the same column.
            autoPadding: false
        }
    }
};
```

#### Formatadores

##### Formatador `full` (default)
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            formatter: "full" // or `null`
        }
    }
};
```

**Pré visualizar** ![Console](assets/logging/console-full.png#zoomable)


##### Formatador `short`
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            formatter: "short"
        }
    }
};
```

**Pré visualizar** ![Console](assets/logging/console-short.png#zoomable)


##### Formatador `simple`
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            formatter: "simple"
        }
    }
};
```

**Pré visualizar** ![Console](assets/logging/console-simple.png#zoomable)


##### Formatador `json`
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            formatter: "json"
        }
    }
};
```

**Pré visualizar** ![Console](assets/logging/console-json.png#zoomable)


##### Formatador personalizado
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            formatter: (level, args, bindings) => [`[${level.toUpperCase()}]`, ...args]
        }
    }
};
```

**Pré visualizar** ![Console](assets/logging/console-custom.png#zoomable)


### File
Este logger salva todas as mensagens de log em arquivo(s). Ele suporta JSON & arquivos de texto formatados ou você pode usar o seu formatador personalizado.

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "File",
};
```
_Ele salvará as mensagens de log na pasta `logs` no diretório atual com nome do arquivo `molleculer -{date}.log`._

**Configuração completa**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "File",
        options: {
            // Logging level
            level: "info",
            // Folder path to save files. You can use {nodeID} & {namespace} variables.
            folder: "./logs",
            // Filename template. You can use {date}, {nodeID} & {namespace} variables.
            filename: "moleculer-{date}.log",
            // Line formatter. It can be "json", "short", "simple", "full", a `Function` or a template string like "{timestamp} {level} {nodeID}/{mod}: {msg}"
            formatter: "json",
            // Custom object printer. If not defined, it uses the `util.inspect` method.
            objectPrinter: null,
            // End of line. Default values comes from the OS settings.
            eol: "\n",
            // File appending interval in milliseconds.
            interval: 1 * 1000
        }
    }
};
```
## Loggers Externos

### Pino
Este logger usa o logger [Pino](https://github.com/pinojs/pino).

**Shorthand configuration with default options**
```js
// moleculer.config.js
module.exports = {
    logger: "Pino",
};
```

**Full configuration**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Pino",
        options: {
            // Logging level
            level: "info",

            pino: {
                // More info: http://getpino.io/#/docs/api?id=options-object
                options: null,

                // More info: http://getpino.io/#/docs/api?id=destination-sonicboom-writablestream-string
                destination: "/logs/moleculer.log",
            }
        }
    }
};
```

{% note info %}
To use this logger please install the `pino` module with `npm install pino --save` command.
{% endnote %}

**Preview** ![Pino](assets/logging/pino.png#zoomable)

### Bunyan
This logger uses the [Bunyan](https://github.com/trentm/node-bunyan) logger.

**Shorthand configuration with default options**
```js
// moleculer.config.js
module.exports = {
    logger: "Bunyan",
};
```

**Full configuration**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Bunyan",
        options: {
            // Logging level
            level: "info",

            bunyan: {
                // More settings: https://github.com/trentm/node-bunyan#constructor-api
                name: "moleculer"
            }
        }
    }
};
```

{% note info %}
To use this logger please install the `bunyan` module with `npm install bunyan --save` command.
{% endnote %}

**Preview** ![Bunyan](assets/logging/bunyan.png#zoomable)

### Winston
This logger uses the [Winston](https://github.com/winstonjs/winston) logger.

**Shorthand configuration with default options**
```js
// moleculer.config.js
module.exports = {
    logger: "Winston",
};
```

**Full configuration**
```js
// moleculer.config.js
const winston = require("winston");

module.exports = {
    logger: {
        type: "Winston",
        options: {
            // Logging level
            level: "info",

            winston: {
                // More settings: https://github.com/winstonjs/winston#creating-your-own-logger
                transports: [
                    new winston.transports.Console(),
                    new winston.transports.File({ filename: "/logs/moleculer.log" })
                ]
            }
        }
    }
};
```

{% note info %}
To use this logger please install the `winston` module with `npm install winston --save` command.
{% endnote %}

**Preview** ![Winston](assets/logging/winston.png#zoomable)

### `debug`
This logger uses the [debug](https://github.com/visionmedia/debug) logger. To see messages you have to set the `DEBUG` environment variable to `export DEBUG=moleculer:*`.

**Shorthand configuration with default options**
```js
// moleculer.config.js
module.exports = {
    logger: "Debug",
};
```

**Full configuration**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Debug",
        options: {
            // Logging level
            level: "info",
        }
    }
};
```

{% note info %}
To use this logger please install the `debug` module with `npm install debug --save` command.
{% endnote %}

**Preview** ![debug](assets/logging/debug.png#zoomable)

### Log4js
This logger uses the [Log4js](https://github.com/log4js-node/log4js-node) logger.

**Shorthand configuration with default options**
```js
// moleculer.config.js
module.exports = {
    logger: "Log4js",
};
```

**Full configuration**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Log4js",
        options: {
            // Logging level
            level: "info",

            log4js: {
                // More info: https://github.com/log4js-node/log4js-node#usage
                appenders: {
                    app: { type: "file", filename: "/logs/moleculer.log" }
                },
                categories: {
                    default: { appenders: [ "app" ], level: "debug" }
                }
            }
        }
    }
};
```

{% note info %}
To use this logger please install the `log4js` module with `npm install log4js --save` command.
{% endnote %}

**Preview** ![Log4js](assets/logging/log4js.png#zoomable)

### Datadog
This logger uploads log messages to the [Datadog](https://www.datadoghq.com/) server.

{% note info %}
Please note, this logger doesn't print any messages to the console, just collects & uploads. Use it beside another logger which also prints the messages.
{% endnote %}

**Shorthand configuration with default options**
```js
// moleculer.config.js
module.exports = {
    logger: "Datadog",
};
```

**Full configuration**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Datadog",
        options: {
            // Logging level
            level: "info",
            // Datadog server endpoint. https://docs.datadoghq.com/api/?lang=bash#send-logs-over-http
            url: "https://http-intake.logs.datadoghq.com/v1/input/",
            // Datadog API key
            apiKey: process.env.DATADOG_API_KEY,
            // Datadog source variable
            ddSource: "moleculer",
            // Datadog env variable
            env: undefined,
            // Datadog hostname variable
            hostname: os.hostname(),
            // Custom object printer function for `Object` & `Ąrray`
            objectPrinter: null,
            // Data uploading interval
            interval: 10 * 1000
        }
    }
};
```

**Preview** ![Datadog Log Explorer](assets/logging/datadog-log-explorer.png#zoomable)

## Multiple Loggers
This new logger configuration admits usage of multiple loggers even from the same logger type and different logging levels.

**Define multiple loggers with different logging levels**
```js
// moleculer.config.js
module.exports = {
    logger: [
        {
            type: "Console",
            options: {
                level: "info",
            }
        },
        {            
            type: "File",
            options: {
                level: "info",
                folder: "/logs/moleculer",
                filename: "all-{date}.log",
                formatter: "{timestamp} {level} {nodeID}/{mod}: {msg}"
            }
        },
        {
            type: "File",
            options: {
                level: "error",
                folder: "/logs/moleculer",
                filename: "errors-{date}.json",
                formatter: "json"
            }
        }
    ]   
};
```

This example shows a configuration of `Console` logger, a `File` logger that saves all log messages in formatted text file and another `File` logger that only saves error messages in JSON format.

### Filtering

You can configure your loggers to only log data of certain services or modules. **Example**
```js
// moleculer.config.js
module.exports = {
    logger: [
        // Shorthand `Console` logger configuration
        "Console",
        {            
            // This logger saves messages from all modules except "greeter" service.
            type: "File",
            options: {
                level: {
                    "GREETER": false,
                    "**": "info"
                },
                filename: "moleculer-{date}.log"
            }
        },
        {
            // This logger saves messages from only "greeter" service.
            type: "File",
            options: {
                level: {
                    "GREETER": "debug",
                    "**": false
                },
                filename: "greeter-{date}.log"
            }
        }
    ],

    logLevel: "info" // global log level. All loggers inherits it. 
};
```

## Log Level Setting
To configure logging levels, you can use the well-known `logLevel` broker option which can be a `String` or an `Object`. However, it is also possible to overwrite it in all logger `options` with the `level` property.

**Complex logging level configuration**
```js
// moleculer.config.js
module.exports = {
    logger: [
        // The console logger will use the `logLevel` global setting.
        "Console",
        {            
            type: "File",
            options: {
                // Overwrite the global setting.
                level: {
                    "GREETER": false,
                    "**": "warn"
                }
            }
        }
    ],
    logLevel: {
        "TRACING": "trace",
        "TRANS*": "warn",
        "GREETER": "debug",
        "**": "info",
    }
};
```

## Custom logger
If you have your custom logger you should wrap it into a `BaseLogger` class and implement at least the `getLogHandler` method.

**Using a custom logger**
```js
// moleculer.config.js
 const BaseLogger = require("moleculer").Loggers.Base;

class MyLogger extends BaseLogger {
    getLogHandler(bindings) {
        return (type, args) => console[type](`[MYLOG-${bindings.mod}]`, ...args);
    }
}

module.exports = {
    logger: new MyLogger()
};
```