title: Cache
---

Moleculer tem uma solução integrada para armazenar em cache as respostas das ações dos serviços. Para ativá-lo, defina um tipo de `cache` em [opções do broker](configuration.html#Broker-options) e defina `cache: true` nas [configurações de ações](services.html#Actions) daquilo que quiser manter em cache.

**Exemplo de ação em cache**
```js
const { ServiceBroker } = require("moleculer");

// Create broker
const broker = new ServiceBroker({
    cacher: "Memory"
});

// Create a service
broker.createService({
    name: "users",
    actions: {
        list: {
            // Enable caching to this action
            cache: true, 
            handler(ctx) {
                this.logger.info("Handler called!");
                return [
                    { id: 1, name: "John" },
                    { id: 2, name: "Jane" }
                ]
            }
        }
    }
});

broker.start()
    .then(() => {
        // Will be called the handler, because the cache is empty
        return broker.call("users.list").then(res => broker.logger.info("Users count:", res.length));
    })
    .then(() => {
        // Return from cache, handler won't be called
        return broker.call("users.list").then(res => broker.logger.info("Users count from cache:", res.length));
    });
```

**Mensagens do console:**
```
[2017-08-18T13:04:33.845Z] INFO  dev-pc/BROKER: Broker started.
[2017-08-18T13:04:33.848Z] INFO  dev-pc/USERS: Handler called!
[2017-08-18T13:04:33.849Z] INFO  dev-pc/BROKER: Users count: 2
[2017-08-18T13:04:33.849Z] INFO  dev-pc/BROKER: Users count from cache: 2
```
Como pode ver, a mensagem `Handler called` aparece apenas uma vez porque a resposta da segunda requisição é retornada do cache.

> [Experimente no Runkit](https://runkit.com/icebob/moleculer-cacher-example2)

## Chaves de cache
O cache gera a chave a partir do nome do serviço, nome da ação e os parâmetros do context. A sintaxe da chave é:
```
<serviceName>.<actionName>:<parameters or hash of parameters>
```
Então, se você chamar a ação `posts.list` com parâmetros `{ limit: 5, offset: 20 }`, o cache calcula um hash dos parâmetros. Então, da próxima vez, quando você chamar esta ação com os mesmos parâmetros, ele encontrará a entrada no cache pela chave.

**Exemplo de chave de cache para a ação "post.find"**
```
posts.find:limit|5|offset|20
```

O objeto params pode conter propriedades que não são relevantes para a chave de cache. Além disso, pode causar problemas de desempenho, se a chave for muito longa. Portanto, é recomendado definir um objeto para a propriedade `cache` que contém uma lista de nomes de parâmetros essenciais sob a propriedade `keys`. Para usar campos do meta no cache via propriedade `keys` use o prefixo `#`.

**Restringe a lista de `params` & propriedades `meta` para a geração de chaves**
```js
{
    name: "posts",
    actions: {
        list: {
            cache: {
                //  generate cache key from "limit", "offset" params and "user.id" meta
                keys: ["limit", "offset","#user.id"]
            },
            handler(ctx) {
                return this.getList(ctx.params.limit, ctx.params.offset);
            }
        }
    }
}

// If params is { limit: 10, offset: 30 } and meta is { user: { id: 123 } }, 
// the cache key will be:
//   posts.list:10|30|123
```

{% note info Performance tip %}
Esta solução é muito rápida, por isso recomendamos usá-la em produção. ![](https://img.shields.io/badge/performance-%2B20%25-brightgreen.svg)
{% endnote %}

### Limitando tamanho da chave cache
Às vezes, a chave pode ser muito longa, o que pode causar problemas de desempenho. Para evitar isso, limite o tamanho dos parâmetros concatenados na chave com a opção de cache `maxParamsLength`. Quando a chave é maior do que o valor limite configurado, o cache calcula um hash (SHA256) da chave completa e a adiciona ao fim da chave.

> O mínimo de `maxParamsLength` é `44` (Tamanho do hash SHA 256 em Base64).
> 
> Para desativar este recurso, defina como `0` ou `null`.

**Gerar uma chave completa a partir de todos os parâmetros sem limite**
```js
cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. So this key will also be too long" });
// Key: 'posts.find:id|2|title|New post|content|It can be very very looooooooooooooooooong content. Portanto, esta chave será também muito longa'
```

**Gerar uma chave de comprimento limitado**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            maxParamsLength: 60
        }
    }
});

