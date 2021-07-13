title: Cluster
---
O framework Moleculer suporta várias arquiteturas de software.

## Arquitetura Monolítica
Nesta versão, todos os serviços estão rodando no mesmo nó como um monolítico. Não há latência de rede e não há módulo de transporte. _As chamadas locais são as mais rápidas._

![Monolith architecture](assets/architectures/monolith.svg)

## Arquitetura de microsserviços
Esta é a bem conhecida arquitetura dos microsserviços quando todos os serviços funcionam em nós individuais e se comunicam através do módulo de transporte. Neste caso, a latência de rede não é insignificante. No entanto, os seus serviços podem ser escalados de forma resiliente e com tolerância a falhas.

![Microservices architecture](assets/architectures/microservices.svg)

## Arquitetura mista
Neste caso, estamos executando serviços relacionados agrupados no mesmo nó. Isto combina as vantagens das arquiteturas monolíticas e de microsserviços. For example, if the `posts` service calls the `users` service multiple times, put them to the same node, so that the network latency between these services is cut down. If the node is overloaded, just scale it up.

![Mixed architecture](assets/architectures/mixed.svg)

{% note info Tip %}
The ServiceBroker first tries to call the local instances of service (if exists) to reduce network latencies. This logic can be turned off in [broker options](configuration.html#Broker-options) with `preferLocal: false` property under the `registry` key.
{% endnote %}

## How choose
Do you choose between monolith and microservices when developing your application? Do you choose monolith approach because its easy to develop? Do you prefer microservices architecture because it is reliable and highly scalable? With Moleculer you don't have to choose. You can have the best of both approaches. During the development of your application load all services is single node. This way you can quickly debug and test of your application logic. When ready, simply distribute your services across multiple nodes. Don't worry, you don't have to change a single line of code in your services. Just select a transporter, load one service per node and you're done. Your application is running in microservices architecture.