title: Registro & Descoberta
---

## Descoberta de serviço dinâmico
O framework Moleculer possui um módulo integrado responsável pela descoberta e verificação periódica de sinal de vida de cada nó. A descoberta é dinâmica significando que um nó não precisa saber nada sobre outros nós durante a inicialização. Quando ele inicia, ele vai anunciar sua presença a todos os outros nós para que cada um possa construir seu próprio registro de serviço local. Em caso de falha de um nó (ou parada) outros nós irão detectá-lo e remover os serviços afetados do seu registro. Desta forma, as próximas requisições serão encaminhados para nós ativos.

### Local
A Descoberta local (opção padrão) usa o [módulo de transporte](networking.html#Transporters) para trocar informações do nó e pacotes de sinal de vida (para mais informações sobre a estrutura dos pacotes, verifique o [protocolo Moleculer](https://github.com/moleculer-framework/protocol/blob/master/4.0/PROTOCOL.md)). É o mais simples e o mais rápido entre os mecanismos de descoberta disponíveis, pois não requer nenhuma solução externa. No entanto, este método de descoberta também tem alguns inconvenientes, especialmente para implantações de grande escala com mais de `100` nós. Os pacotes de sinal de vida podem gerar grande quantidade de tráfego que podem saturar o protocolo de comunicação e, portanto, deteriorar o desempenho de ações e eventos, por exemplo, lentidão na entrega de requisições/resposta e pacotes de eventos.


{% note warn%}
Observe que o módulo de transporte TCP usa o protocolo Gossip & pacotes UDP para descoberta & sinal de vida, o que significa que só pode funcionar como mecanismo local de descoberta.
{% endnote %}

**Descoberta local com opções padrão**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Local"
    }    
}
```

**Descoberta local com opções personalizadas**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: {
            type: "Local",
            options: {
                // Send heartbeat in every 10 seconds
                heartbeatInterval: 10,

                // Heartbeat timeout in seconds
                heartbeatTimeout: 30,

                // Disable heartbeat checking & sending, if true
                disableHeartbeatChecks: false,

                // Disable removing offline nodes from registry, if true
                disableOfflineNodeRemoving: false,

                // Remove offline nodes after 10 minutes
                cleanOfflineNodesTimeout: 10 * 60
            }
        }
    }    
}
```

### Redis
![Módulo de Transporte experimental](https://img.shields.io/badge/status-experimental-orange.svg) A descoberta baseada em Redis usa uma conexão dedicada com o [servidor Redis](https://redis.io/) para compartilhar descobertas e pacotes de sinal de vida. Esta abordagem reduz a carga sobre o módulo de transporte; e é usada exclusivamente para compartilhamento de requisições, respostas, pacotes de eventos.

Quando o método de descoberta baseado em Redis está habilitado, os nós do Moleculer publicam e buscam periodicamente a informação no Redis e atualizam seu registro de serviços interno. Mecanismo de expiração de chaves do Redis remove nós que não publicam pacotes de sinal de vida por um determinado período de tempo. Isto permite que nós do Moleculer detectem que um nó específico foi desconectado.

Por favor, note que este método é mais lento para detectar novos nós já que ele depende de verificações periódicas de sinal de vida no servidor Redis. A periodicidade depende da opção `heartbeatInterval` do broker.

{% note info%}
Para usar a descoberta via Redis instale o módulo `ioredis` com o comando `npm install ioredis --save`.
{% endnote %}

**Exemplo de conexão em um servidor Redis local**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Redis"
    }    
}
```


**Exemplo de conexão em um servidor Redis remoto**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "redis://redis-server:6379"
    }    
}
```

