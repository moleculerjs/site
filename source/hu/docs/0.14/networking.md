title: Networking
---
In order to communicate with other nodes (ServiceBrokers) you need to configure a transporter. Most of the supported transporters connect to a central message broker that provide a reliable way of exchanging messages among remote nodes. These message brokers mainly support publish/subscribe messaging pattern.

<div align="center">
    <img src="assets/networking.svg" alt="Networking diagram" />
</div>

## Transporter-ek
Transporter is an important module if you are running services on multiple nodes. Transporter communicates with other nodes. It transfers events, calls requests and processes responses ...etc. If multiple instances of a service are running on different nodes then the requests will be load-balanced among them.

The whole communication logic is outside of transporter class. It means that you can switch between transporters without changing any line of code.

There are several built-in transporters in Moleculer framework.

### TCP transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) This is a no-dependency, zero-configuration TCP transporter. It uses [Gossip protocol](https://en.wikipedia.org/wiki/Gossip_protocol) to disseminate node statuses, service list and heartbeats. It contains an integrated UDP discovery feature to detect new and disconnected nodes on the network. If the UDP is prohibited on your network, use `urls` option. It is a list of remote endpoints (host/ip, port, nodeID). It can be a static list in your configuration or a file path which contains the list.

**Use TCP transporter with default options**
```js
// moleculer.config.js
module.exports = {
    transporter: "TCP"
};
```

**All TCP transporter options with default values**
```js
// moleculer.config.js
module.exports = {
    logger: true,
    transporter: {
        type: "TCP",
        options: {
            // Enable UDP discovery
            udpDiscovery: true,
            // Reusing UDP server socket
            udpReuseAddr: true,

            // UDP port
            udpPort: 4445,
            // UDP bind address (if null, bind on all interfaces)
            udpBindAddress: null,
            // UDP sending period (seconds)
            udpPeriod: 30,

            // Multicast address.
            udpMulticast: "239.0.0.0",
            // Multicast TTL setting
            udpMulticastTTL: 1,

            // Send broadcast (Boolean, String, Array<String>)
            udpBroadcast: false,

            // TCP server port. Null or 0 means random port
            port: null,
            // Static remote nodes address list (when UDP discovery is not available)
            urls: null,
            // Use hostname as preffered connection address
            useHostname: true,

            // Gossip sending period in seconds
            gossipPeriod: 2,
            // Maximum enabled outgoing connections. If reach, close the old connections
            maxConnections: 32,
            // Maximum TCP packet size
            maxPacketSize: 1 * 1024 * 1024            
        }
    }
};
```

**TCP transporter with static endpoint list**
```js
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    logger: true,
    transporter: {
        type: "TCP",
        options: {
            udpDiscovery: false,
            urls: [
                "172.17.0.1:6000/node-1",
                "172.17.0.2:6000/node-2",
                "172.17.0.3:6000/node-3"                
            ],
        }
    }
};
```
_You don't need to set `port` because it find & parse the self TCP port from URL list._

**TCP transporter with shorthand static endpoint list** It needs to start with `tcp://`.
```js
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    transporter: "tcp://172.17.0.1:6000/node-1,172.17.0.2:6000/node-2,172.17.0.3:6000/node-3"
};
```

**TCP transporter with static endpoint list file**
```js
// moleculer.config.js
module.exports = {
    nodeID: "node-1",
    transporter: "file://./nodes.json"
};
```

```js
// nodes.json
[
    "127.0.0.1:6001/client-1",
    "127.0.0.1:7001/server-1",
    "127.0.0.1:7002/server-2"
]
```

{% note info Serviceless node %}
Please note, you don't need to list all remote nodes. It's enough at least one node which is online. For example, create a "serviceless" gossiper node, which does nothing, just shares other remote nodes addresses by gossip messages. So all nodes must know only the gossiper node address to be able to communicate with all other nodes.
{% endnote %}

### NATS Transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) Built-in transporter for [NATS](http://nats.io/).
> NATS Server is a simple, high performance open source messaging system for cloud-native applications, IoT messaging, and microservices architectures.

```js
// moleculer.config.js
module.exports = {
    nodeID: "server-1",
    transporter: "nats://nats.server:4222"
};
```

{% note info Dependencies %}
To use this transporter install the `nats` module with `npm install nats@1.4.12 --save` command.
{% endnote %}

