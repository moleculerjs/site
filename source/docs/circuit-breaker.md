title: Circuit breaker
---
_Added in: v0.7.6_

The Moleculer has a built-in circuit-breaker solution.
{% note info What is the circuit breaker? %}
Read more from circuit breaker on [Martin Fowler blog](https://martinfowler.com/bliki/CircuitBreaker.html).
{% endnote %}

If you enable it, every service call will be protected with the built-in circuit breaker.

**Enable it in the broker options**
```js
let broker = new ServiceBroker({
    circuitBreaker: {
        enabled: true,
        maxFailures: 5,
        halfOpenTime: 10 * 1000,
        failureOnTimeout: true,
        failureOnReject: true
    }
});
```

## Settings

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `enabled` | `Boolean` | `false` | Enable the protection |
| `maxFailures` | `5` | `false` | Trip breaker after 5 failures |
| `halfOpenTime` | `Number` | `10000` | Number of milliseconds to switch from `open` to `half-open` state |
| `failureOnTimeout` | `Boolean` | `true` | Increment failures if the request is timed out |
| `failureOnReject` | `Boolean` | `true` | Increment failures if the request is rejected (by any `Error`) |
