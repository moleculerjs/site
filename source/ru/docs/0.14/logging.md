title: Логирование
---
Все модули ядра Moleculer имеют пользовательский экземпляр логгер. Они унаследованы от экземпляра логгера брокера, который можно настроить в [настройках брокера](configuration.html#Broker-options).

{% note warn %}
Версия `v0.14` содержит изменения, не совместимый с предыдущими версиями. Это означает, что вы не можете использовать старый способ настройки логирования. Это не относится к встроенному логгеру в консоль. Для получения дополнительной информации ознакомьтесь с [Руководством по миграции](https://github.com/moleculerjs/moleculer/blob/next/docs/MIGRATION_GUIDE_0.14.md).
{% endnote %}


## Встроенные логгеры

### Консоль (по умолчанию)
Этот логгер выводит все сообщения в консоль `console`. Он поддерживает несколько встроенных форматов а так же пользовательский формат.

**Простая конфигурация с настройками по умолчанию**
```js
// moleculer.config.js
module.exports = {
    logger: "Console",
};

// moleculer.config.js
module.exports = {
    // включить логирование
    logger: true,
};
```

**Полная конфигурация**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            // Уровень логирования
            level: "info",
            // Использовать цветные шрифты при выводе
            colors: true,
            // Печатать имена модулей различными цветами (аналогично docker-compose для контейнеров)
            moduleColors: false,
            // Форматирование линий. Может быть "json", "short", "simple", "full", `Function` или шаблон строкового литерала, например, "{timestamp} {level} {nodeID}/{mod}: {msg}"
            formatter: "full",
            // Принтер пользовательского объекта. Если не определено, то используется метод `util.inspect`.
            objectPrinter: null,
            // Автозаполнение имени модуля для того, чтобы сообщения начинались с того же столбца.
            autoPadding: false
        }
    }
};
```

#### Функции форматирования

##### `полный` формат (по умолчанию)
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "Console",
        options: {
            formatter: "full" // или `null`
        }
    }
};
```

**Предпросмотр** ![Console](assets/logging/console-full.png#zoomable)


##### `короткий` формат
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

**Предпросмотр** ![Console](assets/logging/console-short.png#zoomable)


##### `простой` формат
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

**Предпросмотр** ![Console](assets/logging/console-simple.png#zoomable)


##### `json` формат
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

**Предпросмотр** ![Console](assets/logging/console-json.png#zoomable)


##### Пользовательский формат
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

**Предпросмотр** ![Console](assets/logging/console-custom.png#zoomable)


### Файл
Этот логгер сохраняет все сообщения журнала в файл(ы). Он поддерживает JSON & форматированные текстовые файлы или можно использовать пользовательский формат.

**Простая конфигурация с настройками по умлчанию**
```js
// moleculer.config.js
module.exports = {
    logger: "File",
};
```
_Такая настройка сохранит сообщения журнала в папке `журналов` в текущем каталоге с именем `moleculer-{date}.log`._

**Полная конфигурация**
```js
// moleculer.config.js
module.exports = {
    logger: {
        type: "File",
        options: {
            // Уровень логирования
            level: "info",
            // Путь к папке для сохранения файлов. Вы можете использовать переменные {nodeID} & {namespace}.
            folder: "./logs",
            // Шаблон имени файла. Вы можете использовать переменные {date}, {nodeID} & {namespace}.
            filename: "moleculer-{date}.log",
            // Формат строки. Может быть "json", "short", "simple", "full", `Function` или шаблон строкового литерала, например, "{timestamp} {level} {nodeID}/{mod}: {msg}"
            formatter: "full",
            // Принтер пользовательского объекта. Если не определено, то используется метод `util.inspect`.
            objectPrinter: null,
            // Конец строки. Значения по умолчанию исходят из настроек ОС.
            eol: "\n",
            // Интервал добавления файла в миллисекундах.
            interval: 1 * 1000
        }
    }
};
```
## Внешние логгеры

### Pino
Этот логгер использует логгер [Pino](https://github.com/pinojs/pino).

**Простая конфигурация с настройками по умолчанию**
```js
// moleculer.config.js
module.exports = {
    logger: "Pino",
};
```

**Полная конфигурация**
```js
// модуль moleculer.config.js
module.exports = {
    logger: {
        type: "Pino",
        options: {
            // Уровень логирования
            level: "info",

            pino: {
                // Подробнее: http://getpino. o/#/docs/api? d=options-object
                options: null,

                // Подробнее: http://getpino. o/#/docs/api?id=destination-sonicboom-wriablestream-string
                destination: "/logs/moleculer. og",
            }
        }
    }
};
```

{% note info %}
Для использования этого логгера необходимо установить модуль `pino` командой `npm install pino --save`.
{% endnote %}

**Предпросмотр** ![Pino](assets/logging/pino.png#zoomable)

### Bunyan
Этот логгер использует логгер [Bunyan](https://github.com/trentm/node-bunyan).

**Простая конфигурация с настройками по умолчанию**
```js
// moleculer.config.js
module.exports = {
    logger: "Bunyan",
};
```

**Полная конфигурация**
```js
// модуль moleculer.config.js
module.exports = {
    logger: {
        type: "Bunyan",
        options: {
            // Уровень логирования
            level: "info",

            bunyan: {
                // Дополнительные настройки: https://github. om/trentm/node-bunyan#constructor-api
                name: "moleculer"
            }
        }
    }
};
```

{% note info %}
Для использования этого логгера установите модуль `bunyan` с помощью команды `npm install bunyan --save`.
{% endnote %}

**Предпросмотр** ![Bunyan](assets/logging/bunyan.png#zoomable)

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