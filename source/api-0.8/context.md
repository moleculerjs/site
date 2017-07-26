title: Context
---



# Context




`new Context(broker, action)`

Context class for action calls




### Properties

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `id` | String | - | Context ID |
| `broker` | ServiceBroker | - | Broker instance |
| `action` | Action | - | Action definition |
| `nodeID` |  | `null` | Node ID |
| `parentID` | String | - | Parent Context ID |
| `metrics` | Boolean | - | Need send metrics events |
| `level` |  | `1` | Level of context |







## Instance Members



### constructor




`constructor(broker: ServiceBroker, action: Action)`

Creates an instance of Context.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | Context ID |
| `action` | Action | - | Context ID |







### Examples





```js
let ctx = new Context(broker, action);
```





```js
let ctx2 = new Context(broker, action);
```







### setParams




`setParams(newParams: Object, cloning: Boolean)`

Set params of context


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `newParams` | Object | - | Context ID |
| `cloning` | Boolean | - | Context ID |










### call




`call(actionName: String, params, opts): Promise`

Call an other action. It will be create a sub-context.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - | Context ID |
| `params` |  | - | Context ID |
| `opts` |  | - | Context ID |







### Examples




**Call an other service with params &amp; options**


```js
ctx.call("posts.get", { id: 12 }, { timeout: 1000 });
```







### emit




`emit(eventName: String, data: any)`

Call a global event (with broker.emit).


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | String | - | Context ID |
| `data` | any | - | Context ID |







### Examples





```js
ctx.emit("user.created", { entity: user, creator: ctx.meta.user });
```












