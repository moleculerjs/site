layout: index
headline: Moleculer
description: Moleculer is a fast & powerful microservices framework powered by Node.js.
subtitle: Fast & powerful microservices framework for Node.js.
comments: false
---
```js
const { ServiceBroker } = require("moleculer");

// Create broker
let broker = new ServiceBroker({ logger: console });

// Create a service
broker.createService({
    name: "math",
    actions: {
        // You can call it as broker.call("math.add")
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});

// Start broker
broker.start();

// Call actions of service
broker.call("math.add", { a: 5, b: 3 })
    .then(res => console.log("5 + 3 =", res));
```
