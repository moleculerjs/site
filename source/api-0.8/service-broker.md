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



`getLogger(name: String)`

Get a custom logger for sub-modules (service, transporter, cacher, context...etc)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | String | - | name of module |








### fatal



`fatal(message: String, err, needExit: boolean)`

Fatal error. Print the message to console (if logger is not exists). And exit the process (if need)


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



`registerRemoteService(nodeID: any, service: any)`

Register a remote service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | any | - | NodeID if it is on a remote server/node |
| `service` | any | - |  |








### registerAction



`registerAction(nodeID: any, action: any)`

Register an action in a local server


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | any | - | NodeID if it is on a remote server/node |
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



`unregisterAction(nodeID: any, action: any)`

Unregister an action on a local server. 
It will be called when a remote node disconnected.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | any | - | NodeID if it is on a remote server/node |
| `action` | any | - | action schema |








### registerInternalActions



`registerInternalActions()`

Register internal actions









### on



`on(name: any, handler: any)`

Subscribe to an event


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | any | - |  |
| `handler` | any | - |  |








### once



`once(name: any, handler: any)`

Subscribe to an event once


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | any | - |  |
| `handler` | any | - |  |








### off



`off(name: any, handler: any)`

Unsubscribe from an event


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | any | - |  |
| `handler` | any | - |  |








### getService



`getService(serviceName: any)`

Get a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | any | - |  |








### hasService



`hasService(serviceName: any)`

Has a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | any | - |  |








### hasAction



`hasAction(actionName: any)`

Has an action by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - |  |








### getAction



`getAction(actionName: any): Object`

Get an action by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - |  |








### isActionAvailable



`isActionAvailable(actionName: any)`

Check has available action handler


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - |  |








### use



`use(mws, mw: any)`

Add a middleware to the broker


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mw` | any | - |  |








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










## Static Members



### MOLECULER_VERSION



`MOLECULER_VERSION`

Version of Moleculer









### defaultConfig



`defaultConfig`

Default configuration










