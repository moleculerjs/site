title: 使用
---
# 安装 Moleculer

使用`npm`或`yarn`安装 Moleculer。

```bash
$ npm i moleculer --save
```

# 创建您的第一个微服务
本示例展示如何创建一个极小的 `math` 服务来添加2个数字并在本地调用。

```js
const { ServiceBroker } = require("moleculer");

// Create a ServiceBroker
const broker = new ServiceBroker();

// Define a service
broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});

// Start the broker
broker.start()
    // Call the service
    .then(() => broker.call("math.add", { a: 5, b: 3 }))
    // Print the response
    .then(res => console.log("5 + 3 =", res))
    .catch(err => console.error(`Error occured! ${err.message}`));
```

{% note info Try it in your browser! %}
在 [Runkit!](https://runkit.com/icebob/moleculer-usage) 上打开此示例
{% endnote %}

# 创建Moleculer项目
在这个例子中，我们使用官方的[Moleculer CLI 工具](moleculer-cli.html)来创建一个基于Moleculer的微服务项目，其中包括一个样例服务和一个 API 网关，通过REST API从浏览器调用。

1. 全局安装 `moleculer-cli`
    ```bash
    $ npm i moleculer-cli -g
    ```
2. 新建一个 (名为 `moleculer-demo`) 的项目
    ```bash
    $ moleculer init project moleculer-demo
    ```

    <div align="center"><img src="assets/usage/usage-demo-1.gif" /></div>

    > Press `ENTER` to all questions _(accept default answers)_    
    
    {% note warn %}
    Don't forget to install and start [NATS Server](https://docs.nats.io/nats-server/installation). 否则，您将会遇到以下错误：
    `NATS error. Could not connect to server: Error: connect ECONNREFUSED 127.0.0.1:4222` {% endnote %}

3. 打开项目文件夹
    ```bash
    $ cd moleculer-demo
    ```

4. 启动项目
    ```bash
    $ npm run dev
    ```


<div align="center">
  <img src="assets/usage/usage-demo-2.gif" />
</div>

5. 在您的浏览器中打开 [http://localhost:3000/](http://localhost:3000/) 链接。 它显示了一个包含两个链接的起始页面，通过 [API 网关](https://github.com/moleculerjs/moleculer-web)调用`greeter` 服务。

{% note info Congratulations! %}
您刚刚创建了第一个基于 Moleculer 的微服务项目！ 接下来，查看 Moleculer [核心概念](concepts.html) 页面来熟悉这些概念并看看它们是如何相互配合的。 或者，您也可以签出[examples](examples.html)或[demo projects](https://github.com/moleculerjs/moleculer-examples)。
{% endnote %}

您也可以观看下面的视频，它是您刚刚创建的项目的讲解。 <iframe width="730" height="410" src="https://www.youtube.com/embed/t4YR6MWrugw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


# Moleculer 演示
如果你不想在你的计算机上安装[moleculer-demo](usage.html#Create-a-Moleculer-project), 你可以使用这个在线演示。 <iframe src="https://codesandbox.io/embed/github/moleculerjs/sandbox-moleculer-project/tree/master/?fontsize=14" title="moleculer-project" allow="geolocation; microphone; camera; midi; vr; accelerometer; gyroscope; payment; ambient-light-sensor; encrypted-media" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin"></iframe>
