title: Validation
---
Moleculer has a built-in validator module. It uses the [fastest-validator](https://github.com/icebob/fastest-validator) library.

```js
let { ServiceBroker } = require("moleculer");

let broker = new ServiceBroker({
    validation: true // Default is true
});

broker.createService({
    name: "say",
    actions: {
        hello: {
            // Parameters definitions to validator
            params: {
                name: { type: "string", min: 2 }
            },
            handler(ctx) {
                return "Hello " + ctx.params.name;
            }
        }
    }
});

broker.call("say.hello").then(console.log).catch(err => console.error(err.message));
// -> throw ValidationError: "The 'name' field is required!"

broker.call("say.hello", { name: 123 }).then(console.log).catch(err => console.error(err.message));
// -> throw ValidationError: "The 'name' field must be a string!"

broker.call("say.hello", { name: "Walter" }).then(console.log).catch(err => console.error(err.message));
// -> "Hello Walter"

```
[Play it on Runkit](https://runkit.com/icebob/moleculer-validation-example)