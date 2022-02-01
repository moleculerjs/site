title: Serviços
---
O `service` representa um microsserviço no framework Moleculer. Você pode definir ações e assinar eventos. Para criar um serviço você deve definir um esquema. O esquema de serviço é semelhante a um [componente do VueJS](https://vuejs.org/v2/guide/components.html#What-are-Components).

## Esquema
O esquema tem algumas partes principais: `name`, `version`, `settings`, `actions`, `methods`, `events`.

### Esquema de serviço simples para definir duas ações
```js
// math.service.js
module.exports = {
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },

        sub(ctx) {
            return Number(ctx.params.a) - Number(ctx.params.b);
        }
    }
}
```

## Propriedades básicas
O Serviço tem algumas propriedades básicas no esquema.
```js
// posts.v1.service.js
module.exports = {
    name: "posts",
    version: 1
}
```
O `name` é uma propriedade obrigatória, então deve ser definida. É a primeira parte do nome da ação quando você a chama.

> Para desativar o prefixo do nome do serviço, defina `$noServiceNamePrefix: true` nas configurações do serviço.

A propriedade `version` é opcional. Use-a para executar várias versões do mesmo serviço. É um prefixo no nome da ação. Pode ser `Number` ou `String`.
```js
// posts.v2.service.js
module.exports = {
    name: "posts",
    version: 2,
    actions: {
        find() {...}
    }
}
```
Para chamar esta ação `find` na versão `2` do serviço:
```js
broker.call("v2.posts.find");
```

{% note info REST call %}
Através do [API Gateway](moleculer-web.html), faça uma requisição para `GET /v2/posts/find`.
{% endnote %}

> Para desativar o prefixo da versão defina `$noVersionPrefix: true` nas configurações do serviço.

## Confirgurações
A propriedade `settings` é um store estático, onde você pode armazenar todas as configurações/opções para seu serviço. Você pode acessa-lo através de `this.settings` dentro do serviço.

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    settings: {
        transport: "mailgun"
    },

    action: {
        send(ctx) {
            if (this.settings.transport == "mailgun") {
                ...
            }
        }
    }
}
```
> A propriedade `settings` também pode ser acessada em nós remotos. É repassado durante a descoberta de serviços.

### Configurações internas
Existem algumas configurações internas que são utilizadas pelos módulos centrais. Nessas configurações os nomes começam com `$` _(sinal de dólar)_.

| Nome                   | Tipo      | Padrão  | Descrição                                                         |
| ---------------------- | --------- | ------- | ----------------------------------------------------------------- |
| `$noVersionPrefix`     | `Boolean` | `false` | Desabilita o prefixo da versão nos nomes das ações.               |
| `$noServiceNamePrefix` | `Boolean` | `false` | Desabilita o prefixo do nome do serviço nos nomes das ações.      |
| `$dependencyTimeout`   | `Number`  | `0`     | Tempo limite para esperar pelas dependências.                     |
| `$shutdownTimeout`     | `Number`  | `0`     | Tempo limite para esperar por requisições ativas no desligamento. |
| `$secureSettings`      | `Array`   | `[]`    | Lista de configurações protegidas.                                |

### Configurações de serviço protegidas
Para proteger seus tokens & chaves de API, defina uma propriedade `$secureSettings: []` nas configurações de serviço e defina as chaves de propriedade protegidas. As configurações protegidas não serão publicadas em outros nós e não aparecerão no Service Registry. Estas configurações só estarão disponíveis sob `this.settings` dentro das funções de serviço.

```js
// mail.service.js
module.exports = {
    name: "mailer",
    settings: {
        $secureSettings: ["transport.auth.user", "transport.auth.pass"],

        from: "sender@moleculer.services",
        transport: {
            service: 'gmail',
            auth: {
                user: 'gmail.user@gmail.com',
                pass: 'yourpass'
            }
        }
    }        
    // ...
};
```

## Mixins
Os Mixins são uma maneira flexível de distribuir funcionalidades reutilizáveis para os serviços Moleculer. O construtor do serviço mescla esses mixins com o esquema atual. Quando um serviço usa mixins, todas as propriedades presentes no mixin serão "misturadas" no serviço atual.

**Exemplo de como estender o serviço `moleculer-web`**

```js
// api.service.js
const ApiGwService = require("moleculer-web");

