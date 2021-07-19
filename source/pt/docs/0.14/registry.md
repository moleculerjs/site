title: Registro & Descoberta
---

## Descoberta de serviço dinâmico
O framework Moleculer possui um módulo integrado responsável pela descoberta e verificação periódica de sinal de vida de cada nó. A descoberta é dinâmica significando que um nó não precisa saber nada sobre outros nós durante a inicialização. Quando ele inicia, ele vai anunciar sua presença a todos os outros nós para que cada um possa construir seu próprio registro de serviço local. Em caso de falha de um nó (ou parada) outros nós irão detectá-lo e remover os serviços afetados do seu registro. Desta forma, as próximas requisições serão encaminhados para nós ativos.

### Local
A Descoberta local (opção padrão) usa o [módulo de transporte](networking.html#Transporters) para trocar informações do nó e pacotes de sinal de vida (para mais informações sobre a estrutura dos pacotes, verifique o [protocolo Moleculer](https://github.com/moleculer-framework/protocol/blob/master/4.0/PROTOCOL.md)). É o mais simples e o mais rápido entre os mecanismos de descoberta disponíveis, pois não requer nenhuma solução externa. No entanto, este método de descoberta também tem alguns inconvenientes, especialmente para implantações de grande escala com mais de `100` nós. Os pacotes de sinal de vida podem gerar grande quantidade de tráfego que podem saturar o protocolo de comunicação e, portanto, deteriorar o desempenho de ações e eventos, por exemplo, lentidão na entrega de requisições/resposta e pacotes de eventos.


{% note warn%}
Observe que o módulo de transporte TCP usa o protocolo Gossip & pacotes UDP para descoberta & sinal de vida, o que significa que só pode funcionar como mecanismo local de descoberta.
{% endnote %}

**Descoberta local com opções padrão**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Local"
    }    
}
```

**Descoberta local com opções personalizadas**
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
![Experimental transporter](https://img.shields.io/badge/status-experimental-orange.svg) A descoberta baseada em Redis usa uma conexão dedicada com o [servidor Redis](https://redis.io/) para compartilhar descobertas e pacotes de sinal de vida. Esta abordagem reduz a carga sobre o módulo de transporte; e é usada exclusivamente para compartilhamento de requisições, respostas, pacotes de eventos.

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
