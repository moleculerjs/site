title: Действия
---

Действия (Action) это публично вызываемый метод сервиса. Работа с действиями построена по принципу удаленного вызова процедур (RPC). Действие похоже на обычный HTTP запрос, принимает на вход параметры и возвращает результат.

Если запущено несколько экземпляров сервиса, то брокер будет балансировать запросы между экземплярами. [Подробнее о балансировке](balancing.html).

<div align="center">
    <img src="assets/action-balancing.gif" alt="Диаграмма балансировки действий" />
</div>

## Вызов сервисов
Для вызова сервиса используется метод `broker.call`. Брокер ищет сервис (и узел) который предоставляет требуемое действие и вызывает его. Функция возвращает `Promise`.

### Синтаксис
```js
const res = await broker.call(actionName, params, opts);
```
`actionName` содержит точку в качестве разделителя. Первая часть является именем сервиса, а вторая часть название действия. К примеру, у нас есть сервис `posts` и действие `create`, в таком случае actionName = `posts.create`.

`params` это объект, который передается действию в качестве части [Context](context.html) контекста. Сервис может получить доступ к нему через `ctx.params`. *Необязательное. Значение по умолчанию `{}`*.

`opts` является объектом для установки/переопределения некоторых опций запроса, например: `timeout` таймаут, `retryCount` количество повторов. *Необязательное.*

**Доступные опции вызова:**

