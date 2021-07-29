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

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Pino",
};
```

**Configuração completa**
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
Para usar este logger por favor instale o módulo `pino` com o comando `npm install pino --save`.
{% endnote %}

**Pré visualizar** ![Pino](assets/logging/pino.png#zoomable)

### Bunyan
Este logger usa o logger [Bunyan](https://github.com/trentm/node-bunyan).

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Bunyan",
};
```

**Configuração completa**
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
Para usar esse logger por favor instale o módulo `bunyan` com o comando `npm install bunyan --save`.
{% endnote %}

**Pré visualizar** ![Bunyan](assets/logging/bunyan.png#zoomable)

### Winston
Este logger usa o logger [Winston](https://github.com/winstonjs/winston).

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Winston",
};
```

**Configuração completa**
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
Para usar esse logger por favor instale o módulo `winston` com o comando `npm install winston --save`.
{% endnote %}

**Pré visualizar** ![Winston](assets/logging/winston.png#zoomable)

### `debug`
Este logger usa o [debug](https://github.com/visionmedia/debug). Para ver mensagens você tem que definir a variável de ambiente `DEBUG` para `export DEBUG=moleculer:*`.

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Debug",
};
```

**Configuração completa**
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
Para usar esse logger por favor instale o módulo `debug` com o comando `npm install debug --save`.
{% endnote %}

**Pré visualizar** ![debug](assets/logging/debug.png#zoomable)

### Log4js
Este logger usa o logger [Log4js](https://github.com/log4js-node/log4js-node).

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Log4js",
};
```

**Configuração completa**
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
Para usar esse logger por favor instale o módulo `log4js` com o comando `npm install log4js --save`.
{% endnote %}

**Pré visualizar** ![Log4js](assets/logging/log4js.png#zoomable)

### Datadog
Este logger envia mensagens de log para o servidor do [Datadog](https://www.datadoghq.com/).

{% note info %}
Por favor, note que este logger não imprime nenhuma mensagem para o console, apenas coleta & envia. Use junto com outro logger que também imprime as mensagens.
{% endnote %}

**Configuração abreviada com opções padrão**
```js
// moleculer.config.js
module.exports = {
    logger: "Datadog",
};
```

**Configuração completa**
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

**Pré visualizar** ![Datadog Log Explorer](assets/logging/datadog-log-explorer.png#zoomable)

## Vários loggers
Esta nova configuração de logger admite o uso de vários loggers até do mesmo tipo de logger com níveis de log diferentes.

**Define múltiplos loggers com diferentes níveis de logs**
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

Este exemplo mostra uma configuração do logger `Console`, um logger `File` que salva todas as mensagens de log no arquivo de texto formatado e outro Logger `File` que só salva as mensagens de erro no formato JSON.

### Filtro

Você pode configurar seus loggers para registrar apenas dados de certos serviços ou módulos. **Exemplo**
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

## Configuração de Nível de Log
Para configurar níveis de log, você pode usar a famosa opção `logLevel` que pode ser uma `String` ou um `Object`. No entanto, também é possível substituí-lo em `options` do logger com a propriedade `level`.

**Configuração complexa de nível de log**
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

## Logger personalizado
Se você tiver seu logger personalizado, deverá envolvê-lo em uma classe `BaseLogger` e implementar pelo menos o método `getLogHandler`.

**Usando um logger personalizado**
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