module.exports = {
    name: "api",
    mixins: [ApiGwService]
    settings: {
        // Change port setting
        port: 8080
    },
    actions: {
        myAction() {
            // Add a new action to apiGwService service
        }
    }
}
```
O exemplo acima cria um serviço `api` que herda todas as propriedades do `ApiGwService`, mas substitui a configuração de porta e amplia com uma nova ação `myAction`.

### Algoritmo de mesclagem
O algoritmo de mesclagem depende do tipo da propriedade.

| Propriedade                     | Algoritmo                                                                                                                                                                   |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`, `version`               | Mesclar & substituir.                                                                                                                                                       |
| `settings`                      | Extensão profunda com [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep).                                                                                          |
| `metadata`                      | Extensão profunda com [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep).                                                                                          |
| `actions`                       | Extensão profunda com [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep). _Você pode desabilitar uma ação do mixin se você a definir como `false` em seu serviço._ |
| `hooks`                         | Extensão profunda com [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep).                                                                                          |
| `methods`                       | Mesclar & substituir.                                                                                                                                                       |
| `events`                        | Concatenar assinantes.                                                                                                                                                      |
| `created`, `started`, `stopped` | Concatenar assinantes.                                                                                                                                                      |
| `mixins`                        | Mesclar & substituir.                                                                                                                                                       |
| `dependencies`                  | Mesclar & substituir.                                                                                                                                                       |
| _any custom_                    | Mesclar & substituir.                                                                                                                                                       |

{% note info Merge algorithm examples %}
__Mesclar & substituir__: se o serviço tem `a: 5`, `b: 8` e o serviço B tem `c: 10`, `b: 15`, o serviço misto terá `a: 5`, `b: 15` e `c: 10`. __Concatenar__: se serviceA & serviceB se inscreverem para o evento `users.created`, ambos os manipuladores de eventos serão chamados quando o evento `users.created` for emitido.
{% endnote %}

## Ações
Ações são os métodos de um serviço que podem ser chamados externamente. Eles podem ser chamadas com `broker.call` ou `ctx.call`. A ação pode ser uma `função` (abreviação para manipulador) ou um objeto com algumas propriedades e o `manipulador`. As ações devem ser colocadas na chave `actions` do esquema. Para obter mais informações verifique a [documentação de ações](actions.html).

```js
// math.service.js
module.exports = {
    name: "math",
    actions: {
        // Shorthand definition, only a handler function
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },

        // Normal definition with other properties. In this case
        // the `handler` function is required!
        mult: {
            cache: false,
            params: {
                a: "number",
                b: "number"
            },
            handler(ctx) {
                // The action properties are accessible as `ctx.action.*`
                if (!ctx.action.cache)
                    return Number(ctx.params.a) * Number(ctx.params.b);
            }
        }
    }
};
```
Você pode chamar as ações acima dessa forma
```js
const res = await broker.call("math.add", { a: 5, b: 7 });
const res = await broker.call("math.mult", { a: 10, b: 31 });
```

