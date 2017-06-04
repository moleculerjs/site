title: Transporters
---
Transporter is an important module if you are running services on more nodes. Transporter communicates with other nodes. Send events, call requests...etc.

## Built-in transporters

### NATS Transporter
Built-in transporter for [NATS](http://nats.io/).
> NATS Server is a simple, high performance open source messaging system for cloud native applications, IoT messaging, and microservices architectures.

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

// Connect to a remote server and change the prefix of channels
new NatsTransporter({
    nats: {
        url: "nats://nats-server:4222",
    },
    prefix: "MY-PREFIX" // Use for channel names at subscribe & publish. Default: "MOL"
});

// Connect to a remote server with credentials
new NatsTransporter({
    nats: {
        url: "nats://nats-server:4222",
        user: "admin",
        pass: "1234"
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

// Connect to a remote server and change the prefix of channels
new RedisTransporter({
    redis: {
        url: "redis://redis-server:6379",
    },
    prefix: "MY-PREFIX" // Use for channel names at subscribe & publish. Default: "MOL"
});

// Connect to a remote server with credentials
new RedisTransporter({
    redis: {
        port: 6379,             // Redis port
        host: 'redis-server',   // Redis host
        family: 4,              // 4 (IPv4) or 6 (IPv6)
        password: 'auth',       // Password
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

// Connect to a remote server and change the prefix of channels
new MqttTransporter({
    mqtt: {
        url: "mqtt://mqtt-server:1883",
    },
    prefix: "MY-PREFIX" // Use for channel names at subscribe & publish. Default: "MOL"
});

// Connect to a remote server with credentials
new MqttTransporter({
    mqtt: {
        host: "mqtt-server",
        port: 1883,
        username: "admin",
        password: "1234"
    }
});
```

### Custom transporter
You can also create your custom transporter module. We recommend you that copy the source of [NatsTransporter](https://github.com/ice-services/moleculer/blob/master/src/transporters/nats.js) and implement the `connect`, `disconnect`,  `subscribe` and `publish` methods.
