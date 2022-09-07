title: API Gateway
---
## moleculer-web [![npm](https://img.shields.io/npm/v/moleculer-web.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-web)
O [moleculer-web](https://github.com/moleculerjs/moleculer-web) é o serviço oficial de API gateway para o framework Moleculer. Use-o para publicar seus serviços como APIs RESTful.

## Funcionalidades
* suporta HTTP & HTTPS
* servidor de arquivos estáticos
* múltiplas rotas
* suporta middlewares, do tipo Connect, a nível global, a nível de rotas e a nível de alias.
* nomes de alias (com parâmetros nomeados & rotas REST)
* lista de permissões (allowlist)
* múltiplos body parsers (json, urlencoded)
* cabeçalhos CORS
* Limitador de taxa
* hooks antes & depois de chamadas
* Manipulação de buffer & fluxo
* modo middleware (use como um middleware com Express)

{% note info Experimente em seu navegador! %}
[![Editar moleculer-web](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/github/moleculerjs/sandbox-moleculer-api-routing/tree/master/?fontsize=14)
{% endnote %}

## Instalação
```bash
npm i moleculer-web
```

## Utilização

### Execute com configurações padrão
Este exemplo usa o serviço de API Gateway com configurações padrão. Você pode acessar todos os serviços (incluindo o interno `$node.`) através de `http://localhost:3000/`

```js
const { ServiceBroker } = require("moleculer");
const ApiService = require("moleculer-web");

const broker = new ServiceBroker();

// Load API Gateway
broker.createService(ApiService);

// Start server
broker.start();
```

**Modelos de URLs:**
- Chame a ação `test.hello`: `http://localhost:3000/test/hello`
- Chama a ação `math.add` com parâmetros: `http://localhost:3000/math/add?a=25&b=13`

- Obter informação de saúde do nó: `http://localhost:3000/~node/health`
- Listar todas as ações: `http://localhost:3000/~node/actions`

## Lista de permissões (allowlist)
Se você não quiser publicar todas as ações, você pode filtrá-las com a opção allowlist. Use sequências de caracteres ou expressão regular na lista. _Para ativar todas as ações, use `"**"` item._

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            path: "/api",

            whitelist: [
                // Access any actions in 'posts' service
                "posts.*",
                // Access call only the `users.list` action
                "users.list",
                // Access any actions in 'math' service
                /^math\.\w+$/
            ]
        }]
    }
});
```

## Aliases
Você pode usar nomes de alias ao invés de nomes de ação. Você também pode especificar o método. Caso contrário, irá lidar com todos os tipos de métodos.

Usar parâmetros nomeados em aliases é possível. Parâmetros nomeados são definidos prefixando dois pontos ao nome do parâmetro (`:name`).

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                // Call `auth.login` action with `GET /login` or `POST /login`
                "login": "auth.login",

                // Restrict the request method
                "POST users": "users.create",

                // The `name` comes from named param. 
                // You can access it with `ctx.params.name` in action
                "GET greeter/:name": "test.greeter",
            }
        }]
    }
});
```

{% note info %}
O parâmetro nomeado é manipulado com o módulo [path-to-regexp](https://github.com/pillarjs/path-to-regexp). Portanto, você também pode usar parâmetros [opcionais](https://github.com/pillarjs/path-to-regexp#optional) e [repetidos](https://github.com/pillarjs/path-to-regexp#zero-or-more).
{% endnote %}

{% note info Aliases Action%}
O API gateway implementa a [ação](actions.html) `listAliases` que lista os endpoints HTTP para mapeamentos de ações.
{% endnote %}

Você também pode criar APIs RESTful.
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "GET users": "users.list",
                "GET users/:id": "users.get",
                "POST users": "users.create",
                "PUT users/:id": "users.update",
                "DELETE users/:id": "users.remove"
            }
        }]
    }
});
```

Para rotas REST você também pode usar este atalho simples:
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "REST users": "users"
            }
        }]
    }
});
```
{% note warn %}
Para usar esse atalho abreviado, crie um serviço que tem as ações `list`, `get`, `create`, `update` e `remove`.
{% endnote %}

