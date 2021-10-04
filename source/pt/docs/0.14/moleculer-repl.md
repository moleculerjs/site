title: Console Interativo (REPL)
---
## moleculer repl [![npm](https://img.shields.io/npm/v/moleculer-repl.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-repl)
O [moleculer-repl](https://github.com/moleculerjs/moleculer-repl) é um console interativo de desenvolvedor para Moleculer.

## Instalação
```bash
npm i moleculer-repl
```

## Utilização

**Alternar broker para modo REPL**
```js
const broker = new ServiceBroker();

broker.start().then(() => {
    // Switch to REPL mode
    broker.repl();
});
```

## Comandos REPL

```
  Comandos:
    help [command...]                                   Fornece ajuda para um determinado comando.
    q                                                   Encerra aplicação
    actions [options]                                   Lista de ações
    bench [options] <action> [jsonParams]               Performance de um serviço
    broadcast <eventName>                               Transmitir um evento
    broadcastLocal <eventName>                          Transmitir um evento localmente
    call [options] <actionName> [jsonParams]            Executar uma ação
    dcall [options] <nodeID> <actionName> [jsonParams]  Executar uma ação direta
    clear [pattern]                                     Limpar registro de cache
    cls                                                 Limpar console   
    destroy <serviceName> [version]                     Destruir um serviço executando localmente
    emit <eventName>                                    Emitir um evento
    env                                                 Listar as variáveis de ambiente
    events [options]                                    Lista de ouvintes de eventos
    info                                                Informações do broker
    load <servicePath>                                  Carregar um serviço do arquivo
    loadFolder <serviceFolder> [fileMask]               Carregar todos os serviços de um diretório
    metrics [options]                                   Listar métricas
    nodes [options]                                     Listar nós
    services [options]                                  Listar serviços
```

### Listar nós
```bash
mol $ nodes
```

**Opções**
```
    -a, --all             lista todos os nós (offline)
    -d, --details         lista detalhada
    -f, --filter <match>  filtra nós (ex.: 'node-*')
    --raw                 converte o registro de serviço em JSON
    --save [filename]     salva o registro de serviço para um arquivo JSON
```

**Saída** ![image](assets/repl/nodes.png)

**Saída detalhada** ![image](assets/repl/nodes-detailed.png)

### Listar serviços
```bash
mol $ services
```

**Opções**
```
    -a, --all             lista todos os serviços (offline)
    -d, --details         exibe endpoints
    -f, --filter <match>  filtra serviços (ex.: 'user*')
    -i, --skipinternal    ignora serviços internos
    -l, --local           só serviços locais
```

**Saída** ![image](assets/repl/services.png)

**Saída detalhada** ![image](assets/repl/services-detailed.png)

### Listar ações
```bash
mol $ actions
```

**Opções**
```
    -a, --all             listar todas as ações (offline)
    -d, --details         exibir endpoints
    -f, --filter <match>  filtrar ações (ex.: 'users.*')
    -i, --skipinternal    ignorar ações internas
    -l, --local           só ações locais
```

**Saída** ![image](assets/repl/actions.png)

**Saída detalhada** ![image](assets/repl/actions-detailed.png)

### Listar eventos
```bash
mol $ events
```

**Opções**
```
    -a, --all             listar todos os ouvintes de eventos (offline)
    -d, --details         exibir endpoints
    -f, --filter <match>  filtrar ouvintes de eventos (ex.: 'user.*')
    -i, --skipinternal    ignorar ouvintes de eventos internos
    -l, --local           só ouvintes de eventos locais
```

**Saída** ![image](assets/repl/events.png)

**Saída detalhada** ![image](assets/repl/events-detailed.png)


### Mostrar informações comuns
```bash
mol $ info
```

**Saída** ![image](https://cloud.githubusercontent.com/assets/306521/26260974/aaea9b02-3ccf-11e7-9e1c-ec9150518791.png)

### Listar variáveis de ambiente
```bash
mol $ env
```

### Executar uma ação
```bash
mol $ call "test.hello"
```

**Saída** ![image](assets/repl/call1.png)

**Opções**
```
    --help               output usage information
    --load [filename]    Load params from file
    --stream [filename]  Send a file as stream
    --save [filename]    Save response to file
```

#### Call an action with parameters
```bash
mol $ call "math.add" --a 5 --b Bob --c --no-d --e.f "hello"
```
Params will be `{ a: 5, b: 'Bob', c: true, d: false, e: { f: 'hello' } }`

#### Call an action with params & meta
```bash
mol $ call "math.add" --a 5 --#b Bob
```
Params will be `{ a: 5 }` and meta will be `{ b: 'Bob' }`

#### Call with JSON string parameter
```bash
mol $ call "math.add" '{"a": 5, "b": "Bob", "c": true, "d": false, "e": { "f": "hello" } }'
```
Params will be `{ a: 5, b: 'Bob', c: true, d: false, e: { f: 'hello' } }`

#### Call with parameters from file
```bash
mol $ call "math.add" --load
```
It tries to load the `<current_dir>/math.add.params.json` file to params.

```bash
mol $ call "math.add" --load my-params.json
```
It tries to load the `my-params.jon` file to params.

#### Call with file stream
```bash
mol $ call "math.add" --stream my-picture.jpg
```
It loads the `my-picture.png` file and send to the `math.add` action as a `Stream`.

#### Call and save response to file
```bash
mol $ call "math.add" --save
```
It saved the response to the `<current_dir>/posts.find.response.json` file. The extension is `.json` when the response is `object`. Otherwise it is `.txt`.

```bash
mol $ call "math.add" --save my-response.json
```
It saved the response to the `my-response.json` file.

### Direct call
Get health info from `node-12` node
```bash
mol $ dcall "node-12" "$node.health"
```
> Parameter passing is similar to `call` command.

### Emit an event
```bash
mol $ emit "user.created"
```

#### Emit an event with parameters
```bash
mol $ emit "user.created" --a 5 --b Bob --c --no-d --e.f "hello"
```
Params will be `{ a: 5, b: 'Bob', c: true, d: false, e: { f: 'hello' } }`

#### Emit an event with params & meta
```bash
mol $ emit "user.created" --a 5 --#b Bob
```
Params will be `{ a: 5 }` and meta will be `{ b: 'Bob' }`

### Benchmark services

Moleculer REPL module has a new bench command to measure your services.

```bash
# Call service until 5 seconds (default)
mol $ bench math.add

# Call service 5000 times
mol $ bench --num 5000 math.add

# Call service until 30 seconds
mol $ bench --time 30 math.add
```

**Opções**
```
    --num <number>     Number of iterates
    --time <seconds>   Time of bench
    --nodeID <nodeID>  NodeID (direct call)
```

**Output** ![image](assets/repl/bench.gif)


#### Parâmetros
Please note, parameters can be passed only as JSON string.
```bash
mol $ bench math.add '{ "a": 50, "b": 32 }'
```

### Load a service from file
```bash
mol $ load "./math.service.js"
```

### Load all services from a folder
```bash
mol $ load "./services"
```

### List metrics
```bash
mol $ metrics
```

**Opções**
```
    -f, --filter <match>  filter metrics (e.g.: 'moleculer.**')
```

**Output** ![image](assets/repl/metrics.png#zoomable)

### Cache Keys
You can list keys of cache entries with

```bash
mol $ cache keys
```

**Opções**
```
-f, --filter <match>  filter keys
```


### Cache Clear

You clear the cache with:

```bash
mol $ cache clear
```

that by default removes all the entries. If you want to remove a subset of entries, you must add a `pattern`:

**Clear with pattern**
```
mol $ cache clear greeter.*
```

### Custom commands
Custom REPL commands can be defined in broker options to extend Moleculer REPL commands.

```js
// moleculer.config.js
module.exports = {
    replCommands: [
        {
            command: "hello <name>",
            description: "Call the greeter.hello service with name",
            alias: "hi",
            options: [
                { option: "-u, --uppercase", description: "Uppercase the name" }
            ],
            types: {
                string: ["name"],
                boolean: ["u", "uppercase"]
            },
            //parse(command, args) {},
            //validate(args) {},
            //help(args) {},
            allowUnknownOptions: true,
            action(broker, args/*, helpers*/) {
                const name = args.options.uppercase ? args.name.toUpperCase() : args.name;
                return broker.call("greeter.hello", { name }).then(console.log);
            }
        }
    ]
};
```

```bash
mol $ hello -u John
Hello JOHN
```
