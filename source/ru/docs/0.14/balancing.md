title: Балансирование нагрузки
---

Moleculer имеет несколько встроенных стратегий балансирования нагрузки. Если сервис запущен в нескольких экземплярах на разных узлах, ServiceRegistry использует эти стратегии для выбора одного из доступных узлов.

## Встроенные стратегии
Чтобы настроить стратегию, необходимо в файле конфигурации брокера указать свойство `strategy` в объекте `registry`. Это может быть либо именем (в случае встроенных стратегий) или `Strategy` классом, который унаследован от `BaseStrategy` (в случае пользовательских стратегий).

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

| Название      | Тип      | По умолчанию | Описание                                                                                                   |
| ------------- | -------- | ------------ | ---------------------------------------------------------------------------------------------------------- |
| `sampleCount` | `Number` | `3`          | The number of samples. _To turn of sampling, set to `0`._                                                  |
| `lowCpuUsage` | `Number` | `10`         | The low CPU usage percent (%). The node which has lower CPU usage than this value is selected immediately. |

**Usage with custom options**
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

### Latency-based strategy
This strategy selects a node that has the lowest latency, measured by periodic ping commands. Notice that the strategy only ping one node / host. Since the node list can be very long, it gets samples and selects the host with the lowest latency only from a sample instead of the whole node list.

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

| Название       | Тип      | По умолчанию | Описание                                                                                                                              |
| -------------- | -------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `sampleCount`  | `Number` | `5`          | The number of samples. If you have a lot of hosts/nodes, it's recommended to *increase* the value. _To turn of sampling, set to `0`._ |
| `lowLatency`   | `Number` | `10`         | The low latency (ms). The node which has lower latency than this value is selected immediately.                                       |
| `collectCount` | `Number` | `5`          | The number of measured latency per host to keep in order to calculate the average latency.                                            |
| `pingInterval` | `Number` | `10`         | Ping interval in seconds. If you have a lot of host/nodes, it's recommended to *increase* the value.                                  |

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