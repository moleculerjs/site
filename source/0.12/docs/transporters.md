title: Transporters
---
Transporter is an important module if you are running services on multiple nodes. Transporter communicates with other nodes. It transfers events, calls requests, processes responses ...etc. If a service runs on multiple instances on different nodes, the requests are load-balanced between nodes.

## Built-in transporters

### TCP transporter
There is new built-in zero-config TCP transporter. It uses [Gossip protocol](https://en.wikipedia.org/wiki/Gossip_protocol) to disseminate node info, service list and heartbeats. It has an integrated UDP discovery to detect new nodes on the network. It broadcasts discovery messages
If the UDP is prohibited on your network, you can use `urls` option. It is a list of remote endpoints (host/ip, port, nodeID). It can be a static list in your configuration or a file path which contains the list.

>Please note, you don't need to list all remote nodes. It's enough at least one node which is online. For example, you can create a "serviceless" gossiper node, which does nothing, just shares other remote nodes addresses by gossip messages. So all nodes need to know only the gossiper node address to be able to communicate with all other nodes.

<!-- **This TCP transporter is the default transporter in Moleculer**.
It means, you don't have to configure any transporter, just start the brokers/nodes, use same namespaces and the nodes will find each others.
>If you don't want to use transporter, set `transporter: null` in broker options.
-->

**Use TCP transporter with default options**
```js
let broker = new ServiceBroker({
    transporter: "TCP"
});
```

**All TCP transporter options with default values**
```js
let broker = new ServiceBroker({
    logger: true,
    transporter: {
        type: "TCP",
        options: {
            // Enable UDP discovery
            udpDiscovery: true,
            // Reusing UDP server socket
            udpReuseAddr: true,

            // Address for broadcast messages
            broadcastAddress: "255.255.255.255",
            // Broadcast port
            broadcastPort: 4445,
            // Broadcast sending period
            broadcastPeriod: 5,

            // Multicast address. If null it is not used.
            multicastAddress: null,
            // Multicast TTL setting
            multicastTTL: 1,

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
});
```

### NATS Transporter
Built-in transporter for [NATS](http://nats.io/).
> NATS Server is a simple, high performance open source messaging system for cloud-native applications, IoT messaging, and microservices architectures.

```js
let { ServiceBroker } = require("moleculer");
let NatsTransporter = require("moleculer").Transporters.NATS;

let broker = new ServiceBroker({
    nodeID: "server-1",
    transporter: new NatsTransporter(),
    requestTimeout: 5 * 1000
});
```

{% note info Dependencies %}
To use this transporter install the `nats` module with `npm install nats --save` command.
{% endnote %}

#### Transporter options
You can pass options to `nats.connect()` method.

```js
// Connect to 'nats://localhost:4222'
new NatsTransporter();

// Connect to a remote server
new NatsTransporter("nats://nats.server:4222");

// Connect to a remote server
new NatsTransporter({
    url: "nats://nats-server:4222",
});

// Connect to a remote server with credentials
new NatsTransporter({
    url: "nats://nats-server:4222",
    user: "admin",
    pass: "1234"
});
```

#### Shorthands
You can also set transporter with shorthands. With them, you can configure transporter in configuration files. No need to create an instance of transporter. Use this form, if you are running your services with [Moleculer Runner](runner.html).
```js
// Shorthand with default settings
let broker = new ServiceBroker({
    transporter: "NATS"
});

// Shorthand with connection string
let broker = new ServiceBroker({
    transporter: "nats://localhost:4222"
});

// Shorthand with options
let broker = new ServiceBroker({
    transporter: {
        type: "NATS",
        options: {
            url: "nats://localhost:4222"
            user: "admin",
            pass: "1234"
        }
});

// Shorthand with TLS
let broker = new ServiceBroker({
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
});
```

### Redis Transporter
Built-in transporter for [Redis](http://redis.io/).

```js
let { ServiceBroker } = require("moleculer");
let RedisTransporter = require("moleculer").Transporters.Redis;

let broker = new ServiceBroker({
    nodeID: "server-1",
    transporter: new RedisTransporter(),
    requestTimeout: 5 * 1000
});
```
{% note info Dependencies %}
To use this transporter install the `ioredis` module with `npm install ioredis --save` command.
{% endnote %}

#### Transporter options
You can pass options to `new Redis()` method.

```js
// Connect to 'redis://localhost:6379'
new RedisTransporter();

// Connect to a remote server
new RedisTransporter("redis://redis.server:6379");

// Connect to a remote server
new RedisTransporter({
    url: "redis://redis-server:6379",
});

// Connect to a remote server with credentials
new RedisTransporter({
    port: 6379,             // Redis port
    host: 'redis-server',   // Redis host
    family: 4,              // 4 (IPv4) or 6 (IPv6)
    password: 'auth',       // Password
    db: 0
});
```

#### Shorthands
You can also set transporter with shorthands. With them, you can configure transporter in configuration files. No need to create an instance of transporter. Use this form, if you are running your services with [Moleculer Runner](runner.html).
```js
// Shorthand with default settings
let broker = new ServiceBroker({
    transporter: "Redis"
});

// Shorthand with connection string
let broker = new ServiceBroker({
    transporter: "redis://localhost:6379"
});

// Shorthand with options
let broker = new ServiceBroker({
    transporter: {
        type: "Redis",
        options: {
            host: "redis-server",
            db: 0
        }
});
```

### MQTT Transporter
Built-in transporter for [MQTT](http://mqtt.org/) protocol *(e.g.: [Mosquitto](https://mosquitto.org/))*.

```js
let { ServiceBroker } = require("moleculer");
let MqttTransporter = require("moleculer").Transporters.MQTT;

let broker = new ServiceBroker({
    nodeID: "server-1",
    transporter: new MqttTransporter(),
    requestTimeout: 5 * 1000
});
```
{% note info Dependencies %}
To use this transporter install the `mqtt` module with `npm install mqtt --save` command.
{% endnote %}

#### Transporter options
You can pass options to `mqtt.connect()` method.

```js
// Connect to 'mqtt://localhost:1883'
new MqttTransporter();

// Connect to a remote server
new MqttTransporter("mqtt://mqtt.server:1883");

// Connect to a remote server
new MqttTransporter({
    url: "mqtt://mqtt-server:1883",
});

// Connect to a remote server with credentials
new MqttTransporter({
    host: "mqtt-server",
    port: 1883,
    username: "admin",
    password: "1234"
});
```

#### Shorthands
You can also set transporter with shorthands. With them, you can configure transporter in configuration files. No need to create an instance of transporter. Use this form, if you are running your services with [Moleculer Runner](runner.html).
```js
// Shorthand with default settings
let broker = new ServiceBroker({
    transporter: "MQTT"
});

// Shorthand with connection string
let broker = new ServiceBroker({
    transporter: "mqtt://mqtt.server:1883"
});

// Shorthand with options
let broker = new ServiceBroker({
    transporter: {
        type: "MQTT",
        options: {
            host: "mqtt-server",
            port: 1883,
        }
});
```

### AMQP Transporter
Built-in transporter for [AMQP](https://www.amqp.org/) protocol *(e.g.: [RabbitMQ](https://www.rabbitmq.com/))*.

```js
let { ServiceBroker } = require("moleculer");
let AmqpTransporter = require("moleculer").Transporters.AMQP;

let broker = new ServiceBroker({
    nodeID: "server-1",
    transporter: new AmqpTransporter(),
    requestTimeout: 5 * 1000
});
```
{% note info Dependencies %}
To use this transporter install the `amqplib` module with `npm install amqplib --save` command.
{% endnote %}

#### Transporter options
You can pass options to `amqp.connect()` method.

```js
// Connect to 'amqp://guest:guest@localhost:5672'
new AmqpTransporter();

// Connect to a remote server
new AmqpTransporter("amqp://rabbitmq-server:5672");

// Connect to a remote server
new AmqpTransporter({
    url: "amqp://rabbitmq-server:5672",
});

// Connect to a remote server with options & credentials
new AmqpTransporter({
    url: "amqp://user:pass@rabbitmq-server:5672",
    eventTimeToLive: 5000,
    prefetch: 1
});
```
### Kafka Transporter

There is a new transporter for [Kafka](https://kafka.apache.org/). It is a very simple implementation. It transfers Moleculer packets to consumers via pub/sub. There are not implemented offset, replay...etc features.
Please note, it is an **experimental** transporter. **Do not use it in production yet!**

>To use it, install `kafka-node` with `npm install kafka-node --save` command.

**Connect to Zookeeper**
```js
let broker = new ServiceBroker({
    logger: true,
    transporter: "kafka://192.168.51.29:2181"
});
```

**Connect to Zookeeper with custom options**
```js
let broker = new ServiceBroker({
    logger: true,
    transporter: {
        type: "kafka",
        options: {
            kafka: {
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
    }

});
```
### TCP transporter

There is a new transporter for [NATS Streaming](https://nats.io/documentation/streaming/nats-streaming-intro/). It is a very simple implementation. It transfers Moleculer packets to consumers via pub/sub. There are not implemented offset, replay...etc features.
Please note, it is an **experimental** transporter. **Do not use it in production yet!**

>To use it, install `node-nats-streaming` with `npm install node-nats-streaming --save` command.

**Connect to NATS Streaming server**
```js
// Shorthand to local server
let broker = new ServiceBroker({
    logger: true,
    transporter: "STAN"
});

// Shorthand
let broker = new ServiceBroker({
    logger: true,
    transporter: "stan://192.168.0.120:4222"
});

// Shorthand with options
let broker = new ServiceBroker({
    logger: true,
    transporter: {
        type: "STAN",
        options: {
            stan: {
                url: "stan://127.0.0.1:4222",
                clusterID: "my-cluster"
            }
        }
    }
});

```
#### Shorthands
You can also set transporter with shorthands. With them, you can configure transporter in configuration files. No need to create an instance of transporter. Use this form, if you are running your services with [Moleculer Runner](runner.html).
```js
// Shorthand with default settings
let broker = new ServiceBroker({
    transporter: "AMQP"
});

// Shorthand with connection string
let broker = new ServiceBroker({
    transporter: "amqp://rabbitmq-server:5672"
});

// Shorthand with options
let broker = new ServiceBroker({
    transporter: {
        type: "AMQP",
        options: {
            host: "rabbitmq-server",
            port: 5672,
        }
});
```

### Custom transporter
You can also create your custom transporter module. We recommend you that copy the source of [NatsTransporter](https://github.com/ice-services/moleculer/blob/master/src/transporters/nats.js) and implement the `connect`, `disconnect`,  `subscribe` and `publish` methods.

### Disabled balancer
"TODO"
