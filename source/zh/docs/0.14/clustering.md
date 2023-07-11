title: 集群化（Clustering）
---
Moleculer框架支持多种软件架构。

## 单体架构（Monolith Architecture）
在这个版本中，所有服务都在同一个节点上运行，就像单个个体一样。 没有网络延迟和也不需要传输模块。 _本地调用是最快的。_

![单体架构](assets/architectures/monolith.svg)

## 微服务架构（Microservices Architecture）
这是现在非常流行的微服务架构，所有服务都在各自的节点上运行并通过推送系统（Transporter）进行通信。 在这种情况下，网络延迟不可忽略。 此外，你的服务可以扩展以实现弹性和容错性。

![微服务架构](assets/architectures/microservices.svg)

## 混合架构（Mixed Architecture）
这种情况下，我们将一组相关联的服务运行在同一个节点上， 它结合了单体和微服务架构的优点。 例如，如果`posts`服务需要经常调用`users`服务，则将它们放到同一个节点上，以减少这些服务之间的网络延迟。 如果节点压力过大，只需将其扩展（Scale）即可。

![混合架构](assets/architectures/mixed.svg)

{% note info Tip %}
ServiceBroker会首先尝试调用本地实例（如果存在）以减少网络延迟。 这个功能可以通过`registry`关键词下的[broker 选项](configuration.html#Broker-options)中的`preferLocal: false`属性关闭。
{% endnote %}

## 如何选择
开发应用时，你是不是在纠结用单体架构还是微服务架构？ 你是不是选择了单体方法，因为它易于开发？ 又或者，你是不是更喜欢微服务架构因为它可靠且高度可扩展？ 使用Moleculer你无需纠结。 你可以同时获得两种架构的优点。 在开发的时候，可以在单个节点上加载所有服务， 这样您可以快速调试和测试应用程序逻辑。 开发完成后，只需将你的服务分布到多个节点即可。 别担心，你无需更改任何一行代码即可完成此操作。 只需选择一个推送系统（Transporter），在每个节点上加载一个服务，就能实现。 你的应用就会运行在微服务架构上。