title: Load balancing
---
**TODO: update**

Moleculer has several built-in load balancing strategies. If services have multiple running instances, Registry uses strategies to select a node from all available nodes. There are some built-in strategies, or you can create your custom strategies too.

## Built-in strategies
To configure strategy, set `strategy` broker options under `registry` property. It can be either a name (in case of built-in strategies) or an `Strategy` class which inherited from `BaseStrategy` (in case of custom strategies).

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
| `sampleCount` | `Number` | `3` | the number of samples. _To turn of sampling, set to `0`._ |
| `lowCpuUsage` | `Number` | `10` | the low CPU usage percent (%). The node which has lower CPU usage than this value is selected immediately. |

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
| `sampleCount` | `Number` | `5` | the number of samples. If you have a lot of hosts/nodes, it's recommended to *increase* the value. _To turn of sampling, set to `0`._ |
| `lowLatency` | `Number` | `10` | the low latency (ms). The node which has lower latency than this value is selected immediately. |
| `collectCount` | `Number` | `5` | the number of measured latency per host to keep in order to calculate the average latency. |
| `pingInterval` | `Number` | `10` | ping interval (s). If you have a lot of host/nodes, it's recommended to *increase* the value. |

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

## Custom strategy
You can also create your custom strategy module. We recommend to copy the source of [RandomStrategy](https://github.com/moleculerjs/moleculer/blob/master/src/strategies/random.js) and implement the `select` method.

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
        strategy: new MyStrategy()
    }
});
```