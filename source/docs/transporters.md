title: Transporters
---
Transporter is an important module if you are running services on multiple nodes. Transporter communicates with other nodes. It transfers events, calls requests, processes responses ...etc. If a service runs on multiple instances on different nodes, the requests are load-balanced between nodes.

## Built-in transporters

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
    nats: {
        url: "nats://nats-server:4222",
    }
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
            nats: {
                url: "nats://localhost:4222"
                user: "admin",
                pass: "1234"
            }
        }
});

// Shorthand with TLS
let broker = new ServiceBroker({
    transporter: {
        type: "NATS",
        options: {
            nats: {
                url: "nats://localhost:4222"
                
                // More info: https://github.com/nats-io/node-nats#tls
                tls: {
                    key: fs.readFileSync('./client-key.pem'),
                    cert: fs.readFileSync('./client-cert.pem'),
                    ca: [ fs.readFileSync('./ca.pem') ]
                }
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
    redis: {
        url: "redis://redis-server:6379",
    }
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
            redis: {
                host: "redis-server",
                db: 0
            }
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
    mqtt: {
        url: "mqtt://mqtt-server:1883",
    }
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
            mqtt: {
                host: "mqtt-server",
                port: 1883,
            }
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
    amqp: {
        url: "amqp://rabbitmq-server:5672",
    }
});

// Connect to a remote server with options & credentials
new AmqpTransporter({
    amqp: {
        url: "amqp://user:pass@rabbitmq-server:5672",
        eventTimeToLive: 5000,
        prefetch: 1
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
            amqp: {
                host: "rabbitmq-server",
                port: 5672,
            }
        }
});
```

### Custom transporter
You can also create your custom transporter module. We recommend you that copy the source of [NatsTransporter](https://github.com/moleculerjs/moleculer/blob/master/src/transporters/nats.js) and implement the `connect`, `disconnect`,  `subscribe` and `publish` methods.