Dentro das ações, você pode chamar outras ações aninhadas em outros serviços com o método `ctx.call`. É um atalho para `broker.call`, mas ele se define como contexto pai (devido ao encadeamento correto no rastreamento).
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        async get(ctx) {
            // Find a post by ID
            let post = posts[ctx.params.id];

            // Populate the post.author field through "users" service
            // Call the "users.get" action with author ID
            const user = await ctx.call("users.get", { id: post.author });
            if (user) {
                // Replace the author ID with the received user object
                post.author = user;
            }

            return post;
        }
    }
};
```
> Nos manipuladores de ação `this` sempre aponta para a instância do Serviço.


## Eventos
Você pode assinar eventos com a chave `events`. Para obter mais informações, verifique a [documentação dos eventos](events.html).

```js
// report.service.js
module.exports = {
    name: "report",

    events: {
        // Subscribe to "user.created" event
        "user.created"(ctx) {
            this.logger.info("User created:", ctx.params);
            // Do something
        },

        // Subscribe to all "user.*" events
        "user.*"(ctx) {
            console.log("Payload:", ctx.params);
            console.log("Sender:", ctx.nodeID);
            console.log("Metadata:", ctx.meta);
            console.log("The called event name:", ctx.eventName);
        }

        // Subscribe to a local event
        "$node.connected"(ctx) {
            this.logger.info(`Node '${ctx.params.id}' is connected!`);
        }
    }
};
```
> Nos manipuladores de eventos `this` sempre aponta para a instância do Serviço.

### Agrupamento
O broker agrupa os assinantes do evento pelo nome do grupo. Por padrão, o nome do grupo é o nome do serviço. Mas você pode substituí-la na definição do evento.

```js
// payment.service.js
module.exports = {
    name: "payment",
    events: {
        "order.created": {
            // Register handler to the "other" group instead of "payment" group.
            group: "other",
            handler(payload) {
                // ...
            }
        }
    }
}
```

## Métodos
Para criar métodos privados no serviço, coloque suas funções na chave `methods`. Essas funções são privadas, não podem ser chamadas com `broker.call`. Mas você pode chamá-las de dentro do serviço (de manipuladores de ações, manipuladores de eventos e manipuladores de eventos de ciclo de vida).

**Utilização**
```js
// mailer.service.js
module.exports = {
    name: "mailer",
    actions: {
        send(ctx) {
            // Call the `sendMail` method
            return this.sendMail(ctx.params.recipients, ctx.params.subject, ctx.params.body);
        }
    },

    methods: {
        // Send an email to recipients
        sendMail(recipients, subject, body) {
            return new Promise((resolve, reject) => {
                ...
            });
        }
    }
};
```
Se você quer encapsular um método com um [middleware](middlewares.html#localMethod-next-method) use a seguinte notação:

```js
// posts.service.js
module.exports = {
    name: "posts",

    methods: {
        list: {
            async handler(count) {
                // Do something
                return posts;
            }
        }
    }
};
```


> O nome do método não pode ser `name`, `version`, `settings`, `metadata`, `schema`, `broker`, `actions`, `logger`, porque essas palavras são reservadas no esquema.

> Nos métodos `this` sempre aponta para a instância do Serviço.

## Eventos de Ciclo de vida
Existem alguns eventos de ciclo de vida que serão acionados pelo broker. Estão na base do esquema.

```js
// www.service.js
module.exports = {
    name: "www",
    actions: {...},
    events: {...},
    methods: {...},

    created() {
        // Fired when the service instance created (with `broker.loadService` or `broker.createService`)
    },

    merged() {
        // Fired after the service schemas merged and before the service instance created
    },

    async started() {
        // Fired when broker starts this service (in `broker.start()`)
    }

    async stopped() {
        // Fired when broker stops this service (in `broker.stop()`)
    }
};
```
## Dependências
Se o seu serviço depende de outros serviços, use a propriedade `dependencies` no esquema. O serviço aguarda pelos serviços dependentes antes de chamar o evento `started` do ciclo de vida.

```js
// posts.service.js
module.exports = {
  name: "posts",
  settings: {
      $dependencyTimeout: 30000 // Default: 0 - no timeout
  },
  dependencies: [
      "likes", // shorthand w/o version
      "v2.auth", // shorthand w version
      { name: "users", version: 2 }, // with numeric version
      { name: "comments", version: "staging" } // with string version
  ],
  async started() {
      this.logger.info("It will be called after all dependent services are available.");
      const users = await this.broker.call("users.list");
  }
  ....
}
```
O manipulador de serviços `started` é chamado uma vez que os serviços `likes`, `v2.auth`, `v2.users`, `staging.comments` estiverem disponíveis (nós locais ou remotos).

### Esperar por serviços via ServiceBroker
Para esperar pelos serviços, você também pode usar o método `waitForServices` do `ServiceBroker`. Isto retorna uma `Promise` que será resolvida, quando todos os serviços definidos estiverem disponíveis & iniciados.

**Parâmetros**

| Parâmetro  | Tipo                | Valor padrão | Descrição                                                                                                            |
| ---------- | ------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------- |
| `services` | `String` ou `Array` | -            | Lista de serviços dependentes                                                                                        |
| `timeout`  | `Number`            | `0`          | Timeout da espera. `0` significa que não há tempo limite. Se alcançado, um erro `MoleculerServerError` será lançado. |
| `interval` | `Number`            | `1000`       | Frequência em milissegundos                                                                                          |

**Exemplo**
```js
broker.waitForServices(["posts", "v2.users"]).then(() => {
    // Called after the `posts` & `v2.users` services are available
});
```

**Definir tempo limite & intervalo**
```js
broker.waitForServices("accounts", 10 * 1000, 500).then(() => {
    // Called if `accounts` service becomes available in 10 seconds
}).catch(err => {
    // Called if service is not available in 10 seconds
});
```

## Metadados

O esquema do `Service` tem uma propriedade `metadata`. Você pode armazenar aqui qualquer informação sobre o serviço. Você pode acessá-lo com `this.metadata` dentro das funções do serviço. _Moleculer não os usa. Você pode armazenar o que você quiser._

```js
module.exports = {
    name: "posts",
    settings: {},
    metadata: {
        scalable: true,
        priority: 5
    },

    actions: { ... }
};
```
> A propriedade `metadata` também pode ser obtida em nós remotos. É transferido durante a descoberta de serviços.

## Propriedades das Instâncias de Serviços
Nas funções do serviço, `this` sempre aponta para a instância do Serviço. Ele tem algumas propriedades & métodos que você pode usar em suas funções de serviço.

| Nome                   | Tipo                 | Descrição                                                               |
| ---------------------- | -------------------- | ----------------------------------------------------------------------- |
| `this.name`            | `String`             | Nome do serviço (do esquema)                                            |
| `this.version`         | `Number` ou `String` | Versão do serviço (do esquema)                                          |
| `this.fullName`        | `String`             | Nome do prefixo da versão                                               |
| `this.settings`        | `Object`             | Configurações do serviço (do esquema)                                   |
| `this.metadata`        | `Object`             | Metadados do serviço (do esquema)                                       |
| `this.schema`          | `Object`             | Definição do esquema de serviço                                         |
| `this.broker`          | `ServiceBroker`      | Instância do broker                                                     |
| `this.Promise`         | `Promise`            | Classe de Promessa (Bluebird)                                           |
| `this.logger`          | `Log`                | Instância do logger                                                     |
| `this.actions`         | `Object`             | Ações de serviço. _O serviço pode chamar as próprias ações diretamente_ |
| `this.waitForServices` | `Function`           | Link para o método `broker.waitForServices`                             |
| `this.currentContext`  | `Contexto`           | Obtém ou define o objeto de contexto atual.                             |

## Criação de Serviço
Existem várias maneiras de criar e carregar um serviço.

### broker.createService()
Para testes, desenvolvimento ou protótipos use o método `broker.createService` para carregar & criar um serviço por esquema. É mais simples & mais rápido.

```js
broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});
```

### Carregar um serviço de um arquivo
A maneira recomendada é colocar seu código de serviço em um único arquivo e carregá-lo com o broker.

**math.service.js**
```js
// Export the schema of service
module.exports = {
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },
        sub(ctx) {
            return Number(ctx.params.a) - Number(ctx.params.b);
        }
    }
}
```

**Carregar com o broker:**
```js
// Create broker
const broker = new ServiceBroker();

