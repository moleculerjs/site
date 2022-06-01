title: Tolerância a falhas
---

Moleculer tem vários recursos integrados de tolerância a falhas. Eles podem ser habilitados ou desabilitados nas opções de broker.

## Circuit Breaker

Moleculer tem uma solução integrada que aplica o padrão circuit-breaker. Trata-se de uma implementação baseada em limites. Ele usa uma janela do tempo para verificar a taxa de falha das requisições. Uma vez que o limite é atingido, ele aciona o disjuntor.

{% note info O que é circuit breaker? %}
O Circuit Breaker pode impedir que um aplicativo tente repetidamente executar uma operação que provavelmente falhará. Permitindo que continue sem esperar que a falha seja corrigida ou desperdiçando processamento enquanto determina que a falha ainda persiste. O padrão Circuit Breaker também permite que uma aplicação detecte se a falha foi resolvida. Se o problema parece ter sido corrigido, a aplicação pode tentar chamar a operação.

Leia mais sobre o circuit breaker no [blog Martin Fowler](https://martinfowler.com/bliki/CircuitBreaker.html) ou no [Microsoft Azure Docs](https://docs.microsoft.com/azure/architecture/patterns/circuit-breaker).
{% endnote %}

Se ativá-lo, todas as chamadas de serviço serão protegidas pelo circuit breaker.

**Habilite-o nas opções do broker**
```js
const broker = new ServiceBroker({
    circuitBreaker: {
        enabled: true,
        threshold: 0.5,
        minRequestCount: 20,
        windowTime: 60, // in seconds
        halfOpenTime: 5 * 1000, // in milliseconds
        check: err => err && err.code >= 500
    }
});
```

### Configurações

| Nome              | Tipo       | Valor padrão                        | Descrição                                                                    |
| ----------------- | ---------- | ----------------------------------- | ---------------------------------------------------------------------------- |
| `enabled`         | `Boolean`  | `false`                             | Ativar recurso                                                               |
| `threshold`       | `Number`   | `0.5`                               | Valor limite. `0.5` significa que 50% deve falhar para ser acionado.         |
| `minRequestCount` | `Number`   | `20`                                | Contagem mínima de requisições. Abaixo dele, Circuit Breaker não é acionado. |
| `windowTime`      | `Number`   | `60`                                | Número de segundos para a janela de tempo.                                   |
| `halfOpenTime`    | `Number`   | `10000`                             | Número de milissegundos para mudar de `aberto` para estado `semiaberto`      |
| `check`           | `Function` | `err && err.code >= 500` | Uma função para verificar falhas de requisições.                             |

> Se o estado do circuit breaker for alterado, o ServiceBroker enviará [eventos internos](events.html#circuit-breaker-opened).

Estas opções globais também podem ser substituídas nas definições de ações.
```js
// users.service.js
module.export = {
    name: "users",
    actions: {
        create: {
            circuitBreaker: {
                // All CB options can be overwritten from broker options.
                threshold: 0.3,
                windowTime: 30
            },
            handler(ctx) {}
        }
    }
};
```

## Retry
Há uma solução de backoff exponencial. Ele pode chamar novamente solicitações que falharam.

**Habilite-o nas opções do broker**
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

### Configurações

| Nome       | Tipo       | Valor padrão                     | Descrição                                                        |
| ---------- | ---------- | -------------------------------- | ---------------------------------------------------------------- |
| `enabled`  | `Boolean`  | `false`                          | Ativar recurso.                                                  |
| `retries`  | `Number`   | `5`                              | Contagem de tentativas.                                          |
| `delay`    | `Number`   | `100`                            | Primeiro atraso em milissegundos.                                |
| `maxDelay` | `Number`   | `2000`                           | Atraso máximo em milissegundos.                                  |
| `fator`    | `Number`   | `2`                              | Fator retroativo para atraso. `2` significa backoff exponencial. |
| `check`    | `Function` | `err && !!err.retryable` | Uma função para verificar falhas de requisições.                 |

**Substituir valor de retentativas na opções de chamada**
```js
broker.call("posts.find", {}, { retries: 3 });
```

**Sobrescrever os valores da política de repetição nas definições da ação**
```js
// users.service.js
module.export = {
    name: "users",
    actions: {
        find: {
            retryPolicy: {
                // All Retry policy options can be overwritten from broker options.
                retries: 3,
                delay: 500
            },
            handler(ctx) {}
        },
        create: {
            retryPolicy: {
                // Disable retries for this action
                enabled: false
            },
            handler(ctx) {}
        }
    }
};
```

## Timeout
Um Timeout pode ser definido para chamadas de serviço. Ele pode ser definido globalmente nas opções do broker ou nas opções de chamada. Se o tempo limite for definido e a requisição for expirada, o broker irá lançar um erro `RequestTimeoutError`.

**Habilite-o nas opções do broker**
```js
const broker = new ServiceBroker({
    requestTimeout: 5 * 1000 // in milliseconds
});
```

**Substituir o valor de timeout nas opções de chamada**
```js
broker.call("posts.find", {}, { timeout: 3000 });
```

### Timeout distribuido
Moleculer uses [distributed timeouts](https://www.getambassador.io/learn/service-mesh/resilience-for-distributed-systems/#:~:text=too%20many%20times.-,Deadlines,-In%20addition%20to). Em caso de chamadas aninhadas, o valor do timeout é reduzido com o tempo decorrido. Se o valor do timeout for menor ou igual a 0, as próximas chamadas aninhadas serão ignoradas (`RequestippedError`) porque a primeira chamada já foi rejeitada com um erro `RequestTimeoutError` erro.

## Bulkhead
O recurso Bulkhead está implementado no framework Moleculer para controlar a execução de requisições simultâneas.

**Habilite-o nas opções do broker**
```js
const broker = new ServiceBroker({
    bulkhead: {
        enabled: true,
        concurrency: 3,
        maxQueueSize: 10,
    }
});
```

### Configurações Globais

| Nome           | Tipo      | Valor padrão | Descrição                        |
| -------------- | --------- | ------------ | -------------------------------- |
| `enabled`      | `Boolean` | `false`      | Ativar recurso.                  |
| `concurrency`  | `Number`  | `3`          | Máximo de execuções simultâneas. |
| `maxQueueSize` | `Number`  | `10`         | Tamanho máximo da fila           |

O valor de `concurrency` restringe as execuções simultâneas. Se o `maxQueueSize` for maior que `0`, o broker armazena as solicitações adicionais em uma fila se todos os slots estiverem ocupados. Se o tamanho da fila atingir o limite `maxQueueSize`, o broker lançará a exceção `QueueIsFull` para cada requisição adicional.

### Configurações de ação

[As configurações globais](#Global-Settings) podem ser substituídas nas definições da ação.

**Sobrescrever os valores da política de repetição nas definições da ação**
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


### Configurações de eventos
Os manipuladores de eventos também suportam o recurso [bulkhead](#Bulkhead).

**Exemplo**
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
O Recurso de fallback é útil, quando você não quer devolver erros aos usuários. Em vez disso, chame uma outra ação ou retorne algum conteúdo padrão. A resposta de fallback pode ser definida nas opções de chamada ou nas definições da ação. Deve ser uma `Function` que retorna uma `Promise` com qualquer conteúdo. O broker passa os objetos `Context` & `Error` atuais para esta função como argumentos.

**Configuração de resposta de fallback em opções de chamada**
```js
const result = await broker.call("users.recommendation", { userID: 5 }, {
    timeout: 500,
    fallbackResponse(ctx, err) {
        // Return a common response from cache
        return broker.cacher.get("users.fallbackRecommendation:" + ctx.params.userID);
    }
});
```

### Fallback nas definições da ação
A resposta de fallback também pode ser definida no lado do destinatário, nas definições da ação.
> Por favor, note que esta resposta de fallback só será usada se o erro ocorrer dentro do manipulador da ação. Se a requisição for chamada de um nó remoto e a requisição for expirada no nó remoto, a resposta de fallback não é usada. Neste caso, use o `fallbackResponse` nas opções da chamada.

**Fallback como função**
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

**Fallback como nome de um método em formato string**
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
