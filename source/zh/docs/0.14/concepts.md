核心概念
---

本指南涵盖 Moleculer 的核心概念。

## 服务
一个[service](services.html)就是一个简单的 JavaScript 模块，它是某个复杂的应用程序的一部分。 服务是独立的, 自包含的，即使某个服务停止工作或者崩溃了，其它的服务也不会受到影响。

## 节点
节点是一个在本地或外部网络上运行的简单进程。 单个节点实例可以提供一个或多个服务。

### 本地服务
在单个节点上运行的两个(或多个) 服务被视为当地服务。 他们共享硬件资源并以本地方式相互通讯，无网络延迟(也不需要使用[transporter](#Transporter))。

### 远程服务
跨越多个节点分配的服务被认为是远程的。 在这种情况下，通过[transporter](#Transporter)进行通信。

## 服务管理者
[Service Broker](broker.html)是Moleculer的核心。 它负责各（本地和远程）服务之间的管理和通信。 每个节点至少需要有一个 Service Broker 实例。

## 推送系统
[Transporter](networking.html)用于在服务间交换信息。 它传送事件、请求和响应。

## 网关
[API 网关](moleculer-web.html)将 Moleculer 服务暴露给最终用户。 网关是一个运行 (HTTP, WebSockets 等) 服务器的 Moleculer 常规服务。 它处理收到的请求，将请求转换为服务调用，然后返回适当的响应。

## Overall View
说半天不如举个例子。 我们假设有一个网上商店，现在，只想列出它的产品。 它实际上没有在线销售任何东西。

### 架构

从构建的角度来看，这个网上商店可以被看作是两个独立服务的组合：`products` 服务和 `gateway` 服务。 Products 服务负责产品的储存和管理，gateway 服务接受用户的请求，并将其转达到`products` 服务上。

现在让我们看看怎样使用 Moleculer 来创建这个假设的商店。

我们把 `products` 和 `gateway` 服务放到不同的 [节点](#Node) (`node-1` 和 `node-2`) ，以提高系统容错弹性. 还要记得，不同节点运行的服务之间相互服务通信需要 [transportter](#Transporter) 模块。 Moleculer 支持的大多数 transporters 都依赖消息代理进行服务间通信，因此我们需要有一个正在运行的推送系统。 总的来说，我们商店的内部结构见下图。

现在，假定我们的服务已经启动和运行，在线商店可以满足用户的要求。 所以让我们看看请求列出所有可用产品的实际情况。 首先，运行 `node-1`的 HTTP 服务器收到请求 (`GET /products`) 。 传入请求只是简单地从 HTTP 服务器映射到 [gateway](#Gateway) 服务来完成所有操作。 特别是在这种情况下，用户的请求将映射到 `products` 服务的 `listProducts` 操作中。  接下来，该请求会被传递到[broker](#Service-Broker), 由它检查 `products` 服务是 [local](#Local-Services) 或 [remote](#Remote-Services) 服务。 这里，`products` 服务是远程服务，因此服务管理器需要使用 [transportter](#Transporter) 模块来传递请求。 Transporter 仅简单地抓取请求并通过通信总线发送出去。 由于两个节点(`node-1`和`node-2`) 都与同一通信总线连接(message broker)，请求已成功送达`node-2`。 `node-2` 的服务管理器将解析收到的请求并将其转发到`products` 服务上。 最后，`products` 服务会执行 `listProducts` 动作并返回所有可用产品列表。 响应仅简单地转发给最终用户。

**用户请求流程**
<div align="center">
    <img src="assets/overview.svg" alt="Architecture Overview" />
</div>

我们刚刚看到的所有细节似乎都复杂地令人生畏，但是您不必担心。 Moleculer为您完成所有繁重的工作！ 您（开发人员）只需要关注应用程序逻辑。 去看看我们在线商店的实现 [implementation](#Implementation)。

### 实现
现在我们已经定义了我们商店的架构，让我们来实现它。 我们将使用一个开源的推送系统 NATS，作为通信总线。 请先着手获取最新版本的[NATS Server](https://nats.io/download/nats-io/nats-server/)。 使用默认设置运行它。 您应该收到以下消息：

```
[18141] 2016/10/31 13:13:40.732616 [INF] Starting nats-server version 0.9.4
[18141] 2016/10/31 13:13:40.732704 [INF] Listening for client connections on 0.0.0.0:4222
[18141] 2016/10/31 13:13:40.732967 [INF] Server is ready
```

接下来，为我们的应用程序创建一个新的目录，创建一个新的 `package.json` 文件并安装依赖项。 我们将使用 `moleculer` 来创建我们的服务，`moleculer-web` 作为HTTP网关，`nats`用于通信。 最后，你的`package.json`应该像这样：

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

最后，我们需要配置服务管理者并创建我们的服务。 所以让我们创建一个新文件(`index.js`)：
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
现在在您的终端运行 `node index.js` 并打开链接[`http://localhost:3000/products`](http://localhost:3000/products)。 您应该看到以下响应：
```json
[
    { "name": "Apples", "price": 5 },
    { "name": "Oranges", "price": 3 },
    { "name": "Bananas", "price": 2 }
]
```

只有几行代码，我们创建了两个独立的服务，能够满足用户的请求并列出产品。 此外，我们的服务可以轻易地得到弹性扩展和容错功能。 令人印象深刻，对不对？

前往 [Documentation](broker.html) 部分了解更多详细信息，或查看 [Examples](examples.html) 页面以获取更复杂的示例。