cacher.getCacheKey("posts.find", { id: 2, title: "New post", content: "It can be very very looooooooooooooooooong content. So this key will also be too long" });
// Key: 'posts.find:id|2|title|New pL4ozUU24FATnNpDt1B0t1T5KP/T5/Y+JTIznKDspjT0='
```

## Cache condicional

O cache condicional permite ignorar a resposta em cache e executar uma ação para obter dados "frescos". Para ignorar o cache defina `ctx.meta.$cache` para `false` antes de chamar uma ação.

**Exemplo desativando o cache para a ação `greeter.hello`**
```js
broker.call("greeter.hello", { name: "Moleculer" }, { meta: { $cache: false }}))
```

Como alternativa, uma função personalizada pode ser implementada para ignorar o cache. A função personalizada aceita como argumento uma instância do context (`ctx`), portanto, ela tem acesso a quaisquer parâmetros ou meta dados. Isso permite passar o sinalizador bypass dentro da requisição.

**Exemplo de uma função de cache condicional personalizada**
```js
// greeter.service.js
module.exports = {
    name: "greeter",
    actions: {
        hello: {
            cache: {
                enabled: ctx => ctx.params.noCache !== true, //`noCache` passed as a parameter
                keys: ["name"]
            },
            handler(ctx) {
                this.logger.debug(chalk.yellow("Execute handler"));
                return `Hello ${ctx.params.name}`;
            }
        }
    }
};

// Use custom `enabled` function to turn off caching for this request
broker.call("greeter.hello", { name: "Moleculer", noCache: true }))
```

## TTL
A configuração padrão de TTL pode ser substituída na definição de ação.

```js
const broker = new ServiceBroker({
    cacher: {
        type: "memory",
        options: {
            ttl: 30 // 30 seconds
        }
    }
});

broker.createService({
    name: "posts",
    actions: {
        list: {
            cache: {
                // These cache entries will be expired after 5 seconds instead of 30.
                ttl: 5
            },
            handler(ctx) {
                // ...
            }
        }
    }
});
```

## Gerador de chaves personalizado
Para sobrescrever o gerador de chaves de cache interno, defina sua própria função como `keygen` nas opções do cache.

```js
const broker = new ServiceBroker({
    cacher: {
        type: "memory",
        options: {
            keygen(name, params, meta, keys) {
                // Generate a cache key
                // name - action name
                // params - ctx.params
                // meta - ctx.meta
                // keys - cache keys defined in action
                return "";
            }
        }
    }
});
```

## Cache manual
O módulo de cache pode ser usado manualmente. Basta chamar os métodos `get`, `set`, `del` do `broker.cacher`.

```js
// Save to cache
broker.cacher.set("mykey.a", { a: 5 });

// Get from cache (async)
const obj = await broker.cacher.get("mykey.a")

// Remove entry from cache
await broker.cacher.del("mykey.a");

// Clean all 'mykey' entries
await broker.cacher.clean("mykey.**");

