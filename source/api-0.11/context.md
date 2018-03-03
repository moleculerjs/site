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
| `nodeID` |  | - | Node ID |
| `parentID` | String | - | Parent Context ID |
| `metrics` | Boolean | - | Need send metrics events |
| `level` |  | - | Level of context |







## Static Members



### constructor



`new Context(broker: ServiceBroker, action: Action)`

Creates an instance of Context.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | Broker instance |
| `action` | Action | - | Action definition |






#### Examples





```js
let ctx = new Context(broker, action);
```





```js
let ctx2 = new Context(broker, action);
```





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

Call an other action. It will be create a sub-context.


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



`emit(eventName: String, data: any)`

Call a global event (with broker.emit).


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/context.md
| `eventName` | string | - | - |
| `groups` |  | - | - |
| `payload` | any | - | - |
=======
| `eventName` | String | - |  |
| `data` | any | - |  |
>>>>>>> master:source/api-0.11/context.md






#### Examples





```js
ctx.emit("user.created", { entity: user, creator: ctx.meta.user });
```





<<<<<<< HEAD:source/0.12/api/context.md
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





=======
>>>>>>> master:source/api-0.11/context.md

