title: Core Concepts
---

This guide covers the core concepts of any Moleculer application.

## Service
A [service](services.html) is a simple JavaScript module containing some part of a complex application. It is isolated and self-contained, meaning that even if it goes offline or crashes the remaining services would be unaffected.

## Node
A node is a simple OS process running on a local or external network. A single instance of a node can host one or many services.

### Local Services
Two (or more) services running on a single node are considered local services. They share hardware resources and use local bus to communicate with each other, no network latency ([transporter](#Transporter) is not used).

### Remote Services
Services distributed across multiple nodes are considered remote. In this case, the communication is done via [transporter](#Transporter).

## Service Broker
[Service Broker](broker.html) is the heart of Moleculer. It is responsible for management and communication between services (local and remote). Each node must have an instance of Service Broker.

## Transporter
[Transporter](networking.html) is a communication bus that services use to exchange messages. It transfers events, requests and responses.

## Gateway
[API Gateway](moleculer-web.html) exposes Moleculer services to end-users. The gateway is a regular Moleculer service running a (HTTP, WebSockets, etc.) server. It handles the incoming requests, maps them into service calls, and then returns appropriate responses.

## Overall View
There's nothing better than an example to see how all these concepts fit together. So let's consider a hypothetical online store that only lists its products. It doesn't actually sell anything online.

### Architecture

From the architectural point-of-view the online store can be seen as a composition of 2 independent services: the `products` service and the `gateway` service. The first one is  responsible for storage and management of the products while the second simply receives user´s requests and conveys them to the `products` service.

Now let's take a look at how this hypothetical store can be created with Moleculer.

To ensure that our system is resilient to failures we will run the `products` and the `gateway` services in dedicated [nodes](#Node) (`node-1` and `node-2`). If you recall, running services at dedicated nodes means that the [transporter](#Transporter) module is required for inter services communication. Most of the transporters supported by Moleculer rely on a message broker for inter services communication, so we're going to need one up and running. Overall, the internal architecture of our store is represented in the figure below.

Now, assuming that our services are up and running, the online store can serve user's requests. So let's see what actually happens with a request to list all available products. First, the request (`GET /products`) is received by the HTTP server running at `node-1`. The incoming request is simply passed from the HTTP server to the [gateway](#Gateway) service that does all the processing and mapping. In this case in particular, the user´s request is mapped into a `listProducts` action of the `products` service.  Next, the request is passed to the [broker](#Service-Broker), which checks whether the `products` service is a [local](#Local-Services) or a [remote](#Remote-Services) service. In this case, the `products` service is remote so the broker needs to use the [transporter](#Transporter) module to deliver the request. The transporter simply grabs the request and sends it through the communication bus. Since both nodes (`node-1` and `node-2`) are connected to the same communication bus (message broker), the request is successfully delivered to the `node-2`. Upon reception, the broker of `node-2` will parse the incoming request and forward it to the `products` service. Finally, the `products` service invokes the `listProducts` action and returns the list of all available products. The response is simply forwarded back to the end-user.

**Flow of user's request**
<div align="center">
    <img src="assets/overview.svg" alt="Architecture Overview" />
</div>

All the details that we've just seen might seem scary and complicated but you don't need to be afraid. Moleculer does all the heavy lifting for you! You (the developer) only need to focus on the application logic. Take a look at the actual [implementation](#Implementation) of our online store.

### Implementation
Now that we've defined the architecture of our shop, let's implement it. We're going to use NATS, an open source messaging system, as a communication bus. So go ahead and get the latest version of [NATS Server](https://nats.io/download/nats-io/nats-server/). Run it with the default settings. You should get the following message:

```
[18141] 2016/10/31 13:13:40.732616 [INF] Starting nats-server version 0.9.4
[18141] 2016/10/31 13:13:40.732704 [INF] Listening for client connections on 0.0.0.0:4222
[18141] 2016/10/31 13:13:40.732967 [INF] Server is ready
```

Next, create a new directory for our application, create a new `package.json` and install the dependencies. We´re going to use `moleculer` to create our services, `moleculer-web` as the HTTP gateway and `nats` for communication. In the end your `package.json` should look like this:

```json
// package.json
{
  "name": "moleculer-store",
  "dependencies": {
    "moleculer": "^0.14.0",
    "moleculer-web": "^0.9.0",
    "nats": "^1.3.2"
  }
}
```

Finally, we need to configure the brokers and create our services. So let's create a new file (`index.js`) and do it:
```javascript
// index.js
const { ServiceBroker } = require("moleculer");
const HTTPServer = require("moleculer-web");

// Create the broker for node-1
// Define nodeID and set the communication bus
const brokerNode1 = new ServiceBroker({
  nodeID: "node-1",
  transporter: "NATS"
});

// Create the "gateway" service
brokerNode1.createService({
  // Define service name
  name: "gateway",
  // Load the HTTP server
  mixins: [HTTPServer],

  settings: {
    routes: [
      {
        aliases: {
          // When the "GET /products" request is made the "listProducts" action of "products" service is executed
          "GET /products": "products.listProducts"
        }
      }
    ]
  }
});

// Create the broker for node-2
// Define nodeID and set the communication bus
const brokerNode2 = new ServiceBroker({
  nodeID: "node-2",
  transporter: "NATS"
});

// Create the "products" service
brokerNode2.createService({
  // Define service name
  name: "products",

  actions: {
    // Define service action that returns the available products
    listProducts(ctx) {
      return [
        { name: "Apples", price: 5 },
        { name: "Oranges", price: 3 },
        { name: "Bananas", price: 2 }
      ];
    }
  }
});

// Start both brokers
Promise.all([brokerNode1.start(), brokerNode2.start()]);
```
Now run `node index.js` in your terminal and open the link [`http://localhost:3000/products`](http://localhost:3000/products). You should get the following response:
```json
[
    { "name": "Apples", "price": 5 },
    { "name": "Oranges", "price": 3 },
    { "name": "Bananas", "price": 2 }
]
```

With just a couple dozen of lines of code we've created 2 isolated services capable to serve user's requests and list the products. Moreover, our services can be easily scaled to become resilient and fault-tolerant. Impressive, right?

Head out to the [Documentation](broker.html) section for more details or check the [Examples](examples.html) page for more complex examples.