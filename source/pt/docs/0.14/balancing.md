title: Balanceamento de carga
---

Moleculer tem várias estratégias de balanceamento de carga embutidas. Se um serviço estiver rodando em múltiplas instâncias de nós, o ServiceRegistry utiliza essas estratégias para selecionar um único nó entre os que estão disponíveis.

## Estratégias integradas
Para configurar a estratégia, defina a propriedade `strategy` que está contida em `registry` nas configurações do broker. O valor pode ser um nome (em caso de estratégias incorporadas) ou uma classe `Strategy` que herde de `BaseStrategy` (em caso de estratégias personalizadas).

### Estratégia RoundRobin
Esta estratégia seleciona um nó baseando-se no algoritmo [round-robin](https://en.wikipedia.org/wiki/Round-robin_DNS).

**Utilização**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "RoundRobin"
    }
};
```

### Estratégia aleatória
Esta estratégia seleciona um nó aleatoriamente.

**Utilização**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Random"
    }
};
```
### Estratégia baseada na CPU
Esta estratégia seleciona um nó que possui o menor uso de CPU. Uma vez que a lista de nós pode ser muito longa, a estratégia se baseia em amostragem, selecionando o nó com a menor utilização de CPU à partir da amostra verificada ao invés de verificar toda a lista de nós.

**Utilização**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "CpuUsage"
    }
};
```

**Opções da estratégia**

| Nome          | Tipo     | Valor padrão | Descrição                                                                                                                |
| ------------- | -------- | ------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `sampleCount` | `Number` | `3`          | O número de amostras. _Para desativar a amostragem, defina como `0`._                                                    |
| `lowCpuUsage` | `Number` | `10`         | A porcentagem de uso da CPU (%). O nó que possuir utilização de CPU menor do que este valor é selecionado imediatamente. |

**Uso com opções personalizadas**
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

### Estratégia baseada em latência
Esta estratégia seleciona o nó que tem a mais baixa latência, medida por comandos de ping periódicos. Observe que essa estratégia somente pinga um nó / host. Uma vez que a lista de nós pode ser muito longa, a estratégia se baseia em amostragem, selecionando o nó com a menor latência à partir da amostra verificada ao invés de verificar toda a lista de nós.

**Utilização**
```js
// moleculer.config.js
module.exports = {
    registry: {
        strategy: "Latency"
    }
};
```

**Opções da estratégia**

| Nome           | Tipo     | Valor padrão | Descrição                                                                                                                                |
| -------------- | -------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `sampleCount`  | `Number` | `5`          | O número de amostras. Se você tem muitos hosts/nós, é recomendado *aumentar* esse valor. _Para desativar a amostragem, defina como `0`._ |
| `lowLatency`   | `Number` | `10`         | A menor latência (ms). O nó que possuir latência menor do que este valor é selecionado imediatamente.                                    |
| `collectCount` | `Number` | `5`          | O número de medições de latência por host para calcular a latência média.                                                                |
| `pingInterval` | `Number` | `10`         | Intervalo de ping em segundos. Se você tem muitos host/nós, é recomendado que *aumente* este valor.                                      |

**Uso com opções personalizadas**
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

### Estratégia de sharding
A estratégia de sharding é baseada no algoritmo [consistent-hashing](https://www.toptal.com/big-data/consistent-hashing). Utiliza um valor chave definido em `params` ou `meta` do contexto para rotear o pedido para os nós. Isto significa que pedidos com o mesmo valor chave serão encaminhados para o mesmo nó.

**Exemplo de uma shard key `name` em `params`**
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

**Exemplo de uma shard key `user.id` em `meta`**
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
Se a shard key estiver em `meta` ela deve ser declarada no início com um `#`. O `#` é ignorado e é utilizado apenas o valor que existe após ele.
{% endnote %}

**Opções da estratégia**

| Nome        | Tipo     | Valor padrão | Descrição              |
| ----------- | -------- | ------------ | ---------------------- |
| `shardKey`  | `String` | `null`       | Shard key              |
| `vnodes`    | `Number` | `10`         | Número de nós virtuais |
| `ringSize`  | `Number` | `2^32`       | Tamanho do anel        |
| `cacheSize` | `Number` | `1000`       | Tamanho do cache       |


**Todas as opções disponíveis na estratégia de Sharding**
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
## Sobrescrever opções globais
Você pode sobrescrever a estratégia de balanceamento definida globalmente nas definições de ações/eventos.

**Usando estratégia 'Shard' para a ação 'hello' ao invés da global 'RoundRobin'**
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



## Estratégia personalizada
Uma estratégia customizada pode ser criada. Recomendamos copiar o código fonte de [RandomStrategy](https://github.com/moleculerjs/moleculer/blob/master/src/strategies/random.js) e implementar o método `select`.

### Criar estratégia personalizada
```js
const BaseStrategy = require("moleculer").Strategies.Base;

class MyStrategy extends BaseStrategy {
    select(list, ctx) { /*...*/ }
}

module.exports = MyStrategy;
```

### Use custom strategy

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