Você pode usar funções personalizadas dentro da declaração de aliases. Neste caso, a assinatura é a função `(req, res) {...}`.

{% note info %}
Por favor, note que Moleculer usa o [servidor HTTP](https://nodejs.org/api/http.html) nativo do Node.js
{% endnote %}

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "POST upload"(req, res) {
                    this.parseUploadedFile(req, res);
                },
                "GET custom"(req, res) {
                    res.end('hello from custom handler')
                }
            }
        }]
    }
});
```

{% note info %}
Há alguns ponteiros internos nos objetos `req` & `res`:
* `req.$ctx` estão apontadas para o context da requisição.
* `req.$service` & `res.$service` apontam para esta instância do serviço.
* `req.$route` & `res.$route` estão apontados para a definição da rota resolvida.
* `req.$params` é apontado para os parâmetros resolvidos (da string de consulta & corpo do post)
* `req.$alias` está apontado para a definição de alias resolvido.
* `req.$action` está apontado para a ação resolvida.
* `req.$endpoint` foi apontado para o endpoint da ação resolvida.
* `req.$next` é apontado para o manipulador `next()` se a solicitação vem do ExpressJS.

Ex.: Para acessar o broker, use `req.$service.broker`.
{% endnote %}

### Política de mapeamento
A `rota` possui uma propriedade `mappingPolicy` para manipular rotas sem aliases.

**Opções disponíveis:**
- `all` - habilitar para requisitar todas as rotas com ou sem aliases (padrão)
- `restrict` - ativar para solicitar apenas as rotas com aliases.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            mappingPolicy: "restrict",
            aliases: {
                "POST add": "math.add"
            }
        }]
    }
});
```
Você não pode solicitar `/math.add` ou `/math/add` URLs, apenas `POST /add`.

