title: Registry & Discovery
---

## Dynamic service discovery
Within the Moleculer framework, a dedicated module handles node discovery and performs periodic heartbeat verification. This discovery mechanism operates dynamically, eliminating the need for nodes to possess prior knowledge of one another during startup. Upon initialization, each node broadcasts its presence to all others, enabling each node to construct its own local service registry.

In the event of a node crash or shutdown, neighboring nodes will detect detect the absence and consequently update their respective registries by removing the affected services. This dynamic behavior ensures that subsequent requests are only routed to live, operational nodes, thereby maintaining system resilience and continuity of service.

### Local
Local discovery (default option) uses the [transporter](networking.html#Transporters) module to exchange node info and heartbeat packets (for more info about packet structure check [Moleculer protocol](https://github.com/moleculer-framework/protocol/blob/master/4.0/PROTOCOL.md)). It's the simplest and the fastest among the available discovery mechanisms as it doesn't require any external solutions. However, this discovery method also has some drawbacks, especially for large scale deployments with `>100` nodes. The heartbeat packets can generate large amount traffic that can saturate the communication bus and, therefore, deteriorate the performance of actions and events, i.e., slow down the delivery of request/response and event packets.


{% note warn%}
Please note the TCP transporter uses Gossip protocol & UDP packets for discovery & heartbeats, it means it can work only with local discovery mechanism.
{% endnote %}

**Local Discovery with default options**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Local"
    }    
}
```

**Local Discovery with custom options**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: {
            type: "Local",
            options: {
                // Send heartbeat in every 10 seconds
                heartbeatInterval: 10,

                // Heartbeat timeout in seconds
                heartbeatTimeout: 30,

                // Disable heartbeat checking & sending, if true
                disableHeartbeatChecks: false,

                // Disable removing offline nodes from registry, if true
                disableOfflineNodeRemoving: false,

                // Remove offline nodes after 10 minutes
                cleanOfflineNodesTimeout: 10 * 60
            }
        }
    }    
}
```

### Redis
![Experimental transporter](https://img.shields.io/badge/status-experimental-orange.svg)
Redis-based discovery uses a dedicated connection with the [Redis server](https://redis.io/) to exchange discovery and heartbeat packets. This approach reduces the load over the transporter module, it's used exclusively for the exchange of the request, response, event packets.

When Redis-based discovery method is enabled, Moleculer nodes periodically publish and fetch the info from Redis and update their internal service registry. Redis key expiration mechanism removes nodes that don't publish heartbeat packets for a certain period of time. This allows Moleculer nodes to detect that a specific node has disconnected.

Please note that this method is slower to detect new nodes as it relies on periodic heartbeat checks at Redis server. The periodicity depends on the `heartbeatInterval` broker option.

{% note info%}
To use Redis discovery install the `ioredis` module with the `npm install ioredis --save` command.
{% endnote %}

**Example of connection to a local Redis server**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Redis"
    }    
}
```


**Example of connection to a remote Redis server**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "redis://redis-server:6379"
    }    
}
```

**Example with options**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: {
            type: "Redis",
            options: {
                redis: {
                    // Redis connection options.
                    // More info: https://github.com/luin/ioredis#connect-to-redis
                    port: 6379,
                    host: "redis-server",
                    password: "123456",
                    db: 3
                }

                // Serializer
                serializer: "JSON",

                // Full heartbeat checks. It generates more network traffic
                // 10 means every 10 cycle.
                fullCheck: 10,

                // Key scanning size
                scanLength: 100,

                // Monitoring Redis commands
                monitor: true,
                
                // --- COMMON DISCOVERER OPTIONS ---

                // Send heartbeat in every 10 seconds
                heartbeatInterval: 10,

                // Heartbeat timeout in seconds
                heartbeatTimeout: 30,

                // Disable heartbeat checking & sending, if true
                disableHeartbeatChecks: false,

                // Disable removing offline nodes from registry, if true
                disableOfflineNodeRemoving: false,

                // Remove offline nodes after 10 minutes
                cleanOfflineNodesTimeout: 10 * 60
            }
        }
    }    
}
```

{% note info%}
Tip: To further reduce network traffic use [MsgPack/Notepack serializers](networking.html#MsgPack-serializer) instead of JSON.
{% endnote %}

### etcd3
![Experimental transporter](https://img.shields.io/badge/status-experimental-orange.svg)

Etcd3-based discovery method is very similar to [Redis-based discovery](#Redis). It stores heartbeat and discovery packets at [etcd3 server](https://etcd.io/). etcd3's [lease](https://etcd.io/docs/v3.4.0/learning/api/#lease-api) option will remove heartbeat info of nodes that have crashed or disconnected from the network.

This method has the same strengths and weaknesses of Redis-based discovery. It doesn't use the transporter module for the discovery but it's also slower to detect new or disconnected nodes.

{% note info%}
To use etcd3 discovery install the `etcd3` module with the `npm install etcd3 --save` command.
{% endnote %}

**Example to connect local etcd3 server**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Etcd3"
    }    
}
```

**Example to connect remote etcd3 server**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "etcd3://etcd-server:2379"
    }    
}
```

**Example with options**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: {
            type: "Etcd3",
            options: {
                etcd: {
                    // etcd3 connection options.
                    // More info: https://mixer.github.io/etcd3/interfaces/options_.ioptions.html
                    hosts: "etcd-server:2379",
                    auth: "12345678"
                }

                // Serializer
                serializer: "JSON",

                // Full heartbeat checks. It generates more network traffic
                // 10 means every 10 cycle.
                fullCheck: 10,
                
                // --- COMMON DISCOVERER OPTIONS ---

                // Send heartbeat in every 10 seconds
                heartbeatInterval: 10,

                // Heartbeat timeout in seconds
                heartbeatTimeout: 30,

                // Disable heartbeat checking & sending, if true
                disableHeartbeatChecks: false,

                // Disable removing offline nodes from registry, if true
                disableOfflineNodeRemoving: false,

                // Remove offline nodes after 10 minutes
                cleanOfflineNodesTimeout: 10 * 60
            }
        }
    }    
}
```

{% note info%}
Tip: To further reduce network traffic use [MsgPack/Notepack serializers](networking.html#MsgPack-serializer) instead of JSON.
{% endnote %}

### Customization
You can create your custom discovery mechanism. We recommend to copy the source of Redis Discoverer and implement the necessary methods.

<!-- **TODO: diagram, which shows node's local registry, when a new node coming & leaving.** -->

## Built-in Service Registry
Moleculer has a built-in service registry module. It stores all information about services, actions, event listeners and nodes. When you call a service or emit an event, broker asks the registry to look up a node which is able to execute the request. If there are multiple nodes, it uses load-balancing strategy to select the next node.

> Read more about [load-balancing & strategies](balancing.html).

> Registry data is available via [internal service](services.html#Internal-Services).
