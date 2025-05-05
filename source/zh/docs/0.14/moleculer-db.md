标题：数据库适配器
---
Moleculer 框架有一组官方 [DB 适配器](https://github.com/moleculerjs/moleculer-db)。 可以使用它们在数据库中保存您的数据。

{% note info Database per service%}
Moleculer遵循* 一个数据库就是一个服务 *的模式。 要了解更多关于这种设计模式及其影响的信息，请参考 [这篇文章](https://microservices.io/patterns/data/database-per-service.html)。 至于 *每个服务对应多个实体/表格* 的方式请参考 [常见问题](faq.html#DB-Adapters-moleculer-db).
{% endnote %}

## 特性概览
* 默认 CRUD 操作
* [cached](caching.html)活动
* 分页支持
* 插件式 adapter ([NeDB](https://github.com/louischatriot/nedb) is the default memory adapter for testing & prototyping)
* 官方提供 MongoDB, PostgreSQL, SQLite, MySQL, MSSQL 等适配器。
* 字段过滤
* 联合查询
* ID 编码/解码
* entity 生命周期事件通知

{% note info Try it in your browser! %}
[![Edit moleculer-db](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/github/moleculerjs/sandbox-moleculer-db/tree/master/?fontsize=14)
{% endnote %}

## 基础适配器 [![NPM version](https://img.shields.io/npm/v/moleculer-db.svg)](https://www.npmjs.com/package/moleculer-db)

Moleculer 的默认适配器基于 [NeDB](https://github.com/louischatriot/nedb)。 可以用它来快速设置和测试您的原型。

{% note warn%}
请仅使用此适配器进行原型输入和测试。 当你准备好用于生产环境时，简单地切换到 [Mongo](moleculer-db.html#Mongo-Adapter), [Mongoose](moleculer-db.html#Mongoose-Adapter) 或 [Sequelize](moleculer-db.html#Sequelize-Adapter) 适配器就实现了常见的 [Settings](moleculer-db.html#Settings), [Actions](moleculer-db.html#Actions) 和 [Methods](moleculer-db.html#Methods)
{% endnote %}

### 安装

```bash
$ npm install moleculer-db --save
```

### 使用

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

> More examples can be found on [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db/examples)

## 设置

所有数据库适配器共享一组常见的设置：

| Property          | Type                   | 默认设置         | 说明                                                                                                                        |
| ----------------- | ---------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `idField`         | `String`               | **required** | Name of ID field.                                                                                                         |
| `fields`          | `Array.<String>` | `null`       | Field filtering list. It must be an `Array`. If the value is `null` or `undefined` doesn't filter the fields of entities. |
| `populates`       | `Array`                | `null`       | Schema for population. [Read more](#Populating).                                                                          |
| `pageSize`        | `Number`               | **required** | Default page size in `list` action.                                                                                       |
| `maxPageSize`     | `Number`               | **required** | Maximum page size in `list` action.                                                                                       |
| `maxLimit`        | `Number`               | **required** | Maximum value of limit in `find` action. Default: `-1` (no limit)                                                         |
| `entityValidator` | `Object`, `function`   | `null`       | Validator schema or a function to validate the incoming entity in `create` & 'insert' actions.                            |

{% note warn%}
`idField` does not work with Sequelize adapter as you can freely set your own ID while creating the model.
{% endnote %}

## Customization

As with all mixins, the standard [merge algorithm](services.html#Merge-algorithm) allows you to override the defaults applied by this mixin. For example to disable an action you can set the action to `false` in your service.

**示例**
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

## Actions

DB adapters also implement CRUD operations. These [actions](actions.html) are [`published`](actions.html#Action-visibility) methods and can be called by other services.

### `find` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

Find entities by query.

#### Parameters
| Property       | 类型                     | 默认设置         | 说明                                                               |
| -------------- | ---------------------- | ------------ | ---------------------------------------------------------------- |
| `populate`     | `Array.<String>` | -            | Populated fields.                                                |
| `fields`       | `Array.<String>` | -            | Fields filter.                                                   |
| `limit`        | `Number`               | **required** | Max count of rows.                                               |
| `offset`       | `Number`               | **required** | Count of skipped rows.                                           |
| `sort`         | `String`               | **required** | Sorted fields.                                                   |
| `search`       | `String`               | **required** | Search text.                                                     |
| `iSearch`      | `String`               | **required** | Search text (case insensitive) *Available only using Sequelize*. |
| `searchFields` | `String`               | **required** | Fields for searching.                                            |
| `query`        | `Object`               | **required** | Query object. Passes to adapter.                                 |

#### Results
**Type:** `Array.<Object>` - List of found entities.


### `count` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

Get count of entities by query.

#### Parameters
| Property       | 类型       | 默认设置         | 说明                                                               |
| -------------- | -------- | ------------ | ---------------------------------------------------------------- |
| `search`       | `String` | **required** | Search text.                                                     |
| `iSearch`      | `String` | **required** | Search text (case insensitive) *Available only using Sequelize*. |
| `searchFields` | `String` | **required** | Fields list for searching.                                       |
| `query`        | `Object` | **required** | Query object. Passes to adapter.                                 |

#### Results
**Type:** `Number` - Count of found entities.


### `list` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

List entities by filters and pagination results.

#### Parameters
| Property       | Type                   | 默认设置         | 描述                                                               |
| -------------- | ---------------------- | ------------ | ---------------------------------------------------------------- |
| `populate`     | `Array.<String>` | -            | Populated fields.                                                |
| `fields`       | `Array.<String>` | -            | Fields filter.                                                   |
| `page`         | `Number`               | **required** | Page number.                                                     |
| `pageSize`     | `Number`               | **required** | Size of a page.                                                  |
| `sort`         | `String`               | **required** | Sorted fields.                                                   |
| `search`       | `String`               | **required** | Search text.                                                     |
| `iSearch`      | `String`               | **required** | Search text (case insensitive) *Available only using Sequelize*. |
| `searchFields` | `String`               | **required** | Fields for searching.                                            |
| `query`        | `Object`               | **required** | Query object. Passes to adapter.                                 |

#### Results
**Type:** `Object` - List of found entities and count.

### `create`

Create a new entity.

#### Parameters
| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| -        | -    | -       | -           |


*No input parameters.*

#### Results
**Type:** `Object` - Saved entity.

### `insert`

Create many new entities.

#### Parameters
| Property   | Type                   | 默认设置 | 描述                |
| ---------- | ---------------------- | ---- | ----------------- |
| `entity`   | `Object`               | -    | Entity to save.   |
| `entities` | `Array.<Object>` | -    | Entities to save. |

#### Results
**Type:** `Object`, `Array.<Object>` - Saved entity(ies).

### `get` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

Get entity by ID.

##### Parameters
| Property   | Type                       | 默认设置         | 描述                                                                           |
| ---------- | -------------------------- | ------------ | ---------------------------------------------------------------------------- |
| `id`       | `any`, `Array.<any>` | **required** | ID(s) of entity.                                                             |
| `populate` | `Array.<String>`     | -            | Field list for populate.                                                     |
| `fields`   | `Array.<String>`     | -            | Fields filter.                                                               |
| `mapping`  | `Boolean`                  | -            | Convert the returned `Array` to `Object` where the key is the value of `id`. |

#### Results
**Type:** `Object`, `Array.<Object>` - Found entity(ies).


### `update`

Update an entity by ID.
> After update, clear the cache & call lifecycle events.

#### Parameters
| Property | Type | 默认设置 | 描述 |
| -------- | ---- | ---- | -- |
| -        | -    | -    | -  |


*No input parameters.*

#### Results
**Type:** `Object` - Updated entity.


### `remove`

Remove an entity by ID.

#### Parameters
| Property | Type  | 默认设置         | 描述            |
| -------- | ----- | ------------ | ------------- |
| `id`     | `any` | **required** | ID of entity. |

#### Results
**Type:** `Number` - Count of removed entities.

## Methods

DB adapters also has a set of helper [methods](services.html#Methods).

### `getById`

Get entity(ies) by ID(s).

#### Parameters
| Property   | Type                        | 默认设置         | 描述                  |
| ---------- | --------------------------- | ------------ | ------------------- |
| `id`       | `String`, `Number`, `Array` | **required** | ID or IDs.          |
| `decoding` | `Boolean`                   | **required** | Need to decode IDs. |

#### Results
**Type:** `Object`, `Array.<Object>` - Found entity(ies).


### `clearCache`

Clear cached entities

#### Parameters
| Property | Type | 默认设置 | 描述 |
| -------- | ---- | ---- | -- |
| -        | -    | -    | -  |


*No input parameters.*

#### Results
**Type:** `Promise`


### `encodeID`

Encode ID of entity.

#### Parameters
| Property | Type  | 默认设置         | 描述 |
| -------- | ----- | ------------ | -- |
| `id`     | `any` | **required** | -  |

#### Results
**Type:** `any`


### `decodeID`

Decode ID of entity.

#### Parameters
| Property | 类型    | 默认设置         | Description |
| -------- | ----- | ------------ | ----------- |
| `id`     | `any` | **required** | -           |

#### Results
**Type:** `any`

### `_find` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

Find entities by query.

#### Parameters
| Property       | Type                   | 默认设置         | 描述                                                               |
| -------------- | ---------------------- | ------------ | ---------------------------------------------------------------- |
| `populate`     | `Array.<String>` | -            | Populated fields.                                                |
| `fields`       | `Array.<String>` | -            | Fields filter.                                                   |
| `limit`        | `Number`               | **required** | Max count of rows.                                               |
| `offset`       | `Number`               | **required** | Count of skipped rows.                                           |
| `sort`         | `String`               | **required** | Sorted fields.                                                   |
| `search`       | `String`               | **required** | Search text.                                                     |
| `iSearch`      | `String`               | **required** | Search text (case insensitive) *Available only using Sequelize*. |
| `searchFields` | `String`               | **required** | Fields for searching.                                            |
| `query`        | `Object`               | **required** | Query object. Passes to adapter.                                 |

#### Results
**Type:** `Array.<Object>`

List of found entities.


### `_count` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

Get count of entities by query.

#### Parameters
| Property       | Type     | 默认设置         | 描述                                                               |
| -------------- | -------- | ------------ | ---------------------------------------------------------------- |
| `search`       | `String` | **required** | Search text.                                                     |
| `iSearch`      | `String` | **required** | Search text (case insensitive) *Available only using Sequelize*. |
| `searchFields` | `String` | **required** | Fields list for searching.                                       |
| `query`        | `Object` | **required** | Query object. Passes to adapter.                                 |

#### Results
**Type:** `Number`

Count of found entities.


### `_list` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

List entities by filters and pagination results.

#### Parameters
| Property       | Type                   | 默认设置         | 描述                                                               |
| -------------- | ---------------------- | ------------ | ---------------------------------------------------------------- |
| `populate`     | `Array.<String>` | -            | Populated fields.                                                |
| `fields`       | `Array.<String>` | -            | Fields filter.                                                   |
| `page`         | `Number`               | **required** | Page number.                                                     |
| `pageSize`     | `Number`               | **required** | Size of a page.                                                  |
| `sort`         | `String`               | **required** | Sorted fields.                                                   |
| `search`       | `String`               | **required** | Search text.                                                     |
| `iSearch`      | `String`               | **required** | Search text (case insensitive) *Available only using Sequelize*. |
| `searchFields` | `String`               | **required** | Fields for searching.                                            |
| `query`        | `Object`               | **required** | Query object. Passes to adapter.                                 |

#### Results
**Type:** `Object`

List of found entities and count.


### `_create`

Create a new entity.

#### Parameters
| Property | Type     | 默认设置 | 描述              |
| -------- | -------- | ---- | --------------- |
| `params` | `Object` | -    | Entity to save. |

#### Results
**Type:** `Object`

Saved entity.


### `_insert`

Create many new entities.

#### Parameters
| Property   | Type                   | 默认设置 | 描述                |
| ---------- | ---------------------- | ---- | ----------------- |
| `entity`   | `Object`               | -    | Entity to save.   |
| `entities` | `Array.<Object>` | -    | Entities to save. |

#### Results
**Type:** `Object`, `Array.<Object>`

Saved entity(ies).


### `_get` ![Cached action](https://img.shields.io/badge/cache-true-blue.svg)

Get entity by ID.

#### Parameters
| Property   | Type                       | 默认设置         | 描述                                                                           |
| ---------- | -------------------------- | ------------ | ---------------------------------------------------------------------------- |
| `id`       | `any`, `Array.<any>` | **required** | ID(s) of entity.                                                             |
| `populate` | `Array.<String>`     | -            | Field list for populate.                                                     |
| `fields`   | `Array.<String>`     | -            | Fields filter.                                                               |
| `mapping`  | `Boolean`                  | -            | Convert the returned `Array` to `Object` where the key is the value of `id`. |

#### Results
**Type:** `Object`, `Array.<Object>`

Found entity(ies).


### `_update`

Update an entity by ID.
> After update, clear the cache & call lifecycle events.

#### Parameters
| Property | 类型       | 默认设置 | Description       |
| -------- | -------- | ---- | ----------------- |
| `params` | `Object` | -    | Entity to update. |

#### Results
**Type:** `Object`

Updated entity.


### `_remove`

Remove an entity by ID.

#### Parameters
| Property | Type  | 默认设置         | 描述            |
| -------- | ----- | ------------ | ------------- |
| `id`     | `any` | **required** | ID of entity. |

#### Results
**Type:** `Number`

Count of removed entities.

## Data Manipulation

You can easily use [Action hooks](actions.html#Action-hooks) to modify (e.g. add timestamps, hash user's passwords or remove sensitive info) before or after saving the data in DB. Hooks will only run before or after actions. If you need to run your data manipulations before or after the this._create(), this._update() or this._remove() methods, you can use the [Lifecycle events](moleculer-db.html#Lifecycle-entity-events)

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



> The `populate` parameter is available in `find`, `list` and `get` actions.


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

> Please note! If you manipulate multiple entities (updateMany, removeMany), the `json` parameter will be a `Number` instead of entities!

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


## Mongo Adapter [![NPM version](https://img.shields.io/npm/v/moleculer-db-adapter-mongo.svg)](https://www.npmjs.com/package/moleculer-db-adapter-mongo)

This adapter is based on [MongoDB](http://mongodb.github.io/node-mongodb-native/).

### 安装

```bash
$ npm install moleculer-db moleculer-db-adapter-mongo --save
```
{% note info Dependencies%}
To use this adapter you need to install [MongoDB](https://www.mongodb.com/) on you system.
{% endnote %}

### 使用

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

### Options

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

> More MongoDB examples can be found on [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongo/examples)

## Mongoose Adapter [![NPM version](https://img.shields.io/npm/v/moleculer-db-adapter-mongoose.svg)](https://www.npmjs.com/package/moleculer-db-adapter-mongoose)

This adapter is based on [Mongoose](https://mongoosejs.com/docs/).

### 安装

```bash
$ npm install moleculer-db moleculer-db-adapter-mongoose mongoose --save
```

{% note info Dependencies%}
To use this adapter you need to install [MongoDB](https://www.mongodb.com/) on you system.
{% endnote %}

### 使用

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

### Options

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

### Connect to multiple DBs

If your services are running on separate nodes and you wish to connect to multiple databases then you can use `model` in your service definition. On the other hand, if your services are running on a single node and you wish to connect to multiple databases, you should define the `schema` that will make multiple connections for you.

> More Mongoose examples can be found on [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongoose/examples)

## Sequelize Adapter [![NPM version](https://img.shields.io/npm/v/moleculer-db-adapter-sequelize.svg)](https://www.npmjs.com/package/moleculer-db-adapter-sequelize)

SQL adapter (Postgres, MySQL, SQLite & MSSQL) for Moleculer DB service with [Sequelize](https://github.com/sequelize/sequelize).

### 安装

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

### 使用

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

### Options
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

> More Sequelize examples can be found on [GitHub](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-sequelize/examples)