| Название           | Тип       | По умолчанию | Описание                                                                                                                                                                                                                                                                                                   |
| ------------------ | --------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `timeout`          | `Number`  | `null`       | Время ожидания запроса в миллисекундах. Если время истекло, и вы не определили `fallbackResponse`, брокер бросит ошибку `RequestTimeout`. Чтобы отключить установите `0`. Если не определено, будет использовано значение `requestTimeout` из опций брокера. [Читать далее](fault-tolerance.html#Timeout). |
| `retries`          | `Number`  | `null`       | Количество повторных запросов. Если время истекло, брокер попытается повторить вызов ещё раз. Чтобы отключить установите `0`. Если не определено, будет использовано значение `retryPolicy.retries` из опций брокера. [Читать далее](fault-tolerance.html#Retry).                                          |
| `fallbackResponse` | `Any`     | `null`       | Возвращает его, если запрос не удался. [Читать далее](fault-tolerance.html#Fallback).                                                                                                                                                                                                                      |
| `nodeID`           | `String`  | `null`       | Целевой nodeID. Если задан, то вызов будет отправлен указанному узлу.                                                                                                                                                                                                                                      |
| `meta`             | `Object`  | `{}`         | Метаданные запроса. Доступны через `ctx.meta` в обработчике действия. Они будут переданы и объединены со всеми вложенными вызовами.                                                                                                                                                                        |
| `parentCtx`        | `Context` | `null`       | Экземпляр родительского контекста `Context`. Используется для создание цепочки вызовов.                                                                                                                                                                                                                    |
| `requestID`        | `String`  | `null`       | ID запроса или ID корреляции. Используется для трассировки вызовов.                                                                                                                                                                                                                                        |


### Примеры использования
**Вызов без параметров**
```js
const res = await broker.call("user.list");
```

**Вызов с параметрами**
```js
const res = await broker.call("user.get", { id: 3 });
```

**Вызов с опциями**
```js
const res = await broker.call("user.recommendation", { limit: 5 }, {
    timeout: 500,
    retries: 3,
    fallbackResponse: defaultRecommendation
});
```

**Вызов с обработкой ошибок**
```js
broker.call("posts.update", { id: 2, title: "Modified post title" })
    .then(res => console.log("Post updated!"))
    .catch(err => console.error("Unable to update Post!", err));    
```

**Прямой вызов: получить информацию о здоровье от узла "node-21"**
```js
const res = await broker.call("$node.health", null, { nodeID: "node-21" })
```

### Метаданные
Для передачи метаданных используется свойство `meta`. Получить доступ к ним можно внутри обработчика действия через `ctx.meta`. Вложенные вызовы объединяют `meta`.
```js
broker.createService({
    name: "test",
    actions: {
        first(ctx) {
            return ctx.call("test.second", null, { meta: {
                b: 5
            }});
        },
        second(ctx) {
            console.log(ctx.meta);
            // Prints: { a: "John", b: 5 }
        }
    }
});

broker.call("test.first", null, { meta: {
    a: "John"
}});
```

`meta` отправляются обратно сервису, который осуществил вызов метода. Используйте это для возврата дополнительных данных отправителю. К примеру: оправка заголовков обратно в API gateway или запись данных авторизованного пользователя в метаданные.

```js
broker.createService({
    name: "test",
    actions: {
        async first(ctx) {
            await ctx.call("test.second", null, { meta: {
                a: "John"
            }});

            console.log(ctx.meta);
            // Prints: { a: "John", b: 5 }
        },
        second(ctx) {
            // Modify meta
            ctx.meta.b = 5;
        }
    }
});
```

При выполнении внутренних вызовов действий (`this.actions.xy()`) необходимо установить `parentCtx` для передачи `meta` данных.

**Внутренние вызовы**
```js
broker.createService({
  name: "mod",
  actions: {
    hello(ctx) {
      console.log(ctx.meta);
      // Prints: { user: 'John' }
      ctx.meta.age = 123
      return this.actions.subHello(ctx.params, { parentCtx: ctx });
    },

    subHello(ctx) {
      console.log("meta from subHello:", ctx.meta);
      // Prints: { user: 'John', age: 123 }
      return "hi!";
    }
  }
});

broker.call("mod.hello", { param: 1 }, { meta: { user: "John" } });
```

### Таймауты

Таймаут может быть установлен на уровне действия. Он переопределит глобальное значение брокера [опцию `requestTimeout`](fault-tolerance.html#Timeout), но не опцию `timeout` указанную для конкретного вызова действия.

**Пример**
 ```js
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    requestTimeout: 3000
};

 // greeter.service.js
module.exports = {
    name: "greeter",
    actions: {
        normal: {
            handler(ctx) {
                return "Normal";
            }
        },
         slow: {
            timeout: 5000, // 5 secs
            handler(ctx) {
                return "Slow";
            }
        }
    },
```
**Пример вызова**
```js
// тут используется глобальный таймаут (3000)
await broker.call("greeter.normal");
 // тут используется таймаут настроенный на действии (5000)
await broker.call("greeter.slow");
 // тут используется непосредственно переданный таймаут (1000)
await broker.call("greeter.slow", null, { timeout: 1000 });
```
### Массовый вызов

Также возможно выполнить несколько действий одновременно. Для этого используйте `broker.mcall` или `ctx.mcall`.
**`mcall` c Массивом \<Object\\>**

```js
await broker.mcall(
    [
        { action: 'posts.find', params: { author: 1 }, options: { /* Опции для этого действия. */} },
        { action: 'users.find', params: { name: 'John' } }
    ],
    {
        // Общие опции вызова для всей группы действий.
        meta: { token: '63f20c2d-8902-4d86-ad87-b58c9e2333c2' }
    }
);
```

**`mcall` с объектом и options.meta**
```js
await broker.mcall(
    {
        posts: { action: 'posts.find', params: { author: 1 }, options: { /* Опции для этого действия. */} },
        users: { action: 'users.find', params: { name: 'John' } }
    }, 
    {
        // Общие опции вызова для всей группы действий.
        meta: { token: '63f20c2d-8902-4d86-ad87-b58c9e2333c2' }
    }
);
```

**`settled` option in `broker.mcall`**

Метод `mcall` имеет новую опцию `settled`, позволяющую получить результаты всех Promise. Если установить `settled: true`, то `mcall` всегда возвращает успешно выполненный Promise, и в ответе будут содержаться статусы и результаты всех вызовов. Обратите внимание: без этой опции вы не сможете узнать, сколько (и какие) вызовы были отклонены.

Пример
```js
const res = await broker.mcall([
    { action: "posts.find", params: { limit: 2, offset: 0 },
    { action: "users.find", params: { limit: 2, sort: "username" } },
    { action: "service.notfound", params: { notfound: 1 } }
], { settled: true });
console.log(res);
```

`res` будет примерно таким

```js
[
    { status: "fulfilled", value: [/*... response of `posts.find`...*/] },
    { status: "fulfilled", value: [/*... response of `users.find`...*/] },
    { status: "rejected", reason: {/*... Rejected response/Error`...*/} }
]
```

## Потоки
Moleculer supports Node.js streams as request `params` and as response. Use it to transfer an incoming file from a gateway, encode/decode or compress/decompress streams.

### Примеры

**Send a file to a service as a stream**
```js
const stream = fs.createReadStream(fileName);

broker.call("storage.save", stream, { meta: { filename: "avatar-123.jpg" }});
```

{% note info Object Mode Streaming%}
Режим [Object Mode Streaming](https://nodejs.org/api/stream.html#stream_object_mode) так же поддерживается. Чтобы его задействовать, установите `$streamObjectMode: true` в [`meta`](actions.html#Metadata).
{% endnote %}

Please note, the `params` should be a stream, you cannot add any additional variables to the `params`. Use the `meta` property to transfer additional data.

**Receiving a stream in a service**
```js
module.exports = {
    name: "storage",
    actions: {
        save(ctx) {
            // Save the received stream to a file
            const s = fs.createWriteStream(`/tmp/${ctx.meta.filename}`);
            ctx.params.pipe(s);
        }
    }
};
```

**Return a stream as response in a service**
```js
module.exports = {
    name: "storage",
    actions: {
        get: {
            params: {
                filename: "string"
            },
            handler(ctx) {
                return fs.createReadStream(`/tmp/${ctx.params.filename}`);
            }
        }
    }
};
```

**Process received stream on the caller side**
```js
const filename = "avatar-123.jpg";
broker.call("storage.get", { filename })
    .then(stream => {
        const s = fs.createWriteStream(`./${filename}`);
        stream.pipe(s);
        s.on("close", () => broker.logger.info("File has been received"));
    })
```

**AES encode/decode example service**
```js
const crypto = require("crypto");
const password = "moleculer";

module.exports = {
    name: "aes",
    actions: {
        encrypt(ctx) {
            const encrypt = crypto.createCipher("aes-256-ctr", password);
            return ctx.params.pipe(encrypt);
        },

        decrypt(ctx) {
            const decrypt = crypto.createDecipher("aes-256-ctr", password);
            return ctx.params.pipe(decrypt);
        }
    }
};
```

## Видимость методов
The action has a `visibility` property to control the visibility & callability of service actions.

**Available values:**
- `published` или `null`: публичное действие. Оно может быть вызвано локально, удаленно и может быть опубликован через API шлюз
- `public`: публичное действие, может быть вызвано локально или удаленно, но не опубликовано через API шлюз
- `protected`: можно вызвать только локально (из локального сервиса)
- `private`: можно вызвать только внутри сервиса (через `this.actions.xy()`)

**Change visibility**
```js
module.exports = {
    name: "posts",
    actions: {
        // It's published by default
        find(ctx) {},
        clean: {
            // Callable only via `this.actions.clean`
            visibility: "private",
            handler(ctx) {}
        }
    },
    methods: {
        cleanEntities() {
            // Call the action directly
            return this.actions.clean();
        }
    }
}
```

> Значения по умолчанию `null` (означает `published`) для обратной совместимости.

## Хуки действий
Action hooks are pluggable and reusable middleware functions that can be registered `before`, `after` or on `errors` of service actions. A hook is either a `Function` or a `String`. In case of a `String` it must be equal to service's [method](services.html#Methods) name.

### Хуки Before
In before hooks, it receives the `ctx`, it can manipulate the `ctx.params`, `ctx.meta`, or add custom variables into `ctx.locals` what you can use in the action handlers. If there are any problem, it can throw an `Error`. _Please note, you can't break/skip the further executions of hooks or action handler._

**Основное назначение:**
- очистка параметров
- валидация параметров
- поиск сущности
- авторизация

### After hooks
In after hooks, it receives the `ctx` and the `response`. It can manipulate or completely change the response. In the hook, it has to return the response.

**Main usages:**
- заполнение сущностей
- удаление чувствительных данных.
- оборачивание ответа в `Объект`
- конвертирование структуры ответа

### Хуки ошибок
The error hooks are called when an `Error` is thrown during action calling. It receives the `ctx` and the `err`. It can handle the error and return another response (fallback) or throws further the error.

**Main usages:**
- обработка ошибок
- обернуть ошибку в другую
- резервный ответ

### Декларация на уровне сервиса
Hooks can be assigned to a specific action (by indicating action `name`), all actions (`*`) in service or by indicating a wildcard (e.g., `create-*`). The latter will be applied to all actions whose name starts with `create-`. Action names can also be combined using a pipe symbol (e.g., `create|update`)

{% note warn%}
Please notice that hook registration order matter as it defines sequence by which hooks are executed. For more information take a look at [hook execution order](#Execution-order).
{% endnote %}

**Before hooks**

```js
const DbService = require("moleculer-db");

module.export = {
    name: "posts",
    mixins: [DbService]
    hooks: {
        before: {
            // Глобальный хук для всех действий
            // хук вызовет метод `resolveLoggedUser`.
            "*": "resolveLoggedUser",

            // Define multiple hooks for action `remove`
            remove: [
                function isAuthenticated(ctx) {
                    if (!ctx.user)
                        throw new Error("Forbidden");
                },
                function isOwner(ctx) {
                    if (!this.checkOwner(ctx.params.id, ctx.user.id))
                        throw new Error("Only owner can remove it.");
                }
            ],
            // Applies to all actions that start with "create-"
            "create-*": [
                async function (ctx){}
            ],
            // Applies to all actions that end with "-user"
            "*-user": [
                async function (ctx){}
            ],
            // Applies to all actions that start with "create-" or end with "-user"
            "create-*|*-user": [
                async function (ctx){}
            ],
        }
    },

    methods: {
        async resolveLoggedUser(ctx) {
            if (ctx.meta.user)
                ctx.user = await ctx.call("users.get", { id: ctx.meta.user.id });
        }
    }
}
```

**After & Error hooks**

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "users",
    mixins: [DbService]
    hooks: {
        after: {
            // Define a global hook for all actions to remove sensitive data
            "*": function(ctx, res) {
                // Remove password
                delete res.password;

                // Please note, must return result (either the original or a new)
                return res;
            },
            get: [
                // Add a new virtual field to the entity
                async function (ctx, res) {
                    res.friends = await ctx.call("friends.count", { query: { follower: res._id }});

                    return res;
                },
                // Populate the `referrer` field
                async function (ctx, res) {
                    if (res.referrer)
                        res.referrer = await ctx.call("users.get", { id: res._id });

                    return res;
                }
            ],
            // Applies to all actions that start with "create-"
            "create-*": [
                async function (ctx, res){}
            ],
            // Applies to all actions that end with "-user"
            "*-user": [
                async function (ctx, res){}
            ],
        },
        error: {
            // Global error handler
            "*": function(ctx, err) {
                this.logger.error(`Error occurred when '${ctx.action.name}' action was called`, err);

                // Throw further the error
                throw err;
            },
            // Applies to all actions that start with "create-"
            "create-*": [
                async function (ctx, err){}
            ],
            // Applies to all actions that end with "-user"
            "*-user": [
                async function (ctx, err){}
            ],
        }
    }
};
```

### Декларация на уровне действия
Hooks can be also registered inside action declaration.

{% note warn%}
Please note that hook registration order matter as it defines sequence by which hooks are executed. For more information take a look at [hook execution order](#Execution-order).
{% endnote %}

**Before & After hooks**

```js
broker.createService({
    name: "greeter",
    actions: {
        hello: {
            hooks: {
                before(ctx) {
                    broker.logger.info("Before action hook");
                },
                after(ctx, res) {
                    broker.logger.info("After action hook"));
                    return res;
                }
            },

            handler(ctx) {
                broker.logger.info("Action handler");
                return `Hello ${ctx.params.name}`;
            }
        }
    }
});
```
### Порядок выполнения
It is important to keep in mind that hooks have a specific execution order. This is especially important to remember when multiple hooks are registered at different ([service](#Service-level-declaration) and/or [action](#Action-level-declaration)) levels.  Overall, the hooks have the following execution logic:

- `before` хуки: глобальные (`*`) `->` уровень сервиса `->` уровень действия.

- `after` хуки: уровень действия `->` уровень сервиса `->` глобальные (`*`).

{% note info%}
When using several hooks it might be difficult visualize their execution order. However, you can set the [`logLevel` to `debug`](logging.html#Log-Level-Setting) to quickly check the execution order of global and service level hooks.
{% endnote %}

**Example of a global, service & action level hook execution chain**
```js
broker.createService({
    name: "greeter",
    hooks: {
        before: {
            "*"(ctx) {
                broker.logger.info(chalk.cyan("Before all hook"));
            },
            hello(ctx) {
                broker.logger.info(chalk.magenta("  Before hook"));
            }
        },
        after: {
            "*"(ctx, res) {
                broker.logger.info(chalk.cyan("After all hook"));
                return res;
            },
            hello(ctx, res) {
                broker.logger.info(chalk.magenta("  After hook"));
                return res;
            }
        },
    },

    actions: {
        hello: {
            hooks: {
                before(ctx) {
                    broker.logger.info(chalk.yellow.bold("    Before action hook"));
                },
                after(ctx, res) {
                    broker.logger.info(chalk.yellow.bold("    After action hook"));
                    return res;
                }
            },

            handler(ctx) {
                broker.logger.info(chalk.green.bold("      Action handler"));
                return `Hello ${ctx.params.name}`;
            }
        }
    }
});
```
**Output produced by global, service & action level hooks**
```bash
INFO  - Before all hook
INFO  -   Before hook
INFO  -     Before action hook
INFO  -       Action handler
INFO  -     After action hook
INFO  -   After hook
INFO  - After all hook
```

### Переиспользование
The most efficient way of reusing hooks is by declaring them as service methods in a separate file and import them with the [mixin](services.html#Mixins) mechanism. This way a single hook can be easily shared across multiple actions.

```js
// authorize.mixin.js
module.exports = {
    methods: {
        checkIsAuthenticated(ctx) {
            if (!ctx.meta.user)
                throw new Error("Unauthenticated");
        },
        checkUserRole(ctx) {
            if (ctx.action.role && ctx.meta.user.role != ctx.action.role)
                throw new Error("Forbidden");
        },
        checkOwner(ctx) {
            // Check the owner of entity
        }
    }
}
```

```js
// posts.service.js
const MyAuthMixin = require("./authorize.mixin");

module.exports = {
    name: "posts",
    mixins: [MyAuthMixin]
    hooks: {
        before: {
            "*": ["checkIsAuthenticated"],
            create: ["checkUserRole"],
            update: ["checkUserRole", "checkOwner"],
            remove: ["checkUserRole", "checkOwner"]
        }
    },

    actions: {
        find: {
            // No required role
            handler(ctx) {}
        },
        create: {
            role: "admin",
            handler(ctx) {}
        },
        update: {
            role: "user",
            handler(ctx) {}
        }
    }
};
```
### Локальное хранилище
The `locals` property of `Context` object is a simple storage that can be used to store some additional data and pass it to the action handler. `locals` property and hooks are a powerful combo:

**Setting `ctx.locals` in before hook**
```js
module.exports = {
    name: "user",

    hooks: {
        before: {
            async get(ctx) {
                const entity = await this.findEntity(ctx.params.id);
                ctx.locals.entity = entity;
            }
        }
    },

    actions: {
        get: {
            params: {
                id: "number"
            },
            handler(ctx) {
                this.logger.info("Entity", ctx.locals.entity);
            }
        }
    }
}
```