**Exemplo com opções**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: {
            type: "Redis",
            options: {
                redis: {
                    // Redis connection options.
                    // More info: https://github.com/luin/ioredis#connect-to-redis
                    port: 6379,
                    host: "redis-server",
                    password: "123456",
                    db: 3
                }

                // Serializer
                serializer: "JSON",

                // Full heartbeat checks. It generates more network traffic
                // 10 means every 10 cycle.
                fullCheck: 10,

                // Key scanning size
                scanLength: 100,

                // Monitoring Redis commands
                monitor: true,

                // --- COMMON DISCOVERER OPTIONS ---

                // Send heartbeat in every 10 seconds
                heartbeatInterval: 10,

                // Heartbeat timeout in seconds
                heartbeatTimeout: 30,

                // Disable heartbeat checking & sending, if true
                disableHeartbeatChecks: false,

                // Disable removing offline nodes from registry, if true
                disableOfflineNodeRemoving: false,

                // Remove offline nodes after 10 minutes
                cleanOfflineNodesTimeout: 10 * 60
            }
        }
    }    
}
```

{% note info%}
Dica: Para reduzir ainda mais o tráfego de rede, use os serializadores [ MsgPack/Notepack](networking.html#MsgPack-serializer) ao invés de JSON.
{% endnote %}

### etcd3
![Módulo de Transporte experimental](https://img.shields.io/badge/status-experimental-orange.svg)

O método de descoberta baseado em Etcd3 é muito semelhante ao [descoberta baseada em Redis](#Redis). Ele armazena sinais de vida e pacotes de descoberta no [servidor etcd3](https://etcd.io/). A opção [lease](https://etcd.io/docs/v3.4.0/learning/api/#lease-api) do etcd3 removerá as informações de sinal de vida dos nós que caírem ou forem desconectados da rede.

Este método tem os mesmos pontos fortes e fracos da descoberta baseada em Redis. Ele não usa o módulo de transporte para a descoberta, mas também é mais lento para detectar nós novos ou desconectados.

{% note info%}
Para usar a descoberta via etcd3 instale o módulo `etcd3` com o comando `npm install etcd3 --save`.
{% endnote %}

**Exemplo para conectar o servidor local etcd3**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "Etcd3"
    }    
}
```

**Exemplo de conexão do servidor remoto etcd3**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: "etcd3://etcd-server:2379"
    }    
}
```

**Exemplo com opções**
```js
// moleculer.config.js
module.exports = {
    registry: {
        discoverer: {
            type: "Etcd3",
            options: {
                etcd: {
                    // etcd3 connection options.
                    // More info: https://mixer.github.io/etcd3/interfaces/options_.ioptions.html
                    hosts: "etcd-server:2379",
                    auth: "12345678"
                }

                // Serializer
                serializer: "JSON",

                // Full heartbeat checks. It generates more network traffic
                // 10 means every 10 cycle.
                fullCheck: 10,

                // --- COMMON DISCOVERER OPTIONS ---

                // Send heartbeat in every 10 seconds
                heartbeatInterval: 10,

                // Heartbeat timeout in seconds
                heartbeatTimeout: 30,

                // Disable heartbeat checking & sending, if true
                disableHeartbeatChecks: false,

                // Disable removing offline nodes from registry, if true
                disableOfflineNodeRemoving: false,

                // Remove offline nodes after 10 minutes
                cleanOfflineNodesTimeout: 10 * 60
            }
        }
    }    
}
```

{% note info%}
Dica: Para reduzir ainda mais o tráfego de rede, use os serializadores [ MsgPack/Notepack](networking.html#MsgPack-serializer) ao invés de JSON.
{% endnote %}

### Personalização
Você pode criar seu mecanismo de descoberta personalizado. Recomendamos copiar a fonte do Redis Discoverer e implementar os métodos necessários.

<!-- **TODO: diagram, which shows node's local registry, when a new node coming & leaving.** -->

## Registro de Serviços Integrado
Moleculer tem um módulo de registro de serviços integrado. Ele armazena todas as informações sobre serviços, ações, assinantes de eventos e nós. Quando você chama um serviço ou emite um evento, o broker pede ao registro para procurar um nó que possa executar a requisição. Se houver vários nós, ele usa a estratégia de balanceamento de carga para selecionar o próximo nó.

> Leia mais sobre o [balanceamento de carga & estratégias](balancing.html).

> Os dados de registro estão disponíveis através de [serviço interno](services.html#Internal-Services).
