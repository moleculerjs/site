title: Балансировка нагрузки
---

Moleculer имеет несколько встроенных стратегий балансировки нагрузки. Если сервис запущен в нескольких экземплярах на разных узлах, ServiceRegistry использует эти стратегии для выбора одного из доступных узлов.

## Доступные стратегии
Чтобы настроить стратегию, необходимо в файле конфигурации брокера указать свойство `strategy` в объекте `registry`. Это может быть либо именем (в случае доступных стратегий) или `Strategy` классом, который унаследован от `BaseStrategy` (в случае пользовательских стратегий).

### Стратегия RoundRobin
Эта стратегия выбирает узел на основе алгоритма [round-robin](https://en.wikipedia.org/wiki/Round-robin_DNS).

**Использование**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "RoundRobin"
    }
};
```

### Случайная стратегия
Эта стратегия случайно выбирает узел.

**Использование**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Random"
    }
};
```
### Стратегия по нагрузке CPU
Эта стратегия выбирает узел с менее загруженным процессором. Поскольку список узлов может быть очень длинным, то брокер получает измерения и выбирает узел с наименьшей загруженностью процессора только из имеющихся данных, а не всего списка узлов.

**Использование**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "CpuUsage"
    }
};
```

**Настройки**

| Название      | Тип      | По умолчанию | Описание                                                                                               |
| ------------- | -------- | ------------ | ------------------------------------------------------------------------------------------------------ |
| `sampleCount` | `Number` | `3`          | Количество измерений. _Чтобы выключить, установите `0`._                                               |
| `lowCpuUsage` | `Number` | `10`         | Процент загруженности процессора (%). Минимальный порог при котором узел будет выбран незамедлительно. |

**Использование с пользовательскими настройками**
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

### Стратегия по времени отклика
Эта стратегия выбирает узел, который имеет самую низкую задержку, измеряемую периодическими командами ping. Обратите внимание, что данная стратегия позволяет опрашивать только один узел / хост. Поскольку список узлов может быть очень длинным, то брокер получает измерения и выбирает узел с наименьшей задержкой только из имеющихся данных, а не всего списка узлов.

**Использование**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Latency"
    }
};
```

**Настройки**

| Название       | Тип      | По умолчанию | Описание                                                                                                                    |
| -------------- | -------- | ------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `sampleCount`  | `Number` | `5`          | Количество измерений. Если у вас много хостов/узлов, рекомендуется *увеличить* значение. _Чтобы выключить, установите `0`._ |
| `lowLatency`   | `Number` | `10`         | Минимальная задержка (мс). Минимальный порог при котором узел будет выбран незамедлительно.                                 |
| `collectCount` | `Number` | `5`          | Количество измерений задержки на каждый хост для расчета средней задержки.                                                  |
| `pingInterval` | `Number` | `10`         | Интервал пинга в секундах. Если у вас много хостов/узлов, рекомендуется *увеличить* значение.                               |

**Использование с пользовательскими настройками**
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

### Стратегия шардирования
Стратегия поиска шарда основана на алгоритме [согласованного хеширования](https://www.toptal.com/big-data/consistent-hashing). Он использует значение ключа из контекста `params` или `meta` для распределения запросов между узлами. Это означает, что запросы с одним значением ключа будут отправлены на один и тот же узел.

**Пример ключа шардирования `name` в контексте `params`**
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

**Пример ключа шардирования `user.id` в контексте `meta`**
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
Если ключ шардирования находится в контексте `meta`, то он должен начинаться с символа `#`. Символ `#` игнорируется.
{% endnote %}

**Настройки шардирования**

| Название    | Тип      | По умолчанию | Описание                     |
| ----------- | -------- | ------------ | ---------------------------- |
| `shardKey`  | `String` | `null`       | Ключ шардирования            |
| `vnodes`    | `Number` | `10`         | Количество виртуальных узлов |
| `ringSize`  | `Number` | `2^32`       | Размер кольца                |
| `cacheSize` | `Number` | `1000`       | Размер кэша                  |


**Все доступные настройки стратегии шардирования**
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
## Переопределение глобальных параметров
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



## Своя стратегия
Можно создать свою стратегию. Мы рекомендуем использовать исходный код [RandomStrategy](https://github.com/moleculerjs/moleculer/blob/master/src/strategies/random.js) и использовать метод `select`.

### Создание собственной стратегии
```js
const BaseStrategy = require("moleculer").Strategies.Base;

class MyStrategy extends BaseStrategy {
    select(list, ctx) { /*...*/ }
}

module.exports = MyStrategy;
```

### Использование собственной стратегии

```js
const { ServiceBroker } = require("moleculer");
const MyStrategy = require("./my-strategy");

// moleculer.config.js
module.exports = {
    registry: {
        strategy: MyStrategy
    }
};
```