### Aliases para carregamento de arquivo
Api Gateway implementa upload de arquivos. Você pode fazer upload de arquivos como dados de um formulário (graças à biblioteca [busboy](https://github.com/mscdex/busboy)) ou como corpo de requisição no formato raw. Em ambos os casos, o arquivo é transferido para uma ação como um `Stream`. No modo de dados mutipart você pode fazer upload de vários arquivos também.

**Exemplo**
```js
const ApiGateway = require("moleculer-web");

module.exports = {
    mixins: [ApiGateway],
    settings: {
        path: "/upload",

        routes: [
            {
                path: "",

                aliases: {
                    // File upload from HTML multipart form
                    "POST /": "multipart:file.save",

                    // File upload from AJAX or cURL
                    "PUT /:id": "stream:file.save",

                    // File upload from HTML form and overwrite busboy config
                    "POST /multi": {
                        type: "multipart",
                        // Action level busboy config
                        busboyConfig: {
                            limits: { files: 3 }
                        },
                        action: "file.save"
                    }
                },

                // Route level busboy config.
                // More info: https://github.com/mscdex/busboy#busboy-methods
                busboyConfig: {
                    limits: { files: 1 }
                    // Can be defined limit event handlers
                    // `onPartsLimit`, `onFilesLimit` or `onFieldsLimit`
                },

                mappingPolicy: "restrict"
            }
        ]
    }
});
```
**Parâmetros multipart**

Para acessar os arquivos passados em formato multipart-form, esses campos específicos podem ser usados dentro da ação:
- `ctx.params` é a transmissão que contém o arquivo passado para o endpoint
- `ctx.meta.$params` parâmetros da URL querystring
- `ctx.meta.$multipart` contém os campos de formulário adicional _deve ser enviado antes de outros campos de arquivos_.

### Auto-alias
O auto-alias permite que você declare o alias de rota diretamente nos seus serviços. O gateway irá dinamicamente construir as rotas completas do esquema de serviço.

{% note info %}
Gateway irá regerar as rotas sempre que um serviço entrar ou sair da rede.
{% endnote %}

Use o parâmetro `whitelist` para especificar os serviços que o Gateway deve rastrear e construir as rotas.

**Exemplo**
```js
// api.service.js
module.exports = {
    mixins: [ApiGateway],

    settings: {
        routes: [
            {
                path: "/api",

                whitelist: [
                    "v2.posts.*",
                    "test.*"
                ],

                aliases: {
                    "GET /hi": "test.hello"
                },

                autoAliases: true
            }
        ]
    }
};
```

```js
// posts.service.js
module.exports = {
    name: "posts",
    version: 2,

    settings: {
        // Base path
        // rest: "posts/" // If you want to change the base 
        // path with /api/posts instead 
        // of /api/v2/posts, you can uncomment this line.
    },

    actions: {
        list: {
            // Expose as "/api/v2/posts/"
            rest: "GET /",
            handler(ctx) {}
        },

        get: {
            // Expose as "/api/v2/posts/:id"
            rest: "GET /:id",
            handler(ctx) {}
        },

        create: {
            rest: "POST /",
            handler(ctx) {}
        },

        update: {
            rest: "PUT /:id",
            handler(ctx) {}
        },

        remove: {
            rest: "DELETE /:id",
            handler(ctx) {}
        }
    }
};
```

**Aliases gerados**

```bash
    GET     /api/hi             => test.hello
    GET     /api/v2/posts       => v2.posts.list
    GET     /api/v2/posts/:id   => v2.posts.get
    POST    /api/v2/posts       => v2.posts.create
    PUT     /api/v2/posts/:id   => v2.posts.update
    DELETE  /api/v2/posts/:id   => v2.posts.remove
```

**Exemplo para definir caminho completo de alias**
```js
// posts.service.js
module.exports = {
    name: "posts",
    version: 2,

    settings: {
        // Base path
        rest: "posts/"
    },

    actions: {
        tags: {
            // Expose as "/tags" instead of "/api/v2/posts/tags"
            rest: {
                method: "GET",
                fullPath: "/tags"
            },
            handler(ctx) {}
        }
    }
};
```


## Parâmetros
O gateway API coleta parâmetros pela URL, parâmetros de requisição & corpo da requisição e os mescla. Os resultados são colocados na `req.$params`.

### Desativar mesclagem
Para desativar o mapeamento de parâmetros atribua `mergeParams: false` nas configurações de rota. Neste caso, os parâmetros estarão separados.

**Exemplo**
```js
broker.createService({
    mixins: [ApiService],
    settings: {
        routes: [{
            path: "/",
            mergeParams: false
        }]
    }
});
```

**`req.$params` não mesclada:**
```js
{
    // Querystring params
    query: {
        category: "general",
    }

    // Request body content
    body: {
        title: "Hello",
        content: "...",
        createdAt: 1530796920203
    },

    // Request params
    params: {
        id: 5
    }
}
```

### Parâmetros via URL
Mais informações: https://github.com/ljharb/qs

**Array parameters** URL: `GET /api/opt-test?a=1&a=2`
```js
a: ["1", "2"]
```

**Objetos aninhados & arrays** URL: `GET /api/opt-test?foo[bar]=a&foo[bar]=b&foo[baz]=c`
```js
foo: { 
    bar: ["a", "b"], 
    baz: "c" 
}
```

## Middlewares
Suporta middlewares, do tipo Connect, a nível global, a nível de rotas & a nível de alias. Assinatura: `function(req, res, next) {...}`. Para mais informações verifique [middleware express](https://expressjs.com/en/guide/using-middleware.html)

**Exemplos**
```js
broker.createService({
    mixins: [ApiService],
    settings: {
        // Global middlewares. Aplicado a todas as rotas.
        use: [
            cookieParser(),
            helmet()
        ],

        routes: [
            {
                path: "/",

                // Route-level middlewares.
                use: [
                    compression(),

                    passport.initialize(),
                    passport.session(),

                    serveStatic(path.join(__dirname, "public"))
                ],

                aliases: {
                    "GET /secret": [
                        // Alias-level middlewares.
                        auth.isAuthenticated(),
                        auth.hasRole("admin"),
                        "top.secret" // Call the `top.secret` action
                    ]
                }
            }
        ]
    }
});
```
Use [swagger-stats](https://swaggerstats.io/) para visualizar rapidamente a "saúde" da sua API (TypeScript)
```ts
import { Service, ServiceSchema } from "moleculer";
import ApiGatewayService from "moleculer-web";
const swStats = require("swagger-stats");

const swMiddleware = swStats.getMiddleware();

broker.createService({
    mixins: [ApiGatewayService],
    name: "gw-main",

    settings: {
        cors: {
            methods: ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"],
            origin: "*",
        },

        routes: [
            // ...
        ],

        use: [swMiddleware],
    },

    async started(this: Service): Promise<void> {
        this.addRoute({
            path: "/",
            use: [swMiddleware],
        });
    },
} as ServiceSchema);
```

### Middleware para tratamento de erros
Existe suporte para usar middlewares manipuladores de erro no gateway. Então, se você passar um `Error` para a função `next(err)`, ele chamará middlewares com a assinatura `(err, req, res, next)`.

```js
broker.createService({
    mixins: [ApiService],
    settings: {
        // Global middlewares. Aplicado a todas as rotas.
        use: [
            cookieParser(),
            helmet()
        ],

        routes: [
            {
                path: "/",

                // Route-level middlewares.
                use: [
                    compression(),

                    passport.initialize(),
                    passport.session(),

                    function(err, req, res, next) {
                        this.logger.error("Error is occured in middlewares!");
                        this.sendError(req, res, err);
                    }
                ],
```

## Servidor de arquivos estáticos
Ele serve conteúdo com o módulo [serve-static](https://github.com/expressjs/serve-static) como o ExpressJS.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        assets: {
            // Root folder of assets
            folder: "./assets",

            // Further options to `serve-static` module
            options: {}
        }       
    }
});
```

## Opções de chamada
O objeto `route` possui uma propriedade `callOptions` que é passada para `broker.call`. Então você pode definir `timeout`, `retries` ou `opções de fallbackResponse` para rotas. [Leia mais sobre as opções de chamadas](actions.html#Call-services)

{% note info %}
Note que você também pode definir o tempo limite para uma ação diretamente na sua [definição](actions.html#Timeout)
{% endnote %}

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{

            callOptions: {
                timeout: 500,
                retries: 3,
                fallbackResponse(ctx, err) { ... }
            }

        }]      
    }
});
```

## Múltiplas rotas
Você pode criar várias rotas com um prefixo diferente, allowlist, alias, opções de chamadas & autorização.

{% note info %}
Ao usar várias rotas você deve definir explicitamente os body parsers para cada rota.
{% endnote %}

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [
            {
                path: "/admin",

                authorization: true,

                whitelist: [
                    "$node.*",
                    "users.*",
                ]

                bodyParsers: {
                    json: true
                }
            },
            {
                path: "/",

                whitelist: [
                    "posts.*",
                    "math.*",
                ]

                bodyParsers: {
                    json: true
                }
            }
        ]
    }
});
```

## Tipo de resposta & código de estado
Quando a resposta é recebida de um manipulador de ação, o gateway API detecta o tipo de resposta e define o `Content-Type` nos cabeçalhos `res`. O código de status é `200` por padrão. É claro que você pode substituir esses valores, além disso, você também pode definir cabeçalhos de resposta personalizados.

Para definir cabeçalhos de resposta & status código use os campos `ctx.meta`:

**Campos meta disponíveis:**
* `ctx.meta.$statusCode` - atribui `res.statusCode`.
* `ctx.meta.$statusMessage` - atribui `res.statusMessage`.
* `ctx.meta.$responseType` - atribui `Content-Type` no cabeçalho.
* `ctx.meta.$responseHeaders` - atribui chaves no cabeçalho.
* `ctx.meta.$location` - atribui `Location` no cabeçalho para redirecionamentos.

**Exemplo**
```js
module.exports = {
    name: "export",
    actions: {
        // Download response as a file in the browser
        downloadCSV(ctx) {
            ctx.meta.$responseType = "text/csv";
            ctx.meta.$responseHeaders = {
                "Content-Disposition": `attachment; filename="data-${ctx.params.id}.csv"`
            };

            return csvFileStream;
        }

        // Redirect the request
        redirectSample(ctx) {
            ctx.meta.$statusCode = 302;
            ctx.meta.$location = "/login";

            return;
        }
    }
}
```

## Autorização
Você pode implementar a autorização. Faça duas coisas para ativá-lo.
1. Defina `authorization: true` em suas rotas
2. Defina o método `authorize` no serviço.

**Exemplo de autorização**
```js
const E = require("moleculer-web").Errors;

broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            // First thing
            authorization: true
        }]
    },

    methods: {
        // Second thing
        authorize(ctx, route, req, res) {
            // Read the token from header
            let auth = req.headers["authorization"];
            if (auth && auth.startsWith("Bearer")) {
                let token = auth.slice(7);

                // Check the token
                if (token == "123456") {
                    // Set the authorized user entity to `ctx.meta`
                    ctx.meta.user = { id: 1, name: "John Doe" };
                    return Promise.resolve(ctx);

                } else {
                    // Invalid token
                    return Promise.reject(new E.UnAuthorizedError(E.ERR_INVALID_TOKEN));
                }

            } else {
                // No token
                return Promise.reject(new E.UnAuthorizedError(E.ERR_NO_TOKEN));
            }
        }

    }
}
```

{% note info %}
Você pode encontrar um exemplo de autorização JWT mais detalhado com base nesse [exemplo completo](https://github.com/moleculerjs/moleculer-web/blob/master/examples/full/index.js#L239).
{% endnote %}

## Autenticação
Para habilitar o suporte para a autenticação, você precisa fazer algo semelhante ao que é descrito no parágrafo de autorização. Também neste caso você precisa:
1. Defina `authentication: true` em suas rotas
2. Defina o seu método personalizado `authenticate` no seu serviço

O valor retornado será atribuído para a propriedade `ctx.meta.user`. Você pode usá-lo em suas ações para obter a entidade de usuário logada.

**Exemplo de autenticação**
```js
broker.createService({
    mixins: ApiGatewayService,

    settings: {
        routes: [{
            // Enable authentication
            authentication: true
        }]
    },

    methods: {
        authenticate(ctx, route, req, res) {
            let accessToken = req.query["access_token"];
            if (accessToken) {
                if (accessToken === "12345") {
                    // valid credentials. It will be set to `ctx.meta.user`
                    return Promise.resolve({ id: 1, username: "john.doe", name: "John Doe" });
                } else {
                    // invalid credentials
                    return Promise.reject();
                }
            } else {
                // anonymous user
                return Promise.resolve(null);
            }
        }
    }
});
```

## Hooks de rotas
O objeto `rote` tem hooks antes de & após chamadas. Você pode usá-lo para definir `ctx.meta`, acessar `req.headers` ou modificar os `dados ` de resposta.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [
            {
                path: "/",

                onBeforeCall(ctx, route, req, res) {
                    // Set request headers to context meta
                    ctx.meta.userAgent = req.headers["user-agent"];
                },

                onAfterCall(ctx, route, req, res, data) {
                    // Async function which return with Promise
                    return doSomething(ctx, res, data);
                }
            }
        ]
    }
});
```

