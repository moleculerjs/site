title: Serializers
---
For transportation needs a serializer module which serialize & deserialize the transferred packets. If you don't set serializer, the default is the JSON serializer.

**Example**
```js
let { ServiceBroker } = require("moleculer");
let NatsTransporter = require("moleculer").Transporters.NATS;
let AvroSerializer = require("moleculer").Serializers.Avro;

let broker = new ServiceBroker({
    nodeID: "server-1",
    transporter: new NatsTransporter(),
    serializer: new AvroSerializer()
});
```

## Built-in serializers

### JSON serializer
This is the default serializer. Serialize the packets to JSON string and deserialize the received data to packet.

```js
let broker = new ServiceBroker({
    ...
    // serializer: new JSONSerializer() // don't need to set, because it is the default
});
```

### Avro serializer
This is an [Avro](https://github.com/mtth/avsc) serializer.

```js
let AvroSerializer = require("moleculer").Serializers.Avro;

let broker = new ServiceBroker({
    ...
    serializer: new AvroSerializer()
});
```
{% note info Dependencies %}
To use this serializer install the `avsc` module with `npm install avsc --save` command.
{% endnote %}

### MsgPack serializer
This is an [MsgPack](https://github.com/mcollina/msgpack5) serializer.

```js
let MsgPackSerializer = require("moleculer").Serializers.MsgPack;

let broker = new ServiceBroker({
    ...
    serializer: new MsgPackSerializer()
});
```
{% note info Dependencies %}
To use this serializer install the `msgpack5` module with `npm install msgpack5 --save` command.
{% endnote %}

### ProtoBuf serializer
This is a [Protocol Buffer](https://developers.google.com/protocol-buffers/) serializer.

```js
let ProtoBufSerializer = require("moleculer").Serializers.ProtoBuf;

let broker = new ServiceBroker({
    ...
    serializer: new ProtoBufSerializer()
});
```
{% note info Dependencies %}
To use this serializer install the `protobufjs` module with `npm install protobufjs --save` command.
{% endnote %}

### Custom serializer
You can also create your custom serializer module. We recommend you that copy the source of [JSONSerializer](https://github.com/ice-services/moleculer/blob/master/src/serializers/json.js) and implement the `serialize` and `deserialize` methods.