// Load service
broker.loadService("./math.service");

// Start broker
broker.start();
```

No arquivo de serviço, você também pode criar a instância de serviço. Nesse caso, você tem que exportar uma função que retorne a instância do [Service](#service).
```js
const { Service } = require("moleculer");

// Export a function, the `loadService` will call it with the ServiceBroker instance.
module.exports = function(broker) {
    return new Service(broker, {
        name: "math",
        actions: {
            add(ctx) {
                return Number(ctx.params.a) + Number(ctx.params.b);
            },
            sub(ctx) {
                return Number(ctx.params.a) - Number(ctx.params.b);
            }
        }
    });
}
```

Ou crie uma função que retorne com o esquema de serviço
```js
// Export a function, the `loadService` will call with the ServiceBroker instance.
module.exports = function() {
    let users = [....];

    return {
        name: "math",
        actions: {
            create(ctx) {
                users.push(ctx.params);
            }
        }
    };
}
```

### Carregar vários serviços de uma pasta
Se você tem muitos serviços (e você terá), sugerimos colocá-los em uma pasta de `services` e carregá-los com método `broker.loadServices`.

**Sintaxe**
```js
broker.loadServices(folder = "./services", fileMask = "**/*.service.js");
```

**Exemplo**
```js
// Load every *.service.js file from the "./services" folder (including subfolders)
broker.loadServices();

