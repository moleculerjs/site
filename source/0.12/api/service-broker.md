title: ServiceBroker
---



# defaultOptions




`defaultOptions`

Default broker options













# ServiceBroker




`new ServiceBroker()`

Service broker class








## Instance Members



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



`getLogger(module: String, service: String, version): Logger`

Get a custom logger for sub-modules (service, transporter, cacher, context...etc)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `module` | String | - | Name of module |
| `service` | String | - | Service name |
| `version` |  | - | Service version |








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








### createService



`createService(schema: any, schemaMods): Service`

Create a new service by schema


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | any | - | Schema of service |
| `schemaMods` |  | - | Modified schema |








### wrapAction



`wrapAction(action: any)`

Wrap action handler for middlewares


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `action` | any | - | - |








### registerInternalServices



`registerInternalServices()`

Register internal services









### getLocalService



`getLocalService(name: String, version): Service`

Get a local service by name


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String | - | - |








### use



`use(mws: Function)`

Add a middleware to the broker


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mws` | Function | - | - |








### call



`call(actionName: String, params, opts): Promise`

Call an action


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - | name of action |
| `params` |  | - | params of action |
| `opts` |  | - | options of call (optional) |








### shouldMetric



`shouldMetric()`

Check should metric the current call









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

Emit an event for all local & remote services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |








### broadcastLocal



`broadcastLocal(eventName: string, payload: any, groups, nodeID)`

Emit an event for all local services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |
| `nodeID` |  | - | - |









## Static Members



### watchService



`watchService(service: Service)`

Watch a service file and hot reload if it changed.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |








### hotReloadService



`hotReloadService(service: Service): Service`

Hot reload a service


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |








### registerLocalService



`registerLocalService(service: Service, registryItem: Object)`

Add & register a local service instance


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |
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



`findNextActionEndpoint(actionName: String, opts: Object): undefined`

Find the next available endpoint for action


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | String | - | - |
| `opts` | Object | - | - |








### mcall



`mcall(def): undefined`

Multiple action calls.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `def` |  | - | Calling definitions. |






#### Examples





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





### sendPing



`sendPing(nodeID)`

Send ping to a node (or all nodes if nodeID is null)


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` |  | - | - |








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

Emit event to local nodes


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `event` | String | - | - |
| `payload` | any | - | - |
| `groups` | any | - | - |
| `sender` | String | - | - |
| `broadcast` | boolean | - | - |








### MOLECULER_VERSION



`MOLECULER_VERSION`

Version of Moleculer









### PROTOCOL_VERSION



`PROTOCOL_VERSION`

Version of Protocol









### defaultOptions



`defaultOptions`

Default configuration










