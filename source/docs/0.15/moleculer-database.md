title: Database Service
---

## @moleculer/database [![npm](https://img.shields.io/npm/v/@moleculer/database.svg?maxAge=3600)](https://www.npmjs.com/package/@moleculer/database)

[`@moleculer/database`](https://github.com/moleculerjs/database) is the official database access service for Moleculer. It is a service mixin that gives your service a validated field schema, generated CRUD actions (with REST endpoints for the [API Gateway](moleculer-web.html)), populating between services, scopes, soft delete, caching, entity events and multi-tenancy — on top of pluggable adapters for NeDB, MongoDB and Knex (PostgreSQL, MySQL, SQLite, MSSQL...).

It is the successor of [moleculer-db](moleculer-db.html). New projects should use `@moleculer/database`; `moleculer-db` is still maintained for existing projects.

This page is a short introduction. **The full reference lives in the module repository: [@moleculer/database documentation](https://github.com/moleculerjs/database/blob/master/docs/README.md).**

{% note info Requirements %}
Node.js >= 22 and Moleculer >= 0.14.12 (0.15 recommended). The module follows the [one database per service](https://microservices.io/patterns/data/database-per-service.html) pattern: one service handles one entity/table. For multiple entities per service see the [FAQ](faq.html#DB-Adapters-moleculer-db).
{% endnote %}

## Features
- pluggable adapters: NeDB (in-memory or file, good for prototyping), MongoDB, Knex (SQL databases)
- generated CRUD actions with parameter validation and REST endpoints
- field definitions with sanitization, validation, defaults, read-only / immutable / virtual / hidden fields
- field-level permissions (read/write)
- populating entities from other Moleculer services
- scopes, soft delete, indexes, cascade delete
- action caching with automatic cache invalidation
- entity lifecycle events (`posts.created`, `posts.updated`, `posts.removed`)
- create/update/remove hooks
- streaming results
- multi-tenancy (record-, table- or database-based)

## Install

```bash
npm install @moleculer/database
```

Install the driver of the adapter you want to use:

```bash
npm install @seald-io/nedb   # NeDB (optional, prototyping)
npm install mongodb          # MongoDB
npm install knex pg          # Knex + PostgreSQL (or mysql2, better-sqlite3, tedious...)
```

## Define a service

The field definitions use the [fastest-validator](https://github.com/icebob/fastest-validator) schema format, extended with database-specific properties (`primaryKey`, `columnName`, `readonly`, `onCreate`, `populate`, ...). All fields are optional unless `required: true` is set.

```js
// posts.service.js
const DbService = require("@moleculer/database").Service;

module.exports = {
    name: "posts",
    mixins: [
        DbService({
            adapter: "NeDB" // in-memory NeDB, replace it in production (see Adapters)
        })
    ],

    settings: {
        fields: {
            id: { type: "string", primaryKey: true, columnName: "_id" },
            title: { type: "string", max: 255, trim: true, required: true },
            content: { type: "string" },
            votes: { type: "number", integer: true, min: 0, default: 0 },
            status: { type: "boolean", default: true },
            createdAt: { type: "number", readonly: true, onCreate: () => Date.now() },
            updatedAt: { type: "number", readonly: true, onUpdate: () => Date.now() }
        }
    }
};
```

[Field properties reference](https://github.com/moleculerjs/database/blob/master/docs/README.md#fields)

## Generated actions

The mixin registers these actions on the service (all of them can be disabled with the `createActions: false` mixin option). With [moleculer-web](moleculer-web.html) and `autoAliases: true` the REST endpoints are generated automatically.

| Action | REST endpoint | Description |
| ------ | ------------- | ----------- |
| `find` | `GET /posts/all` | Find entities by query (`query`, `sort`, `limit`, `offset`, `fields`, `search`, `populate`, `scope`) |
| `list` | `GET /posts` | Paginated list (`page`, `pageSize` + the `find` params). Returns `{ rows, total, page, pageSize, totalPages }` |
| `count` | `GET /posts/count` | Count entities by query |
| `get` | `GET /posts/:id` | Get an entity by ID |
| `resolve` | – | Get one or more entities by ID(s), optionally as a map |
| `create` | `POST /posts` | Create an entity |
| `createMany` | – | Create multiple entities |
| `update` | `PATCH /posts/:id` | Update fields of an entity |
| `replace` | `PUT /posts/:id` | Replace an entity |
| `remove` | `DELETE /posts/:id` | Delete an entity (or soft-delete it if configured) |

```js
// Create a new post
let post = await broker.call("posts.create", {
    title: "My first post",
    content: "Content of my first post..."
});
// { id: 'Zrpjq8B1XTSywUgT', title: 'My first post', content: '...', votes: 0, status: true, createdAt: 1618065551990 }

// Find posts
const posts = await broker.call("posts.find", { sort: "-createdAt", query: { status: true } });

// Paginated list
const page = await broker.call("posts.list", { page: 1, pageSize: 10 });

// Get by ID
post = await broker.call("posts.get", { id: post.id });

// Update
post = await broker.call("posts.update", { id: post.id, title: "Modified post" });

// Remove
await broker.call("posts.remove", { id: post.id });
```

[Actions reference](https://github.com/moleculerjs/database/blob/master/docs/README.md#actions)

## Expose via API Gateway

```js
// api.service.js
const ApiGateway = require("moleculer-web");

module.exports = {
    name: "api",
    mixins: [ApiGateway],
    settings: {
        routes: [
            {
                path: "/api",
                autoAliases: true // generates GET/POST/PATCH/PUT/DELETE /api/posts... from the actions
            }
        ]
    }
};
```

## Adapters

If no `adapter` is defined, the service uses an in-memory NeDB database. The adapter connects lazily, on the first request, so the service starts even if the database server is not available yet.

**MongoDB**
```js
mixins: [
    DbService({
        adapter: {
            type: "MongoDB",
            options: {
                uri: "mongodb://127.0.0.1:27017",
                dbName: "mydb" // collection name defaults to the service name
            }
        }
    })
]
```

**Knex (PostgreSQL)**
```js
mixins: [
    DbService({
        adapter: {
            type: "Knex",
            options: {
                tableName: "posts",
                knex: {
                    client: "pg",
                    connection: "postgres://user:pass@localhost:5432/mydb"
                }
            }
        }
    })
]
```

Adapter documentation: [NeDB](https://github.com/moleculerjs/database/blob/master/docs/adapters/NeDB.md), [MongoDB](https://github.com/moleculerjs/database/blob/master/docs/adapters/MongoDB.md), [Knex](https://github.com/moleculerjs/database/blob/master/docs/adapters/Knex.md)

## Custom actions

Add your own actions next to the generated ones and use the entity methods of the mixin (`findEntities`, `resolveEntities`, `createEntity`, `updateEntity`, `removeEntity`, ...).

```js
// posts.service.js
module.exports = {
    name: "posts",
    mixins: [DbService({ adapter: "NeDB" })],
    settings: { /* fields */ },

    actions: {
        voteUp: {
            rest: "POST /:id/vote-up",
            params: {
                id: "string"
            },
            async handler(ctx) {
                const entity = await this.resolveEntities(ctx, { id: ctx.params.id }, { throwIfNotExist: true });
                return this.updateEntity(ctx, {
                    id: ctx.params.id,
                    votes: entity.votes + 1
                });
            }
        }
    }
};
```

[Methods reference](https://github.com/moleculerjs/database/blob/master/docs/README.md#methods)

## Populating

A field can be resolved from another service (typically its `resolve` action) when the caller asks for it with the `populate` parameter.

```js
// posts.service.js
settings: {
    fields: {
        // ...
        author: {
            type: "string",
            populate: {
                action: "users.resolve",
                params: { fields: ["username", "fullName"] }
            }
        }
    }
}
```

```js
const posts = await broker.call("posts.find", { populate: ["author"] });
// [{ id: "...", title: "...", author: { id: "...", username: "john", fullName: "John Doe" } }]
```

[Populating reference](https://github.com/moleculerjs/database/blob/master/docs/README.md#populating)

## Further reading

Everything below is documented in the module repository:

- [Mixin options & settings](https://github.com/moleculerjs/database/blob/master/docs/README.md#mixin-options)
- [Scopes](https://github.com/moleculerjs/database/blob/master/docs/README.md#scopes) and [soft delete](https://github.com/moleculerjs/database/blob/master/docs/README.md#soft-delete)
- [Indexes](https://github.com/moleculerjs/database/blob/master/docs/README.md#indexes)
- [Nested objects & arrays](https://github.com/moleculerjs/database/blob/master/docs/README.md#nested-objects--arrays)
- [Permissions](https://github.com/moleculerjs/database/blob/master/docs/README.md#permissions)
- [Caching](https://github.com/moleculerjs/database/blob/master/docs/README.md#caching) and [entity events](https://github.com/moleculerjs/database/blob/master/docs/README.md#events)
- [Cascade delete](https://github.com/moleculerjs/database/blob/master/docs/README.md#cascade-delete)
- [Service hooks](https://github.com/moleculerjs/database/blob/master/docs/README.md#service-hooks)
- [Streaming](https://github.com/moleculerjs/database/blob/master/docs/README.md#streaming)
- [Multi-tenancy](https://github.com/moleculerjs/database/blob/master/docs/README.md#multi-tenancy)
- [Examples](https://github.com/moleculerjs/database/tree/master/examples) and [benchmarks](https://github.com/moleculerjs/database/blob/master/benchmark/results/common/README.md)
