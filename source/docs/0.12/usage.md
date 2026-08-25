title: Usage
---

# Install Moleculer

You can install Moleculer with npm

``` bash
$ npm install moleculer --save
```
or with yarn
```
$ yarn add moleculer
```

# Create your first microservice
This example shows how you can create a small `math` service to add two numbers.

```js
const { ServiceBroker } = require("moleculer");

let broker = new ServiceBroker({ logger: console });

broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});

broker.start()
    // Call service
    .then(() => broker.call("math.add", { a: 5, b: 3 }))
    .then(res => console.log("5 + 3 =", res))
    .catch(err => console.error(`Error occured! ${err.message}`));
```

{% note info Try it in your browser! %}
Open this example on [Runkit!](https://runkit.com/icebob/moleculer-usage)
{% endnote %}

# Create a Moleculer project
Use the [Moleculer CLI tool](moleculer-cli.html) to create a new Moleculer-based microservices project.

1. Create a new project (named `first-demo`)
    ```bash
    $ npx -p moleculer-cli moleculer init project moleculer-demo
    ```
    > Press Y to all questions
    
2. Open project folder
    ```bash
    $ cd moleculer-demo
    ```
    
3. Start project
    ```bash
    $ npm run dev
    ```
4. Open the [http://localhost:3000/](http://localhost:3000/) link in your browser. It shows a start page which contains two links to call the `greeter` service via [API gateway](https://github.com/moleculerjs/moleculer-web).

{% note info Congratulations! %}
You have just created your first Moleculer-based microservices project! The next step is to check our [examples](examples.html) or [demo projects](https://github.com/moleculerjs/moleculer-examples).
{% endnote %}


