title: 参数验证
---
Moleculer 有一个内置的验证模块。 它使用[fastest-validator](https://github.com/icebob/fastest-validator) 库.

## 内置验证器
### 动作验证
动作验证默认是启用的，因此您只需要定义动作声明中的`params`属性，动作声明包含正在接收的`ctx.params`的验证模型。

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

### 事件验证
也支持事件参数验证。 为了启用它，定义事件声明中的 `params`，而内置的 `Validator` 将负责验证它们。
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
可以创建自定义验证器。 您需要实现 `BaseValidator` 的 `compile` 和 `validate` 方法。

### 创建 [Joi](https://github.com/hapijs/joi) 验证器
```js
const BaseValidator = require("moleculer").Validator;
const { ValidationError } = require("moleculer").Errors;

class JoiValidator extends BaseValidator {
    constructor() {
        super();
        this.validator = require("joi");
    }

    compile(schema) {
        return (params) => this.validate(params, schema);
    }

    validate(params, schema) {
        const res = this.validator.validate(params, schema);
        if (res.error)
            throw new ValidationError(res.error.message, null, res.error.details);

        return true;
    }
}

module.exports = JoiValidator;
```

**使用自定义 Joi 验证器**
```js
const { ServiceBroker } = require("moleculer");
const Joi = require("joi");
const JoiValidator = require("./joi.validator");

const broker = new ServiceBroker({
    logger: true,
    // Use custom validator
    validator: new JoiValidator()
});

// --- SERVICE ---
broker.createService({
    name: "greeter",
    actions: {
        hello: {
            params: Joi.object().keys({
                name: Joi.string().min(4).max(30).required()
            }),
            handler(ctx) {
                return `Hello ${ctx.params.name}`;
            }
        }
    }
});

// --- TEST ---
broker.start()
    .then(() => broker.call("greeter.hello").then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))

    .then(() => broker.call("greeter.hello", { name: 100 }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))

    .then(() => broker.call("greeter.hello", { name: "Joe" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))

    .then(() => broker.call("greeter.hello", { name: "John" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data));
```

{% note info Find more validators %}
[可从模块页面找到更多验证器。](/modules.html#validation)
{% endnote %}