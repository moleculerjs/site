title: Fundamental Concepts
---

This guide covers the core concepts of any Moleculer application.

## Service
A [service](services.html) it is a simple JavaScript module containing some part of a complex application. It is isolated and self-contained meaning that even it goes offline or crashes the remaining services would still work as usual. 

## Node
A node is a simple OS process running on a local or external network. A single instance of a node can hold one or more services.

### Local Services
Two (or more) services running on a single node are considered local services. They share hardware resources and the communication between them is in-memory ([transporter](networking.html) module is not used).

### Remote Services
Services distributed across multiple nodes are considered remote services. In this case, the communication between services is done via [transporter](networking.html) module.

## Service Broker
[Service Broker](broker.html) is the heart of Moleculer. It is responsible for management and communication between the services (local and remote). Each node must have an instance of Service Broker.

## Transporter
[Transporter](networking.html) is a communication bus that allows to exchange messages between services. It transfers events, requests and responses.

## Gateway
[API Gateway](moleculer-web.html) allows to expose Moleculer services to end-users. The gateway is a regular Moleculer service running a (HTTP, WebSockets, etc.) server.  It handles the incoming requests, maps them into service calls and then returns appropriate responses.

## Overall View
ToDo:
1. Describe the figure
2. Add the code that mimics the figure

### Architecture
<div align="center">
![Broker logical diagram](assets/overview.svg)
</div>

### The Code
```javascript
// Add code here
```