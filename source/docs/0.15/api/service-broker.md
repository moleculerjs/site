title: ServiceBroker
---



# defaultOptions




`defaultOptions`

Default broker options













# ServiceBroker




`new ServiceBroker(options)`

Service broker class










## Static Members



### constructor



`new ServiceBroker(options: Object)`

Creates an instance of ServiceBroker.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `options` | Object | - | - |








### registerMiddlewares



`registerMiddlewares(userMiddlewares)`

Register middlewares (user & internal)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |








### start



`start()`

Start broker. If has transporter, transporter.connect will be called.









### stop



`stop()`

Stop broker. If has transporter, transporter.disconnect will be called.









### repl



`repl()`

Switch the console to REPL mode.







#### Examples





```js
broker.start().then(() => broker.repl());
```





### getLogger



`getLogger(module: String, props): Logger`

Get a custom logger for sub-modules (service, transporter, cacher, context...etc)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `module` | String | - | Name of module |
| `props` |  | - | Module properties (service name, version, ...etc |








### fatal



`fatal(message: String, err, needExit: boolean)`

Fatal error. Print the message to console and exit the process (if need)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `message` | String | - | - |
| `err` |  | - | - |
| `needExit` |  | - | - |








### loadServices



`loadServices(folder: string, fileMask: string): Number`

Load services from a folder


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `folder` |  | - | Folder of services |
| `fileMask` |  | - | Service filename mask |








### loadService



`loadService(filePath, Path: string): Service`

Load a service from file


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `Path` | string | - | of service |








### watchService



`watchService(service: Service)`

Watch a service file and hot reload if it's changed.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |



### createService



`createService(schema: any): Service`

Create a new service by schema


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | any | - | Schema of service or a Service class |








### addLocalService



`addLocalService(service: Service)`

Add a local service instance


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |








### registerLocalService



`registerLocalService(registryItem: Object)`

Register a local service to Service Registry


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `registryItem` | Object | - | - |








### destroyService



`destroyService(service: Service)`

Destroy a local service


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |








### servicesChanged



`servicesChanged(localService)`

It will be called when a new local or remote service
is registered or unregistered.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |








### registerInternalServices



`registerInternalServices()`

Register internal services









### getLocalService



`getLocalService(name|obj): Service`

Get a local service by name (e.g. `posts` or `v2.posts`) or by object (e.g. `{ name: "posts", version: 2 }`)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String\|Object | - | - |








### waitForServices



`waitForServices(serviceNames, timeout: Number, interval: Number, logger): Promise`

Wait for other services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceNames` |  | - | - |
| `timeout` | Number | - | Timeout in milliseconds |
| `interval` | Number | - | Check interval in milliseconds |



### findNextActionEndpoint



`findNextActionEndpoint(actionName: String, opts): undefined`

Find the next available endpoint for action


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - | - |
| `opts` |  | - | - |


### call



`call(actionName: String, params: Object, opts: Object): Promise`

Call an action


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - | name of action |
| `params` | Object | - | params of action |
| `opts` | Object | - | options of call (optional) |








### mcall



`mcall(def, options): Promise<Array<Object>|Object>|PromiseSettledResult`

Multiple action calls.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `def` | Array/Object | - | Calling definitions. |
| `opts` | Object | - | Calling options for each call. |
| `opts.settled` | Boolean | false | Set `true` for result of each promise with reject (only works from node.js version >= 12.9.0) |





#### Examples





Call `mcall` with an array:
```js
broker.mcall([
	{ action: "posts.find", params: { limit: 5, offset: 0 } },
	{ action: "users.find", params: { limit: 5, sort: "username" }, options: { timeout: 500 } }
]).then(results => {
	let posts = results[0];
	let users = results[1];
})
```





Call `mcall` with an Object:
```js
broker.mcall({
	posts: { action: "posts.find", params: { limit: 5, offset: 0 } },
	users: { action: "users.find", params: { limit: 5, sort: "username" }, options: { timeout: 500 } }
}).then(results => {
	let posts = results.posts;
	let users = results.users;
})
```

**`mcall` with options**
```js
await broker.mcall(
    [
        { action: 'posts.find', params: { author: 1 }, options: { /* Calling options for this call. */} },
        { action: 'users.find', params: { name: 'John' } },
        { action: 'service.notfound', params: { notfound: 1 } },
    ],
    {
        // result of each promise with reject
        settled: true,
        // set meta for each call 
        meta: { userId: 12345 }
    }
);
```



### emit



`emit(eventName: string, payload: any, groups)`

Emit an event (grouped & balanced global event)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |








### broadcast



`broadcast(eventName: string, payload: any, groups)`

Broadcast an event for all local & remote services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |








### broadcastLocal



`broadcastLocal(eventName: string, payload: any, groups, nodeID)`

Broadcast an event for all local services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |
| `nodeID` |  | - | - |








### ping



`ping(nodeID, timeout): Promise`

Send ping to a node (or all nodes if nodeID is null)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` |  | - | - |
| `timeout` |  | - | - |








### getHealthStatus



`getHealthStatus(): Promise`

Get local node health status









### getLocalNodeInfo



`getLocalNodeInfo()`

Get local node info.









### getEventGroups



`getEventGroups(eventName: String)`

Get event groups by event name


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | String | - | - |








### emitLocalServices



`emitLocalServices(event: String, payload: any, groups: any, sender: String, broadcast: boolean)`

Emit event to local nodes. It is called from transit when a remote event received
or from 


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `event` | String | - | - |
| `payload` | any | - | - |
| `groups` | any | - | - |
| `sender` | String | - | - |
| `broadcast` | boolean | - | - |








### getCpuUsage



`getCpuUsage(): undefined`

Get node overall CPU usage









### MOLECULER_VERSION



`MOLECULER_VERSION`

Version of Moleculer









### PROTOCOL_VERSION



`PROTOCOL_VERSION`

Version of Protocol









### defaultOptions



`defaultOptions`

Default configuration
