title: Usage
---

# Install Moleculer

Moleculer can be installed with npm or yarn

```bash
$ npm i moleculer --save
```

# Create your first microservice
This example shows how to create a small `math` service to add two numbers.

```js
const { ServiceBroker } = require("moleculer");

const broker = new ServiceBroker();

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

1. Install `moleculer-cli` globally
    ```bash
    $ npm i moleculer-cli -g
    ```
2. Create a new project (named `moleculer-demo`)
    ```bash
    $ moleculer init project moleculer-demo
    ```
    > Press `Y` to all questions
    
    > Don't forget to install and start [NATS Server](https://nats-io.github.io/docs/nats_server/installation.html). Otherwise, you will get the following error:
    > `NATS error. Could not connect to server: Error: connect ECONNREFUSED 127.0.0.1:4222`


3. Open project folder
    ```bash
    $ cd moleculer-demo
    ```

4. Start project
    ```bash
    $ npm run dev
    ```
5. Open the [http://localhost:3000/](http://localhost:3000/) link in your browser. It shows a start page which contains two links to call the `greeter` service via [API gateway](https://github.com/moleculerjs/moleculer-web).

{% note info Congratulations! %}
You have just created your first Moleculer-based microservices project! Next, check out Moleculer's [core concepts](concepts.html) page to get familiar with them and to see how they fit together. Otherwise, check our [examples](examples.html) or [demo projects](https://github.com/moleculerjs/moleculer-examples).
{% endnote %}


