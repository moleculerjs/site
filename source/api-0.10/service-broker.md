title: ServiceBroker
---



# ServiceBroker




`new ServiceBroker(options)`

Service broker class










## Static Members



### constructor



`new ServiceBroker(options: any)`

Creates an instance of ServiceBroker.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `options` | any | - | - |








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








### watchService



`watchService(service: Service)`

Watch a service file and hot reload if it changed.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | - |








<<<<<<< HEAD:source/0.12/api/service-broker.md
### hotReloadService



`hotReloadService(service: Service): Service`

Hot reload a service
=======
### registerLocalService



`registerLocalService(service: Service)`

Register a local service
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `service` | Service | - | - |
=======
| `service` | Service | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### createService



`createService(schema: any, schemaMods): Service`

Create a new service by schema


#### Parameters
=======
### registerRemoteService



`registerRemoteService(nodeID: String, service: Service)`

Register a remote service
>>>>>>> master:source/api-0.10/service-broker.md

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | any | - | Schema of service |
| `schemaMods` |  | - | Modified schema |

### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - | NodeID if it is on a remote server/node |
| `service` | Service | - |  |






<<<<<<< HEAD:source/0.12/api/service-broker.md
### registerLocalService
=======
>>>>>>> master:source/api-0.10/service-broker.md


### registerAction

<<<<<<< HEAD:source/0.12/api/service-broker.md
`registerLocalService(service: Service, registryItem: Object)`

Add & register a local service instance
=======


`registerAction(nodeID: String, action: any)`

Register an action
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `service` | Service | - | - |
| `registryItem` | Object | - | - |
=======
| `nodeID` | String | - | NodeID if it is on a remote server/node |
| `action` | any | - | action schema |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### destroyService



`destroyService(service: Service)`

Destroy a local service
=======
### wrapAction



`wrapAction(action: any)`

Wrap action handler for middlewares
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `service` | Service | - | - |
=======
| `action` | any | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### servicesChanged



`servicesChanged(localService)`

It will be called when a new local or remote service
is registered or unregistered.
=======
### unregisterServicesByNode



`unregisterServicesByNode(nodeID: String)`

Unregister services by node
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
=======
| `nodeID` | String | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### wrapAction



`wrapAction(action: any)`

Wrap action handler for middlewares


#### Parameters
=======
### unregisterAction



`unregisterAction(nodeID: String, action: any)`

Unregister an action on a local server.
It will be called when a remote node disconnected.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - | NodeID if it is on a remote server/node |
| `action` | any | - | action schema |








### registerInternalServices



`registerInternalServices()`

Register internal services
>>>>>>> master:source/api-0.10/service-broker.md

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `action` | any | - | - |








<<<<<<< HEAD:source/0.12/api/service-broker.md
### registerInternalServices


=======
### on



`on(name: String, handler: Function)`

Subscribe to an event
>>>>>>> master:source/api-0.10/service-broker.md

`registerInternalServices()`

Register internal services

<<<<<<< HEAD:source/0.12/api/service-broker.md
=======
| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String | - |  |
| `handler` | Function | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### getLocalService



`getLocalService(name: String, version): Service`

Get a local service by name
=======
### once



`once(name: String, handler: Function)`

Subscribe to an event once
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `name` | String | - | - |
=======
| `name` | String | - |  |
| `handler` | Function | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### waitForServices



`waitForServices(serviceNames, timeout: Number, interval: Number, logger): Promise`

Wait for other services
=======
### off



`off(name: String, handler: Function)`

Unsubscribe from an event
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `serviceNames` |  | - | - |
| `timeout` | Number | - | Timeout in milliseconds |
| `interval` | Number | - | Check interval in milliseconds |
=======
| `name` | String | - |  |
| `handler` | Function | - |  |




>>>>>>> master:source/api-0.10/service-broker.md




### getService



`getService(serviceName: String): Service`

Get a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | String | - |  |


<<<<<<< HEAD:source/0.12/api/service-broker.md
### use



`use(mws: Function)`

Add a middleware to the broker
=======






### hasService



`hasService(serviceName: String): Boolean`

Has a local service by name
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `mws` | Function | - | - |
=======
| `serviceName` | String | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### findNextActionEndpoint



`findNextActionEndpoint(actionName: String, opts: Object): undefined`

