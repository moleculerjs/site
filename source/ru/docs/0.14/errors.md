title: Ошибки
---
Moleculer предоставляет несколько классов `Error`, для вызова в сервисах.

## Базовые классы ошибок

### `MoleculerError`
Базовый класс ошибки.

**Параметры**

| Название  | Тип      | Значение по умолчанию | Описание                     |
| --------- | -------- | --------------------- | ---------------------------- |
| `message` | `String` |                       | Сообщение об ошибке          |
| `code`    | `Number` | `500`                 | Код ошибки                   |
| `type`    | `String` |                       | Тип ошибки                   |
| `data`    | `any`    |                       | Любые соответствующие данные |

**Пример**
```js
const { MoleculerError } = require("moleculer").Errors;

throw new MoleculerError("Something happened", 501, "ERR_SOMETHING", { a: 5, nodeID: "node-666" });
```

### `MoleculerRetryableError`
Ошибка для повторных ошибок. Используется в `broker.call`. Брокер повторяет запрос, если запрос не удался и вернул ошибку `MoleculerRetryableError`.

**Параметры**

| Название  | Тип      | Значение по умолчанию | Описание                     |
| --------- | -------- | --------------------- | ---------------------------- |
| `message` | `String` |                       | Сообщение об ошибке          |
| `code`    | `Number` | `500`                 | Код ошибки                   |
| `type`    | `String` |                       | Тип ошибки                   |
| `data`    | `any`    |                       | Любые соответствующие данные |

**Пример**
```js
const { MoleculerRetryableError } = require("moleculer").Errors;

throw new MoleculerRetryableError("Some retryable thing happened", 501, "ERR_SOMETHING", { a: 5, nodeID: "node-666" });
```

### `MoleculerServerError`
Ошибка для повторных серверных ошибок. Параметры такие же, как для `MoleculerRetryableError`.


### `MoleculerClientError`
Клиентская ошибка, при получении которой **не** будет выполнен повторный запрос. Параметры такие же, как для `MoleculerError`.

## Классы внутренних ошибок

### `ServiceNotFoundError`
Бросьте эту ошибку, если происходит вызов `call` не зарегистрированного служебного действия. Error code: **404** Retryable: **true** Type: `SERVICE_NOT_FOUND`

### `ServiceNotAvailableError`
Бросьте эту ошибку, если происходит вызов `call` недоступного в момент вызова действия сервиса. Например, узел, который содержит данный сервис отключён или открыт прерыватель бесконечных циклов. Error code: **404** Retryable: **true** Type: `SERVICE_NOT_AVAILABLE`


### `RequestTimeoutError`
Бросьте эту ошибку, если время вашего запроса истекло. Error code: **504** Retryable: **true** Type: `REQUEST_TIMEOUT`

### `RequestSkippedError`
Бросьте эту ошибку, если вложенный вызов пропущен, потому что его выполнение истекает по причине наступления распределенного тайм-аута. Error code: **514** Retryable: **false** Type: `REQUEST_SKIPPED`

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
Throw it if transporter receives unknow data. Error code: **500** Retryable: **false** Type: `INVALID_PACKET_DATA`

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