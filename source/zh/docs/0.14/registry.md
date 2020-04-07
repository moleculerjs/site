title: Registry & Discovery
---

## Dynamic service discovery
Moleculer framework has a built-in service discovery feature meaning that you don't need to use any external service discovery tool (like Zookeeper, Consul, etcd) as it is already integrated into the [Moleculer protocol](https://github.com/moleculer-framework/protocol/blob/master/4.0/PROTOCOL.md). Moleculer implement dynamic discovery meaning that the nodes don't need to know all other nodes at start. When a new node starts, it will send information to all local services and to all other nodes so that every node can build its own local service registry. In case of a node crash (or stop) other nodes will detect it and remove the affected services from their registry. This way the following requests will be routed to live nodes.


<!-- **TODO: diagram, which shows node's local registry, when a new node coming & leaving.** -->

## Built-in Service Registry
Moleculer has a built-in service registry module. It stores all information about services, actions, event listeners and nodes. When you call a service or emit an event, broker asks the registry to look up a node which is able to execute the request. If there are multiple nodes, it uses load-balancing strategy to select the next node.

> Read more about [load-balancing & strategies](balancing.html).

> Registry data is available via [internal service](services.html#Internal-Services).