// Load every *.service.js file from the current folder (including subfolders)
broker.loadServices("./");

// Load every user*.service.js file from the "./svc" folder
broker.loadServices("./svc", "user*.service.js");
```

### Carregar com Moleculer Runner (recomendado)
Recomendamos usar o [Moleculer Runner](runner.html) para iniciar um ServiceBroker e carregar serviços. [Leia mais sobre o Moleculer Runner](runner.html). Esta é a maneira mais fácil de começar um nó.

## Recarregando serviços
Moleculer possui uma função de hot-reloading integrada. Durante o desenvolvimento, pode ser muito útil porque recarrega seus serviços quando você modificá-los. Você pode habilitá-lo nas opções do broker ou no [Moleculer Runner](runner.html). [Vídeo demonstração de como funciona.](https://www.youtube.com/watch?v=l9FsAvje4F4)

**Habilitar nas opções do broker**

```js
const broker = new ServiceBroker({
    hotReload: true
});

broker.loadService("./services/test.service.js");
```

**Ativar no Moleculer Runner**

Ative-o com as flags `--hot` ou `-H`.

```bash
$ moleculer-runner --hot ./services/test.service.js
```

{% note info %}
A função hot-reloading está funcionando somente com o Moleculer Runner ou se você carregar seus serviços com `broker.loadService` ou `broker.loadServices`. Ele não funciona com o `broker.createService`.
{% endnote %}

{% note info %}
O mecanismo de hot-reloading observa os arquivos de serviço e suas dependências. Toda vez que uma alteração de arquivo é detectada o mecanismo de hot-reloading irá rastrear os serviços que dependem dela e reiniciá-los.
{% endnote %}

## Variáveis Locais
Se você gostaria de usar propriedades/variáveis locais em seu serviço, declare-as no manipulador de eventos `created`.

**Exemplo para variáveis locais**
```js
const http = require("http");

module.exports = {
    name: "www",

    settings: {
        port: 3000
    },

    created() {
        // Create HTTP server
        this.server = http.createServer(this.httpHandler);
    },

    started() {
        // Listening...
        this.server.listen(this.settings.port);
    },

    stopped() {
        // Stop server
        this.server.close();
    },

    methods() {
        // HTTP handler
        httpHandler(req, res) {
            res.end("Hello Moleculer!");
        }
    }
}
```
{% note warn Naming restriction %}
É importante estar ciente de que você não pode usar um nome de variável que é reservado para o serviço ou coincide com seus nomes de método! Ex.: `this.name`, `this.version`, `this.settings`, `this.schema`...etc.
{% endnote %}

## Classes ES6
Se você preferir classes da ES6 para o esquema de serviço Moleculer, você pode escrever seus serviços em classes ES6. Há duas maneiras de fazer.

### Classes nativas ES6 com parse de esquema

Defina manipuladores de `actions` e `events` como métodos de classe e chame o método `parseServiceSchema` no construtor com a definição de esquema e os manipuladores apontarão para esses métodos de classe.
```js
const Service = require("moleculer").Service;