// Clean all entries
await broker.cacher.clean();
```

Além disso, a API completa do cliente [ioredis](https://github.com/luin/ioredis) está disponível em `broker.cacher.client` quando estiver usando o cache Redis integrado:

```js
// create an ioredis pipeline
const pipeline = broker.cacher.client.pipeline();
// set values in cache
pipeline.set('mykey.a', 'myvalue.a');
pipeline.set('mykey.b', 'myvalue.b');
// execute pipeline
pipeline.exec();
```

## Limpar cache
Ao criar um novo registro em seu serviço, você deve limpar as entradas em cache antigas.

**Exemplo de como limpar o cache dentro das ações**
```js
{
    name: "users",
    actions: {
        create(ctx) {
            // Create new user entity
            const user = new User(ctx.params);

            // Clear all cache entries
            this.broker.cacher.clean();

            // Clear all cache entries which keys start with `users.`
            this.broker.cacher.clean("users.**");

            // Clear multiple cache entries
            this.broker.cacher.clean([ "users.**", "posts.**" ]);

            // Delete an entry
            this.broker.cacher.del("users.list");

            // Delete multiple entries
            this.broker.cacher.del([ "users.model:5", "users.model:8" ]);
        }
    }
}
```

### Limpar cache entre várias instâncias de serviço
A melhor prática para limpar entradas de cache entre várias instâncias de serviço é usar eventos do tipo broadcast. Note que isso é somente necessário para cachers não centralizados como `Memory` ou `MemoryLRU`.

**Exemplo**
```js
module.exports = {
    name: "users",
    actions: {
        create(ctx) {
            // Create new user entity
            const user = new User(ctx.params);

            // Clear cache
            this.cleanCache();

            return user;
        }
    },

    methods: {
        cleanCache() {
            // Broadcast the event, so all service instances receive it (including this instance). 
            this.broker.broadcast("cache.clean.users");
        }
    },

    events: {
        "cache.clean.users"() {
            if (this.broker.cacher) {
                this.broker.cacher.clean("users.**");
            }
        }
    }
};
```

### Limpar cache entre diferentes serviços
Dependências entre serviços é uma situação comum. Ex.: O serviço de `posts` armazena em cache informações do serviço de `users` (quando houver campos populados).

**Exemplo de entrada de cache no serviço `posts`**
```js
{
    _id: 1,
    title: "My post",
    content: "Some content",
    author: {
        _id: 130,
        fullName: "John Doe",
        avatar: "https://..."
    },
    createdAt: 1519729167666
}
```
O campo `author` é recebido do serviço `users`. Então se o serviço `users` limpar as entradas de cache, o serviço `posts` também terá que limpar as próprias entradas de cache. Portanto, você também deve se subscrever ao evento `cache.clear.users` no serviço `posts`.

Para facilitar, crie um mixin `CacheCleaner` e defina no esquema de serviços dependentes.

**cache.cleaner.mixin.js**
```js
module.exports = function(serviceNames) {
    const events = {};

    serviceNames.forEach(name => {
        events[`cache.clean.${name}`] = function() {
            if (this.broker.cacher) {
                this.logger.debug(`Clear local '${this.name}' cache`);
                this.broker.cacher.clean(`${this.name}.*`);
            }
        };
    });

    return {
        events
    };
};
```

**posts.service.js**
```js
const CacheCleaner = require("./cache.cleaner.mixin");

module.exports = {
    name: "posts",
    mixins: [CacheCleaner([
        "users",
        "posts"
    ])],

    actions: {
        //...
    }
};
```

Com esta solução se o serviço `users` emitir um evento `cache.clean.users`, o serviço `posts` também limpará suas próprias entradas de cache.

## Bloqueio de cache
Moleculer também suporta o recurso de bloqueio de cache. Para informações detalhadas [verifique esta PR](https://github.com/moleculerjs/moleculer/pull/490).

**Ativar bloqueio**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: true, // Set to true to enable cache locks. Default is disabled.
    }
});
```

