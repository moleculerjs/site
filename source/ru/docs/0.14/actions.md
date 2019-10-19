title: Actions
---

Action это публично вызываемый метод сервиса. Работа с actions по принципу удаленного вызова процедур (RPC). Action похож на обычный HTTP запрос, имеет параметры и возвращает результат.

Если запущено несколько экземпляров сервиса, то брокер будет балансировать запросы между экземплярами. [Подробнее о балансировке](balancing.html).

<div align="center">
    <img src="assets/action-balancing.gif" alt="Action balancing diagram" />
</div>

## Вызов сервисов
Для вызова сервиса используется метод `broker.call`. Брокер ищет сервис (и узел) который предоставляет указанный action и вызывает его. Функция возвращает `Promise`.

### Синтаксис
```js
const res = await broker.call(actionName, params, opts);
```
`actionName` содержит точку в качестве разделителя. Первая часть является именем сервиса, а вторая часть название action метода. К примеру, у нас есть сервис `posts` и action метод `create`, в таком случае actionName = `posts.create`.

The `params` is an object which is passed to the action as a part of the [Context](context.html). Служба может получить доступ через `ctx.params`. *Необязательное. If you don't define, it will be `{}`*.

The `opts` is an object to set/override some request parameters, e.g.: `timeout`, `retryCount`. *Необязательное.*

**Available calling options:**

