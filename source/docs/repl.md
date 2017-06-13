title: REPL mode
---
Broker has an interactive REPL mode to help the development & testing. With REPL you can load services, call actions, emit events, subscribe & unsubscribe events from your console. You can list registered nodes, services, actions, broker information and broker settings.

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
    dcall <nodeID> <actionName> [params]   Direct call an action
    emit <eventName> [payload]             Emit an event
    load <servicePath>                     Load a service from file
    loadFolder <serviceFolder> [fileMask]  Load all service from folder
    subscribe <eventName>                  Subscribe to an event
    unsubscribe <eventName>                Unsubscribe from an event
    actions [options]                      List of actions
    services [options]                     List of services
    nodes [options]                        List of nodes
    info                                   Information from broker
```

### List nodes
```
mol $ nodes
```

**Options**
```
    -d, --details
```

**Output**
![image](https://user-images.githubusercontent.com/306521/27083082-9fcb9cb8-5047-11e7-9817-1b1a0de42f3e.png)

### List services
```
mol $ services
```

**Options**
```
    -l, --local         Only local services
    -i, --skipinternal  Skip internal services
```

**Output**
![image](https://user-images.githubusercontent.com/306521/27083119-bdea2426-5047-11e7-879e-0634c1aba258.png)

### List actions
```
mol $ actions
```

**Options**
```
    -l, --local         Only local services
    -i, --skipinternal  Skip internal services
    -d, --details       Print endpoints
```

**Output**
![image](https://cloud.githubusercontent.com/assets/306521/26260954/8ef9d44e-3ccf-11e7-995a-ccbe035b2a9a.png)

### Show common informations
```
mol $ info
```

**Output**
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

### Load a service from file
```
mol $ load "./math.service.js"
```

### Load all services from a folder
```
mol $ load "./services"
```