{% note warn NATS v2.0 %}
Please note that [nats `v2.x`](https://github.com/nats-io/nats.js/blob/HEAD/migration.md), a complete re-write of nats client, is not yet supported.
{% endnote %}

#### Példák
**Connect to 'nats://localhost:4222'**
```js
// moleculer.config.js
module.exports = {
    transporter: "NATS"
};
```

**Connect to a remote NATS server**
```js
// moleculer.config.js
module.exports = {
    transporter: "nats://nats-server:4222"
};
```

**Connect with options**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "NATS",
        options: {
            url: "nats://localhost:4222"
            user: "admin",
            pass: "1234"
        }
    }
};
```

**Connect with TLS**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "NATS",
        options: {
            url: "nats://localhost:4222"
            // More info: https://github.com/nats-io/node-nats#tls
            tls: {
                key: fs.readFileSync('./client-key.pem'),
                cert: fs.readFileSync('./client-cert.pem'),
                ca: [ fs.readFileSync('./ca.pem') ]
            }
        }
    }
};
```

### Redis Transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) Built-in transporter for [Redis](http://redis.io/).

```js
// moleculer.config.js
module.exports = {
    nodeID: "server-1",
    transporter: "redis://redis.server:6379"
};
```
{% note info Dependencies %}
To use this transporter install the `ioredis` module with `npm install ioredis --save` command.
{% endnote %}

#### Példák
**Connect with default settings**
```js
// moleculer.config.js
module.exports = {
    transporter: "Redis"
};
```

**Connect with connection string**
```js
// moleculer.config.js
module.exports = {
    transporter: "redis://localhost:6379"
};
```

**Connect to a secure Redis server**
```js
// moleculer.config.js
module.exports = {
    transporter: "rediss://localhost:6379"
};
```

**Connect with options**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "Redis",
        options: {
            host: "redis-server",
            db: 0
        }
    }
};
```

**Connect to Redis cluster**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "Redis",
        options: {
            cluster: {
                nodes: [
                    { host: "localhost", port: 6379 },
                    { host: "localhost", port: 6378 }
                ]
            }
        }
    }
};
```

### MQTT Transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) Built-in transporter for [MQTT](http://mqtt.org/) protocol *(e.g.: [Mosquitto](https://mosquitto.org/))*.

```js
// moleculer.config.js
module.exports = {
    nodeID: "server-1",
    transporter: "mqtt://mqtt-server:1883"
};
```
{% note info Dependencies %}
To use this transporter install the `mqtt` module with `npm install mqtt --save` command.
{% endnote %}

#### Példák
**Connect with default settings**
```js
// moleculer.config.js
module.exports = {
    transporter: "MQTT"
};
```

**Connect with connection string**
```js
// moleculer.config.js
module.exports = {
    transporter: "mqtt://mqtt-server:1883"
};
```

**Connect to secure MQTT server**
```js
// moleculer.config.js
module.exports = {
    transporter: "mqtts://mqtt-server:1883"
};
```

**Connect with options**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "MQTT",
        options: {
            host: "mqtt-server",
            port: 1883,
            qos: 0,
            topicSeparator: "."
        }
    }
};
```

### AMQP (0.9) Transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) Built-in transporter for [AMQP](https://www.amqp.org/) 0.9 protocol *(e.g.: [RabbitMQ](https://www.rabbitmq.com/))*.

```js
// moleculer.config.js
module.exports = {
    nodeID: "server-1",
    transporter: "amqp://rabbitmq-server:5672"
};
```
{% note info Dependencies %}
To use this transporter install the `amqplib` module with `npm install amqplib --save` command.
{% endnote %}

#### Transporter options
Options can be passed to `amqp.connect()` method.

**Connect to 'amqp://guest:guest@localhost:5672'**
```js
// moleculer.config.js
module.exports = {
    transporter: "AMQP"
});
```

**Connect to a remote server**
```js
// moleculer.config.js
module.exports = {
    transporter: "amqp://rabbitmq-server:5672"
});
```

**Connect to a secure server**
```js
// moleculer.config.js
module.exports = {
    transporter: "amqps://rabbitmq-server:5672"
});
```

**Connect to a remote server with options & credentials**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "AMQP",
        options: {
            url: "amqp://user:pass@rabbitmq-server:5672",
            eventTimeToLive: 5000,
            prefetch: 1,
            socketOptions: {
                servername: process.env.RABBIT_SERVER_NAME
            }
            // If true, queues will be autodeleted once service is stopped, i.e., queue listener is removed
            autoDeleteQueues: true
        }
    }
};
```