> Nas versões anteriores do Moleculer Web, você não pode manipular os `dados` em `onAfterCall`. Agora você pode, mas você deve sempre retornar os `dados` novos ou originais.


## Manipuladores de erros
Você pode adicionar manipuladores de erros personalizados a nível de rota & a nível global.
> Nos manipuladores, você deve chamar `res.end`. Caso contrário, a requisição não será concluída.

```js
broker.createService({
    mixins: [ApiService],
    settings: {

        routes: [{
            path: "/api",

            // Route error handler
            onError(req, res, err) {
                res.setHeader("Content-Type", "application/json; charset=utf-8");
                res.writeHead(500);
                res.end(JSON.stringify(err));
            }
        }],

        // Global error handler
        onError(req, res, err) {
            res.setHeader("Content-Type", "text/plain");
            res.writeHead(501);
            res.end("Global error: " + err.message);
        }       
    }
}
```

### Formatador de erro
O gateway API implementa uma função auxiliar que formata o erro. Você pode usá-lo para filtrar os dados desnecessários.

```js
broker.createService({
    mixins: [ApiService],
    methods: {
        reformatError(err) {
            // Filter out the data from the error before sending it to the client
            return _.pick(err, ["name", "message", "code", "type", "data"]);
        },
    }
}
```

## Cabeçalhos CORS
Você pode usar os cabeçalhos [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) no serviço Moleculer-Web.

