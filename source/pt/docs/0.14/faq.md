title: FAQ
---

# Core & Common

## Por que estou recebendo um `NATS error. Could not connect to server: Error: connect ECONNREFUSED 127.0.0.1:4222` quando tento iniciar o meu projeto?
O servidor NATS não faz parte do Moleculer. Você tem que o instalar & iniciar antes de executar o seu projeto. Baixe-o aqui: https://nats.io/download/nats-io/nats-server/
```
[7480] 2019/10/06 14:18:05.801763 [INF] Starting nats-server version 2.0.0
[7480] 2019/10/06 14:18:05.805763 [INF] Git commit [not set]
[7480] 2019/10/06 14:18:05.809763 [INF] Listening for client connections on 0.0.0.0:4222
[7480] 2019/10/06 14:18:05.809763 [INF] Server id is NCHICRYD3SMATIT6QMO557ZDHQUY5JUYPO25TK4SAQYP7IPCIOGKTIRU
[7480] 2019/10/06 14:18:05.810763 [INF] Server is ready
```

## Como posso iniciar serviços com o Moleculer Runner no modo de debug?
Use o seguinte comando:
```bash
$ node --inspect=0.0.0.0:9229 node_modules/moleculer/bin/moleculer-runner services
```

## Como adicionar flags V8 ao executar o Moleculer Runner?
```bash
$ node --max-old-space-size=8192 node_modules/moleculer/bin/moleculer-runner services
```

## O que acontece se eu emitir um evento e o serviço que utiliza esse evento estiver offline?
Os eventos de Moleculer são "disparar e esquecer" (fire-and-forget), isso significa que caso o serviço esteja offline, o evento será perdido. Se você quiser eventos persistentes, procure por transportadores que oferecem este tipo de recursos.

## Por que o broker encerra sem exibir qualquer erro quando inicio meu serviço?
Se não houver nenhum processo em execução continuamente (por exemplo, conexão com transportador, API gateway, conexão de BD) que mantenha o laço de eventos em execução, o processo será fechado. É um comportamento normal e não um erro. Se você quiser manter seu broker em execução, você deve manter o loop de eventos "ocupado". Tente habilitar o transportador em `moleculer.config.js`.

# API Gateway (moleculer-web)

## Por que estou recebendo uma mensagem de erro `413 - request entity too large` ao enviar um POST com muitos dados?
Você deve configurar os `bodyParsers` para sobrescrever o limite padrão de `100kb` que existe para o corpo de requisições POST. [Mais informações](https://github.com/expressjs/body-parser#limit).

```js
module.exports = {
    name: "api",
    settings: {
        routes: [{
            path: "/api",

            // Use bodyparser modules
            bodyParsers: {
                json: { limit: "2MB" },
                urlencoded: { extended: true, limit: "2MB" }
            }
        }]
    }
}
```

{% note info Recommendation %}
Use o [recurso de streaming](https://moleculer.services/docs/0.13/actions.html#Streaming) quando você quiser enviar ou receber grandes volumes de dados de/para um serviço.
{% endnote %}

## Como faço para formatar as respostas de erro?
Você deve definir um hook `onError` nas configurações do API Gateway. [Mais informações](https://moleculer.services/docs/0.13/moleculer-web.html#Error-handlers).

```js
// api.service.js
module.exports = {
    mixins: [ApiService],
    settings: {
        // Global error handler
        onError(req, res, err) {
            res.setHeader("Content-Type", "application/json");
            res.writeHead(err.code || 500);
            res.end(JSON.stringify({
                success: false,
                message: err.message
            }));
        }       
    }
};
```

# DB Adapters (moleculer-db)
## Como posso gerenciar várias entidades/tabelas por serviço?
No momento, [Moleculer DB](moleculer-db.html) suporta apenas [um modelo por serviço](https://microservices.io/patterns/data/database-per-service.html). Este design funciona bem se você estiver usando um banco de dados NoSQL, especialmente bancos de dados orientados a documentos, porque você pode facilmente aninhar todas as entidades filhas. No entanto, para os bancos de dados SQL as coisas ficam complicadas, porque você pode ter relações múltiplas e complexas entre as entidades/tabelas. Devido a isso, é muito difícil (com a atual força de trabalho) criar uma solução que funcionará para todos. Portanto, para cenários com várias entidades e relacionamentos, você terá que escrever seu próprio adaptador.


## `moleculer-db` viola o Design Orientado pelo Domínio (DDD)?
`moleculer-db` é um mixin de serviço simples (e opcional) que auxilia na manipulação de uma entidade/tabela de BD. Não significa que isso obrigue ou force você a alterar sua mentalidade ou sua maneira de implementar/modelar as coisas. Se os recursos fornecidos pelo `moleculer-db` não atendem a suas necessidades, então você deve escrever seu próprio serviço com ações personalizadas.