class GreeterService extends Service {

    constructor(broker) {
        super(broker);

        this.parseServiceSchema({
            name: "greeter",
            version: "v2",
            meta: {
                scalable: true
            },
            dependencies: [
                "auth",
                "users"
            ],

            settings: {
                upperCase: true
            },
            actions: {
                hello: this.hello,
                welcome: {
                    cache: {
                        keys: ["name"]
                    },
                    params: {
                        name: "string"
                    },
                    handler: this.welcome
                }
            },
            events: {
                "user.created": this.userCreated
            },
            created: this.serviceCreated,
            started: this.serviceStarted,
            stopped: this.serviceStopped,
        });
    }

    // Action handler
    hello() {
        return "Hello Moleculer";
    }

    // Action handler
    welcome(ctx) {
        return this.sayWelcome(ctx.params.name);
    }

    // Private method
    sayWelcome(name) {
        this.logger.info("Say hello to", name);
        return `Welcome, ${this.settings.upperCase ? name.toUpperCase() : name}`;
    }

    // Event handler
    userCreated(user) {
        this.broker.call("mail.send", { user });
    }

    serviceCreated() {
        this.logger.info("ES6 Service created.");
    }

    serviceStarted() {
        this.logger.info("ES6 Service started.");
    }

    serviceStopped() {
        this.logger.info("ES6 Service stopped.");
    }
}

module.exports = GreeterService;
```

### Usar decoradores
Graças a [@ColonelBundy](https://github.com/ColonelBundy), você também pode usar decoradores ES7/TS: [moleculer-decorators](https://github.com/ColonelBundy/moleculer-decorators)

{% note info Need a compiler %}
Por favor, note que você deve usar Typescript ou Babel para compilar decoradores.
{% endnote %}

**Serviço de exemplo**
```js
const { ServiceBroker } = require('moleculer');
const { Service, Action, Event, Method } = require('moleculer-decorators');
const web = require('moleculer-web');
const broker = new ServiceBroker();

@Service({
    mixins: [web],
    settings: {
        port: 3000,
        routes: [
            //...
        ]
    }
})
class MyService {
    @Action()
    Login(ctx) {
        //...
    }

    // With options
    @Action({
        cache: false,
        params: {
            a: "number",
            b: "number"
        }
    })
    Login2(ctx) {
        //...
    }

    @Event
    'event.name'(payload, sender, eventName) {
        //...
    }

    @Method
    authorize(ctx, route, req, res) {
        //...
    }

    hello() { // Private
        //...
    }

    started() { // Reserved for moleculer, fired when started
        //...
    }

    created() { // Reserved for moleculer, fired when created
        //...
    }

    stopped() { // Reserved for moleculer, fired when stopped
        //...
    }
}