**Utilização**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {

        // Global CORS settings for all routes
        cors: {
            // Configures the Access-Control-Allow-Origin CORS header.
            origin: "*",
            // Configures the Access-Control-Allow-Methods CORS header. 
            methods: ["GET", "OPTIONS", "POST", "PUT", "DELETE"],
            // Configures the Access-Control-Allow-Headers CORS header.
            allowedHeaders: [],
            // Configures the Access-Control-Expose-Headers CORS header.
            exposedHeaders: [],
            // Configures the Access-Control-Allow-Credentials CORS header.
            credentials: false,
            // Configures the Access-Control-Max-Age CORS header.
            maxAge: 3600
        },

        routes: [{
            path: "/api",

            // Route CORS settings (overwrite global settings)
            cors: {
                origin: ["http://localhost:3000", "https://localhost:4000"],
                methods: ["GET", "OPTIONS", "POST"],
                credentials: true
            },
        }]
    }
});
```

## Limitador de taxa
O Moleculer-Web tem um limitador de taxa integrado com armazenamento em memória.

**Utilização**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {
        rateLimit: {
            // How long to keep record of requests in memory (in milliseconds). 
            // Defaults to 60000 (1 min)
            window: 60 * 1000,

            // Max number of requests during window. Defaults to 30
            limit: 30,

            // Set rate limit headers to response. Defaults to false
            headers: true,

            // Function used to generate keys. Defaults to: 
            key: (req) => {
                return req.headers["x-forwarded-for"] ||
                    req.connection.remoteAddress ||
                    req.socket.remoteAddress ||
                    req.connection.socket.remoteAddress;
            },
            //StoreFactory: CustomStore
        }
    }
});
```

### Exemplo de armazenamento personalizado
```js
class CustomStore {
    constructor(clearPeriod, opts) {
        this.hits = new Map();
        this.resetTime = Date.now() + clearPeriod;

        setInterval(() => {
            this.resetTime = Date.now() + clearPeriod;
            this.reset();
        }, clearPeriod);
    }

    /**
     * Increment the counter by key
     *
     * @param {String} key
     * @returns {Number}
     */
    inc(key) {
        let counter = this.hits.get(key) || 0;
        counter++;
        this.hits.set(key, counter);
        return counter;
    }

    /**
     * Reset all counters
     */
    reset() {
        this.hits.clear();
    }
}
```

## ETag

