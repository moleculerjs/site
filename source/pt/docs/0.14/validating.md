title: Validação de parâmetros
---

Um middleware de validação é usado para validações de parâmetros de [Ações](actions.html) e [Eventos](events.html).

## Fastest Validator
Por padrão, Moleculer usa a biblioteca [fastest-validator](https://github.com/icebob/fastest-validator).

**Uso padrão**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: true // Using the default Fastest Validator
}
```

**Setting validator by name**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
    validator: "Fastest" // Using the Fastest Validator
}
```

**Exemplo com opções**
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

### Validação de ações
Para realizar a validação de parâmetros você precisa definir a propriedade `params` na definição da ação e criar um esquema de validação para a `ctx.params` recebida.

**Exemplo**
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
[Experimente no Runkit](https://runkit.com/icebob/moleculer-validation-example)

**Exemplo de esquema de validação**
```js
{
    id: { type: "number", positive: true, integer: true },
    name: { type: "string", min: 3, max: 255 },
    status: "boolean" // short-hand def
}
```

{% note info Documentation %}
Encontre mais informações sobre o esquema de validação na [documentação da biblioteca](https://github.com/icebob/fastest-validator#readme)
{% endnote %}

#### Validador personalizado assíncrono
FastestValidator (`>= v1.11.0`) suporta validadores customizados assíncronos e você pode [passar metadata para uma função de validação customizada](https://github.com/icebob/fastest-validator/blob/master/CHANGELOG.md#meta-information-for-custom-validators). No Moleculer, o FastestValidator passa o `ctx` como metadados. Isso significa que você pode acessar o context atual, serviço, broker. Isso permite que você faça chamadas assíncronas (por exemplo, chamar outro serviço) em funções de validações personalizadas.

Exemplo

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

### Validação de Eventos
A validação dos parâmetros de evento também é suportada. Para habilitá-la, defina `params` na definição do evento.
> Por favor, note que os erros de validação não são enviados de volta para o requisitante, como acontece com os erros de ação. Erros de validação de evento são registrados, mas você também pode recuperá-los com o [manipulador de erro global](broker.html#Global-error-handler).

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

## Validador personalizado
Você também pode implementar validadores personalizados. Recomendamos copiar o código fonte de [Fastest Validator](https://github.com/moleculerjs/moleculer/blob/master/src/validators/fastest.js) e implementar os métodos `compile` e `validate`.

**Criar validador personalizado**
```js
//moleculer.config.js
const BaseValidator = require("moleculer").Validators.Base;

class MyValidator extends BaseValidator {}

module.exports = {
    nodeID: "node-100",
    validator: new MyValidator()
}
```

**Criar validador Joi**
```js
const { ServiceBroker } = require("moleculer");
const BaseValidator = require("moleculer").Validators.Base;
const { ValidationError } = require("moleculer").Errors;
const Joi = require("joi");

// --- JOI VALIDATOR CLASS ---
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
    .then(() => broker.call("greeter.hello", { name: 100 }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    .then(() => broker.call("greeter.hello", { name: "Joe" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data))
    .then(() => broker.call("greeter.hello", { name: "John" }).then(res => broker.logger.info(res)))
    .catch(err => broker.logger.error(err.message, err.data));
```

{% note info Find more validators %}
[Verifique a página de módulos e encontre mais validadores.](/modules.html#validation)
{% endnote %}
