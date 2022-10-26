title: Middlewares
---

Moleculer suporta middlewares. É o mesmo que plugins em outros frameworks. O middleware é um `Object` com funções wrapper & hook. Ele permite encapsular manipuladores de ação, manipuladores de eventos, métodos do broker e hook de eventos de ciclo de vida.

**Exemplo**
```js
// awesome.middleware.js
module.exports = {
    name: "Awesome",

    localAction(next, action) {
        return function(ctx) {
            console.log(`My middleware is called before the `${ctx.action.name}` action executed.`);
            return next(ctx);
        }
    }
};
```

## Encapsulando Manipuladores
Alguns hooks podem ser encapsulados. Significa que você pode encapsular o manipulador original e retornar uma nova Função. Hooks encapsuláveis são os quais o primeiro parâmetro é `next`.

**Encapsular manipulador de ação local**
```js
const MyDoSomethingMiddleware = {
    localAction(next, action) {
        if (action.myFunc) {
            // Wrap the handler
            return function(ctx) {
                doSomethingBeforeHandler(ctx);

                return next(ctx)
                    .then(res => {
                        doSomethingAfterHandler(res);
                        // Return the original result
                        return res;
                    })
                    .catch(err => {
                        doSomethingAfterHandlerIfFailed(err);

                        // Throw further the error
                        throw err;
                    });
            }
        }

        // If the feature is disabled we don't wrap it, return the original handler
        // So it won't cut down the performance when the feature is disabled.
        return next;
    }
};
```

**Exemplo do middleware validador**
```js
const MyValidator = {
    localAction(next, action) {
        // Wrap with a param validator if `action.params` is defined
        if (_.isObject(action.params)) {
            return ctx => {
                this.validate(action.params, ctx.params);
                return next(ctx);
            };
        }
        return next;
    }
};
```

O `next` é o manipulador original ou o seguinte manipulador encapsulado. O middleware deve retornar o `handler` original ou um novo manipulador encapsulado. Como você pode ver acima, o middleware verifica se a ação tem uma propriedade `params`. Se sim, ele retornará um manipulador encapsulado que chama o módulo do validador antes de chamar o `handler` original. Se a propriedade `params` não for definida, simplesmente retorna o `handler` original (ignorando o encapsulamento).
> Se você não chamar o original `next` no middleware ele quebrará a requisição. Isto pode ser usado em cachers. Por exemplo, se ele encontrar os dados solicitados no cache, retornará os dados em cache ao invés de chamar o `next`.

**Exemplo de middleware cacher**
```js
const MyCacher = {
    localAction(next, action) {
        return async function cacherMiddleware(ctx) {
            const cacheKey = this.getCacheKey(action.name, ctx.params, action.cache.keys);
            const content = await this.get(cacheKey);
            if (content != null) {
                // Found in the cache! Don't call next, return with the cached content
                ctx.cachedResult = true;
                return content;
            }

            // Call the next
            const result = await next(ctx);

            // Save the response to the cache
            this.set(cacheKey, result);
            return result;

        }.bind(this);
    }
};
```
> O `next()` sempre retorna uma `Promise`. Então você também pode ter acesso a respostas e manipulá-las.

## Decorar módulos centrais (estender funcionalidade)
As funções Middleware podem ser usadas para adicionar novos recursos às classes `ServiceBroker` ou `Service`.

**Decore o broker com um novo método `allCall`**
```js
// moleculer.config.js
module.exports = {
    middlewares: [
        {
            // After broker is created
            created(broker) {
                // Call action on all available nodes
                broker.allCall = function(action, params, opts = {}) {
                    const nodeIDs = this.registry.getNodeList({ onlyAvailable: true })
                        .map(node => node.id);

                    // Make direct call to the given Node ID
                    return Promise.all(
                        nodeIDs.map(nodeID => broker.call(action, params, Object.assign({ nodeID }, opts)))
                    );
                }
            }
        }
    ]
};
```

Chame o novo método para chamar `$node.health` em cada um dos nós:
```js
const res = await broker.allCall("$node.health");
```

