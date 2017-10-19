title: Nodes
---
Moleculer supports several architectures.

## Monolith architecture
In this version every services are running on the same node. So there is no network latency and no transporter module. _The local call is the fastest._

![Monolith architecture](/images/monolith-architecture.png)

## Microservices architecture
This is the well-known microservices architecture when every services are running on an individual nodes and communicates via transporter. In this case the network latency is not negligible. But you can scale your services to avoid faults.

![Microservices architecture](/images/microservices-architecture.png)

## Mixed architecture
In this case we are running coherent services in a group on the same node. It combines the advantages of monolith and microservices architectures.
For example, if the `posts` service calls the `users` service multiple times, we put them together,so that we can cut down the network latency between those services. If this node is overloaded, we will scale it up together. 

![Mixed architecture](/images/mixed-architecture.png)

{% note info Tip %}
The ServiceBroker first tries to call the local instances of service (if exists) to reduce network latencies. You can turn off this logic in [broker options](broker.html#Constructor-options) with `preferLocal: false` under the `serviceRegistry` key.
{% endnote %}