O valor da opção `etag`pode ser `false`, `true`, `weak`, `strong`, ou uma `Function` personalizada. Para obter detalhes verifique o [código](https://github.com/moleculerjs/moleculer-web/pull/92).

```js
const ApiGateway = require("moleculer-web");

module.exports = {
    mixins: [ApiGateway],
    settings: {
        // Service-level option
        etag: false,
        routes: [
            {
                path: "/",
                // Route-level option.
                etag: true
            }
        ]
    }
}
```

**Função personalizada `etag`**
```js
module.exports = {
    mixins: [ApiGateway],
    settings: {
        // Service-level option
        etag: (body) => generateHash(body)
    }
}
```

Por favor, note que isso não funciona com respostas stream. Nesse caso, você deve gerar a tag `etag` por si mesmo.

**`etag` personalizada para streaming**
```js
module.exports = {
    name: "export",
    actions: {
        // Download response as a file in the browser
        downloadCSV(ctx) {
            ctx.meta.$responseType = "text/csv";
            ctx.meta.$responseHeaders = {
                "Content-Disposition": `attachment; filename="data-${ctx.params.id}.csv"`,
                "ETag": '<your etag here>'
            };
            return csvFileStream;
        }
    }
}
```

## Servidor HTTP2
Gateway API fornece um suporte experimental para HTTP2. Você pode ativá-lo com `http2: true` nas configurações do serviço. **Exemplo**
```js
const ApiGateway = require("moleculer-web");

module.exports = {
    mixins: [ApiGateway],
    settings: {
        port: 8443,

        // HTTPS server with certificate
        https: {
            key: fs.readFileSync("key.pem"),
            cert: fs.readFileSync("cert.pem")
        },

        // Use HTTP2 server
        http2: true
    }
});
```

## Uso de middleware ExpressJS
Você pode usar Moleculer-Web como um middleware em uma aplicação [ExpressJS](http://expressjs.com/).

**Utilização**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {
        server: false // Default is "true"
    }
});

// Create Express application
const app = express();

// Use ApiGateway as middleware
app.use("/api", svc.express());

// Listening
app.listen(3000);

