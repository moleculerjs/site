title: Parameter Validation
---

Validation middleware is used for [`actions`](actions.html) and [`events`](events.html) parameter validation.

## Fastest Validator
By default, Moleculer uses the [fastest-validator](https://github.com/icebob/fastest-validator) library.

**Default usage**
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
    validator: "FastestValidator" // Using the Fastest Validator
}
```

**Example with options**
```js
//moleculer.config.js
module.exports = {
    nodeID: "node-100",
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

### Actions Validation
In order to perform parameter validation you need to define `params` property in action definition and create validation schema for the incoming `ctx.params`.

**Example**
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
[Play it on Runkit](https://runkit.com/icebob/moleculer-validation-example)

**Example validation schema**
```js
{
    id: { type: "number", positive: true, integer: true },
    name: { type: "string", min: 3, max: 255 },
    status: "boolean" // short-hand def
}
```

{% note info Documentation %}
Find more information about validation schema in the [documentation of the library](https://github.com/icebob/fastest-validator#readme)
{% endnote %}

### Events Validation
Event parameter validation is also supported. To enable it, define `params` in event definition.
> Please note that the validation errors are not sent back to the caller, as happens with action errors. Event validation errors are logged but you can also catch them with the [global error handler](broker.html#Global-error-handler).

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

## Custom validator
You can also implement custom validators. We recommend to copy the source of [Fastest Validator](https://github.com/moleculerjs/moleculer/blob/master/src/validators/fastest.js) and implement the `compile` and `validate` methods.

**Creating custom validator**
```js
//moleculer.config.js
const BaseValidator = require("moleculer").Validators.Base;

class MyValidator extends BaseValidator {}

module.exports = {
    nodeID: "node-100",
    validator: new MyValidator()
}
```

**Build Joi validator**
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
[Check the modules page and find more validators.](/modules.html#validation)
{% endnote %}