Find the next available endpoint for action
=======
### hasAction



`hasAction(actionName: String): Boolean`

Has an action by name
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `actionName` | String | - | - |
| `opts` | Object | - | - |
=======
| `actionName` | String | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### call



`call(actionName: String, params, opts): Promise`

Call an action
=======
### getAction



`getAction(actionName: String): Object`

Get an action by name
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `actionName` | String | - | name of action |
| `params` |  | - | params of action |
| `opts` |  | - | options of call (optional) |
=======
| `actionName` | String | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### mcall



`mcall(def): undefined`

Multiple action calls.
=======
### isActionAvailable



`isActionAvailable(actionName: String): Boolean`

Check has callable action handler
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `def` |  | - | Calling definitions. |
=======
| `actionName` | String | - |  |




>>>>>>> master:source/api-0.10/service-broker.md




<<<<<<< HEAD:source/0.12/api/service-broker.md
=======
### use
>>>>>>> master:source/api-0.10/service-broker.md


#### Examples

<<<<<<< HEAD:source/0.12/api/service-broker.md

=======
`use(mws: Function)`

Add a middleware to the broker
>>>>>>> master:source/api-0.10/service-broker.md



<<<<<<< HEAD:source/0.12/api/service-broker.md
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
=======
| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mws` | Function | - |  |
>>>>>>> master:source/api-0.10/service-broker.md





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



<<<<<<< HEAD:source/0.12/api/service-broker.md
=======
### call
>>>>>>> master:source/api-0.10/service-broker.md


### shouldMetric

<<<<<<< HEAD:source/0.12/api/service-broker.md

=======
`call(actionName: any, params: any, opts: any)`

Call an action (local or remote)
>>>>>>> master:source/api-0.10/service-broker.md

`shouldMetric()`

Check should metric the current call

<<<<<<< HEAD:source/0.12/api/service-broker.md
=======
| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - | name of action |
| `params` | any | - | params of action |
| `opts` | any | - | options of call (optional) |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### emit



`emit(eventName: string, payload: any, groups)`

Emit an event (grouped & balanced global event)
=======
### shouldMetric



`shouldMetric()`

Check should metric the current call









### emit



`emit(eventName: string, payload: any): boolean`

Emit an event (global & local)
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |
=======
| `eventName` | string | - |  |
| `payload` | any | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### broadcast



`broadcast(eventName: string, payload: any, groups)`

Emit an event for all local & remote services
=======
### emitLocal



`emitLocal(eventName: string, payload: any, sender, Sender): boolean`

Emit an event only local
>>>>>>> master:source/api-0.10/service-broker.md


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `eventName` | string | - | - |
| `payload` | any | - | - |
| `groups` |  | - | - |
=======
| `eventName` | string | - |  |
| `payload` | any | - |  |
| `Sender` |  | - | nodeID |
>>>>>>> master:source/api-0.10/service-broker.md








<<<<<<< HEAD:source/0.12/api/service-broker.md
### broadcastLocal



`broadcastLocal(eventName: string, payload: any, groups, nodeID)`

Emit an event for all local services
=======
### MOLECULER_VERSION



`MOLECULER_VERSION`

Version of Moleculer
>>>>>>> master:source/api-0.10/service-broker.md


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
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `nodeID` |  | - | - |
=======
| `service` | Service | - |  |
>>>>>>> master:source/api-0.10/service-broker.md








### hotReloadService



`hotReloadService(service: Service): Service`

Hot reload a service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - |  |








### destroyService



`destroyService(service: Service)`

Destroy a local service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - |  |








### servicesChanged


<<<<<<< HEAD:source/0.12/api/service-broker.md
#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | String | - | - |
=======

`servicesChanged()`

It will be called when a new service registered or unregistered

>>>>>>> master:source/api-0.10/service-broker.md








### mcall



`mcall(def): undefined`

Multiple action calls.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<<<<<<< HEAD:source/0.12/api/service-broker.md
| `event` | String | - | - |
| `payload` | any | - | - |
| `groups` | any | - | - |
| `sender` | String | - | - |
| `broadcast` | boolean | - | - |
=======
| `def` |  | - | Calling definitions. |
>>>>>>> master:source/api-0.10/service-broker.md






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









### defaultConfig



`defaultConfig`

Default configuration










