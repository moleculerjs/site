title: Context
---



# ServiceBroker




`new ServiceBroker(options)`

Service broker class








## Instance Members



### constructor



`new ServiceBroker(options: any)`

Creates an instance of ServiceBroker.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `options` | any | - |  |








### start



`start()`

Start broker. If has transporter, transporter.connect will be called.









### stop



`stop()`

Stop broker. If has transporter, transporter.disconnect will be called.









### repl



`repl()`

Switch the console to REPL mode.







### Examples





```js
broker.start().then(() => broker.repl());
```





### getLogger



`getLogger(module: String, service: String, version): Logger`

Get a custom logger for sub-modules (service, transporter, cacher, context...etc)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `module` | String | - | Name of module |
| `service` | String | - | Service name |
| `version` |  | - | Service version |








### fatal



`fatal(message: String, err, needExit: boolean)`

Fatal error. Print the message to console and exit the process (if need)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `message` | String | - |  |
| `err` |  | - |  |
| `needExit` |  | - |  |








### loadServices



`loadServices(folder: string, fileMask: string): Number`

Load services from a folder


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `folder` |  | - | Folder of services |
| `fileMask` |  | - | Service filename mask |








### loadService



`loadService(filePath, Path: string): Service`

Load a service from file


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `Path` | string | - | of service |








### createService



`createService(schema: any, schemaMods): Service`

Create a new service by schema


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | any | - | Schema of service |
| `schemaMods` |  | - | Modified schema |








### registerLocalService



`registerLocalService(service: Service)`

Register a local service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - |  |








### registerRemoteService



`registerRemoteService(nodeID: String, service: Service)`

Register a remote service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - | NodeID if it is on a remote server/node |
| `service` | Service | - |  |








### registerAction



`registerAction(nodeID: String, action: any)`

Register an action


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - | NodeID if it is on a remote server/node |
| `action` | any | - | action schema |








### wrapAction



`wrapAction(action: any)`

Wrap action handler for middlewares


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `action` | any | - |  |








### unregisterServicesByNode



`unregisterServicesByNode(nodeID: String)`

Unregister services by node


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - |  |








### unregisterAction



`unregisterAction(nodeID: String, action: any)`

Unregister an action on a local server. 
It will be called when a remote node disconnected.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - | NodeID if it is on a remote server/node |
| `action` | any | - | action schema |








### registerInternalActions



`registerInternalActions()`

Register internal actions









### on



`on(name: String, handler: Function)`

Subscribe to an event


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String | - |  |
| `handler` | Function | - |  |








### once



`once(name: String, handler: Function)`

Subscribe to an event once


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String | - |  |
| `handler` | Function | - |  |








### off



`off(name: String, handler: Function)`

Unsubscribe from an event


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String | - |  |
| `handler` | Function | - |  |








### getService



`getService(serviceName: String): Service`

Get a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | String | - |  |








### hasService



`hasService(serviceName: String): Boolean`

Has a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | String | - |  |








### hasAction



`hasAction(actionName: String): Boolean`

Has an action by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - |  |








### getAction



`getAction(actionName: String): Object`

Get an action by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - |  |








### isActionAvailable



`isActionAvailable(actionName: String): Boolean`

Check has callable action handler


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - |  |








### use



`use(mws: Function)`

Add a middleware to the broker


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mws` | Function | - |  |








### createNewContext



`createNewContext(action: Object, nodeID, params, opts: Object): Context`

Create a new Context instance


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `action` | Object | - |  |
| `nodeID` |  | - |  |
| `params` |  | - |  |
| `opts` | Object | - |  |








### call



`call(actionName: any, params: any, opts: any)`

Call an action (local or remote)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - | name of action |
| `params` | any | - | params of action |
| `opts` | any | - | options of call (optional) |








### shouldMetric



`shouldMetric()`

Check should metric the current call









### emit



`emit(eventName: string, payload: any): boolean`

Emit an event (global & local)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - |  |
| `payload` | any | - |  |








### emitLocal



`emitLocal(eventName: string, payload: any, sender, nodeID): boolean`

Emit an event only local


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - |  |
| `payload` | any | - |  |
| `nodeID` |  | - | of server |








### MOLECULER_VERSION



`MOLECULER_VERSION`

Version of Moleculer









### LOCAL_NODE_ID



`LOCAL_NODE_ID`

Local NodeID










## Static Members



### destroyService



`destroyService(service: Service)`

Destroy a local service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - |  |








### servicesChanged



`servicesChanged()`

It will be called when a new service registered or unregistered









### mcall



`mcall(def): undefined`

Multiple action calls.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `def` |  | - | Calling definitions. |






### Examples





```js
Call `mcall` with an array:
```js
broker.mcall([
	{ action: "posts.find", params: { limit: 5, offset: 0 } },
	{ action: "users.find", params: { limit: 5, sort: "username" }, opts: { timeout: 500 } }
]).then(results => {
	let posts = results[0];
	let users = results[1];
})
```
```





```js
Call `mcall` with an Object:
```js
broker.mcall({
	posts: { action: "posts.find", params: { limit: 5, offset: 0 } },
	users: { action: "users.find", params: { limit: 5, sort: "username" }, opts: { timeout: 500 } }
}).then(results => {
	let posts = results.posts;
	let users = results.users;
})
```
```





### MOLECULER_VERSION



`MOLECULER_VERSION`

Version of Moleculer









### LOCAL_NODE_ID



`LOCAL_NODE_ID`

Local NodeID









### defaultConfig



`defaultConfig`

Default configuration










