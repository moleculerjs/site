title: Fundamental Concepts
---

This guide covers the core concepts of any Moleculer application.

## Service
A [service](services.html) is a simple JavaScript module containing some part of a complex application. It is isolated and self-contained, meaning that even if it goes offline or crashes the remaining services would be unaffected.

## Node
A node is a simple OS process running on a local or external network. A single instance of a node can hold one or more services.

### Local Services
Two (or more) services running on a single node are considered local services. They share hardware resources and the communication between them is in-memory ([transporter](#Transporter) module is not used).

### Remote Services
Services distributed across multiple nodes are considered remote services. In this case, the communication is done via the [transporter](#Transporter) module.

## Service Broker
[Service Broker](broker.html) is the heart of Moleculer. It is responsible for management and communication between the services (local and remote). Each node must have an instance of Service Broker.

## Transporter
[Transporter](networking.html) is a communication bus that allows to exchange messages between services. It transfers events, requests and responses.

## Gateway
[API Gateway](moleculer-web.html) allows to expose Moleculer services to end-users. The gateway is a regular Moleculer service running a (HTTP, WebSockets, etc.) server.  It handles the incoming requests, maps them into service calls, and then returns appropriate responses.

## Overall View
There is nothing better than an example to see how all these concepts fit together. So let's consider a hypothetical online store that only lists its products. It doesn't actually sell anything online.

### Architecture

From the architectural point-of-view the online store can be seen as a composition of 2 independent services: the `product` service and the `gateway` service. The first one would be responsible for management of the products and the second one would simply receive user´s requests and convey them to the `products` service.

Now let's take a look at how can this online store be created with Moleculer.

To ensure that our system is resilient to failures we will run the `product` and the `gateway` services in dedicated [nodes](#Node) (`node 1` and `node 2`). If you recall, running services at dedicated nodes means that the [transporter](#Transporter) module is required for inter services communication. So we're also going to need a message broker. The message broker is a communication bus whose sole responsibility is message delivery. Overall, the implemented architecture is represented in the figure below.

Now, assuming that our services are up and running, the online store can serve user's requests. So let's see what actually happens with user's request to list all available products. First, the user's request (`GET /products`) is received by the HTTP server running at `node 1`. The incoming request is simply passed from the HTTP server to the [gateway](#Gateway) service that does all the processing and mapping. In this case in particular, the user´s request is mapped into a `listProducts` action of the `product` service.  Next, the request is passed to the [broker](#Service-Broker), which checks whether the `product` service is a [local](#Local-Services) or a [remote](#Remote-Services) service. In this case, the `product` service is remote so the broker needs to use the [transporter](#Transporter) module to deliver the request. The transporter simply grabs the request and sends it through the communication bus. Since both nodes (`node 1` and `node 2`) are connected to the same communication bus (message broker), the request is successfully delivered to the `node 2`. Upon reception, the broker of `node 2` will parse the incoming request and forward it to the `product` service. Finally, the `product` service invokes the `listProducts` action and returns the list of all available products. The response is simply forwarded back to the end-user.

**Data flow of user's request**
<div align="center">
![Broker logical diagram](assets/overview.svg)
</div>

All the details that we've just seen might seem scary and complicated but don't be afraid. Moleculer does all the heavy lifting for you! You (the developer) only need to focus on the application logic. Take a [look](#The-Code) at actual implementation of our online store.

### The Code 
Pretty simple, isn't?
```javascript
// Add code here
```

Check the [Examples](examples.html) page for more complex examples.