### AMQP 1.0 Transporter
![Experimental transporter](https://img.shields.io/badge/status-experimental-orange.svg) Built-in transporter for [AMQP 1.0](https://www.amqp.org/resources/specifications) protocol *(e.g.: [ActiveMq](https://activemq.apache.org/) or [RabbitMQ](https://www.rabbitmq.com/) + [rabbitmq-amqp1.0 plugin](https://github.com/rabbitmq/rabbitmq-amqp1.0))*.
> Please note, it is an **experimental** transporter. **Do not use it in production yet!**

```js
// moleculer.config.js
module.exports = {
    transporter: "amqp10://activemq-server:5672"
};
```
{% note info Dependencies %}
To use this transporter install the `rhea-promise` module with `npm install rhea-promise --save` command.
{% endnote %}

#### Transporter options
Options can be passed to `rhea.connection.open()` method, the topics, the queues, and the messages themselves.

**Connect to 'amqp10://guest:guest@localhost:5672'**
```js
// moleculer.config.js
module.exports = {
    transporter: "AMQP10"
};
```

**Connect to a remote server**
```js
// moleculer.config.js
module.exports = {
    transporter: "amqp10://activemq-server:5672"
};
```

**Connect to a remote server with options & credentials**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        url: "amqp10://user:pass@activemq-server:5672",
        eventTimeToLive: 5000,
        heartbeatTimeToLive: 5000,
        connectionOptions: { // rhea connection options https://github.com/amqp/rhea#connectoptions, example:
            ca: "", // (if using tls)
            servername: "", // (if using tls)
            key: "", // (if using tls with client auth)
            cert: "" // (if using tls with client auth)
        },
        queueOptions: {}, // rhea queue options https://github.com/amqp/rhea#open_receiveraddressoptions
        topicOptions: {}, // rhea queue options https://github.com/amqp/rhea#open_receiveraddressoptions
        messageOptions: {}, // rhea message specific options https://github.com/amqp/rhea#message
        topicPrefix: "topic://", // RabbitMq uses '/topic/' instead, 'topic://' is more common
        prefetch: 1
    }
};
```

### Kafka Transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) Built-in transporter for [Kafka](https://kafka.apache.org/).
> It is a simple implementation. It transfers Moleculer packets to consumers via pub/sub. There are not implemented offset, replay...etc features.

{% note info Dependencies %}
To use this transporter install the `kafka-node` module with `npm install kafka-node --save` command.
{% endnote %}

**Connect to Zookeeper**
```js
// moleculer.config.js
module.exports = {
    transporter: "kafka://192.168.51.29:2181"
};
```

**Connect to Zookeeper with custom options**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "kafka",
        options: {
            host: "192.168.51.29:2181",

            // KafkaClient options. More info: https://github.com/SOHU-Co/kafka-node#clientconnectionstring-clientid-zkoptions-noackbatchoptions-ssloptions
            client: {
                zkOptions: undefined,
                noAckBatchOptions: undefined,
                sslOptions: undefined
            },

            // KafkaProducer options. More info: https://github.com/SOHU-Co/kafka-node#producerclient-options-custompartitioner
            producer: {},
            customPartitioner: undefined,

            // ConsumerGroup options. More info: https://github.com/SOHU-Co/kafka-node#consumergroupoptions-topics
            consumer: {
            },

            // Advanced options for `send`. More info: https://github.com/SOHU-Co/kafka-node#sendpayloads-cb
            publish: {
                partition: 0,
                attributes: 0
            }               
        }
    }
};
```

