title: Nodes
---
Moleculer supports several architectures.

## Monolith architecture
In this version you are running every services on one node with one broker. In this case every service can call other services locally. So there is no network latency and no transporter. The local call is the fastest.

![Monolith architecture](/images/monolith-architecture.png)

## Microservices architecture
This is the well-known microservices architecture when every service running on individual nodes and communicates others via transporter.

![Microservices architecture](/images/microservices-architecture.png)

## Mixed architecture
In this case we are running coherent services on the same node. It is combine the advantages of monolith and microservices architectures.
For example, if the `posts` service calls a lot of times the `users` service, we put them together, that we cut down the network latency between services. If this node is overloaded, we will add replicas.

![Mixed architecture](/images/mixed-architecture.png)
