title: Устойчивость к отказу
---

Moleculer имеет несколько встроенных механизмов, обеспечивающих отказоустойчивость. Они могут быть включены или отключены в настройках брокера.

## Защита от зацикливания

Молекулер имеет встроенный механизм защиты от зацикливания. Это реализация на основе пороговых значений. Для проверки частоты неудачного запроса используется временное окно. При достижении порогового значения активирует механизм защиты от зацикливания.

{% note info What is the circuit breaker? %}
Защита от зацикливания может помешать приложению многократно пытаться выполнить операцию, которая, скорее всего, не сработает. Тем самым позволяет продолжить работу без ожидания исправления сбоя или потери циклов процессора, пока срабатывает определение, что ошибка длительное время сохраняется. Паттерн прерывания зацикливания также позволяет приложению определить, была ли устранена ошибка. Если проблема была исправлена, приложение может попытаться вызвать операцию.

Подробнее о защите от зацикливания можной узнать на [Martin Fowler blog](https://martinfowler.com/bliki/CircuitBreaker.html) или [Microsoft Azure Docs](https://docs.microsoft.com/azure/architecture/patterns/circuit-breaker).
{% endnote %}

Если вы включите его, то все сервисные вызовы будут защищены от зацикливания.

**Включить можно в параметрах брокера**
```js
const broker = new ServiceBroker({
    circuitBreaker: {
        enabled: true,
        threshold: 0.5,
        minRequestCount: 20,
        windowTime: 60, // в секундах
        halfOpenTime: 5 * 1000, // в миллисекундах
        check: err => err && err.code >= 500
    }
});
```

### Настройки

| Название          | Тип        | По умолчанию                        | Описание                                                                          |
| ----------------- | ---------- | ----------------------------------- | --------------------------------------------------------------------------------- |
| `enabled`         | `Boolean`  | `false`                             | Включить функцию                                                                  |
| `threshold`       | `Number`   | `0.5`                               | Значение порога. `0.5` означает, что 50% не могут быть доставлены для передачи.   |
| `minRequestCount` | `Number`   | `20`                                | Минимальное количество запросов. Ниже этого значения, CB не передаётся.           |
| `windowTime`      | `Number`   | `60`                                | Количество секунд за окно времени.                                                |
| `halfOpenTime`    | `Number`   | `10000`                             | Количество миллисекунд для переключения с `открытого` на `полуоткрытое` состояние |
| `check`           | `Function` | `err && err.code >= 500` | Функция для проверки неудачных запросов.                                          |

> Если состояние защиты от зацикливания изменено, ServiceBroker отправит [внутренние события](events.html#circuit-breaker-opened).

Эти глобальные параметры также могут быть переопределены в определении действий.
```js
// users.service.js
module.export = {
    name: "users",
    actions: {
        create: {
            circuitBreaker: {
                // Все параметры CB могут быть переопределены параметров брокера.
                threshold: 0.3,
                windowTime: 30
            },
            handler(ctx) {}
        }
    }
};
```

## Повтор
Для выполнения повторных попыток применяется решение на базе экспоненциального отката. Оно может повторно вызвать неудачные запросы.

**Включить можно в параметрах брокера**
```js
const broker = new ServiceBroker({
    retryPolicy: {
        enabled: true,
        retries: 5,
        delay: 100,
        maxDelay: 2000,
        factor: 2,
        check: err => err && !!err.retryable
    }
});
```

### Настройки

| Название   | Тип        | Значение по умолчанию            | Описание                                                                        |
| ---------- | ---------- | -------------------------------- | ------------------------------------------------------------------------------- |
| `enabled`  | `Boolean`  | `false`                          | Включить функцию.                                                               |
| `retries`  | `Number`   | `5`                              | Количество попыток.                                                             |
| `delay`    | `Number`   | `100`                            | Первая задержка в миллисекундах.                                                |
| `maxDelay` | `Number`   | `2000`                           | Максимальная задержка в миллисекундах.                                          |
| `factor`   | `Number`   | `2`                              | Отключение фактора задержки. `2` означает экспоненциальный алгоритм отключения. |
| `check`    | `Function` | `err && !!err.retryable` | Функция для проверки неудачных запросов.                                        |

**Перезаписать значение повторов в опции вызова**
```js
broker.call("posts.find", {}, { retries: 3 });
```

**Перезаписать значения политики ретраев в определении действий**
```js
// users.service.js
module.export = {
    name: "users",
    actions: {
        find: {
            retryPolicy: {
                // Все настройки политики повторов могут быть перезаписаны значениями из настроек брокера.
                retries: 3,
                delay: 500
            },
            handler(ctx) {}
        },
        create: {
            retryPolicy: {
                // Отключить повторы для этого действия
                enabled: false
            },
            handler(ctx) {}
        }
    }
};
```

## Таймауты
На вызов сервиса можно установить таймаут. Он может быть установлен глобально в опциях брокера или при вызове параметров. Если тайм-аут определен и запрос превышен, брокер выбрасывает ошибку `RequestTimeoutError`.

**Включить можно в параметрах брокера**
```js
const broker = new ServiceBroker({
    requestTimeout: 5 * 1000 // в миллисекундах
});
```

**Перезаписать значение тайм-аута в параметрах вызова**
```js
broker.call("posts.find", {}, { timeout: 3000 });
```

### Распределённые таймауты
Moleculer использует [распределенные таймауты](https://www.datawire.io/guide/traffic/deadlines-distributed-timeouts-microservices/). В случае вложенных вызовов значение таймаута определяется с задержкой выполнения. Если значение таймаута меньше или равно 0, следующие вложенные вызовы будут пропущены (`RequestSkippedError`), потому что первый вызов уже был отклонен с ошибкой `RequestTimeoutError`.

## Bulkhead
Bulkhead feature is implemented in Moleculer framework to control the concurrent request handling of actions.

**Enable it in the broker options**
```js
const broker = new ServiceBroker({
    bulkhead: {
        enabled: true,
        concurrency: 3,
        maxQueueSize: 10,
    }
});
```

### Global Settings

| Название       | Type      | Default | Описание                       |
| -------------- | --------- | ------- | ------------------------------ |
| `enabled`      | `Boolean` | `false` | Enable feature.                |
| `concurrency`  | `Number`  | `3`     | Maximum concurrent executions. |
| `maxQueueSize` | `Number`  | `10`    | Maximum size of queue          |

The `concurrency` value restricts the concurrent request executions. If the `maxQueueSize` is bigger than `0`, broker stores the additional requests in a queue if all slots are taken. If the queue size reaches the `maxQueueSize` limit or it is 0, broker will throw `QueueIsFull` exception for every addition requests.

### Action Settings

[Global settings](#Global-Settings) can be overridden in action definition.

**Overwrite the retry policy values in action definitions**
```js
// users.service.js
module.export = {
    name: "users",
    actions: {
        find: {
            bulkhead: {
                // Disable bulkhead for this action
                enabled: false
            },
            handler(ctx) {}
        },
        create: {
            bulkhead: {
                // Increment the concurrency value for this action
                concurrency: 10
            },
            handler(ctx) {}
        }
    }
};
```


### Events Settings
Event handlers also support [bulkhead](#Bulkhead) feature.

**Example**
```js
// my.service.js
module.exports = {
    name: "my-service",
    events: {
        "user.created": {
            bulkhead: {
                enabled: true,
                concurrency: 1
            },
            async handler(ctx) {
                // Do something.
            }
        }
    }
}
```

## Fallback
Fallback feature is useful, when you don't want to give back errors to the users. Instead, call an other action or return some common content. Fallback response can be set in calling options or in action definition. It should be a `Function` which returns a `Promise` with any content. The broker passes the current `Context` & `Error` objects to this function as arguments.

**Fallback response setting in calling options**
```js
const result = await broker.call("users.recommendation", { userID: 5 }, {
    timeout: 500,
    fallbackResponse(ctx, err) {
        // Return a common response from cache
        return broker.cacher.get("users.fallbackRecommendation:" + ctx.params.userID);
    }
});
```

### Fallback in action definition
Fallback response can be also defined in receiver-side, in action definition.
> Please note, this fallback response will only be used if the error occurs within action handler. If the request is called from a remote node and the request is timed out on the remote node, the fallback response is not be used. In this case, use the `fallbackResponse` in calling option.

**Fallback as a function**
```js
module.exports = {
    name: "recommends",
    actions: {
        add: {
            fallback: (ctx, err) => "Some cached result",
            handler(ctx) {
                // Do something
            }
        }
    }
};
```

**Fallback as method name string**
```js
module.exports = {
    name: "recommends",
    actions: {
        add: {
            // Call the 'getCachedResult' method when error occurred
            fallback: "getCachedResult",
            handler(ctx) {
                // Do something
            }
        }
    },

    methods: {
        getCachedResult(ctx, err) {
            return "Some cached result";
        }
    }
};
```
