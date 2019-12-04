title: Валидация
---
Moleculer имеет встроенный модуль валидации. Используется библиотека [fastest-validator](https://github.com/icebob/fastest-validator).

## Встроенный валидатор
Включён по умолчанию, поэтому достаточно определить свойство `params` содержащее схему валидации для входящих параметров `ctx.params`.

**Пример**
```js
const { ServiceBroker } = require("moleculer");

const broker = new ServiceBroker({
    validator: true // Default is true
});

broker.createService({
    name: "say",
    actions: {
        hello: {
            // схема валидации
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
[Попробуйте это в Runkit](https://runkit.com/icebob/moleculer-validation-example)

**Пример схемы валидации**
```js
{
    id: { type: "number", positive: true, integer: true },
    name: { type: "string", min: 3, max: 255 },
    status: "boolean" // сокращённый способ описания
}
```

{% note info Documentation %}
Более подробную информацию о схеме проверки можно найти в [документации библиотеки](https://github.com/icebob/fastest-validator#readme)
{% endnote %}

## Пользовательский валидатор
Можно создать свой валидатор. Для этого необходимо реализовать методы `compile` и `validate` базового класса `BaseValidator`.

### Использование валидатора [Joi](https://github.com/hapijs/joi)
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

**Пользовательский валидатор Joi**
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
[На странице модулей доступно больше валидаторов.](/modules.html#validation)
{% endnote %}