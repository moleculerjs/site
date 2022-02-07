title: Errors
---
Moleculer has some built-in `Error` to raise an error in services.

## Base error classes

### `MoleculerError`
The base error class.

**Parameters**

| Name      | Typ      | Default | Beschreibung      |
| --------- | -------- | ------- | ----------------- |
| `message` | `String` |         | Error message     |
| `code`    | `Number` | `500`   | Error code        |
| `type`    | `String` |         | Error type        |
| `data`    | `any`    |         | Any relevant data |

**Example**
```js
const { MoleculerError } = require("moleculer").Errors;

throw new MoleculerError("Something happened", 501, "ERR_SOMETHING", { a: 5, nodeID: "node-666" });
```

### `MoleculerRetryableError`
Error for retryable errors. It uses in `broker.call`. The broker retries requests if they rejected a `MoleculerRetryableError`.

**Parameters**

| Name      | Typ      | Default | Beschreibung      |
| --------- | -------- | ------- | ----------------- |
| `message` | `String` |         | Error message     |
| `code`    | `Number` | `500`   | Error code        |
| `type`    | `String` |         | Error type        |
| `data`    | `any`    |         | Any relevant data |

**Example**
```js
const { MoleculerRetryableError } = require("moleculer").Errors;

throw new MoleculerRetryableError("Some retryable thing happened", 501, "ERR_SOMETHING", { a: 5, nodeID: "node-666" });
```

### `MoleculerServerError`
Error for retryable server errors. Parameters are same as `MoleculerRetryableError`.


### `MoleculerClientError`
Error for client error which is **not** retryable. Parameters are same as `MoleculerError`.

## Internal error classes

### `ServiceNotFoundError`
Throw it if you `call` a not registered service action. Error code: **404** Retryable: **true** Type: `SERVICE_NOT_FOUND`

### `ServiceNotAvailableError`
Throw it if you `call` a currently unavailable service action. E.g. node disconnected which contains this service or circuit breaker is opened. Error code: **404** Retryable: **true** Type: `SERVICE_NOT_AVAILABLE`


### `RequestTimeoutError`
Throw it if your request is timed out. Error code: **504** Retryable: **true** Type: `REQUEST_TIMEOUT`

### `RequestSkippedError`
Throw it if your nested call is skipped because the execution is timed out due to distributed timeout. Error code: **514** Retryable: **false** Type: `REQUEST_SKIPPED`

### `RequestRejectedError`
Throw it if the called node is disconnected during requesting. Error code: **503** Retryable: **true** Type: `REQUEST_REJECTED`

### `QueueIsFullError`
Throw it if there are too many active requests. Error code: **429** Retryable: **true** Type: `QUEUE_FULL`

### `ValidationError`
Validator throws it if the calling parameters are not valid. Error code: **422** Retryable: **false** Type: `VALIDATION_ERROR` _(default)_

### `MaxCallLevelError`
Throw it if your nested calls reached the `maxCallLevel` value (to avoid infinite calling loops). Error code: **500** Retryable: **false** Type: `MAX_CALL_LEVEL`

### `ServiceSchemaError`
Throw it if your service schema is not valid. Error code: **500** Retryable: **false** Type: `SERVICE_SCHEMA_ERROR`

### `BrokerOptionsError`
Throw it if your broker options are not valid. Error code: **500** Retryable: **false** Type: `BROKER_OPTIONS_ERROR`

### `GracefulStopTimeoutError`
Throw it if shutdown is timed out. Error code: **500** Retryable: **false** Type: `GRACEFUL_STOP_TIMEOUT`

### `ProtocolVersionMismatchError`
Throw it if an old nodeID connected with older protocol version. Error code: **500** Retryable: **false** Type: `PROTOCOL_VERSION_MISMATCH`

### `InvalidPacketDataError`
Throw it if transporter receives unknown data. Error code: **500** Retryable: **false** Type: `INVALID_PACKET_DATA`

## Create custom errors
The following example shows how to create a custom `Error` class which is inherited from `MoleculerError`.

```js
const { MoleculerError } = require("moleculer").Errors;

class MyBusinessError extends MoleculerError {
    constructor(msg, data) {
        super(msg || `This is my business error.`, 500, "MY_BUSINESS_ERROR", data);
    }
}
```

## Preserve custom error classes while transferring between remote nodes
For this purpose provide your own `Regenerator`. We recommend looking at the source code of [Errors.Regenerator](https://github.com/moleculerjs/moleculer/blob/master/src/errors.js) and implementing `restore`, `extractPlainError` or `restoreCustomError` methods.

### Public interface of Regenerator

| Method                                    | Return                 | Beschreibung                                                                                                |
| ----------------------------------------- | ---------------------- | ----------------------------------------------------------------------------------------------------------- |
| `restore(plainError, payload)`            | `Error`                | Restores an `Error` object                                                                                  |
| `extractPlainError(err)`                  | `Object`               | Extracts a plain error object from `Error` object                                                           |
| `restoreCustomError(plainError, payload)` | `Error` or `undefined` | Hook to restore a custom error in a child class. Prefer to use this method instead of the `restore` method. |

#### Create custom regenerator
```js
const { Regenerator, MoleculerError } = require("moleculer").Errors;
const { ServiceBroker } = require("moleculer");

class TimestampedError extends MoleculerError {
    constructor(message, code, type, data, timestamp) {
        super(message, code, type, data);
        this.timestamp = timestamp;
    }
}

class CustomRegenerator extends Regenerator {
    restoreCustomError(plainError, payload) {
        const { name, message, code, type, data, timestamp } = plainError;
        switch (name) {
            case "TimestampedError":
                return new TimestampedError(message, code, type, data, timestamp);
        }
    }

    extractPlainError(err) {
        return {
            ...super.extractPlainError(err),
            timestamp: err.timestamp
        };
    }
}

module.exports = CustomRegenerator;
```

#### Use custom regenerator
```js
// moleculer.config.js
const CustomRegenerator = require("./custom-regenerator");

module.exports = {
    errorRegenerator: new CustomRegenerator()
}
```
