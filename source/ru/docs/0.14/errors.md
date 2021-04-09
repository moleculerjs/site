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
Бросьте эту ошибку, если вызываемый узел отключен во время запроса. Error code: **503** Retryable: **true** Type: `REQUEST_REJECTED`

### `QueueIsFullError`
Бросьте эту ошибку, если слишком много активных запросов. Error code: **429** Retryable: **true** Type: `QUEUE_FULL`

### `ValidationError`
Валидатор бросает эту ошибку, если вызывающие параметры недействительны. Error code: **422** Retryable: **false** Type: `VALIDATION_ERROR` _(по умолчанию)_

### `MaxCallLevelError`
Бросьте эту ошибку, если вложенные вызовы достигли значения `maxCallLevel` (чтобы избежать бесконечных циклов вызовов). Error code: **500** Retryable: **false** Type: `MAX_CALL_LEVEL`

### `ServiceSchemaError`
Бросьте эту ошибку, если ваша схема сервиса невалидна. Error code: **500** Retryable: **false** Type: `SERVICE_SCHEMA_ERROR`

### `BrokerOptionsError`
Бросьте эту ошибку, если параметры вашего брокера невалидные. Error code: **500** Retryable: **false** Type: `BROKER_OPTIONS_ERROR`

### `GracefulStopTimeoutError`
Бросьте эту ошибку, если время плавного выключения истекло. Error code: **500** Retryable: **false** Type: `GRACEFUL_STOP_TIMEOUT`

### `ProtocolVersionMismatchError`
Бросьте эту ошибку, если старый идентификатор узла подключен к более старшей версии протокола. Error code: **500** Retryable: **false** Type: `PROTOCOL_VERSION_MISMATCH`

### `InvalidPacketDataError`
Бросьте эту ошибку, если транспорт получает неизвестные данные. Error code: **500** Retryable: **false** Type: `INVALID_PACKET_DATA`

## Создание пользовательских ошибок
Следующий пример показывает, как создать пользовательский класс `Error`, который унаследован от `MoleculerError`.

```js
const { MoleculerError } = require("moleculer").Errors;

class MyBusinessError extends MoleculerError {
    constructor(msg, data) {
        super(msg || `This is my business error.`, 500, "MY_BUSINESS_ERROR", data);
    }
}
```