## Hooks

### `localAction(next, action)`
Este hook encapsula os manipuladores de ações locais.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    localAction(next, action) {
        return function(ctx) {
            // Change context properties or something
            return next(ctx)
                .then(res => {
                    // Do something with the response
                    return res;
                })
                .catch(err => {
                    // Handle error or throw further
                    throw err;
                });
        };
    }
}
```

### `remoteAction(next, action)`
Este hook encapsula os manipuladores de ações remotas.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    remoteAction(next, action) {
        return function(ctx) {
            // Change context properties or something
            return next(ctx)
                .then(res => {
                    // Do something with the response
                    return res;
                })
                .catch(err => {
                    // Handle error or throw further
                    throw err;
                });
        };
    }
}
```

### `localEvent(next, event)`
Este hook encapsula os manipuladores de eventos locais.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    localEvent(next, event) {
        return (ctx) => {
            return next(ctx);
        };
    }
}
```

### `localMethod(next, method)`

Este hook encapsula métodos de serviços locais.

```js
// my.middleware.js
module.exports = {
    name: "MyMiddleware",

    localMethod(next, method) {
        return (...args) => {
            console.log(`The '${method.name}' method is called in '${method.service.fullName}' service.`, args);
            return next(...args);
        };
    }
}
```


### `createService(next)`
Este hook encapsula o método `broker.createService`.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    createService(next) {
        return function(schema, schemaMods) {
            console.log("The 'createService' is called.");
            return next(schema, schemaMods);
        };
    }
}
```

### `destroyService(next)`
Este hook encapsula o método `broker.destroyService`

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    destroyService(next) {
        return function(service) {
            console.log("The 'destroyService' is called.");
            return next(service);
        };
    }
}
```

### `call(next)`
Este hook encapsula o método `broker.call`.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    call(next) {
        return function(actionName, params, opts) {
            console.log("The 'call' is called.", actionName);
            return next(actionName, params, opts).then(res => {
                console.log("Response:", res);
                return res;
            });
        };
    }
}
```

### `mcall(next)`
Este hook encapsula o método `broker.mcall`.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    mcall(next) {
        return function() {
            console.log("The 'mcall' is called.");
            return next(...arguments).then(res => {
                console.log("Response:", res);
                return res;
            });
        };
    }
}
```

### `emit(next)`
Este hook encapsula o método `broker.emit`.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    emit(next) {
        return function(eventName, payload, opts) {
            console.log("The 'emit' is called.", eventName);
            return next(eventName, payload, opts);
        };
    }
}
```

### `broadcast(next)`
Este hook encapsula o método `broker.broadcast`.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    broadcast(next) {
        return function(eventName, payload, opts) {
            console.log("The 'broadcast' is called.", eventName);
            return next(eventName, payload, opts);
        };
    }
}
```

### `broadcastLocal(next)`
Este hook encapsula o método `broker.broadcastLocal`.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    broadcastLocal(next) {
        return function(eventName, payload, opts) {
            console.log("The 'broadcastLocal' is called.", eventName);
            return next(eventName, payload, opts);
        };
    }
}
```

### `serviceCreated(service)` _(sync)_
Este hook é chamado após a criação de um serviço local.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceCreated(service) {
        console.log("Service created", service.fullName);
    }
}
```

### `serviceStarting(service)` _(async)_
Este hook é chamado antes do início do serviço.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStarting(service) {
        console.log("Service is starting", service.fullName);
    }
}
```

### `serviceStarted(service)` _(async)_
Este hook é chamado após o início do serviço.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStarted(service) {
        console.log("Service started", service.fullName);
    }
}
```

### `serviceStopping(service)` _(async)_
Este hook é chamado antes da parada do serviço.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStopping(service) {
        console.log("Service is stopping", service.fullName);
    }
}
```

