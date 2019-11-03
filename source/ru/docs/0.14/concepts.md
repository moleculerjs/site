title: Основные концепции
---

Это руководство охватывает основные концепции любого Moleculer приложения.

## Сервис
[Сервис](services.html) является простым JavaScript-модулем, содержащим часть сложного приложения. Он изолирован и самодостаточен, это означает, что даже если он отключится или упадёт, остальные сервисы не будут задеты.

## Узел
Узел - это просто процесс в ОС, работающий в локальной или внешней сети. Один экземпляр узла может хостить один или несколько сервисов.

### Локальный сервис
Два (или более) сервиса, работающих на одном узле, считаются локальными сервисами. Они делят аппаратные ресурсы и используют локальную шину для связи друг с другом, без сетевых задержек ([транспорт](#Transporter) не используется).

### Удалённый сервис
Сервисы, распределённые по нескольким узлам, считаются удалёнными. В этом случае общение между ними осуществляется с помощью [транспорта](#Transporter).

## Сервис брокер
[Сервис брокер](broker.html) является сердцем Moleculer. Он отвечает за управление и связью между службами (локальными и удалёнными). Каждый узел должен иметь экземпляр Сервис брокера.

## Транспорт
[Транспорт](networking.html) это коммуникационная шина, которая обеспечивает обмен сообщениями. Она передает события, запросы и ответы.

## Шлюз
[API шлюз](moleculer-web.html) предоставляет услуги Moleculer конечным пользователям. Шлюз является обычным Moleculer сервисом, в котором запущен (HTTP, WebSockets и др.) сервер. Он обрабатывает входящие запросы, превращает их в вызовы сервисов, а затем возвращает соответствующие ответы.

## Общий вид
Нет ничего лучше, чем пример, чтобы увидеть, как все эти понятия сочетаются друг с другом. Так давайте рассмотрим гипотетический интернет-магазин, который только выводит список товаров. На самом деле он не продает ничего онлайн.

### Архитектура

С точки зрения архитектуры, интернет-магазин можно представить из 2 независимых сервисов: сервиса `товаров` и сервиса `шлюза`. Первый отвечает за хранение и управление товарами, а второй просто получает запросы от пользователя и передает их сервису `товаров`.

Теперь давайте рассмотрим, как этот гипотетический магазин можно создать с Moleculer.

Чтобы убедиться, что наша система устойчиво к сбоям, мы запустим `товары` и `шлюз` на отдельных [узлах](#Node) (`node-1` и `node-2`). Если вы помните, то запуск сервисов на отдельных узлах означает, что необходим модуль [транспорта](#Transporter) для связи между ними. Most of the transporters supported by Moleculer rely on a message broker for inter services communication, so we're going to need one up and running. Overall, the internal architecture of our store is represented in the figure below.

Now, assuming that our services are up and running, the online store can serve user's requests. So let's see what actually happens with a request to list all available products. First, the request (`GET /products`) is received by the HTTP server running at `node-1`. The incoming request is simply passed from the HTTP server to the [gateway](#Gateway) service that does all the processing and mapping. In this case in particular, the user´s request is mapped into a `listProducts` action of the `products` service.  Next, the request is passed to the [broker](#Service-Broker), which checks whether the `products` service is a [local](#Local-Services) or a [remote](#Remote-Services) service. In this case, the `products` service is remote so the broker needs to use the [transporter](#Transporter) module to deliver the request. The transporter simply grabs the request and sends it through the communication bus. Since both nodes (`node-1` and `node-2`) are connected to the same communication bus (message broker), the request is successfully delivered to the `node-2`. Upon reception, the broker of `node-2` will parse the incoming request and forward it to the `products` service. Finally, the `products` service invokes the `listProducts` action and returns the list of all available products. The response is simply forwarded back to the end-user.

**Flow of user's request**
<div align="center">
    <img src="assets/overview.svg" alt="Описание архитектуры" />
</div>

All the details that we've just seen might seem scary and complicated but you don't need to be afraid. Moleculer does all the heavy lifting for you! You (the developer) only need to focus on the application logic. Take a look at the actual [implementation](#Implementation) of our online store.

### Реализация
Now that we've defined the architecture of our shop, let's implement it. We're going to use NATS, an open source messaging system, as a communication bus. So go ahead and get the latest version of [NATS Server](https://nats.io/download/nats-io/nats-server/). Run it with the default settings. You should get the following message:

```
[18141] 2016/10/31 13:13:40.732616 [INF] Starting nats-server version 0.9.4
[18141] 2016/10/31 13:13:40.732704 [INF] Listening for client connections on 0.0.0.0:4222
[18141] 2016/10/31 13:13:40.732967 [INF] Server is ready
```

Next, create a new directory for our application, create a new `package.json` and install the dependencies. We´re going to use `moleculer` to create our services, `moleculer-web` as the HTTP gateway and `nats` for communication. In the end your `package.json` should look like this:

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

Finally, we need to configure the brokers and create our services. So let's create a new file (`index.js`) and do it:
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
Now run `node index.js` in your terminal and open the link [`http://localhost:3000/products`](http://localhost:3000/products). You should get the following response:
```json
[
    { "name": "Apples", "price": 5 },
    { "name": "Oranges", "price": 3 },
    { "name": "Bananas", "price": 2 }
]
```

With just a couple dozen of lines of code we've created 2 isolated services capable of serving user's requests and list the products. Moreover, our services can be easily scaled to become resilient and fault-tolerant. Impressive, right?

Head out to the [Documentation](broker.html) section for more details or check the [Examples](examples.html) page for more complex examples.