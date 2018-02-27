title: Context
---



# Context




`new Context()`

Context class for action calls




### Properties

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `id` | String | - | Context ID |
| `broker` | ServiceBroker | - | Broker instance |
| `action` | Action | - | Action definition |
| `nodeID` |  | - | Node ID |
| `parentID` | String | - | Parent Context ID |
| `metrics` | Boolean | - | Need send metrics events |
| `level` |  | - | Level of context |





## Instance Members



### setParams



`setParams(newParams: Object, cloning: Boolean)`

Set params of context


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `newParams` | Object | - | - |
| `cloning` | Boolean | - | - |








### call



`call(actionName: String, params, opts): Promise`

Call an other action. It creates a sub-context.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - | - |
| `params` |  | - | - |
| `opts` |  | - | - |






#### Examples




**Call an other service with params &amp; options**


```js
ctx.call("posts.get", { id: 12 }, { timeout: 1000 });
```





### emit



`emit(eventName: string, data, groups, payload: any)`

Emit an event (grouped & balanced global event)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `groups` |  | - | - |
| `payload` | any | - | - |






#### Examples





```js
ctx.emit("user.created", { entity: user, creator: ctx.meta.user });
```





### broadcast



`broadcast(eventName: string, data, groups, payload: any)`

Emit an event for all local & remote services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `groups` |  | - | - |
| `payload` | any | - | - |






#### Examples





```js
ctx.broadcast("user.created", { entity: user, creator: ctx.meta.user });
```






## Static Members



### create



`create(broker: ServiceBroker, action: Object, nodeID, params, opts: Object): Context`

Create a new Context instance.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | - |
| `action` | Object | - | - |
| `nodeID` |  | - | - |
| `params` |  | - | - |
| `opts` | Object | - | - |