**Ativar com o TTL**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: {
            ttl: 15, // The maximum amount of time you want the resource locked in seconds
            staleTime: 10, // If the TTL is less than this number, means that the resources are staled
        }
    }
});
```

**Desativar Bloqueio**
```js
const broker = new ServiceBroker({
    cacher: {
        ttl: 60,
        lock: {
            enable: false, // Set to false to disable.
            ttl: 15, // The maximum amount of time you want the resource locked in seconds
            staleTime: 10, // If the TTL is less than this number, means that the resources are staled
        }
    }
});
```
**Exemplo de cache Redis com a biblioteca `redlock`**
```js
const broker = new ServiceBroker({
  cacher: {
    type: "Redis",
    options: {
      // Prefix for keys
      prefix: "MOL",
      // set Time-to-live to 30sec.
      ttl: 30,
      // Turns Redis client monitoring on.
      monitor: false,
      // Redis settings
      redis: {
        host: "redis-server",
        port: 6379,
        password: "1234",
        db: 0
      },
      lock: {
        ttl: 15, //the maximum amount of time you want the resource locked in seconds
        staleTime: 10, // If the TTL is less than this number, means that the resources are staled
      },
      // Redlock settings
      redlock: {
        // Redis clients. Support node-redis or ioredis. By default will use the local client.
        clients: [client1, client2, client3],
        // the expected clock drift; for more details
        // see http://redis.io/topics/distlock
        driftFactor: 0.01, // time in ms

        // the max number of times Redlock will attempt
        // to lock a resource before erroring
        retryCount: 10,

        // the time in ms between attempts
        retryDelay: 200, // time in ms

        // the max time in ms randomly added to retries
        // to improve performance under high contention
        // see https://www.awsarchitectureblog.com/2015/03/backoff.html
        retryJitter: 200 // time in ms
      }
    }
  }
});
```

## Caches integrados

### Cache de memória
`MemoryCacher` é um módulo de cache de memória integrado. Ele armazena entradas na memória.

**Habilitar cache de memória**
```js
const broker = new ServiceBroker({
    cacher: "Memory"
});
```
Ou
```js
const broker = new ServiceBroker({
    cacher: true
});
```

**Habilitar com opções**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Memory",
        options: {
            ttl: 30 // Set Time-to-live to 30sec. Disabled: 0 or null
            clone: true // Deep-clone the returned value
        }
    }
});
```

**Opções**

| Nome              | Tipo                    | Padrão  | Descrição                                            |
| ----------------- | ----------------------- | ------- | ---------------------------------------------------- |
| `ttl`             | `Number`                | `null`  | Tempo de Vida em segundos.                           |
| `clone`           | `Boolean` ou `Function` | `false` | Clonar os dados em cache quando retornarem.          |
| `keygen`          | `Function`              | `null`  | Função de gerador de chaves de cache personalizada.  |
| `maxParamsLength` | `Number`                | `null`  | Comprimento máximo de parâmetros nas chaves geradas. |
| `lock`            | `Boolean` ou `Object`   | `null`  | Ativar recurso de bloqueio.                          |

#### Clonagem
O cache usa o método lodash `_.cloneDeep` para clonagem. Para mudá-lo, defina uma `Função` para a opção `clone` em vez de um `Boolean`.

**Função de clone personalizada com parse de JSON & stringify**
```js
const broker = new ServiceBroker({ 
    cacher: {
        type: "Memory",
        options: {
            clone: data => JSON.parse(JSON.stringify(data))
        }
    }
});
```

