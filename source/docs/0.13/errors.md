title: Errors
---
Moleculer has some built-in `Error`. You can use it when you raise an error in services.

## Base error classes

### `MoleculerError`
The base error class.

**Parameters**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `message` | `String` |  | Error message |
| `code` | `Number` | `500` | Error code |
| `type` | `String` |  | Error type |
| `data` | `any` |  | Any relevant data |

**Example**
```js
const { MoleculerError } = require("moleculer").Errors;

throw new MoleculerError("Something happened", 501, "ERR_SOMETHING", { a: 5, nodeID: "node-666" }));
```

### `MoleculerRetryableError`
Error for retryable errors. It uses in `broker.call`. The broker retries requests if they rejected a `MoleculerRetryableError`.

**Parameters**

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `message` | `String` |  | Error message |
| `code` | `Number` | `500` | Error code |
| `type` | `String` |  | Error type |
| `data` | `any` |  | Any relevant data |

**Example**
```js
const { MoleculerRetryableError } = require("moleculer").Errors;

throw new MoleculerRetryableError("Some retryable thing happened", 501, "ERR_SOMETHING", { a: 5, nodeID: "node-666" }));
```

### `MoleculerServerError`
Error for retryable server errors. Parameters are same as `MoleculerRetryableError`.


### `MoleculerClientError`
Error for client error which is **not** retryable. Parameters are same as `MoleculerRetryableError`.

## Internal error classes

### `ServiceNotFoundError`
Throw it if you `call` a not registered service action.
Error code: **404**
Retryable: **true**

### `ServiceNotAvailableError`
Throw it if you `call` a currently unavailable service action. E.g. nodes disconnected which contains this service or circuit breaker opened.
Error code: **404**
Retryable: **true**

### `RequestTimeoutError`
Throw it if your `broker.call` is timed out.
Error code: **504**
Retryable: **true**

### `RequestSkippedError`
Throw it if your nested call is skipped because the execution is timed out.
Error code: **514**
Retryable: **false**

### `MaxCallLevelError`
Throw it if your nested calls reached the `maxCallLevel` value (to avoid infinite calling loops).
Error code: **500**
Retryable: **false**

### `ValidationError`
Validator throws it if the calling parameters are not valid.
Error code: **422**
Retryable: **false**

### `ServiceSchemaError`
Throw it if your service schema is not valid.
Error code: **500**
Retryable: **false**

### `ProtocolVersionMismatchError`
Throw it if an old nodeID connected with older protocol version.
Error code: **500**
Retryable: **false**

**TODO: add all**