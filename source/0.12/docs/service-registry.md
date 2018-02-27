title: Service Registry
---
## Built-in Registry
The Moleculer has a built-in service registry module. It stores all information about services, event listeners and nodes. When you call a service or emit an event, broker asks the registry to look up a node which executes the given service.

>You can access the stored data via [internal service](http://localhost:4000/0.12/docs/broker.html#Internal-services).

If a service has multiple running instances, Registry uses strategies to select a node from all available nodes. There are some built-in strategies, or you can create your custom strategies too.

## Built-in strategies

ServiceBroker can resolve the `strategy` from a string or set a `BaseStrategy` class to the `strategy` property.

```js
let broker = new ServiceBroker({
    registry: {
        strategy: "Random"
    }
});
```

## RoundRobin strategy
This strategy selects a node based on RoundRobin algorithm.

**Usage**
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "RoundRobin"
    }
});
```

## Random strategy
This strategy selects a node randomly.

**Usage**
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "Random"
    }
});
```
## CPU usage-based strategy
This strategy selects a node which has the lowest CPU usage. Due to the node list can be very long, it gets samples and selects the node with the lowest CPU usage from only samples instead of the whole node list.

**Usage**
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "CpuUsage"
    }
});
```

**Strategy options**

| Name | Type | Default | Description |
| ---- | ---- | --------| ----------- |
| `sampleCount` | `Number` | `3` | the number of samples. |
| `lowCpuUsage` | `Number` | `10` | the low CPU usage percent (%). The node which has lower CPU usage than this value is selected immediately. |

**Usage with custom options**
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "CpuUsage",
        strategyOptions: {
            sampleCount: 3,
            lowCpuUsage: 10
        }
    }
});
```