broker.createService(MyService);
broker.start();
```

## Internal Services
The `ServiceBroker` contains some internal services to check the node health or get some registry information. You can disable them by setting `internalServices: false` in broker options.

### List of nodes
It lists all known nodes (including local node).
```js
broker.call("$node.list").then(res => console.log(res));
```

**Parâmetros**

| Nome            | Tipo      | Padrão  | Descrição                  |
| --------------- | --------- | ------- | -------------------------- |
| `withServices`  | `Boolean` | `false` | List with services.        |
| `onlyAvailable` | `Boolean` | `false` | List only available nodes. |

### List of services
It lists all registered services (local & remote).
```js
broker.call("$node.services").then(res => console.log(res));
```

**Parâmetros**

| Nome            | Tipo      | Padrão  | Descrição                             |
| --------------- | --------- | ------- | ------------------------------------- |
| `onlyLocal`     | `Boolean` | `false` | List only local services.             |
| `skipInternal`  | `Boolean` | `false` | Skip the internal services (`$node`). |
| `withActions`   | `Boolean` | `false` | List with actions.                    |
| `onlyAvailable` | `Boolean` | `false` | List only available services.         |

### List of local actions
It lists all registered actions (local & remote).
```js
broker.call("$node.actions").then(res => console.log(res));
```
It has some options which you can declare within `params`.

**Opções**

| Nome            | Tipo      | Padrão  | Descrição                            |
| --------------- | --------- | ------- | ------------------------------------ |
| `onlyLocal`     | `Boolean` | `false` | List only local actions.             |
| `skipInternal`  | `Boolean` | `false` | Skip the internal actions (`$node`). |
| `withEndpoints` | `Boolean` | `false` | List with endpoints _(nodes)_.       |
| `onlyAvailable` | `Boolean` | `false` | List only available actions.         |

### List of local events
It lists all event subscriptions.
```js
broker.call("$node.events").then(res => console.log(res));
```
It has some options which you can declare within `params`.

**Opções**

| Nome            | Tipo      | Padrão  | Descrição                                  |
| --------------- | --------- | ------- | ------------------------------------------ |
| `onlyLocal`     | `Boolean` | `false` | List only local subscriptions.             |
| `skipInternal`  | `Boolean` | `false` | Skip the internal event subscriptions `$`. |
| `withEndpoints` | `Boolean` | `false` | List with endpoints _(nodes)_.             |
| `onlyAvailable` | `Boolean` | `false` | List only available subscriptions.         |

### List of metrics
It lists all metrics.
```js
broker.call("$node.metrics").then(res => console.log(res));
```
It has some options which you can declare within `params`.

**Opções**

| Nome       | Tipo                | Padrão | Descrição                                                                      |
| ---------- | ------------------- | ------ | ------------------------------------------------------------------------------ |
| `types`    | `String` or `Array` | `null` | [Type](metrics.html#Supported-Metric-Types) of metrics to include in response. |
| `includes` | `String` or `Array` | `null` | List of metrics to be included in response.                                    |
| `excludes` | `String` or `Array` | `null` | List of metrics to be excluded from the response.                              |

### Get Broker options
It returns the broker options.
```js
broker.call("$node.options").then(res => console.log(res));
```

### Health of node
It returns the health info of local node (including process & OS information).
```js
broker.call("$node.health").then(res => console.log(res));
```

Example health info:
```js
{
    "cpu": {
        "load1": 0,
        "load5": 0,
        "load15": 0,
        "cores": 4,
        "utilization": 0
    },
    "mem": {
        "free": 1217519616,
        "total": 17161699328,
        "percent": 7.094400109979598
    },
    "os": {
        "uptime": 366733.2786046,
        "type": "Windows_NT",
        "release": "6.1.7601",
        "hostname": "Developer-PC",
        "arch": "x64",
        "platform": "win32",
        "user": {
            "uid": -1,
            "gid": -1,
            "username": "Developer",
            "homedir": "C:\\Users\\Developer",
            "shell": null
        }
    },
    "process": {
        "pid": 13096,
        "memory": {
            "rss": 47173632,
            "heapTotal": 31006720,
            "heapUsed": 22112024
        },
        "uptime": 25.447
    },
    "client": {
        "type": "nodejs",
        "version": "0.12.0",
        "langVersion": "v8.9.4"
    },
    "net": {
        "ip": [
            "192.168.2.100",
            "192.168.232.1",
            "192.168.130.1",
            "192.168.56.1",
            "192.168.99.1"
        ]
    },
    "time": {
        "now": 1487338958409,
        "iso": "2018-02-17T13:42:38.409Z",
        "utc": "Fri, 17 Feb 2018 13:42:38 GMT"
    }
}
```
{% note info %}
Please note, internal service actions are not traced.
{% endnote %}

### Extending
Internal service can be easily extended with custom functionalities. To do it you must define a mixin schema in broker´s `internalServices` option.

```javascript
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    logger: true,
    internalServices: {
        $node: {
            actions: {
                // Call as `$node.hello`
                hello(ctx) {
                    return `Hello Moleculer!`;
                }
            }
        }
    }
};
```
