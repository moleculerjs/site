title: Контекст
---

Когда вы вызываете действие или создаете событие, брокер создает экземпляр `Контекста`, который содержит всю информацию о запросе и передает его обработчику действия/события в качестве единого аргумента.

## Свойства Контекста

| Имя               | Тип                   | Описание                                                                 |
| ----------------- | --------------------- | ------------------------------------------------------------------------ |
| `ctx.id`          | `String`              | ID контекста                                                             |
| `ctx.broker`      | `ServiceBroker`       | Объект брокера.                                                          |
| `ctx.nodeID`      | `String`              | ID вызывающего или целевого узла.                                        |
| `ctx.action`      | `Object`              | Экземпляр действия.                                                      |
| `ctx.event`       | `Object`              | Экземпляр события.                                                       |
| `ctx.eventName`   | `Object`              | Имя созданного события.                                                  |
| `ctx.eventType`   | `String`              | Тип события ("emit" или "broadcast").                                    |
| `ctx.eventGroups` | `Array<String>` | Группа событий.                                                          |
| `ctx.caller`      | `String`              | Полное имя вызывающего сервиса. Пример: `v3.myService`                   |
| `ctx.requestID`   | `String`              | ID запроса. Если вы совершаете вложенные вызовы, то ID будет одинаковый. |
| `ctx.parentID`    | `String`              | ID родительского контекста (во вложенных вызовах).                       |
| `ctx.params`      | `Any`                 | Параметры запроса. *Второй аргумент в `broker.call`.*                    |
| `ctx.meta`        | `Any`                 | Мета-данные запроса. *Они также будут переданы на вложенные вызовы.*     |
| `ctx.locals`      | `Any`                 | Локальные данные.                                                        |
| `ctx.level`       | `Number`              | Уровень запроса (во вложенных вызовах). Первый уровень `1`.              |
| `ctx.span`        | `Span`                | Текущий активный интервал.                                               |

## Методы Контекста

| Название                    | Ответ     | Описание                                                                |
| --------------------------- | --------- | ----------------------------------------------------------------------- |
| `ctx.call()`                | `Promise` | Создание вложенного вызова. Те же аргументы, как в `broker.call`        |
| `ctx.emit()`                | `void`    | Создать событие, аналогично `broker.emit`                               |
| `ctx.broadcast()`           | `void`    | Создать событие, адресованное всем узлам, аналогично `broker.broadcast` |
| `ctx.startSpan(name, opts)` | `Span`    | Creates a new child span.                                               |
| `ctx.finishSpan(span)`      | `void`    | Finishes a span.                                                        |
| `ctx.toJSON()`              | `Object`  | Преобразовать `Контекст` в JSON формат.                                 |

## Отслеживание Контекста
Если вы хотите, чтобы сервисы плавно отключались, включите функцию отслеживания контекста в опциях брокера. If you enable it, all services will wait for all running contexts before shutdown. A timeout value can be defined with `shutdownTimeout` broker option. The default values is `5` seconds.

**Enable context tracking & change the timeout value**
```js
const broker = new ServiceBroker({
    nodeID: "node-1",
    tracking: {
        enabled: true,
        shutdownTimeout: 10 * 1000
    }
});
```

> The shutdown timeout can be overwritten by `$shutdownTimeout` property in service settings.

**Disable tracking in calling option**

```js
await broker.call("posts.find", {}, { tracking: false });
```