### `serviceStopped(service)` _(async)_
Este hook é chamado após a parada do serviço.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceStopped(service) {
        console.log("Service stopped", service.fullName);
    }
}
```

### `registerLocalService(next)`
Este hook encapsula o método de registro de serviços locais.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    registerLocalService(next) {
        return (service) => {
            console.log("Registering a local service", service.name);
            return next(service);
        };
    }
}
```

### `serviceCreating(service, schema)`
Este hook é chamado durante a criação de serviço local (depois que os mixins são aplicados, portanto o esquema de serviço está mesclado completamente).

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    serviceCreating(service, schema) {
        // Modify schema
        schema.myProp = "John";
    }
}
```

### `transitPublish(next)`
Este hook é chamado antes de enviar um pacote de comunicação.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transitPublish(next) {
        return (packet) => {
            return next(packet);
        };
    }
}
```

### `transitMessageHandler(next)`
Este gancho é chamado antes que o módulo de trânsito receba & analise uma mensagem recebida.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transitMessageHandler(next) {
        return (cmd, packet) => {
            return next(cmd, packet);
        };
    }
}
```

### `transporterSend(next)`
Este hook é chamado após a serialização, mas antes do transportador enviar um pacote de comunicação.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transporterSend(next) {
        return (topic, data, meta) => {
            // Do something with data. Data is a `Buffer`
            return next(topic, data, meta);
        };
    }
}
```

### `transporterReceive(next)`
Este hook é chamado depois que o transportador recebeu um pacote de comunicação, mas antes da serialização.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    transporterReceive(next) {
        return (cmd, data, s) => {
            // Do something with data. Data is a `Buffer`
            return next(cmd, data, s);
        };
    }
}
```

### `newLogEntry(type, args, bindings)` _(sync)_
Este hook é chamado quando um novo log de mensagens é criado.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    newLogEntry(type, args, bindings) {
        // Do something with the `args`.
    }
}
```

### `created(broker)` _(async)_
Este hook é chamado quando o broker é criado.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    created(broker) {
        console.log("Broker created");
    }
}
```

### `starting(broker)` _(async)_
Este hook é chamado antes do broker iniciar.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    starting(broker) {
        console.log("Broker is starting");
    }
}
```

### `started(broker)` _(async)_
Este hook é chamado após o broker iniciar.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    started(broker) {
        console.log("Broker started");
    }
}
```

### `stopping(broker)` _(async)_
Este hook é chamado antes do broker parar.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    stopping(broker) {
        console.log("Broker is stopping");
    }
}
```

### `stopped(broker)` _(async)_
Este hook é chamado após o broker parar.

```js
// my.middleware.js
module.export = {
    name: "MyMiddleware",

    stopped(broker) {
        console.log("Broker stopped");
    }
}
```

## Middlewares internos
Muitos recursos integrados foram expostos como middlewares internos. Estes middlewares são carregados por padrão quando o broker é criado. No entanto, eles podem ser desativados definindo `internalMiddlewares: false` nas opções do broker. Neste caso, você deve especificar explicitamente os middlewares necessários na opção `middlewares: []` do broker.

**Middlewares internos**