### Cache de memória LRU
`Cache de memória LRU` é um módulo [cache LRU](https://github.com/isaacs/node-lru-cache) integrado. Ele exclui os itens menos usados recentemente.

**Habilitar cache LRU**
```js
const broker = new ServiceBroker({
    cacher: "MemoryLRU"
});
```

**Com opções**
```js
let broker = new ServiceBroker({
    logLevel: "debug",
    cacher: {
        type: "MemoryLRU",
        options: {
            // Maximum items
            max: 100,
            // Time-to-Live
            ttl: 3
        }
    }
});
```

**Opções**

| Nome              | Tipo                    | Valor padrão | Descrição                                            |
| ----------------- | ----------------------- | ------------ | ---------------------------------------------------- |
| `ttl`             | `Number`                | `null`       | Tempo de Vida em segundos.                           |
| `max`             | `Number`                | `null`       | Máximo de itens no cache.                            |
| `clone`           | `Boolean` ou `Function` | `false`      | Clonar os dados em cache quando retornarem.          |
| `keygen`          | `Function`              | `null`       | Função de gerador de chaves de cache personalizada.  |
| `maxParamsLength` | `Number`                | `null`       | Comprimento máximo de parâmetros nas chaves geradas. |
| `lock`            | `Boolean` ou `Object`   | `null`       | Ativar recurso de bloqueio.                          |


{% note info Dependencies %}
Para poder usar este cache, instale o módulo `lru-cache` com o comando `npm install lru-cache --save`.
{% endnote %}

### Cache Redis
`RedisCacher` é um módulo de cache distribuído baseado em [Redis](https://redis.io/). Ele usa a biblioteca [`ioredis`](https://github.com/luin/ioredis). Use-o, se você tem várias instâncias de serviços porque se uma instância armazena alguns dados no cache, outras instâncias o encontrarão.

**Habilitar cache do Redis**
```js
const broker = new ServiceBroker({
    cacher: "Redis"
});
```

**Com string de conexão**
```js
const broker = new ServiceBroker({
    cacher: "redis://redis-server:6379"
});
```

**Com opções**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            // Prefix for keys
            prefix: "MOL",            
            // set Time-to-live to 30sec.
            ttl: 30, 
            // Turns Redis client monitoring on.
            monitor: false 
            // Redis settings
            redis: {
                host: "redis-server",
                port: 6379,
                password: "1234",
                db: 0
            }
        }
    }
});
```

**Com o serializador MessagePack** Você pode definir um serializador para o Cache Redis. Por padrão, usa o serializador JSON.
```js
const broker = new ServiceBroker({
    nodeID: "node-123",
    cacher: {
        type: "Redis",
        options: {
            ttl: 30,

            // Using MessagePack serializer to store data.
            serializer: "MsgPack",

            redis: {
                host: "my-redis"
            }
        }
    }
});
```

**Com o cliente Redis Cluster**
```js
const broker = new ServiceBroker({
    cacher: {
        type: "Redis",
        options: {
            ttl: 30, 

            cluster: {
                nodes: [
                    { port: 6380, host: "127.0.0.1" },
                    { port: 6381, host: "127.0.0.1" },
                    { port: 6382, host: "127.0.0.1" }
                ],
                options: { /* More information: https://github.com/luin/ioredis#cluster */ }
            }   
        }
    }
});
```

**Opções**

| Nome              | Tipo                  | Valor padrão | Descrição                                                                                                                                                                      |
| ----------------- | --------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `prefix`          | `String`              | `null`       | Prefixo para chaves geradas.                                                                                                                                                   |
| `ttl`             | `Number`              | `null`       | Tempo de Vida em segundos. Desativado: 0 ou null                                                                                                                               |
| `monitor`         | `Boolean`             | `false`      | Ativar o [recurso de monitoramento do cliente Redis](https://github.com/luin/ioredis#monitor). Se ativado, todas as operações do cliente serão registradas (no nível de debug) |
| `redis`           | `Object`              | `null`       | Opções personalizadas de Redis. Serão transferidas ao construtor `new Redis()`. [Leia mais](https://github.com/luin/ioredis#connect-to-redis).                                 |
| `keygen`          | `Function`            | `null`       | Função de gerador de chaves de cache personalizada.                                                                                                                            |
| `maxParamsLength` | `Number`              | `null`       | Comprimento máximo de parâmetros nas chaves geradas.                                                                                                                           |
| `serializer`      | `String`              | `"JSON"`     | Nome de um serializador integrado.                                                                                                                                             |
| `cluster`         | `Object`              | `null`       | Configuração do cliente Redis Cluster. [Mais informações](https://github.com/luin/ioredis#cluster)                                                                             |
| `lock`            | `Boolean` ou `Object` | `null`       | Ativar recurso de bloqueio.                                                                                                                                                    |
| `pingInterval`    | `Number`              | `null`       | Emitir um comando Redis PING a cada `pingInterval` milissegundos. Pode ser usado para manter as conexões ativas apesar do timeout.                                             |

{% note info Dependencies %}
Para poder usar esse cacher, instale o módulo `ioredis` com o comando `npm install ioredis --save`.
{% endnote %}


## Cache personalizado
Um módulo de cache personalizado pode ser criado. Recomendamos copiar o código fonte do [MemoryCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/memory.js) or [RedisCacher](https://github.com/moleculerjs/moleculer/blob/master/src/cachers/redis.js) e implementar os métodos `get`, `set`, `del` e `clean`.

### Criar cache personalizado
```js
const BaseCacher = require("moleculer").Cachers.Base;

class MyCacher extends BaseCacher {
    async get(key) { /*...*/ }
    async set(key, data, ttl) { /*...*/ }
    async del(key) { /*...*/ }
    async clean(match = "**") { /*...*/ }
}
```

### Usar cache personalizado

```js
const { ServiceBroker } = require("moleculer");
const MyCacher = require("./my-cacher");

const broker = new ServiceBroker({
    cacher: new MyCacher()
});
```