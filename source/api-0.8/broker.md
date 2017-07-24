title: ServiceBroker API 
---

# ServiceBroker API

## Constructor

### Constructor options

## Properties

### `options`

## Methods

### `start()`

### `stop()`

### `repl()`

### `getLogger(name)`

### `fatal()`

### `loadServices(folder = "./services", fileMask = "*.service.js")`

### `loadService(filePath)`

### `createService(schema, schemaMods)`

### `on(name, handler)`

### `once(name, handler)`

### `off(name, handler)`

### `getService(serviceName)`

### `hasService(serviceName)`

### `hasAction(actionName)`

### `getAction(actionName)`

### `isActionAvailable(actionName)`

### `use(...mws)`

### `createNewContext(action, nodeID, params, opts)`

### `call(actionName, params, opts = {})`

### `emit(eventName, payload)`

### `emitLocal(eventName, payload, sender)`

### `start()`

### `start()`

## Static properties

### `MOLECULER_VERSION`

### `defaultConfig`
