title: Registry & Discovery
---

## Dynamic service discovery
The Moleculer framework has a built-in service discovery feature. But you don't need to use any central service discovery tool (like Zookeeper, Consul, etcd) because it is integrated into the Moleculer protocol. 
This solution is a dynamic discovery. It means that the nodes don't need to know all other nodes at starting. When a brand new node starts, it will send informations of all local services to all other nodes so that every node can build an own local service registry. When a node stops or crashed, the other nodes will detect it and clean its services from the registry. So they can always route the requests to the live nodes in order to reduce the count of failed requests due to the not available nodes.

**TODO: diagram, which shows node's local registry, when a new node coming & leaving.**

## Built-in Service Registry
The Moleculer has a built-in service registry module. It stores all information about services, actions, event listeners and nodes. When you call a service or emit an event, broker asks the registry to look up a node which executes the request. If there are multiple nodes which can serve the request, it uses load-balancing strategy to select the next node.

> Read more about [load-balacing & strategies](balancing.html).

> You can access the registry data via [internal service](services.html#Internal-services).
