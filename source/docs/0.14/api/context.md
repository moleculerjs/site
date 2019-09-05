title: Context
---



# Context




`new Context(broker, endpoint)`

Context class for action calls




### Properties

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `id` | String | - | Context ID |
| `broker` | ServiceBroker | - | Broker instance |
| `action` | Action | - | Action definition |
| `nodeID` |  | - | Node ID |
| `caller` | String | - | Action name of the caller. E.g.: `v3.myService.myAction` |
| `parentID` | String | - | Parent Context ID |
| `tracing` | Boolean | - | Need send metrics events |
| `level` |  | - | Level of context |







## Static Members



### constructor



`new Context(broker: ServiceBroker, endpoint: Endpoint)`

Creates an instance of Context.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | Broker instance |
| `endpoint` | Endpoint | - | Endpoint (action & nodeID) |








### create



`create(broker: ServiceBroker, endpoint: Endpoint, params, opts: Object): Context`

Create a new Context instance


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | - |
| `endpoint` | Endpoint | - | - |
| `params` |  | - | - |
| `opts` | Object | - | - |








### id



`id`

Context ID getter



#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |








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






