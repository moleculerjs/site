title: Configuração
---
## Opções do broker
Essas opções podem ser usadas no construtor do `ServiceBroker` ou no arquivo `moleculer.config.js`.

**Lista de todas as opções do broker disponíveis:**

* **`namespace`**: `String` - Namespace de nós para segmentar seus nós na mesma rede (por exemplo: "development", "staging", "production"). _Default: `""`_
* **`nodeID`**: `String` - Identificador de nó único. Deve ser único em um namespace. Se não o broker irá retornar um erro fatal e abortar o processo. _Default: hostname + PID_
* **`logger`**: `Boolean | String | Object | Array<Object>`  ) - Classe de Logger. Por padrão, ele imprime mensagem no `console`. [Leia mais](logging.html). _Default: `<code>"Console"`</li>
* **`logLevel`**: `String | Object` - Nível de log (trace, debug, info, warn, error, fatal). [Leia mais](logging.html). _Default: `info`_
* **`transporter`**: `String | Object | Transporter` - Configuração do módulo de transporte. [Leia mais](networking.html).  _Default: `null`_
* **`requestTimeout`**: `Number` - Número de milissegundos para esperar antes de rejeitar uma solicitação com um erro de `RequestTimeout`. Desabilitado: `0` _Default: `0`_
* **`retryPolicy`**: `Object` - Configuração de política de repetição. [Leia mais](fault-tolerance.html#Retry).
* **`contextParamsCloning`**: `Boolean` - Clonando os `parâmetros` do context, se habilitado. _Alto impacto no desempenho. Use-o com cuidado!_ _Default: `false`_
* **`dependencyInterval`**: Intervalo configurável (definido em `ms`) é usado pelos serviços enquanto aguarda dependências de serviços. _Default: `1000`_
* **`maxCallLevel`**: `Number` - Limite de níveis de chamadas. Se atingir o limite, o broker retornará um erro ` MaxCallLevelError`. _(Proteção de Loop infinito)_ _Default: `0`_
* **`heartbeatInterval`**: `Number` - Número de segundos para enviar um pacote de sinal de vida para outros nós. _Default: `5`_
* **`heartbeatTimeout`**: `Number` - Número de segundos para esperar antes de configurar nós remotos para o status indisponível no Registro. _Default: `15`_
* **`tracking`**: `Object` - Rastrear requisições e aguardar pelas requisições em andamento antes de desligar. _(Desligamento elegante)_ [Leia mais](context.html#Context-tracking).
* **`disableBalancer`**: Boolean - Desabilitar o balanceamento de carga integrado em requisições & emissões de evento. _O módulo de transporte também precisa atender._ [Leia mais](networking.html#Disabled-balancer). _Default: `false`_
* **`registry`**: `Object` - Configurações do [Service Registry](registry.html).
* **`circuitBreaker`**: `Object` - Configurações do [Circuit Breaker](fault-tolerance.html#Circuit-Breaker).
* **`bulkhead`**: `Object` - Configurações do [bulkhead](fault-tolerance.html#Bulkhead).
* **`transit.maxQueueSize`**: `Number` - Uma proteção contra uso exagerado de memória quando existem muitas solicitações de saída. Se houver mais requisições em tempo real do que o _indicado_, as novas solicitações serão rejeitadas com o erro `QueueIsFullError`. _Default: `50000`_
* **`transit.maxChunkSize`** `Number` - Tamanho máximo durante streaming.  _Default: `256KB`_
* **`transit.disableReconnect`**: `Boolean` - Desabilita a lógica de reconexão ao iniciar o broker. _Default: `false`_
* **`transit.disableVersionCheck`**: `Boolean` - Desabilita a validação de versão do protocolo em Transit. _Default: `false`_
* **`transit.packetLogFilter`**: `Array` - Filtra os pacotes nas mensagens de log do debug. Pode ser útil filtrar os pacotes `HEARTBEAT` durante o debug. _Default: `[]`_
* **`uidGenerator`**: `Function` - Função de gerador de UID customizada para ID Context.
* **`errorHandler`**: `Function` - Função [Manipulador de erros global](broker.html#Global-error-handler).
* **`cacher`**: `String | Object | Cacher` - Configurações de cache. [Leia mais](caching.html). _Default: `null`_
* **`serializer`**: `String | Serializer` - Instância do serializador. [Leia mais](networking.html). _Default: `JSONSerializer`_
* **`validator`**: `Boolean | Validator` - Habilita o padrão ou cria [validação de parâmetros](validating.html) personalizada. _Default: `true`_
* **`errorRegenerator`**: `Regenerador` - Instância do regenerador de erro. [Leia mais](errors.html#Preserve-custom-error-classes-while-transferring-between-remote-nodes). _Default: `null`_
* **`metrics`**: `Boolean | Object` - Habilita & configura o recurso de [métricas](metrics.html). _Default: `false`_
* **`tracing`**: `Boolean | Object` - Habilita & configura o recurso de [tracing](tracing.html). _Default: `false`_
* **`internalServices`**: `Boolean | Object` - Registra [serviços internos](services.html#Internal-Services) ao inicializar. _Default: `true`_
* **`internalServices.$node`** - `Object` - Amplia serviços internos com [ações customizadas](services.html#Extending). _Default: `null`_
* **`internalMiddlewares`**: `Boolean` - Registra [middlewares internos](middlewares.html#Internal-middlewares). _Default: `true`_
* **`hotReload`**: `Boolean` - Observar os serviços carregados e recarregar se forem alterados. [Leia mais](services.html#Hot-Reloading-Services). _Default: `false`_
* **`middlewares`**: `Array<Object>` - Registre middlewares personalizados. _Default: `null`_
* **`replDelimiter`**: `String` - Delimitador personalizado de comandos REPL. _Default: `mol $`_
* **`replCommands`**: `Array<Object>` - Registre comandos REPL personalizados. _Default: `null`_
* **`metadata`**: `Object` - Armazene valores personalizados. _Default: `null`_
* **`skipProcessEventRegistration`**: Boolean - Ignore o manipulador [padrão](https://github.com/moleculerjs/moleculer/blob/master/src/service-broker.js#L234) de eventos de desligamento elegante. Neste caso, você tem que registrá-los manualmente. _Default: `false`_
* **`maxSafeObjectSize`**: `Number` - Tamanho máximo de objetos que podem ser serializados. No processo de serialização, checa a propriedade size de cada objeto (baseado no valor da propriedade `length` ou `size`) aparando as extremidades, se o tamanho do objeto for maior que o valor de `maxSafeObjectSize`. _Default: `null`_
* **`created`**: `Function` - Acionado quando o broker for criado. _Default: `null`_
* **`started`**: `Function` - Acionado quando o broker for inicializado _(todos os serviços locais carregados & módulo de transporte conectado)_. _Default: `null`_
* **`stopped`**: `Function` - Acionado quando o broker for parado _(todos os serviços locais parados & módulo de transporte está desconectado)_. _Default: `null`_
* **`ServiceFactory`**: `ServiceClass` - Classe `Service` personalizada. Se não for `null`, o broker usará ao criar serviços via esquema de serviço. _Default: `null`_
* **`ContextFactory`**: `ContextClass` - Classe `Context` personalizada. Se não for `null`, o broker usará ao criar contextos para requisições & eventos. _Default: `null`_</ul>

### Opções completas
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
