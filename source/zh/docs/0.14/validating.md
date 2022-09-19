title: 参数验证
---

验证中间件用于 [Actions](actions.html) 和[Events](events.html) 参数验证。

## Fastest Validator
默认情况下，Moleculer 使用 [fastest-validator](https://github.com/icebob/fastest-validator) 库。

**Default usage**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: true // Using the default Fastest Validator
}
```

**按名称设置验证器**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: "Fastest" // Using the Fastest Validator
}
```

**带选项的示例**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: {
        type: "Fastest",
        options: {
            useNewCustomCheckerFunction: true,
            defaults: { /*...*/ },
            messages: { /*...*/ },
            aliases: { /*...*/ }
        }
    }
}
```

### 动作验证
为了执行参数校验，您需要在动作中定义 `params` 属性，并为动作传入 `ctx.params`以创建验证模式。

**示例**
```js
const { ServiceBroker } = require("moleculer");

const broker = new ServiceBroker({
    validator: true // Default is true
});

broker.createService({
    name: "say",
    actions: {
        hello: {
            // Validator schema for params
            params: {
                name: { type: "string", min: 2 }
            },
            handler(ctx) {
                return "Hello " + ctx.params.name;
            }
        }
    }
});

broker.call("say.hello").then(console.log)
    .catch(err => console.error(err.message));
// -> throw ValidationError: "The 'name' field is required!"

broker.call("say.hello", { name: 123 }).then(console.log)
    .catch(err => console.error(err.message));
// -> throw ValidationError: "The 'name' field must be a string!"

broker.call("say.hello", { name: "Walter" }).then(console.log)
    .catch(err => console.error(err.message));
// -> "Hello Walter"

```
[在 Runkit 运行](https://runkit.com/icebob/moleculer-validation-example)

**验证模式示例**
```js
{
    id: { type: "number", positive: true, integer: true },
    name: { type: "string", min: 3, max: 255 },
    status: "boolean" // short-hand def
}
```

{% note info Documentation %}
在[库文档](https://github.com/icebob/fastest-validator#readme)中查找更多关于验证模型的信息
{% endnote %}

#### Async custom validator
FastestValidator (`>= v1.11.0`) supports async custom validators, meaning that you can [pass metadata for custom validator functions](https://github.com/icebob/fastest-validator/blob/master/CHANGELOG.md#meta-information-for-custom-validators). In Moleculer, the FastestValidator passes the `ctx` as metadata. It means you can access the current context, service, broker. This allows you to make async calls (e.g calling another service) in custom checker functions. To enable it you must set `useNewCustomCheckerFunction` to `true` in `moleculer.config.js`

**Enabling custom async validation**
```js
//moleculer.config.js
module.exports = {
    validator: {
        type: "FastestValidator",
        options: {
            useNewCustomCheckerFunction: true,
            defaults: { /*...*/ },
            messages: { /*...*/ },
            aliases: { /*...*/ }
        }
    }
}
```

**Using custom async validation**
```js
// posts.service.js
module.exports = {
    name: "posts",
    actions: {
        params: {
            $$async: true,
            owner: { type: "string", custom: async (value, errors, schema, name, parent, context) => {
                const ctx = context.meta;

                const res = await ctx.call("users.isValid", { id: value });
                if (res !== true)
                    errors.push({ type: "invalidOwner", field: "owner", actual: value });
                return value;
            } }, 
        },
        /* ... */
    }
}
```

### 事件验证
也支持事件参数验证。 要启用它，在事件中定义 `params`。
> 注意，同时有动作错误发生时，验证错误不会回送给调用者。 事件验证错误会输出到日志，您也可以使用 [global error handler](broker.html#Global-error-handler) 来捕获它们。

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    events: {
        "send.mail": {
            // Validation schema with shorthand notation
            // More info: https://github.com/icebob/fastest-validator#shorthand-definitions
            params: {
                from: "string|optional",
                to: "email",
                subject: "string"
            },
            handler(ctx) {
                this.logger.info("Event received, parameters OK!", ctx.params);
            }
        }
    }
};
```

## 自定义验证器
您也可以实现自定义验证器。 推荐直接复制 [Fastest Validator](https://github.com/moleculerjs/moleculer/blob/master/src/validators/fastest.js) 代码，并实现 `compile` 和 `validate` 方法。

**创建自定义验证器**
```js
//moleculer.config.js
const BaseValidator = require("moleculer").Validators.Base;

class MyValidator extends BaseValidator {}

module.exports = {
    nodeID: "node-100",
    validator: new MyValidator()
}
```

**生成 Joi 验证器**
```js
const { ServiceBroker } = require("moleculer");
const BaseValidator = require("moleculer").Validators.Base;
const { ValidationError } = require("moleculer").Errors;
const Joi = require("joi");

// --- JOI VALIDATOR CLASS ---
class JoiValidator extends BaseValidator {
    constructor() {
        super();
    }

    compile(schema) {
        return (params) => this.validate(params, schema);
    }

    validate(params, schema) {
        const res = schema.validate(params);
        if (res.error)
            throw new ValidationError(res.error.message, null, res.error.details);

        return true;
    }
}

let broker = new ServiceBroker({
    logger: true,
    validator: new JoiValidator // Use Joi validator
});

// --- TEST BROKER ---

broker.createService({
    name: "greeter",
    actions: {
        hello: {
            /*params: {
                name: { type: "string", min: 4 }
            },*/
            params: Joi.object().keys({
                name: Joi.string().min(4).max(30).required()
            }),
            handler(ctx) {
                return `Hello ${ctx.params.name}`;
            }
        }
    }
});

broker.start()
    .then(() => broker.call("greeter.hello").then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    // -> "name" is required ...
    .then(() => broker.call("greeter.hello", { name: 100 }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    // -> "name" must be a string ...
    .then(() => broker.call("greeter.hello", { name: "Joe" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    // -> "name" length must be at least 4 characters long ...
    .then(() => broker.call("greeter.hello", { name: "John" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data));
```

{% note info Find more validators %}
[可从模块页面找到更多验证器。](/modules.html#validation)
{% endnote %}