// Start server
broker.start();
```


## Configurações de serviço completo
Lista de todas as configurações de serviço Moleculer Web:

```js
settings: {

    // Exposed port
    port: 3000,

    // Exposed IP
    ip: "0.0.0.0",

    // HTTPS server with certificate
    https: {
        key: fs.readFileSync("ssl/key.pem"),
        cert: fs.readFileSync("ssl/cert.pem")
    },

    // Used server instance. If null, it will create a new HTTP(s)(2) server
    // If false, it will start without server in middleware mode
    server: true,

    // Exposed global path prefix
    path: "/api",

    // Global-level middlewares
    use: [
        compression(),
        cookieParser()
    ],

    // Logging request parameters with 'info' level
    logRequestParams: "info",

    // Logging response data with 'debug' level
    logResponseData: "debug",

    // Use HTTP2 server (experimental)
    http2: false,

    // Override HTTP server default timeout
    httpServerTimeout: null,

    // Optimize route & alias paths (deeper first).
    optimizeOrder: true,

    // Routes
    routes: [
        {
            // Path prefix to this route  (full path: /api/admin )
            path: "/admin",

            // Whitelist of actions (array of string mask or regex)
            whitelist: [
                "users.get",
                "$node.*"
            ],

            // Call the `this.authorize` method before call the action
            authorization: true,

            // Merge parameters from querystring, request params & body 
            mergeParams: true,

            // Route-level middlewares
            use: [
                helmet(),
                passport.initialize()
            ],

            // Action aliases
            aliases: {
                "POST users": "users.create",
                "health": "$node.health"
            },

            mappingPolicy: "all",

            // Use bodyparser module
            bodyParsers: {
                json: true,
                urlencoded: { extended: true }
            }
        },
        {
            // Path prefix to this route  (full path: /api )
            path: "",

            // Whitelist of actions (array of string mask or regex)
            whitelist: [
                "posts.*",
                "file.*",
                /^math\.\w+$/
            ],

            // No authorization
            authorization: false,

            // Action aliases
            aliases: {
                "add": "math.add",
                "GET sub": "math.sub",
                "POST divide": "math.div",
                "GET greeter/:name": "test.greeter",
                "GET /": "test.hello",
                "POST upload"(req, res) {
                    this.parseUploadedFile(req, res);
                }
            },

            mappingPolicy: "restrict",

            // Use bodyparser module
            bodyParsers: {
                json: false,
                urlencoded: { extended: true }
            },

            // Calling options
            callOptions: {
                timeout: 3000,
                retries: 3,
                fallbackResponse: "Static fallback response"
            },

            // Call before `broker.call`
            onBeforeCall(ctx, route, req, res) {
                ctx.meta.userAgent = req.headers["user-agent"];
            },

            // Call after `broker.call` and before send back the response
            onAfterCall(ctx, route, req, res, data) {
                res.setHeader("X-Custom-Header", "123456");
                return data;
            },

            // Route error handler
            onError(req, res, err) {
                res.setHeader("Content-Type", "text/plain");
                res.writeHead(err.code || 500);
                res.end("Route error: " + err.message);
            }
        }
    ],

    // Folder to server assets (static files)
    assets: {
        // Root folder of assets
        folder: "./examples/www/assets",

        // Options to `server-static` module
        options: {}
    },

    // Global error handler
    onError(req, res, err) {
        res.setHeader("Content-Type", "text/plain");
        res.writeHead(err.code || 500);
        res.end("Global error: " + err.message);
    }    
}
```
## Métodos do Serviço
### `addRoute`
Este [método](services.html#Methods) de serviço (`this.addRoute(opts, toBottom = true)`) adiciona/substitui uma rota. Por exemplo, você pode chamá-lo de seus mixins para definir novas rotas (por exemplo, rota swager, rota graphql, etc.).

> Por favor, note que se já existir uma rota este método irá substituir a configuração anterior da rota por uma nova.

### `removeRoute`
O método de serviço remove a rota pelo caminho (`this.removeRoute("/admin")`).

## Exemplos
- [Simples](https://github.com/moleculerjs/moleculer-web/blob/master/examples/simple/index.js)
    - gateway simples com configurações padrão.

- [Servidor SSL](https://github.com/moleculerjs/moleculer-web/blob/master/examples/ssl/index.js)
    - servidor open HTTPS
    - manipulação de allowlist

- [WWW com conteúdo publicado](https://github.com/moleculerjs/moleculer-web/blob/master/examples/www/index.js)
    - serve arquivos estáticos da pasta `assets`
    - allowlist
    - aliases
    - múltiplos body-parsers

- [Autorização](https://github.com/moleculerjs/moleculer-web/blob/master/examples/authorization/index.js)
    - demonstração de autorização simples
    - definir o usuário autorizado para `Context.meta`

- [REST](https://github.com/moleculerjs/moleculer-web/blob/master/examples/rest/index.js)
    - servidor simples com aliases RESTful
    - exemplo de `posts` com ações CRUD

- [Express](https://github.com/moleculerjs/moleculer-web/blob/master/examples/express/index.js)
    - servidor web com Express
    - use moleculer-web como um middleware

- [Socket.io](https://github.com/moleculerjs/moleculer-web/blob/master/examples/socket.io/index.js)
    - iniciar servidor de websocket socket.io
    - chama a ação e envia de volta a resposta via websocket
    - enviar eventos Moleculer para o navegador via websocket

- [Completo](https://github.com/moleculerjs/moleculer-web/blob/master/examples/full/index.js)
    - SSL
    - arquivos estáticos
    - middlewares
    - várias rotas com diferentes funções
    - autorização baseada em JWT
    - allowlist
    - aliases com parâmetros nomeados
    - múltiplos body-parsers
    - hooks antes & depois
    - métricas, estatísticas & validação com Moleculer
    - manipuladores de erros personalizados

- [Webpack](https://github.com/moleculerjs/moleculer-web/blob/master/examples/webpack)
    - Ambiente de desenvolvimento Webpack para desenvolvimento do lado do cliente
    - arquivo de configuração webpack
    - compactação
    - servir de arquivo estático

- [Webpack-Vue](https://github.com/moleculerjs/moleculer-web/blob/master/examples/webpack-vue)
    - Ambiente de desenvolvimento Webpack+Vue para desenvolvimento VueJS no lado do cliente
    - arquivo de configuração webpack
    - Hot-replacement
    - Babel, SASS, SCSS, Vue SFC
