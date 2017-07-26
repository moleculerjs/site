title: Context
---



# ServiceBroker




`new ServiceBroker(options)`

Service broker class








## Instance Members



### constructor




`constructor(options: any)`

Creates an instance of ServiceBroker.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `options` | any | - | Context ID |










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
| `name` | String | - | Context ID |










### fatal




`fatal(message: String, err, needExit: boolean)`

Fatal error. Print the message to console (if logger is not exists). And exit the process (if need)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `message` | String | - | Context ID |
| `err` |  | - | Context ID |
| `needExit` |  | - | Context ID |










### loadServices




`loadServices(folder: string, fileMask: string): Number`

Load services from a folder


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `folder` |  | - | Context ID |
| `fileMask` |  | - | Context ID |










### loadService




`loadService(filePath, Path: string): Service`

Load a service from file


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `Path` | string | - | Context ID |










### createService




`createService(schema: any, schemaMods): Service`

Create a new service by schema


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | any | - | Context ID |
| `schemaMods` |  | - | Context ID |










### registerLocalService




`registerLocalService(service: Service)`

Register a local service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `service` | Service | - | Context ID |










### registerRemoteService




`registerRemoteService(nodeID: any, service: any)`

Register a remote service


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | any | - | Context ID |
| `service` | any | - | Context ID |










### registerAction




`registerAction(nodeID: any, action: any)`

Register an action in a local server


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | any | - | Context ID |
| `action` | any | - | Context ID |










### wrapAction




`wrapAction(action: any)`

Wrap action handler for middlewares


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `action` | any | - | Context ID |










### unregisterServicesByNode




`unregisterServicesByNode(nodeID: String)`

Unregister services by node


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | String | - | Context ID |










### unregisterAction




`unregisterAction(nodeID: any, action: any)`

Unregister an action on a local server. 
It will be called when a remote node disconnected.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `nodeID` | any | - | Context ID |
| `action` | any | - | Context ID |










### registerInternalActions




`registerInternalActions()`

Register internal actions









### on




`on(name: any, handler: any)`

Subscribe to an event


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | any | - | Context ID |
| `handler` | any | - | Context ID |










### once




`once(name: any, handler: any)`

Subscribe to an event once


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | any | - | Context ID |
| `handler` | any | - | Context ID |










### off




`off(name: any, handler: any)`

Unsubscribe from an event


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `name` | any | - | Context ID |
| `handler` | any | - | Context ID |










### getService




`getService(serviceName: any)`

Get a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | any | - | Context ID |










### hasService




`hasService(serviceName: any)`

Has a local service by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceName` | any | - | Context ID |










### hasAction




`hasAction(actionName: any)`

Has an action by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - | Context ID |










### getAction




`getAction(actionName: any): Object`

Get an action by name


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - | Context ID |










### isActionAvailable




`isActionAvailable(actionName: any)`

Check has available action handler


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - | Context ID |










### use




`use(mws, mw: any)`

Add a middleware to the broker


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mw` | any | - | Context ID |










### createNewContext




`createNewContext(action: Object, nodeID, params, opts: Object): Context`

Create a new Context instance


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `action` | Object | - | Context ID |
| `nodeID` |  | - | Context ID |
| `params` |  | - | Context ID |
| `opts` | Object | - | Context ID |










### call




`call(actionName: any, params: any, opts: any)`

Call an action (local or remote)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `actionName` | any | - | Context ID |
| `params` | any | - | Context ID |
| `opts` | any | - | Context ID |










### shouldMetric




`shouldMetric()`

Check should metric the current call









### emit




`emit(eventName: string, payload: any): boolean`

Emit an event (global & local)


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | Context ID |
| `payload` | any | - | Context ID |










### emitLocal




`emitLocal(eventName: string, payload: any, sender, nodeID): boolean`

Emit an event only local


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `eventName` | string | - | Context ID |
| `payload` | any | - | Context ID |
| `nodeID` |  | - | Context ID |










### MOLECULER_VERSION




`MOLECULER_VERSION`

Version of Moleculer












## Static Members




