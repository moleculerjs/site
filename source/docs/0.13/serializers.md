title: Serializers
---
Transporter needs a serializer module which serializes & deserializes the transferred packets.

**Example**
```js
const { ServiceBroker } = require("moleculer");

const broker = new ServiceBroker({
    nodeID: "server-1",
    transporter: "NATS",
    serializer: "ProtoBuf"
});
```

## Built-in serializers

### JSON serializer
This is the built-in default serializer. It serializes the packets to JSON string and deserializes the received data to packet.

```js
const broker = new ServiceBroker({
    // serializer: "JSON" // don't need to set, because it is the default
});
```

### Avro serializer
Built-in [Avro](https://github.com/mtth/avsc) serializer.

```js
const broker = new ServiceBroker({
    serializer: "Avro"
});
```
{% note info Dependencies %}
To use this serializer install the `avsc` module with `npm install avsc --save` command.
{% endnote %}

### MsgPack serializer
Built-in [MsgPack](https://github.com/mcollina/msgpack5) serializer.

```js
const broker = new ServiceBroker({
    serializer: "MsgPack"
});
```
{% note info Dependencies %}
To use this serializer install the `msgpack5` module with `npm install msgpack5 --save` command.
{% endnote %}

### ProtoBuf serializer
Built-in [Protocol Buffer](https://developers.google.com/protocol-buffers/) serializer.

```js
const broker = new ServiceBroker({
    serializer: "ProtoBuf"
});
```
{% note info Dependencies %}
To use this serializer install the `protobufjs` module with `npm install protobufjs --save` command.
{% endnote %}

### Custom serializer
You can also create your custom serializer module. We recommend to copy the source of [JSONSerializer](https://github.com/moleculerjs/moleculer/blob/master/src/serializers/json.js) and implement the `serialize` and `deserialize` methods.

#### Use custom cacher

```js
const { ServiceBroker } = require("moleculer");
const MyAwesomeSerializer = require("./my-serializer");

const broker = new ServiceBroker({
    serializer: new MyAwesomeSerializer()
});
```