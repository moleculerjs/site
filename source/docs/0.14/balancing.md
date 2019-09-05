title: Load balancing
---

Moleculer has several built-in load balancing strategies. If services have multiple running instances, ServiceRegistry uses these strategies to select a node from all available nodes.

## Built-in strategies
To configure strategy, set `strategy` broker options under `registry` property. It can be either a name (in case of built-in strategies) or a `Strategy` class which inherited from `BaseStrategy` (in case of custom strategies).

**Configure balancing strategy**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Random"
    }
});
```

### RoundRobin strategy
This strategy selects a node based on [round-robin](https://en.wikipedia.org/wiki/Round-robin_DNS) algorithm.

**Usage**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "RoundRobin"
    }
});
```

### Random strategy
This strategy selects a node randomly.

**Usage**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Random"
    }
});
```
### CPU usage-based strategy
This strategy selects a node which has the lowest CPU usage. Due to the node list can be very long, it gets samples and selects the node with the lowest CPU usage from only samples instead of the whole node list.

**Usage**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "CpuUsage"
    }
});
```

**Strategy options**

| Name | Type | Default | Description |
| ---- | ---- | --------| ----------- |
| `sampleCount` | `Number` | `3` | The number of samples. _To turn of sampling, set to `0`._ |
| `lowCpuUsage` | `Number` | `10` | The low CPU usage percent (%). The node which has lower CPU usage than this value is selected immediately. |

**Usage with custom options**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "CpuUsage",
        strategyOptions: {
            sampleCount: 3,
            lowCpuUsage: 10
        }
    }
});
```

### Latency-based strategy
This strategy selects a node which has the lowest latency, measured by periodic ping commands. Notice that the strategy only ping one of nodes from a single host. Due to the node list can be very long, it gets samples and selects the host with the lowest latency from only samples instead of the whole node list.

**Usage**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Latency"
    }
});
```

**Strategy options**

| Name | Type | Default | Description |
| ---- | ---- | --------| ----------- |
| `sampleCount` | `Number` | `5` | The number of samples. If you have a lot of hosts/nodes, it's recommended to *increase* the value. _To turn of sampling, set to `0`._ |
| `lowLatency` | `Number` | `10` | The low latency (ms). The node which has lower latency than this value is selected immediately. |
| `collectCount` | `Number` | `5` | The number of measured latency per host to keep in order to calculate the average latency. |
| `pingInterval` | `Number` | `10` | Ping interval (s). If you have a lot of host/nodes, it's recommended to *increase* the value. |

**Usage with custom options**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Latency",
        strategyOptions: {
            sampleCount: 15,
            lowLatency: 20,
            collectCount: 10,
            pingInterval: 15
        }
    }
});
```

### Sharding strategy
Shard invocation strategy is based on [consistent-hashing](https://www.toptal.com/big-data/consistent-hashing) algorithm. It uses a key value from context `params` or `meta` to route the request a specific node. It means that requests with same key value will be routed to the same node.

**Example of a shard key `name` in context `params`**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Shard",
        strategyOptions: {
            shardKey: "name"
        }
    }
});
```

**Example of a shard key `user.id` in context `meta`**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Shard",
        strategyOptions: {
            shardKey: "#user.id"
        }
    }
});
```
{% note info %}
If shard key is in context's `meta` it must be declared with a `#` at the beginning. The actual `#` is ignored.
{% endnote %}

**Strategy options**

| Name | Type | Default | Description |
| ---- | ---- | --------| ----------- |
| `shardKey` | `String` | `null` |  Shard key |
| `vnodes` | `Number` | `10` | Number of virtual nodes |
| `ringSize` | `Number` | `2^32` | Size of the ring |
| `cacheSize` | `Number` | `1000` | Size of the cache |


**All available options of Shard strategy**
```js
const broker = new ServiceBroker({
    registry: {
        strategy: "Shard",
        strategyOptions: {
            shardKey: "#user.id",
            vnodes: 10,
            ringSize: 1000,
            cacheSize: 1000
        }
    }
});
```


## Custom strategy
Custom strategy can be created. We recommend to copy the source of [RandomStrategy](https://github.com/moleculerjs/moleculer/blob/master/src/strategies/random.js) and implement the `select` method.

### Create custom strategy
```js
const BaseStrategy = require("moleculer").Strategies.Base;

class MyStrategy extends BaseStrategy {
    select(list) { /*...*/ }
}

module.exports = MyStrategy;
```

### Use custom strategy

```js
const { ServiceBroker } = require("moleculer");
const MyStrategy = require("./my-strategy");

const broker = new ServiceBroker({
    registry: {
        strategy: MyStrategy
    }
});
```