| Название           | Тип       | По умолчанию | Описание                                                                                                                                                                                                                                                                                                   |
| ------------------ | --------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `таймаут`          | `Number`  | `null`       | Время ожидания запроса в миллисекундах. Если время истекло, и вы не определили `fallbackResponse`, брокер бросит ошибку `RequestTimeout`. Чтобы отключить установите `0`. Если не определено, будет использовано значение `requestTimeout` из опций брокера. [Читать далее](fault-tolerance.html#Timeout). |
| `retries`          | `Number`  | `null`       | Count of retry of request. If the request is timed out, broker will try to call again. Чтобы отключить установите `0`. If it's not defined, the `retryPolicy.retries` value from broker options will be used. [Читать далее](fault-tolerance.html#Retry).                                                  |
| `fallbackResponse` | `Any`     | `null`       | Возвращает, если запрос не удался. [Читать далее](fault-tolerance.html#Fallback).                                                                                                                                                                                                                          |
| `nodeID`           | `String`  | `null`       | Target nodeID. If set, it will make a direct call to the specified node.                                                                                                                                                                                                                                   |
| `meta`             | `Object`  | `{}`         | Metadata of request. Access it via `ctx.meta` in actions handlers. It will be transferred & merged at nested calls, as well.                                                                                                                                                                               |
| `parentCtx`        | `Context` | `null`       | Parent `Context` instance. Use it to chain the calls.                                                                                                                                                                                                                                                      |
| `requestID`        | `String`  | `null`       | Request ID or Correlation ID. Use it for tracing.                                                                                                                                                                                                                                                          |


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

**Вызов с обработкой ошибок в promise**
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

When making internal calls to actions (`this.actions.xy()`) you should set `parentCtx` to pass `meta` data.

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

### Таймаут

Timeout can be set in action definition, as well. It overwrites the global broker [`requestTimeout` option](fault-tolerance.html#Timeout), but not the `timeout` in calling options.

**Example**
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
**Calling examples**
```js
// It uses the global 3000 timeout
await broker.call("greeter.normal");
 // It uses the 5000 timeout from action definition
await broker.call("greeter.slow");
 // It uses 1000 timeout from calling option
await broker.call("greeter.slow", null, { timeout: 1000 });
```
### Массовый вызов

Также возможно выполнить несколько действий одновременно. Для этого используйте `broker.mcall` или `ctx.mcall`.

**`mcall` с массивом < Объектов >**
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

**`mcall` с объектом**
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

## Потоки
Moleculer поддерживает потоки Node.js в параметрах запроса `params` и в ответах. Используйте их для передачи файлов из gateway, кодирования/декодирования или сжатия/распаковки потоков.

### Примеры

**Отправка фала в виде потока в сервис**
```js
const stream = fs.createReadStream(fileName);

broker.call("storage.save", stream, { meta: { filename: "avatar-123.jpg" }});
```

Имейте ввиду, что `params` должен быть потоком, и вы не сможете добавить дополнительные переменные в свойство `params`. Используйте свойство `meta` для передачи дополнительных данных.

**Получение потока в сервисе**
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

**Возврат потока сервисом**
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

**Обработка полученного потока на стороне отправителя**
```js
const filename = "avatar-123.jpg";
broker.call("storage.get", { filename })
    .then(stream => {
        const s = fs.createWriteStream(`./${filename}`);
        stream.pipe(s);
        s.on("close", () => broker.logger.info("File has been received"));
    })
```

**Пример сервиса шифрования AES**
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
Действие имеет свойство `visibility` для контроля видимости и возможности его вызова другими сервисами.

**Доступные значения:**
- `published` или `null`: публичное действие. Оно может быть вызвано локально, удаленно и может быть опубликован через API шлюз
- `public`: публичное действие, может быть вызвано локально или удаленно, но не опубликовано через API шлюз
- `protected`: можно вызвать только локально (из локального сервиса)
- `private`: можно вызвать только внутри сервиса (через `this.actions.xy()`)

**Управление видимостью**
```js
module.exports = {
    name: "posts",
    actions: {
        // публичное по умолчанию
        find(ctx) {},
        clean: {
            // можно вызвать только через `this.actions.clean`
            visibility: "private",
            handler(ctx) {}
        }
    },
    methods: {
        cleanEntities() {
            // прямой вызов action
            return this.actions.clean();
        }
    }
}
```

> Значения по умолчанию `null` (означает `published`) для обратной совместимости.

## Хуки действий
Хуки действия являются подключаемыми и переиспользуемыми функциями middleware, которые могут быть зарегистрированы `перед`, `после` или при `ошибке` действий сервиса. Хук является `Функцией` или `Строкой`. В случае `Строки` её имя должно совпадать с именем [метода](services.html#Methods) сервиса.

### Хуки Before
Этот хук получает `ctx`, он может манипулировать `ctx.params`, `ctx.meta`, или добавить пользовательские переменные в `ctx.locals` которые можно использовать в обработчиках действий. В случае проблемы, она может бросить `Ошибку`. _Пожалуйста, обратите внимание, что нет возможности остановить/пропустить дальнейшие выполнения хуков или обработчиков действий._

**Основное назначение:**
- очистка параметров
- валидация параметров
- поиск сущности
- авторизация

### After hooks
Этот хук получает `ctx` контекст и `response` ответ. Он может полностью изменить ответ. Хук должен вернуть ответ.

**Основное назначение:**
- заполнение сущностей
- удаление чувствительных данных.
- оборачивание ответа в `Объект`
- конвертирование структуры ответа

### Хуки ошибок
The error hooks are called when an `Error` is thrown during action calling. It receives the `ctx` and the `err`. It can handle the error and return another response (fallback) or throws further the error.

**Основное назначение:**
- error handling
- wrap the error into another one
- fallback response

### Service level declaration
Hooks can be assigned to a specific action (by indicating action `name`) or all actions (`*`) in service.

{% note warn%}
Please notice that hook registration order matter as it defines sequence by which hooks are executed. For more information take a look at [hook execution order](#Execution-order).
{% endnote %}

**Хуки Before**

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "posts",
    mixins: [DbService]
    hooks: {
        before: {
            // Define a global hook for all actions
            // The hook will call the `resolveLoggedUser` method.
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
            ]
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
            ]
        },
        error: {
            // Global error handler
            "*": function(ctx, err) {
                this.logger.error(`Error occurred when '${ctx.action.name}' action was called`, err);

                // Throw further the error
                throw err;
            }
        }
    }
};
```

### Action level declaration
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
### Execution order
It is important to keep in mind that hooks have a specific execution order. This is especially important to remember when multiple hooks are registered at different ([service](#Service-level-declaration) and/or [action](#Action-level-declaration)) levels.  Overall, the hooks have the following execution logic:

- `before` hooks: global (`*`) `->` service level `->` action level.

- `after` hooks: action level `->` service level `->` global (`*`).

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
Свойство `locals` у объекта `Context` является простым хранилищем, который может быть использован для сохранения некоторых дополнительных данных и передачи их в обработчик action метода. Свойство `locals` совместно с хуками удачно дополняют друг друга:

**Установка `ctx.locals` в before хуке**
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