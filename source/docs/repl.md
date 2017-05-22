title: REPL mode
---
Broker has an interactive REPL mode to help the development & testing. With REPL you can load services, call actions, emit events, subscribe & unsubscribe events from your console. You can list registered nodes & actions & broker information and settings.

**Start broker in REPL mode**
```js
let broker = new ServiceBroker({ logger: console });

// Start REPL
broker.repl();
```

## REPL Commands

```
  Commands:

    help [command...]                      Provides help for a given command.
    exit                                   Exits application.
    q                                      Exit application
    call <actionName> [params]             Call an action
    dcall <nodeID> <actionName> [params]   Call a direct action
    emit <eventName> [payload]             Emit an event
    load <servicePath>                     Load a service from file
    loadFolder <serviceFolder> [fileMask]  Load all service from folder
    subscribe <eventName>                  Subscribe to an event
    unsubscribe <eventName>                Unsubscribe from an event
    actions [options]                      List of actions
    nodes                                  List of nodes
    info                                   Information from broker
```

### List nodes
```
mol $ nodes
```
![image](https://cloud.githubusercontent.com/assets/306521/26260893/67a579d4-3ccf-11e7-955a-70f252aa260d.png)

### List actions
```
mol $ actions
```
![image](https://cloud.githubusercontent.com/assets/306521/26260954/8ef9d44e-3ccf-11e7-995a-ccbe035b2a9a.png)

### Show common informations
```
mol $ info
```
![image](https://cloud.githubusercontent.com/assets/306521/26260974/aaea9b02-3ccf-11e7-9e1c-ec9150518791.png)

### Call an action
```
mol $ call "test.hello"
```

### Call an action with params
```
mol $ call "math.add" '{"a": 5, "b": 4}'
```

### Direct call
```
mol $ dcall server-2 "$node.health"
```

### Emit an event
```
mol $ emit "user.created"
```

### Subscribe to an event
```
mol $ subscribe "user.created"
```

### Unsubscribe from an event
```
mol $ unsubscribe "user.created"
```

### Load a service
```
mol $ load "./math.service.js"
```

### Load services from folder
```
mol $ load "./services"
```