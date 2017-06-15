title: Usage
---

# Create your first microservice
This example shows you how to create a small service with an `add` action which can add two numbers.

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

broker.start();

// Call service
broker.call("math.add", { a: 5, b: 3 })
    .then(res => console.log("5 + 3 =", res))
    .catch(err => console.error(`Error occured! ${err.message}`));
```

{% note info Try it in your browser! %}
Open this example on [Runkit!](https://runkit.com/icebob/moleculer-quick-example)
{% endnote %}

# Create a Moleculer project
Use the [Moleculer CLI tool](moleculer-cli.html) to create a new Moleculer based microservices project.

1. Install `moleculer-cli` globally
    ```bash
    $ npm install moleculer-cli -g
    ```
2. Create a new project (named `first-demo`)
    ```bash
    $ moleculer init project-simple first-demo
    ```
    > Add API Gateway and press Y to `npm install`
    
3. Open project folder
    ```bash
    $ cd first-demo
    ```
    
4. Start project
    ```bash
    $ npm run dev
    ```
5. Open the [http://localhost:3000/math.add?a=5&b=3](http://localhost:3000/math.add?a=5&b=3) link in your browser. It will call the `add` action of `math` service with two params via [API gateway](https://github.com/ice-services/moleculer-web) and returns with the result.

{% note info Congratulations! %}
You created your first Moleculer based microservices project! The next step is to check our [examples](examples.html) or [demo projects](https://github.com/ice-services/moleculer-examples).
{% endnote %}


