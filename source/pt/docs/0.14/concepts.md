title: Conceitos Principais
---

Este guia abrange os conceitos principais de qualquer aplicação Moleculer.

## Serviço
Um [serviço](services.html) é simplesmente um módulo JavaScript que contém algumas partes de uma aplicação complexa. Ele é isolado e independente, o que significa que, mesmo que caia ou quebre os demais serviços não serão afetados.

## Nó
Um nó é simplesmente um processo do SO rodando em uma rede local ou externa. Uma única instância de um nó pode hospedar um ou muitos serviços.

### Serviços locais
Dois (ou mais) serviços rodando em um único nó são considerados serviços locais. Eles compartilham recursos de hardware e usam o barramento local para se comunicar entre si, sem latência da rede ([módulo de transporte](#Transporter) não é usado).

### Serviços Remotos
Serviços distribuídos através de vários nós são considerados remotos. Neste caso, a comunicação é feita via [módulo de transporte](#Transporter).

## Service Broker
[Service Broker](broker.html) é o coração do Moleculer. É responsável pelo gerenciamento e pela comunicação entre os serviços (locais e remotos). Cada nó deve ter uma instância do Service Broker.

## Módulo de transporte
[O módulo de transporte](networking.html) é um protocolo de comunicação que os serviços usam para trocar mensagens. Emite eventos, requisições e respostas.

## Gateway
A [API Gateway](moleculer-web.html) expõe o serviços Moleculer para o usuário final. O gateway é um serviço regular do Moleculer executando um servidor (HTTP, WebSockets, etc). Ele lida com as requisições recebidas, as direciona para chamadas de serviço e depois retorna as respostas adequadas.

## Visão geral
Não há nada melhor do que um exemplo para ver como todos esses conceitos se encaixam. Então vamos considerar uma hipotética loja on-line que só lista seus produtos. Na verdade, não vende nada online.

### Arquitetura

Do ponto de vista da arquitetura a loja on-line pode ser vista como uma composição de 2 serviços independentes: o serviço de `products` e o serviço de `gateway`. O primeiro é responsável pelo armazenamento e gerenciamento dos produtos, enquanto o segundo simplesmente recebe requisições do usuário e os direciona para o serviço de `products`.

Agora vamos dar uma olhada como essa loja hipotética pode ser criada com Moleculer.

Para garantir que o nosso sistema seja resistente a falhas, executaremos os serviços `products` e `gateway` em [nós](#Node) dedicados (`node-1` e `node-2`). Relembrando, serviços rodando em nós dedicados significa que o [módulo de transporte](#Transporter) é necessário para a comunicação entre serviços. A maioria dos módulos de transporte suportados pelo Moleculer dependem de um broker de mensagens para comunicação entre serviços, então vamos precisar de um conectado e executando. Em geral, a arquitetura interna de nossa loja é representada na figura abaixo.

Agora, assumindo que nossos serviços estão prontos e funcionando, a loja on-line pode atender a requisições do usuário. Então vamos ver o que acontece de verdade com uma requisição para listar todos os produtos disponíveis. Primeiro, a requisição (`GET /products`) é recebida pelo servidor HTTP em execução no `node-1`. A requisição recebida é simplesmente encaminhada do servidor HTTP para o [serviço de gateway](#Gateway) que faz todo o processamento e direcionamento. Neste caso, em particular, a requisição do usuário é direcionada para uma ação `listProducts` do serviço de `products`.  Em seguida, a requisição é passada para o [broker](#Service-Broker), que verifica se o serviço de `products` é um [serviço local](#Local-Services) ou um [ serviço remoto](#Remote-Services). Neste caso, o serviço de `products` é remoto, então o broker precisa usar o [módulo de transporte](#Transporter) para entregar a requisição. O módulo de transporte simplesmente recebe a requisição e o encaminha via protocolo de comunicação. Uma vez que ambos os nós (`node-1` e `node-2`) estão conectados ao mesmo protocolo de comunicação (broker de mensagens), a requisição será entregue com sucesso ao `node-2`. Após a recepção, o broker do `node-2` analisará a requisição recebida e encaminhará para o serviço `products`. Finalmente, o serviço `products` invoca a ação `listProducts` e retorna a lista de todos os produtos disponíveis. A resposta é simplesmente enviada de volta para o usuário final.

**Fluxo de requisições do usuário**
<div align="center">
    <img src="assets/overview.svg" alt="Visão Geral da Arquitetura" />
</div>

Todos os detalhes que acabamos de ver podem parecer assustadores e complicados, mas você não precisa ter medo. Moleculer faz todo o trabalho pesado para você! Você (o desenvolvedor) só precisa se concentrar na regra de negócio. Dê uma olhada na implementação real da nossa [loja online](#Implementation).

### Implementação
Agora que definimos a arquitetura da nossa loja, vamos implementá-la. Vamos usar o NATS, um sistema de mensagens de código aberto, como protocolo de comunicação. Então vá em frente e obtenha a última versão do [Servidor NATS](https://nats.io/download/nats-io/nats-server/). Execute-o com as configurações padrão. Você deve receber a seguinte mensagem:

```
[18141] 2016/10/31 13:13:40.732616 [INF] Starting nats-server version 0.9.4
[18141] 2016/10/31 13:13:40.732704 [INF] Listening for client connections on 0.0.0.0:4222
[18141] 2016/10/31 13:13:40.732967 [INF] Server is ready
```

Em seguida, crie um novo diretório para nossa aplicação, crie um novo `package.json` e instale as dependências. Vamos usar `moleculer` para criar nossos serviços, `moleculer-web` como o gateway HTTP e `nats` para comunicação. No final, o seu `package.json` deve se parecer com isto:

```json
// package.json
{
  "name": "moleculer-store",
  "dependencies": {
    "moleculer": "^0.14.0",
    "moleculer-web": "^0.9.0",
    "nats": "^1.3.2"
  }
}
```

Finalmente, precisamos configurar os brokers e criar os nossos serviços. Então vamos criar um novo arquivo (`index.js`) e implementar:
```javascript
// index.js
const { ServiceBroker } = require("moleculer");
const HTTPServer = require("moleculer-web");

// Create the broker for node-1
// Define nodeID and set the communication bus
const brokerNode1 = new ServiceBroker({
  nodeID: "node-1",
  transporter: "NATS"
});

// Create the "gateway" service
brokerNode1.createService({
  // Define service name
  name: "gateway",
  // Load the HTTP server
  mixins: [HTTPServer],

  settings: {
    routes: [
      {
        aliases: {
          // When the "GET /products" request is made the "listProducts" action of "products" service is executed
          "GET /products": "products.listProducts"
        }
      }
    ]
  }
});

// Create the broker for node-2
// Define nodeID and set the communication bus
const brokerNode2 = new ServiceBroker({
  nodeID: "node-2",
  transporter: "NATS"
});

// Create the "products" service
brokerNode2.createService({
  // Define service name
  name: "products",

  actions: {
    // Define service action that returns the available products
    listProducts(ctx) {
      return [
        { name: "Apples", price: 5 },
        { name: "Oranges", price: 3 },
        { name: "Bananas", price: 2 }
      ];
    }
  }
});

// Start both brokers
Promise.all([brokerNode1.start(), brokerNode2.start()]);
```
Agora execute `node index.js` no seu terminal e abra o link [`http://localhost:3000/products`](http://localhost:3000/products). Você deve receber a seguinte resposta:
```json
[
    { "name": "Apples", "price": 5 },
    { "name": "Oranges", "price": 3 },
    { "name": "Bananas", "price": 2 }
]
```

Com apenas algumas dezenas de linhas de código, criamos dois serviços isolados capazes de atender as requisições do usuário e listar os produtos. Além disso, os nossos serviços podem ser facilmente escalonados para se tornarem resilientes e tolerantes e falhas. Impressionante, verdade?

Vá até a seção [Documentação](broker.html) para mais detalhes ou verifique a página [Exemplos](examples.html) para exemplos mais complexos.