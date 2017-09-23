title: REPL console
---
## moleculer repl [![npm](https://img.shields.io/npm/v/moleculer-repl.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-repl)
The [moleculer-repl](https://github.com/ice-services/moleculer-repl) is an interactive developer console for Moleculer.

## Install
```bash
npm install moleculer-repl --save
```

## Usage

**Switch broker to REPL mode**
```js
let broker = new ServiceBroker({ logger: console });

// Switch to REPL mode
broker.repl();
```

## REPL Commands

```
  Commands:

    help [command...]                      Provides help for a given command.
    exit                                   Exits application.
    q                                      Exit application
    call <actionName>                      Call an action
    dcall <nodeID> <actionName>            Direct call an action
    emit <eventName>                       Emit an event
    broadcast <eventName>                  Broadcast an event
    broadcastLocal <eventName>             Broadcast an event to local services    
    load <servicePath>                     Load a service from file
    loadFolder <serviceFolder> [fileMask]  Load all service from folder
    actions [options]                      List of actions
    events [options]                       List of events
    services [options]                     List of services
    nodes [options]                        List of nodes
    info                                   Information from broker
```

### List nodes
```bash
mol $ nodes
```

**Options**
```
    -d, --details  Detailed list
    -a, --all      List all (offline) nodes
```

**Output**
![image](https://user-images.githubusercontent.com/306521/27083082-9fcb9cb8-5047-11e7-9817-1b1a0de42f3e.png)

### List services
```bash
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
```bash
mol $ actions
```

**Options**
```
    -l, --local         Only local actions
    -i, --skipinternal  Skip internal actions
    -d, --details       Print endpoints
```

**Output**
![image](https://cloud.githubusercontent.com/assets/306521/26260954/8ef9d44e-3ccf-11e7-995a-ccbe035b2a9a.png)


### List events
```bash
mol $ events
```

**Options**
```
    -l, --local         Only local events
    -i, --skipinternal  Skip internal events
    -d, --details       Print endpoints
```

**Output**
!TODO!

### Show common informations
```bash
mol $ info
```

**Output**
![image](https://cloud.githubusercontent.com/assets/306521/26260974/aaea9b02-3ccf-11e7-9e1c-ec9150518791.png)

### Call an action
```bash
mol $ call "test.hello"
```

### Call an action with parameters
```bash
mol $ call "math.add" --a 5 --b Bob --c --no-d
```
Params will be `{ a: 5, b: 'Bob', c: true, d: false }`

### Direct call
Get health info of `node-12` node
```bash
mol $ dcall "node-12" "$node.health"
```

### Emit an event
```bash
mol $ emit "user.created"
```

### Emit an event with parameters
```bash
mol $ emit "user.created" --a 5 --b Bob --c --no-d
```
Params will be `{ a: 5, b: 'Bob', c: true, d: false }`

### Load a service from file
```bash
mol $ load "./math.service.js"
```

### Load all services from a folder
```bash
mol $ load "./services"
```
