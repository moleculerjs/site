title: Clustering
---
Moleculer framework supports several software architectures.

## Monolith architecture
In this version, all services are running on the same node like a monolith. There is no network latency and no transporter module. _The local calls are the fastest._

![Monolith architecture](/images/monolith-architecture.png)

## Microservices architecture
This is the well-known microservices architecture when all services are running on individual nodes and communicates via transporter. In this case, the network latency is not negligible. But you can scale your services to be resilient and fault-tolerant.

![Microservices architecture](/images/microservices-architecture.png)

## Mixed architecture
In this case, we are running coherent services in a group on the same node. It combines the advantages of monolith and microservices architectures.
For example, if the `posts` service calls the `users` service multiple times, we put them to the same node, so that we can cut down the network latency between these services. If the node is overloaded, we will scale it up.

![Mixed architecture](/images/mixed-architecture.png)

{% note info Tip %}
The ServiceBroker first tries to call the local instances of service (if exists) to reduce network latencies. You can turn off this logic in [broker options](broker.html#Broker-options) with `preferLocal: false` under the `registry` key.
{% endnote %}

## How choose
Don't you choose between monolith and microservices? Would you choose monolith because easy to develop? Would you choose microservice because reliable and easy to scale?
Choose both. With Moleculer it is available. When you develop your services, load all services in one node. Easy to debug and test. When your are ready, separate services to multiple nodes. No need to change service codes. Just select a transporter and load one service per node. Your app is running in microservices architecture.