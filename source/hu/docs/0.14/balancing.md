title: Load balancing
---

Moleculer has several built-in load balancing strategies. If a service is running on multiple node instances, ServiceRegistry uses these strategies to select a single node from the available ones.

## Built-in strategies
To configure strategy, set `strategy` broker options under `registry` property. It can be either a name (in case of built-in strategies) or a `Strategy` class which inherited from `BaseStrategy` (in case of custom strategies).

### RoundRobin strategy
This strategy selects a node based on [round-robin](https://en.wikipedia.org/wiki/Round-robin_DNS) algorithm.

**Használat**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "RoundRobin"
    }
};
```

### Random strategy
This strategy selects a node randomly.

**Használat**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Random"
    }
};
```
### CPU usage-based strategy
This strategy selects a node that has the lowest CPU usage. Since the node list can be very long, it gets samples and selects the node with the lowest CPU usage only from a sample instead of the whole node list.

**Használat**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "CpuUsage"
    }
};
```

**Strategy options**

| Név           | Type     | Default | Leírás                                                                                                     |
| ------------- | -------- | ------- | ---------------------------------------------------------------------------------------------------------- |
| `sampleCount` | `Number` | `3`     | The number of samples. _To turn of sampling, set to `0`._                                                  |
| `lowCpuUsage` | `Number` | `10`    | The low CPU usage percent (%). The node which has lower CPU usage than this value is selected immediately. |

**Usage with custom options**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "CpuUsage",
        strategyOptions: {
            sampleCount: 3,
            lowCpuUsage: 10
        }
    }
};
```

### Latency-based strategy
This strategy selects a node that has the lowest latency, measured by periodic ping commands. Notice that the strategy only ping one node / host. Since the node list can be very long, it gets samples and selects the host with the lowest latency only from a sample instead of the whole node list.

**Használat**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Latency"
    }
};
```

**Strategy options**

| Név            | Type     | Default | Leírás                                                                                                                                |
| -------------- | -------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `sampleCount`  | `Number` | `5`     | The number of samples. If you have a lot of hosts/nodes, it's recommended to *increase* the value. _To turn of sampling, set to `0`._ |
| `lowLatency`   | `Number` | `10`    | The low latency (ms). The node which has lower latency than this value is selected immediately.                                       |
| `collectCount` | `Number` | `5`     | The number of measured latency per host to keep in order to calculate the average latency.                                            |
| `pingInterval` | `Number` | `10`    | Ping interval in seconds. If you have a lot of host/nodes, it's recommended to *increase* the value.                                  |

**Usage with custom options**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Latency",
        strategyOptions: {
            sampleCount: 15,
            lowLatency: 20,
            collectCount: 10,
            pingInterval: 15
        }
    }
};
```

### Sharding strategy
Shard invocation strategy is based on [consistent-hashing](https://www.toptal.com/big-data/consistent-hashing) algorithm. It uses a key value from context `params` or `meta` to route the request to nodes. It means that requests with same key value will be routed to the same node.

**Example of a shard key `name` in context `params`**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Shard",
        strategyOptions: {
            shardKey: "name"
        }
    }
};
```

**Example of a shard key `user.id` in context `meta`**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Shard",
        strategyOptions: {
            shardKey: "#user.id"
        }
    }
};
```
{% note info %}
If shard key is in context's `meta` it must be declared with a `#` at the beginning. The actual `#` is ignored.
{% endnote %}

**Strategy options**

| Név         | Type     | Default | Leírás                  |
| ----------- | -------- | ------- | ----------------------- |
| `shardKey`  | `String` | `null`  | Shard key               |
| `vnodes`    | `Number` | `10`    | Number of virtual nodes |
| `ringSize`  | `Number` | `2^32`  | Size of the ring        |
| `cacheSize` | `Number` | `1000`  | Size of the cache       |


**All available options of Shard strategy**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Shard",
        strategyOptions: {
            shardKey: "#user.id",
            vnodes: 10,
            ringSize: 1000,
            cacheSize: 1000
        }
    }
};
```
## Overwrite global options
You can overwrite globally defined load balancing strategy in action/event definitions.

**Using 'Shard' strategy for 'hello' action instead of global 'RoundRobin'**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "RoundRobin"
    }
});

// greeter.service.js
module.exports = {
    name: "greeter",
    actions: {
        hello: {
            params: {
                name: "string"
            },
            strategy: "Shard",
            strategyOptions: {
                shardKey: "name"
            }            
            handler(ctx) {
                return `Hello ${ctx.params.name}`;
            }
        }
    }
};
```



## Custom strategy
Custom strategy can be created. We recommend to copy the source of [RandomStrategy](https://github.com/moleculerjs/moleculer/blob/master/src/strategies/random.js) and implement the `select` method.

### Create custom strategy
```js
const BaseStrategy = require("moleculer").Strategies.Base;

class MyStrategy extends BaseStrategy {
    select(list, ctx) { /*...*/ }
}

module.exports = MyStrategy;
```

### Use custom strategy

```js
const { ServiceBroker } = require("moleculer");
const MyStrategy = require("./my-strategy");

const Strategies = require("moleculer").Strategies
// Add custom strategy to the registry
Strategies.register("myCustomStrategy", MyStrategy)


// moleculer.config.js
module.exports = {
    registry: {
        // Strategy is already registered. Call it by name
        strategy: "myCustomStrategy"
    }
};
```

## Preferring local services
The ServiceBroker first tries to call the local instances of service (if exists) to reduce network latencies. It means, if the given service is available on the local broker, the configured strategy will be skipped and the broker will call the local service always. This logic can be turned off in broker options with `preferLocal: false` property under the `registry` key.

```js
// moleculer.config.js
module.exports = {
    registry: {
        preferLocal: false
    }
};
```
