title: Adaptadores de Banco de Dados
---
O framework Moleculer possui um conjunto oficial de [Adaptadores de Banco de Dados](https://github.com/moleculerjs/moleculer-db). Use-os para persistir dados em um banco de dados.

{% note info Database per service%}
Moleculer segue o padrão de * um banco de dados por serviço*. Para saber mais sobre esse padrão de desenvolvimento e suas implicações, confira este [artigo](https://microservices.io/patterns/data/database-per-service.html). Para uma abordagem de *múltiplas entidades/tabelas por serviço* verifique [FAQ](faq.html#DB-Adapters-moleculer-db).
{% endnote %}

## Funcionalidades
* ações CRUD padrão
* ações em [cache](caching.html)
* suporte a paginação
* adaptador padrão ([NeDB](https://github.com/louischatriot/nedb) é o adaptador em memória padrão para testes & protótipos)
* adaptadores oficiais para MongoDB, PostgreSQL, SQLite, MySQL, MSSQL.
* filtragem de campos
* popular dados de tabelas relacionadas
* codificar/decodificar IDs
* eventos de ciclo de vida da entidade para notificações

{% note info Experimente em seu navegador! %}
[![Editar moleculer-db](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/github/moleculerjs/sandbox-moleculer-db/tree/master/?fontsize=14)
{% endnote %}

## Adaptador Base [![Versão do NPM](https://img.shields.io/npm/v/moleculer-db.svg)](https://www.npmjs.com/package/moleculer-db)

O adaptador padrão do Moleculer é baseado no [NeDB](https://github.com/louischatriot/nedb). Use-o para configurar rapidamente e testar seu protótipo.

{% note warn%}
Use este adaptador somente para prototipagem e teste. Quando você estiver pronto para entrar em produção, simplesmente troque o adaptador para [Mongo](moleculer-db.html#Mongo-Adapter), [Mongoose](moleculer-db.html#Mongoose-Adapter) ou [Sequelize](moleculer-db.html#Sequelize-Adapter) já que todos implementam as [Configurações](moleculer-db.html#Settings), [Ações](moleculer-db.html#Actions) e [Métodos](moleculer-db.html#Methods) em comum.
{% endnote %}

### Instalação

```bash
$ npm install moleculer-db --save
```

### Utilização

```js
"use strict";

const { ServiceBroker } = require("moleculer");
const DbService = require("moleculer-db");

const broker = new ServiceBroker();

// Create a DB service for `user` entities
broker.createService({
    name: "users",

    // Mixin DB service into (current) 'users' service
    mixins: [DbService],

    settings: {
        fields: ["_id", "username", "name"],
        entityValidator: {
            username: "string"
        }
    },

    afterConnected() {
        // Seed the DB with ˙this.create`
    }
});

broker.start()

// Create a new user
.then(() => broker.call("users.create", {
    username: "john",
    name: "John Doe",
    status: 1
}))

// Get all users
.then(() => broker.call("users.find").then(console.log));

// List users with pagination
.then(() => broker.call("users.list", { page: 2, pageSize: 10 }).then(console.log));

// Get a user
.then(() => broker.call("users.get", { id: 2 }).then(console.log));

// Update a user
.then(() => broker.call("users.update", { id: 2, name: "Jane Doe" }).then(console.log));

// Delete a user
.then(() => broker.call("users.remove", { id: 2 }).then(console.log));

```

> Mais exemplos podem ser encontrados no [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db/examples)

## Confirgurações

Todos os adaptadores de banco de dados compartilham um conjunto comum de configurações:

| Propriedade       | Tipo                   | Padrão          | Descrição                                                                                                                       |
| ----------------- | ---------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `idField`         | `String`               | **obrigatório** | Nome do campo ID.                                                                                                               |
| `fields`          | `Array.<String>` | `null`          | Lista com os campos a serem filtrados. Deve ser um `Array`. Se o valor é `null` ou `undefined` não filtra campos das entidades. |
| `populates`       | `Array`                | `null`          | Esquema para o preenchimento. [Leia mais](#Populating).                                                                         |
| `pageSize`        | `Number`               | **obrigatório** | Tamanho padrão da página em uma ação `list`.                                                                                    |
| `maxPageSize`     | `Number`               | **obrigatório** | Tamanho máximo da página em uma ação `list`.                                                                                    |
| `maxLimit`        | `Number`               | **obrigatório** | Valor máximo do limite na ação `find`. Padrão: `-1` (sem limite)                                                                |
| `entityValidator` | `Object`, `function`   | `null`          | Esquema do validador ou uma função para validar a entrada da entidade nas ações `create` & ações de 'inserir'.                  |

{% note warn%}
`idField` não funciona com o adaptador de Sequelize, pois você pode definir livremente seu próprio ID durante a criação do modelo.
{% endnote %}

## Personalização

As with all mixins, the standard [merge algorithm](services.html#Merge-algorithm) allows you to override the defaults applied by this mixin. For example to disable an action you can set the action to `false` in your service.

**Exemplo**
```js
"use strict";
const { ServiceBroker } = require("moleculer");
const DbService = require("moleculer-db");

const broker = new ServiceBroker();

broker.createService({
    name: "db-with-hooks",

    // Load DB actions
    mixins: [DbService],

    actions: {
        // Disable remove action
        remove: false,
        // Make create and insert public instead of published
        create: {
            visibility: "public",
        },
        insert: {
            visibility: "public",
        }

    }
});
```

## Ações

Adaptadores de BD também implementam operações CRUD. Essas [ações](actions.html) são [`métodos públicos`](actions.html#Action-visibility) e podem ser chamadas por outros serviços.

### `find` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Encontrar entidades por consulta.

#### Parâmetros
| Propriedade    | Tipo                   | Valor padrão    | Descrição                                       |
| -------------- | ---------------------- | --------------- | ----------------------------------------------- |
| `populate`     | `Array.<String>` | -               | Preenche dados relacionados.                    |
| `fields`       | `Array.<String>` | -               | Filtro de campos.                               |
| `limit`        | `Number`               | **obrigatório** | Quantidade máxima de linhas.                    |
| `offset`       | `Number`               | **obrigatório** | Quantidade de linhas ignoradas.                 |
| `sort`         | `String`               | **obrigatório** | Campos para ordenação.                          |
| `search`       | `String`               | **obrigatório** | Pesquisar texto.                                |
| `searchFields` | `String`               | **obrigatório** | Campos para busca.                              |
| `query`        | `Object`               | **obrigatório** | Objeto de consulta. Transfere para o adaptador. |

#### Resultados
**Tipo:** `Matriz.<Object>` - Lista de entidades encontradas.


### `count` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Obter contagem de entidades por consulta.

#### Parâmetros
| Propriedade    | Tipo     | Valor padrão    | Descrição                                       |
| -------------- | -------- | --------------- | ----------------------------------------------- |
| `search`       | `String` | **obrigatório** | Pesquisar texto.                                |
| `searchFields` | `String` | **obrigatório** | Campos para busca.                              |
| `query`        | `Object` | **obrigatório** | Objeto de consulta. Transfere para o adaptador. |

#### Resultados
**Tipo:** `Number` - Contagem de entidades encontradas.


### `list` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Lista entidades com filtros e paginação de resultados.

#### Parâmetros
| Propriedade    | Tipo                   | Padrão          | Descrição                                       |
| -------------- | ---------------------- | --------------- | ----------------------------------------------- |
| `populate`     | `Array.<String>` | -               | Preenche dados relacionados.                    |
| `fields`       | `Array.<String>` | -               | Filtro de campos.                               |
| `page`         | `Number`               | **obrigatório** | Número da página.                               |
| `pageSize`     | `Number`               | **obrigatório** | Tamanho de uma página.                          |
| `sort`         | `String`               | **obrigatório** | Campos para ordenação.                          |
| `search`       | `String`               | **obrigatório** | Pesquisar texto.                                |
| `searchFields` | `String`               | **obrigatório** | Campos para busca.                              |
| `query`        | `Object`               | **obrigatório** | Objeto de consulta. Transfere para o adaptador. |

#### Resultados
**Type:** `Object` - Lista e contagem de entidades encontradas.

### `create`

Criar uma nova entidade.

#### Parâmetros
| Propriedade | Tipo | Padrão | Descrição |
| ----------- | ---- | ------ | --------- |
| -           | -    | -      | -         |


*Nenhum parâmetro de entrada.*

#### Resultados
**Tipo:** `Object` - Entidade gravada.

### `insert`

Criar muitas entidades novas.

#### Parâmetros
| Propriedade | Tipo                   | Padrão | Descrição              |
| ----------- | ---------------------- | ------ | ---------------------- |
| `entity`    | `Object`               | -      | Entidade para salvar.  |
| `entities`  | `Array.<Object>` | -      | Entidades para salvar. |

#### Resultados
**Tipo:** `Object`, `Array.<Object>` - Entidade(s) gravada(s).

### `get` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Obter entidade por ID.

##### Parâmetros
| Propriedade | Tipo                       | Padrão          | Descrição                                                                 |
| ----------- | -------------------------- | --------------- | ------------------------------------------------------------------------- |
| `id`        | `any`, `Array.<any>` | **obrigatório** | ID(s) de entidade(s).                                                     |
| `populate`  | `Array.<String>`     | -               | Lista de campos para preenchimento.                                       |
| `fields`    | `Array.<String>`     | -               | Filtro de campos.                                                         |
| `mapping`   | `Boolean`                  | -               | Converta o `Array` retornado para `Objet` onde a chave é o valor de `id`. |

#### Resultados
**Tipo:** `Objet`, `Array.<Object>` - Entidade(s) encontrada(s).


### `update`

Atualizar a entidade por ID.
> Após a atualização, limpa o cache & chama os eventos de ciclo de vida.

#### Parâmetros
| Propriedade | Tipo | Padrão | Descrição |
| ----------- | ---- | ------ | --------- |
| -           | -    | -      | -         |


*Nenhum parâmetro de entrada.*

#### Resultados
**Tipo:** `Object` - Entidade atualizada.


### `remove`

Remove uma entidade por ID.

#### Parâmetros
| Property | Tipo  | Padrão          | Descrição       |
| -------- | ----- | --------------- | --------------- |
| `id`     | `any` | **obrigatório** | ID da entidade. |

#### Resultados
**Tipo:** `Number` - Contagem de entidades removidas.

## Métodos

Adaptadores de BD também tem um conjunto de [métodos](services.html#Methods) auxiliares.

### `getById`

Obter entidade(es) pelo(s) ID(s).

#### Parâmetros
| Propriedade | Tipo                        | Padrão          | Descrição                     |
| ----------- | --------------------------- | --------------- | ----------------------------- |
| `id`        | `String`, `Number`, `Array` | **obrigatório** | ID ou IDs.                    |
| `decoding`  | `Boolean`                   | **obrigatório** | É necessário decodificar IDs. |

#### Resultados
**Tipo:** `Objet`, `Array.<Object>` - Entidade(s) encontrada(s).


### `clearCache`

Limpar entidades em cache

#### Parâmetros
| Propriedade | Tipo | Padrão | Descrição |
| ----------- | ---- | ------ | --------- |
| -           | -    | -      | -         |


*Nenhum parâmetro de entrada.*

#### Resultados
**Tipo:** `Promise`


### `encodeID`

Codificar ID da entidade.

#### Parâmetros
| Propriedade | Tipo  | Padrão          | Descrição |
| ----------- | ----- | --------------- | --------- |
| `id`        | `any` | **obrigatório** | -         |

#### Resultados
**Tipo:** `any`


### `decodeID`

Decodificar ID da entidade.

#### Parâmetros
| Propriedade | Tipo  | Padrão          | Descrição |
| ----------- | ----- | --------------- | --------- |
| `id`        | `any` | **obrigatório** | -         |

#### Resultados
**Tipo:** `any`

### `_find` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Encontrar entidades por consulta.

#### Parâmetros
| Propriedade    | Tipo                   | Padrão          | Descrição                                       |
| -------------- | ---------------------- | --------------- | ----------------------------------------------- |
| `populate`     | `Array.<String>` | -               | Preenche dados relacionados.                    |
| `fields`       | `Array.<String>` | -               | Filtro de campos.                               |
| `limit`        | `Number`               | **obrigatório** | Quantidade máxima de linhas.                    |
| `offset`       | `Number`               | **obrigatório** | Quantidade de linhas ignoradas.                 |
| `sort`         | `String`               | **obrigatório** | Campos para ordenação.                          |
| `search`       | `String`               | **obrigatório** | Pesquisar texto.                                |
| `searchFields` | `String`               | **obrigatório** | Campos para busca.                              |
| `query`        | `Object`               | **obrigatório** | Objeto de consulta. Transfere para o adaptador. |

#### Resultados
**Tipo:** `Array.<Object>`

Lista de entidades encontradas.


### `_count` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Obter contagem de entidades por consulta.

#### Parâmetros
| Propriedade    | Tipo     | Padrão          | Descrição                                       |
| -------------- | -------- | --------------- | ----------------------------------------------- |
| `search`       | `String` | **obrigatório** | Pesquisar texto.                                |
| `searchFields` | `String` | **obrigatório** | Campos para busca.                              |
| `query`        | `Object` | **obrigatório** | Objeto de consulta. Transfere para o adaptador. |

#### Resultados
**Tipo:** `Number`

Contagem de entidades encontradas.


### `_list` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Lista entidades com filtros e paginação de resultados.

#### Parâmetros
| Propriedade    | Tipo                   | Padrão          | Descrição                                       |
| -------------- | ---------------------- | --------------- | ----------------------------------------------- |
| `populate`     | `Array.<String>` | -               | Preenche dados relacionados.                    |
| `fields`       | `Array.<String>` | -               | Filtro de campos.                               |
| `page`         | `Number`               | **obrigatório** | Número da página.                               |
| `pageSize`     | `Number`               | **obrigatório** | Tamanho de uma página.                          |
| `sort`         | `String`               | **obrigatório** | Campos para ordenação.                          |
| `search`       | `String`               | **obrigatório** | Pesquisar texto.                                |
| `searchFields` | `String`               | **obrigatório** | Campos para busca.                              |
| `query`        | `Object`               | **obrigatório** | Objeto de consulta. Transfere para o adaptador. |

#### Resultados
**Tipo:** `Object`

Lista e contagem de entidades encontradas.


### `_create`

Criar uma nova entidade.

#### Parâmetros
| Propriedade | Tipo     | Padrão | Descrição             |
| ----------- | -------- | ------ | --------------------- |
| `params`    | `Object` | -      | Entidade para salvar. |

#### Resultados
**Tipo:** `Object`

Entidade salva.


### `_insert`

Criar muitas entidades novas.

#### Parâmetros
| Propriedade | Tipo                   | Padrão | Descrição              |
| ----------- | ---------------------- | ------ | ---------------------- |
| `entity`    | `Object`               | -      | Entidade para salvar.  |
| `entities`  | `Array.<Object>` | -      | Entidades para salvar. |

#### Resultados
**Tipo:** `Object`, `Array.<Object>`

Entidade(s) gravada(s).


### `_get` ![Ação em cache](https://img.shields.io/badge/cache-true-blue.svg)

Obter entidade por ID.

#### Parâmetros
| Propriedade | Tipo                       | Padrão          | Descrição                                                                 |
| ----------- | -------------------------- | --------------- | ------------------------------------------------------------------------- |
| `id`        | `any`, `Array.<any>` | **obrigatório** | ID(s) de entidade(s).                                                     |
| `populate`  | `Array.<String>`     | -               | Lista de campos para preenchimento.                                       |
| `fields`    | `Array.<String>`     | -               | Filtro de campos.                                                         |
| `mapping`   | `Boolean`                  | -               | Converta o `Array` retornado para `Objet` onde a chave é o valor de `id`. |

#### Resultados
**Tipo:** `Object`, `Array.<Object>`

Entidade(s) encontrada(s).


### `_update`

Atualizar a entidade por ID.
> Após a atualização, limpa o cache & chama os eventos de ciclo de vida.

#### Parâmetros
| Propriedade | Tipo     | Padrão | Descrição                |
| ----------- | -------- | ------ | ------------------------ |
| `params`    | `Object` | -      | Entidade para atualizar. |

#### Resultados
**Tipo:** `Object`

Entidade atualizada.


### `_remove`

Remove uma entidade por ID.

#### Parâmetros
| Propriedade | Tipo  | Padrão          | Descrição       |
| ----------- | ----- | --------------- | --------------- |
| `id`        | `any` | **obrigatório** | ID da entidade. |

#### Resultados
**Tipo:** `Number`

Contagem de entidades removidas.

## Manipulação de dados

Você pode usar facilmente [hooks de ação](actions.html#Action-hooks) para modificar (por exemplo, adicionar timestamps, codificar senhas do usuário ou remover informações confidenciais) antes ou depois de salvar os dados no banco de dados. Hooks will only run before or after actions. If you need to run your data manipulations before or after the this._create(), this._update() or this._remove() methods, you can use the [Lifecycle events](moleculer-db.html#Lifecycle-entity-events)

**Example of hooks adding a timestamp and removing sensitive data**
```js
"use strict";
const { ServiceBroker } = require("moleculer");
const DbService = require("moleculer-db");

const broker = new ServiceBroker();

broker.createService({
  name: "db-with-hooks",

  // Load DB actions
  mixins: [DbService],

  // Add Hooks to DB actions
  hooks: {
    before: {
      create: [
        function addTimestamp(ctx) {
          // Add timestamp
          ctx.params.createdAt = new Date();
          return ctx;
        }
      ]
    },
    after: {
      get: [
        // Arrow function as a Hook
        (ctx, res) => {
          // Remove sensitive data
          delete res.mail;
          delete res.phoneNumber;

          return res;
        }
      ]
    }
  }
});

const user = {
  name: "John Doe",
  mail: "john.doe@example.com",
  phoneNumber: 123456789
};

broker.start()
  // Insert user into DB
  // Call "create" action. Before hook will be triggered
  .then(() => broker.call("db-with-hooks.create", user))
  // Get user from DB
  // Call "get" action. After hook will be triggered
  .then(entry => broker.call("db-with-hooks.get", { id: entry._id }))
  .then(res => console.log(res))
  .catch(err => console.error(err));

```

## Populating
The service allows you to easily populate fields from other services. For example: If you have an `author` field in `post` entity, you can populate it with `users` service by ID of author. If the field is an `Array` of IDs, it will populate all entities via only one request


**Example of populate schema**
```js
broker.createService({
    name: "posts",
    mixins: [DbService],
    settings: {
        populates: {
            // Shorthand populate rule. Resolve the `voters` values with `users.get` action.
            "voters": "users.get",

            // If the ID to populate is deep within the object, you can simply provide a dot-separated path to the ID to populate it.
            "liked.by": "users.get"

            // Define the params of action call. It will receive only with username & full name of author.
            "author": {
                action: "users.get",
                params: {
                    fields: "username fullName"
                }
            },
            // In case the original field shouldn't be overwritten with the populated values.  
            // The reviewer field will be added to the result containing the values 
            // resolved by the "users.get" action based on the reviewerId field.
            "reviewer": {
                field: "reviewerId",
                action: "users.get",
                params: {
                    fields: "username fullName"
                }
            },

            // Custom populator handler function
            "rate"(ids, items, rule, ctx) {
                // items argument is a mutable array containing response items
                // the resolved value from promise do not matter - items array will always be passed as populated response
                // so you should du custom populate by mutating items, if confused check implementaion:
                // https://github.com/moleculerjs/moleculer-db/blob/master/packages/moleculer-db/src/index.js#L636

                return Promise.resolve(...);
            }
        }
    }
});

// List posts with populated authors
broker.call("posts.find", { populate: ["author"]}).then(console.log);
// Deep population
broker.call("posts.find", { populate: ["liked.by"]}).then(console.log);
```

Recursive population is also supported. For example, if the users service populates a group field:

```js
broker.createService({
    name: "users",
    mixins: [DbService],
    settings: {
        populates: {
            "group": "groups.get"
        }
    }
});
```

Then you can populate the group of a post author or liker like this:

```js
//Recursive population
broker.call("posts.find", { populate: ["author.group"]}).then(console.log);
//Recursive deep population
broker.call("posts.find", { populate: ["liked.by.group"]}).then(console.log);
```



> O parâmetro `populate` está disponível nas ações `find`, `list` e `get`.


## Lifecycle entity events
There are 6 lifecycle entity events which are called when entities are manipulated.

```js
broker.createService({
    name: "posts",
    mixins: [DbService],
    settings: {},

    afterConnected() {
        this.logger.info("Connected successfully");
    },

    beforeEntityCreate(json, ctx) {
        this.logger.info("New entity will be created");
        json.createdAt = new Date()
        json.updatedAt = new Date()
        return json; // You must return the modified entity here
    },

    beforeEntityUpdate(json, ctx) {
        this.logger.info("Entity will be updated");
        json.updatedAt = new Date()
        return json;
    },

    beforeEntityRemove(json, ctx) {
        this.logger.info("Entity will be removed");
        return json;
    },

    entityCreated(json, ctx) {
        this.logger.info("New entity created!");
    },

    entityUpdated(json, ctx) {
        // You can also access to Context
        this.logger.info(`Entity updated by '${ctx.meta.user.name}' user!`);
    },

    entityRemoved(json, ctx) {
        this.logger.info("Entity removed", json);
    },    
});
```

> Por favor, note! Se você manipular várias entidades (updateMany, removeMany), o parâmetro `json` será um `number` em vez de entidades!

## Extend with custom actions
Naturally you can extend this service with your custom actions.

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "posts",
    mixins: [DbService],

    settings: {
        fields: ["_id", "title", "content", "votes"]
    },

    actions: {
        // Increment `votes` field by post ID
        vote(ctx) {
            return this.adapter.updateById(ctx.params.id, { $inc: { votes: 1 } });
        },

        // List posts of an author
        byAuthors(ctx) {
            return this.find({
                query: {
                    author: ctx.params.authorID
                },
                limit: ctx.params.limit || 10,
                sort: "-createdAt"
            });
        }
    }
}
```


## Mongo Adapter [![Versão do NPM](https://img.shields.io/npm/v/moleculer-db-adapter-mongo.svg)](https://www.npmjs.com/package/moleculer-db-adapter-mongo)

This adapter is based on [MongoDB](http://mongodb.github.io/node-mongodb-native/).

### Instalação

```bash
$ npm install moleculer-db moleculer-db-adapter-mongo --save
```
{% note info Dependencies%}
To use this adapter you need to install [MongoDB](https://www.mongodb.com/) on you system.
{% endnote %}

### Utilização

```js
"use strict";

const { ServiceBroker } = require("moleculer");
const DbService = require("moleculer-db");
const MongoDBAdapter = require("moleculer-db-adapter-mongo");

const broker = new ServiceBroker();

// Create a Mongoose service for `post` entities
broker.createService({
    name: "posts",
    mixins: [DbService],
    adapter: new MongoDBAdapter("mongodb://localhost/moleculer-demo"),
    collection: "posts"
});


broker.start()
// Create a new post
.then(() => broker.call("posts.create", {
    title: "My first post",
    content: "Lorem ipsum...",
    votes: 0
}))

// Get all posts
.then(() => broker.call("posts.find").then(console.log));
```

### Opções

**Example with connection URI**
```js
new MongoDBAdapter("mongodb://localhost/moleculer-db")
```


**Example with connection URI & options**
```js
new MongoDBAdapter("mongodb://db-server-hostname/my-db", {
    keepAlive: 1
})

```

> Mais exemplos MongoDB podem ser encontrados no [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongo/examples)

## Mongoose Adapter [![Versão do NPM](https://img.shields.io/npm/v/moleculer-db-adapter-mongoose.svg)](https://www.npmjs.com/package/moleculer-db-adapter-mongoose)

This adapter is based on [Mongoose](https://mongoosejs.com/docs/).

### Instalação

```bash
$ npm install moleculer-db moleculer-db-adapter-mongoose mongoose --save
```

{% note info Dependencies%}
To use this adapter you need to install [MongoDB](https://www.mongodb.com/) on you system.
{% endnote %}

### Utilização

```js
"use strict";

const { ServiceBroker } = require("moleculer");
const DbService = require("moleculer-db");
const MongooseAdapter = require("moleculer-db-adapter-mongoose");
const mongoose = require("mongoose");

const broker = new ServiceBroker();

// Create a Mongoose service for `post` entities
broker.createService({
    name: "posts",
    mixins: [DbService],
    adapter: new MongooseAdapter("mongodb://localhost/moleculer-demo"),
    model: mongoose.model("Post", mongoose.Schema({
        title: { type: String },
        content: { type: String },
        votes: { type: Number, default: 0}
    }))
});


broker.start()
// Create a new post
.then(() => broker.call("posts.create", {
    title: "My first post",
    content: "Lorem ipsum...",
    votes: 0
}))

// Get all posts
.then(() => broker.call("posts.find").then(console.log));
```

### Opções

**Example with connection URI**
```js
new MongooseAdapter("mongodb://localhost/moleculer-db")
```

**Example with URI and options**
```js
new MongooseAdapter("mongodb://db-server-hostname/my-db", {
    user: process.env.MONGO_USERNAME,
    pass: process.env.MONGO_PASSWORD
    keepAlive: true
})
```

### Conectar a vários DBs

If your services are running on separate nodes and you wish to connect to multiple databases then you can use `model` in your service definition. On the other hand, if your services are running on a single node and you wish to connect to multiple databases, you should define the `schema` that will make multiple connections for you.

> Mais exemplos de Mongoose podem ser encontrados no [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongoose/examples)

## Sequelize Adapter [![NPM version](https://img.shields.io/npm/v/moleculer-db-adapter-sequelize.svg)](https://www.npmjs.com/package/moleculer-db-adapter-sequelize)

SQL adapter (Postgres, MySQL, SQLite & MSSQL) for Moleculer DB service with [Sequelize](https://github.com/sequelize/sequelize).

### Instalação

```bash
$ npm install moleculer-db-adapter-sequelize --save
```

You have to install additional packages for your database server:
```bash
# For SQLite
$ npm install sqlite3 --save

# For MySQL
$ npm install mysql2 --save

# For PostgreSQL
$ npm install pg pg-hstore --save

# For MSSQL
$ npm install tedious --save
```

### Utilização

```js
"use strict";

const { ServiceBroker } = require("moleculer");
const DbService = require("moleculer-db");
const SqlAdapter = require("moleculer-db-adapter-sequelize");
const Sequelize = require("sequelize");

const broker = new ServiceBroker();

// Create a Sequelize service for `post` entities
broker.createService({
    name: "posts",
    mixins: [DbService],
    adapter: new SqlAdapter("sqlite://:memory:"),
    model: {
        name: "post",
        define: {
            title: Sequelize.STRING,
            content: Sequelize.TEXT,
            votes: Sequelize.INTEGER,
            author: Sequelize.INTEGER,
            status: Sequelize.BOOLEAN
        },
        options: {
            // Options from https://sequelize.org/docs/v6/moved/models-definition/
        }
    },
});


broker.start()
// Create a new post
.then(() => broker.call("posts.create", {
    title: "My first post",
    content: "Lorem ipsum...",
    votes: 0
}))

// Get all posts
.then(() => broker.call("posts.find").then(console.log));
```

### Opções
Every constructor arguments are passed to the `Sequelize` constructor. Read more about [Sequelize connection](http://docs.sequelizejs.com/manual/installation/getting-started.html).

**Example with connection URI**
```js
new SqlAdapter("postgres://user:pass@example.com:5432/dbname");
```

**Example with connection options**
```js
new SqlAdapter('database', 'username', 'password', {
    host: 'localhost',
    dialect: 'mysql'|'sqlite'|'postgres'|'mssql',

    pool: {
        max: 5,
        min: 0,
        idle: 10000
    },

    noSync: true // If true, the model will not be synced by Sequelize

    // SQLite only
    storage: 'path/to/database.sqlite'
});
```

> Mais exemplos de Sequelize podem ser encontrados no [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-sequelize/examples)
