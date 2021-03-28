title: Валидация параметров
---

Для проверки параметров в [Действиях](actions.html) и [Событиях](events.html) используется промежуточный слой валидации.

## Fastest Validator
По умолчанию в молекулере используется библиотека [fastest-validator](https://github.com/icebob/fastest-validator).

**Использование по умолчанию**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: true // Использовать Fastest Validator по умолчанию
}
```

**Установка валидатора по имени**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: true // Использовать Fastest Validator
}
```

**Пример с параметрами**
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

### Валидация действий
Чтобы выполнить валидацию параметров, необходимо определить свойство `params` в определении действия и создать схему валидации для входящих `ctx. arams`.

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

### Валидация событий
Также поддерживается валидация параметров события. Чтобы включить его, определите `params` в определении события.
> Пожалуйста, обратите внимание, что ошибки валидации не отправляются вызывающему коду, как это происходит с ошибками действия. Ошибки валидации событий логируются, но вы также можно поймать их с помощью [глобального обработчика ошибок](broker.html#Global-error-handler).

```js
// mailer.service.js
module.exports = {
    name: "mailer",
    events: {
        "send.mail": {
            // Схема валидации, записанная с использованием сокращённой записи
            // Больше информации: https://github.com/icebob/fastest-validator#shorthand-definitions
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

## Пользовательский валидатор
Имеется возможность реализовать пользовательские валидаторы. Мы рекомендуем скопировать источник [Fastest Validator](https://github.com/moleculerjs/moleculer/blob/master/src/validators/fastest.js) и реализовать методы `compile` и `validate`.

**Создание пользовательского валидатора**
```js
//moleculer.config.js
const BaseValidator = require("moleculer").Validators.Base;

class MyValidator extends BaseValidator {}

module.exports = {
    nodeID: "node-100",
    validator: new MyValidator()
}
```

**Создание Joi валидатора**
```js
const { ServiceBroker } = require("moleculer");
const BaseValidator = require("moleculer").Validators.Base;
const { ValidationError } = require("moleculer").Errors;
const Joi = require("joi");

// --- КЛАСС JOI ВАЛИДАТОРА ---
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

let broker = new ServiceBroker({
    logger: true,
    validator: new JoiValidator // Использование Joi валидатора
});

// --- ТЕСТОВЫЙ БРОКЕР ---

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
    .then(() => broker.call("greeter.hello", { name: 100 }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    .then(() => broker.call("greeter.hello", { name: "Joe" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    .then(() => broker.call("greeter.hello", { name: "John" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data));
```

{% note info Find more validators %}
[Проверьте страницу модулей и найдите больше валидаторов.](/modules.html#validation)
{% endnote %}
