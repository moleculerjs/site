title: Transporters
---
Transporter is an important module if you are running services on more nodes. Transporter communicates with every nodes. Send events, call requests...etc.

## NATS Transporter
Moleculer has a built-in transporter for [NATS](http://nats.io/).
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

### Transporter options
You can pass options to `nats.connect()` method.

```js
// Connect to 'nats://localhost:4222'
new NatsTransporter(); 

// Connect to remote server
new NatsTransporter("nats://nats.server:4222"); 

// Connect to remote server and change the prefix
new NatsTransporter({
    nats: {
        url: "nats://nats-server:4222",
    },
    prefix: "MY-PREFIX" // Use for channel names at subscribe & publish. Default: "MOL"
});

// Connect to remote server with user & pass
new NatsTransporter({
    nats: {
        url: "nats://nats-server:4222",
        user: "admin",
        pass: "1234"
    }
});
```

## Redis Transporter
Moleculer has a built-in transporter for [Redis](http://redis.io/).

```js
let { ServiceBroker } = require("moleculer");
let RedisTransporter = require("moleculer").Transporters.Redis;

let broker = new ServiceBroker({
	nodeID: "server-1",
	transporter: new RedisTransporter(),
	requestTimeout: 5 * 1000
});
```

### Transporter options
You can pass options to `new Redis()` method.

```js
// Connect to 'redis://localhost:4222'
new RedisTransporter(); 

// Connect to remote server
new RedisTransporter("redis://redis.server:4222"); 

// Connect to remote server and change the prefix
new RedisTransporter({
    redis: {
        url: "redis://redis-server:4222",
    },
    prefix: "MY-PREFIX" // Use for channel names at subscribe & publish. Default: "MOL"
});

// Connect to remote server with user & pass
new RedisTransporter({
    redis: {
        url: "redis://redis-server:4222",
        user: "admin",
        pass: "1234"
    }
});
```

## MQTT Transporter
Moleculer has a built-in transporter for [MQTT](http://mqtt.org/) protocol *(e.g.: [Mosquitto](https://mosquitto.org/))*.

```js
let { ServiceBroker } = require("moleculer");
let MqttTransporter = require("moleculer").Transporters.MQTT;

let broker = new ServiceBroker({
	nodeID: "server-1",
	transporter: new MqttTransporter(),
	requestTimeout: 5 * 1000
});
```

### Transporter options
You can pass options to `mqtt.connect()` method.

```js
// Connect to 'mqtt://localhost:4222'
new MqttTransporter(); 

// Connect to remote server
new MqttTransporter("mqtt://mqtt.server:4222"); 

// Connect to remote server and change the prefix
new MqttTransporter({
    mqtt: {
        url: "mqtt://mqtt-server:4222",
    },
    prefix: "MY-PREFIX" // Use for channel names at subscribe & publish. Default: "MOL"
});

// Connect to remote server with user & pass
new MqttTransporter({
    mqtt: {
        url: "mqtt://mqtt-server:4222",
        user: "admin",
        pass: "1234"
    }
});
```

## Custom transporter
You can also create your custom transporter module. We recommend you that copy the source of [`NatsTransporter`](src/transporters/nats.js) and implement the `connect`, `disconnect`,  `subscribe` and `publish` methods.