### NATS Streaming (STAN) Transporter
![Stable transporter](https://img.shields.io/badge/status-stable-green.svg) Built-in transporter for [NATS Streaming](https://nats.io/documentation/streaming/nats-streaming-intro/).
> It is a simple implementation. It transfers Moleculer packets to consumers via pub/sub. There are not implemented offset, replay...etc features.


```js
// moleculer.config.js
module.exports = {
    nodeID: "server-1",
    transporter: "stan://nats-streaming-server:4222"
};
```

{% note info Dependencies %}
To use this transporter install the `node-nats-streaming` module with `npm install node-nats-streaming --save` command.
{% endnote %}

#### Példák
**Connect with default settings**
```js
// moleculer.config.js
module.exports = {
    transporter: "STAN"
};
```

**Connect with connection string**
```js
// moleculer.config.js
module.exports = {
    transporter: "stan://nats-streaming-server:4222"
};
```

**Connect with options**
```js
// moleculer.config.js
module.exports = {
    transporter: {
        type: "STAN",
        options: {
            url: "stan://127.0.0.1:4222",
            clusterID: "my-cluster"
        }
    }
};
```

### Custom transporter
Custom transporter module can be created. We recommend to copy the source of [NatsTransporter](https://github.com/moleculerjs/moleculer/blob/master/src/transporters/nats.js) and implement the `connect`, `disconnect`, `subscribe` and `send` methods.

#### Create custom transporter
```js
const BaseTransporter = require("moleculer").Transporters.Base;

class MyTransporter extends BaseTransporter {
    connect() { /*...*/ }
    disconnect() { /*...*/ }
    subscribe() { /*...*/ }
    send() { /*...*/ }
}
```

#### Use custom transporter

```js
// moleculer.config.js
const MyTransporter = require("./my-transporter");

module.exports = {
    transporter: new MyTransporter()
};
```

## Disabled balancer
Some transporter servers have built-in balancer solution. E.g.: RabbitMQ, NATS, NATS-Streaming. If you want to use the transporter balancer instead of Moleculer balancer, set the `disableBalancer` broker option to `true`.

**Example**
```js
// moleculer.config.js
module.exports = {
    disableBalancer: true,
    transporter: "nats://some-server:4222"
};
```

{% note info Please note %}
If you disable the built-in Moleculer balancer, all requests & events will be transferred via transporter (including local requests). E.g. you have a local math service and you call `math.add` locally, the request will be sent via transporter.
{% endnote %}

## Serialization
Transporter needs a serializer module which serializes & deserializes the transferred packets. The default serializer is the `JSONSerializer` but there are several built-in serializer.

**Example**
```js
// moleculer.config.js
module.exports = {
    nodeID: "server-1",
    transporter: "NATS",
    serializer: "ProtoBuf"
};
```

### JSON serializer
This is the default serializer. It serializes the packets to JSON string and deserializes the received data to packet.

```js
// moleculer.config.js
module.exports = {
    serializer: "JSON" // not necessary to set, because it is the default
};
```

### Avro serializer
Built-in [Avro](https://github.com/mtth/avsc) serializer.

```js
// moleculer.config.js
module.exports = {
    serializer: "Avro"
};
```
{% note info Dependencies %}
To use this serializer install the `avsc` module with `npm install avsc --save` command.
{% endnote %}

### MsgPack serializer
Built-in [MsgPack](https://github.com/mcollina/msgpack5) serializer.

```js
// moleculer.config.js
module.exports = {
    serializer: "MsgPack"
};
```
{% note info Dependencies %}
To use this serializer install the `msgpack5` module with `npm install msgpack5 --save` command.
{% endnote %}

### Notepack serializer
Built-in [Notepack](https://github.com/darrachequesne/notepack) serializer.

```js
// moleculer.config.js
module.exports = {
    serializer: "Notepack"
};
```
{% note info Dependencies %}
To use this serializer install the `notepack` module with `npm install notepack.io --save` command.
{% endnote %}

### ProtoBuf serializer
Built-in [Protocol Buffer](https://developers.google.com/protocol-buffers/) serializer.

```js
// moleculer.config.js
module.exports = {
    serializer: "ProtoBuf"
};
```
{% note info Dependencies %}
To use this serializer install the `protobufjs` module with `npm install protobufjs --save` command.
{% endnote %}

### Thrift serializer
Built-in [Thrift](http://thrift.apache.org/) serializer.

```js
// moleculer.config.js
module.exports = {
    serializer: "Thrift"
};
```
{% note info Dependencies %}
To use this serializer install the `thrift` module with `npm install thrift --save` command.
{% endnote %}

### Custom serializer
Custom serializer module can be created. We recommend to copy the source of [JSONSerializer](https://github.com/moleculerjs/moleculer/blob/master/src/serializers/json.js) and implement the `serialize` and `deserialize` methods.

#### Create custom serializer
```js
const BaseSerializer = require("moleculer").Serializers.Base;

class MySerializer extends BaseSerializer {
    serialize(obj, type) { /*...*/ }
    deserialize(buf, type) { /*...*/ }
}
```

#### Use custom serializer

```js
// moleculer.config.js
const MySerializer = require("./my-serializer");

module.exports = {
    serializer: new MySerializer()
};
```
