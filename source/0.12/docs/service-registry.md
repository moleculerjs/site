title: Service Registry
---
## Strategies

ServiceBroker can resolve the `strategy` from a string. There are 3 types of strategies.
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "Random"
        // strategy: "RoundRobin"
        // strategy: "CpuUsage"
    }
});
```
You can set it via env variables as well, if you are using the Moleculer Runner:

```js
$ REGISTRY_STRATEGY=random
```
## RoundRobin strategy
In this strategy, it selects a node based on RoundRobin algorithm.
### Usage:
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "RoundRobin"
    }
});
```

## Random strategy
In this strategy, it selects a node randomly.
### Usage:
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "RoundRobin"
    }
});
```
## CPU usage-based strategy

There is a new `CpuUsageStrategy` strategy. It selects a node which has the lowest CPU usage. Due to the node list can be very long, it gets samples and selects the node with the lowest CPU usage from only samples instead of the whole node list.

There are 2 options for the strategy:

- `sampleCount`: the number of samples. Default: `3`
- `lowCpuUsage`: the low CPU usage percent. The node which has lower CPU usage than this value is selected immediately. Default: `10`

### Usage:
```js
let broker = new ServiceBroker({
    registry: {
        strategy: "CpuUsage"
    }
});
```
### Usage with custom options
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