| Nome da classe            | Tipo     | Descrição                                                                            |
| ------------------------- | -------- | ------------------------------------------------------------------------------------ |
| `ActionHook`              | Opcional | Hook de ações. [Leia mais](actions.html#Action-hooks)                                |
| `Validator`               | Opcional | Validações de parâmetros. [Leia mais](validating.html)                               |
| `Bulkhead`                | Opcional | Funcionalidade Bulkhead. [Leia mais](fault-tolerance.html#Bulkhead)                  |
| `Cacher`                  | Opcional | Middleware de cacher. [Leia mais](caching.html)                                      |
| `ContextTracker`          | Opcional | Funcionalidade de rasteamento do Context. [Leia mais](actions.html#Context-tracking) |
| `CircuitBreaker`          | Opcional | Funcionalidade Disjuntor. [Leia mais](fault-tolerance.html#Circuit-Breaker)          |
| `Timeout`                 | Sempre   | Funcionalidade Timeout. [Leia mais](fault-tolerance.html#Timeout)                    |
| `Retry`                   | Sempre   | Funcionaidade Retentativa. [Leia mais](fault-tolerance.html#Retry)                   |
| `Fallback`                | Sempre   | Funcionalidade Fallback. [Leia mais](fault-tolerance.html#Fallback)                  |
| `ErrorHandler`            | Sempre   | Manipulação de erros.                                                                |
| `Rastreamento`            | Opcional | Funcionalidade de rastreamento. [Leia mais](tracing.html)                            |
| `Métricas`                | Opcional | Funcionalidade de métricas. [Leia mais](metrics.html)                                |
| `Debounce`                | Opcional | Funcionalidade debounce. [Leia mais](#Debounce)                                      |
| `Throttle`                | Opcional | Funcionalidade Throttle. [Leia mais](#Throttle)                                      |
| `Transmit.Encryption`     | Opcional | Middleware de transmissão criptografada. [Leia mais](#Encryption)                    |
| `Transmit.Compression`    | Opcional | Middleware de transmissão comprimida. [Leia mais](#Compression)                      |
| `Debugging.TransitLogger` | Opcional | Logs de transporte. [Leia mais](#Transit-Logger)                                     |
| `Debugging.ActionLogger`  | Opcional | Logs de Ações. [Leia mais](#Action-Logger)                                           |

**Acesso a middlewares internos**
```js
const { Bulkhead, Retry } = require("moleculer").Middlewares;
```

### Middlewares de Transmissão

#### Encriptação
O middleware de encriptação AES protege todas as comunicações interserviços que usam o módulo de transporte. Esse middleware usa a biblioteca interna [`cripto`](https://nodejs.org/api/crypto.html).

```js
// moleculer.config.js
const crypto = require("crypto");
const { Middlewares } = require("moleculer");
const initVector = crypto.randomBytes(16);

module.exports = {
  middlewares: [
    Middlewares.Transmit.Encryption("secret-password", "aes-256-cbc", initVector) // "aes-256-cbc" is the default
  ]
};
```
#### Compactação
O middleware de compactação reduz o tamanho das mensagens que passam pelo módulo de transporte. Este middleware usa a biblioteca interna [`zlib`](https://nodejs.org/api/zlib.html).

```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Create broker
module.exports = {
  middlewares: [
    Middlewares.Transmit.Compression("deflate") // or "deflateRaw" or "gzip"
  ]
};
```

### Depurar Middlewares

#### Transit Logger
O middleware de transporte permite rastrear facilmente as mensagens trocadas entre serviços.

```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Create broker
module.exports = {
  middlewares: [
    Middlewares.Debugging.TransitLogger({
      logPacketData: false,
      folder: null,
      colors: {
        send: "magenta",
        receive: "blue"
      },
      packetFilter: ["HEARTBEAT"]
    })
  ]
};
```

**Lista de opções completa**

| Nome da classe  | Tipo                   | Valor padrão | Descrição                                                                                                   |
| --------------- | ---------------------- | ------------ | ----------------------------------------------------------------------------------------------------------- |
| `logger`        | `Object` ou `Function` | `null`       | Classe de logger. [Leia mais](logging.html).                                                                |
| `logLevel`      | `String`               | `info`       | Nível de log para o logger de console. [Leia mais](logging.html).                                           |
| `logPacketData` | `Boolean`              | `false`      | Loga parâmetros do pacote                                                                                   |
| `folder`        | `Object`               | `null`       | Pasta onde os logs serão escritos                                                                           |
| `extension`     | `String`               | `.json`      | Extensão do arquivo de log                                                                                  |
| `color.receive` | `String`               | `grey`       | Suporta todas as [Cores de Chalk](https://github.com/chalk/chalk#colors)                                    |
| `color.send`    | `String`               | `grey`       | Suporta todas as [Cores de Chalk](https://github.com/chalk/chalk#colors)                                    |
| `packetFilter`  | `Array<String>`  | `HEARTBEAT`  | Tipo de [pacotes](https://github.com/moleculer-framework/protocol/blob/master/4.0/PROTOCOL.md) para ignorar |

#### Action Logger
O middleware Action Logger registra "como" os serviços são executados.

```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Create broker
module.exports = {
  middlewares: [
    Middlewares.Debugging.ActionLogger({
      logParams: true,
      logResponse: true,
      folder: null,
      colors: {
        send: "magenta",
        receive: "blue"
      },
      whitelist: ["**"]
    })
  ]
};

```

**Lista de opções completa**

| Nome da classe   | Tipo                   | Valor padrão | Descrição                                                                                                          |
| ---------------- | ---------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------ |
| `logger`         | `Object` ou `Function` | `null`       | Classe de logger. [Leia mais](logging.html).                                                                       |
| `logLevel`       | `String`               | `info`       | Nível de log para o logger de console. [Leia mais](logging.html).                                                  |
| `logParams`      | `Boolean`              | `false`      | Loga parâmetros da requisição                                                                                      |
| `logMeta`        | `Boolean`              | `false`      | Loga parâmetros de metadados                                                                                       |
| `folder`         | `String`               | `null`       | Local da pasta onde os logs serão escritos                                                                         |
| `extension`      | `String`               | `.json`      | Extensão do arquivo de log                                                                                         |
| `color.request`  | `String`               | `yellow`     | Suporta todas as [Cores de Chalk](https://github.com/chalk/chalk#colors)                                           |
| `color.response` | `String`               | `cyan`       | Suporta todas as [Cores de Chalk](https://github.com/chalk/chalk#colors)                                           |
| `colors.error`   | `String`               | `red`        | Suporta todas as [Cores de Chalk](https://github.com/chalk/chalk#colors)                                           |
| `whitelist`      | `Array<String>`  | `["**"]`     | Ações para logar. Usa o mesmo mecanismo de listagem permitida como no [API Gateway](moleculer-web.html#Whitelist). |

### Taxa de Execução de Evento

#### Throttle
É uma redução pura e simples da taxa de acionamento. Fará com que o ouvinte do evento ignore uma parte dos eventos enquanto continua disparando aos ouvintes a uma taxa constante (mas reduzida). Mesma funcionalidade que o [lodash's `_.throttle`](https://lodash.com/docs/4.17.14#throttle). Para mais informações sobre a limitação verifique [este artigo](https://css-tricks.com/debouncing-throttling-explained-examples).

```js
//my.service.js
module.exports = {
    name: "my",
    events: {
        "config.changed": {
            throttle: 3000,
            // It won't be invoked again in 3 seconds.
            handler(ctx) { /* ... */}
        }
    }
};
```

#### Debounce
Ao contrário da desaceleração, o debounce é uma técnica de manter a taxa de ativação exatamente 0 até um período de calma, e, em seguida, acionando o ouvinte exatamente uma vez. Mesma funcionalidade que o [lodash's `_.debounce`](https://lodash.com/docs/4.17.14#debounce). Para mais informações sobre como usar o debounce, cheque [este artigo](https://css-tricks.com/debouncing-throttling-explained-examples).

```js
//my.service.js
module.exports = {
    name: "my",
    events: {
        "config.changed": {
            debounce: 5000,
            // Handler will be invoked when events are not received in 5 seconds.
            handler(ctx) { /* ... */}
        }
    }
};
```

## Carregando & Ampliando
Se você quiser usar os middlewares incorporados, use seus nomes na opção de broker `middlewares[] `. Além disso, os `Middlewares` podem ser facilmente estendidos com funções personalizadas.

**Carregar o middleware pelo nome**
```js
// moleculer.config.js
const { Middlewares } = require("moleculer");

// Extend with custom middleware
Middlewares.MyCustom = {
    created(broker) {
        broker.logger.info("My custom middleware is created!");
    }
};

module.exports = {
    logger: true,
    middlewares: [
        // Load middleware by name
        "MyCustom"
    ]
};  
```

## Visualização global

<div align="center">
    <img src="assets/middlewares.svg" alt="Diagrama de Middlewares" />
</div>

