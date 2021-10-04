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
    --help               mostra informações de utilização
    --load [filename]    Carrega parâmetros do arquivo
    --stream [filename]  Envia um arquivo como stream
    --save [filename]    Salva a resposta em arquivo
```

#### Executa uma ação com parâmetros
```bash
mol $ call "math.add" --a 5 --b Bob --c --no-d --e.f "hello"
```
Parâmetros serão `{ a: 5, b: 'Bob', c: true, d: false, e: { f: 'hello' } }`

#### Executa uma ação com parâmetros & metadados
```bash
mol $ call "math.add" --a 5 --#b Bob
```
Parâmetros serão `{ a: 5 }` e metadados será `{ b: 'Bob' }`

#### Executar com uma string JSON como parâmetro
```bash
mol $ call "math.add" '{"a": 5, "b": "Bob", "c": true, "d": false, "e": { "f": "hello" } }'
```
Parâmetros serão `{ a: 5, b: 'Bob', c: true, d: false, e: { f: 'hello' } }`

#### Executar com parâmetros de arquivo
```bash
mol $ call "math.add" --load
```
Ele tenta carregar o arquivo `<current_dir>/math.add.params.json` para a variável params.

```bash
mol $ call "math.add" --load my-params.json
```
Tenta carregar o arquivo `my-params.json` para a variável params.

#### Executa com stream de arquivo
```bash
mol $ call "math.add" --stream my-picture.jpg
```
Carrega o arquivo `my-picture.png` e envia para a ação `math.add` como um `Stream`.

#### Executar e salvar a resposta em arquivo
```bash
mol $ call "math.add" --save
```
Salva a resposta no arquivo `<current_dir>/posts.find.response.json`. A extensão é `.json` quando a resposta for `object`. Caso contrário é `.txt`.

```bash
mol $ call "math.add" --save my-response.json
```
Salva a resposta para o arquivo `my-response.json`.

### Chamada direta
Obter informações de saúde do nó `node-12`
```bash
mol $ dcall "node-12" "$node.health"
```
> Passagem de parâmetros é semelhante ao comando `call`.

### Emitir um evento
```bash
mol $ emit "user.created"
```

#### Emitir um evento com parâmetros
```bash
mol $ emit "user.created" --a 5 --b Bob --c --no-d --e.f "hello"
```
Parâmetros serão `{ a: 5, b: 'Bob', c: true, d: false, e: { f: 'hello' } }`

#### Emitir um evento com parâmetros & metadados
```bash
mol $ emit "user.created" --a 5 --#b Bob
```
Parâmetros serão `{ a: 5 }` e metadados será `{ b: 'Bob' }`

### Performance de um serviço

O módulo Moleculer REPL possui um novo comando para medir a performance de seus serviços.

```bash
# Executa um serviço até 5 segundos (padrão)
mol $ bench math.add

# Execute um serviço 5000 vezes
mol $ bench --num 5000 math.add

# Executa um serviço até 30 segundos
mol $ bench --time 30 math.add
```

**Opções**
```
    --num <number>     Número de iterações
    --time <seconds>   Tempo de teste
    --nodeID <nodeID>  NodeID (chamada direta)
```

**Saída** ![image](assets/repl/bench.gif)


#### Parâmetros
Por favor, note que os parâmetros podem ser passados apenas como string JSON.
```bash
mol $ bench math.add '{ "a": 50, "b": 32 }'
```

### Carregar um serviço de um arquivo
```bash
mol $ load "./math.service.js"
```

### Carregar todos os serviços de uma pasta
```bash
mol $ load "./services"
```

### Listar métricas
```bash
mol $ metrics
```

**Opções**
```
    -f, --filter <match>  filtra métricas (ex.: 'moleculer.**')
```

**Saída** ![image](assets/repl/metrics.png#zoomable)

### Chaves de cache
Você pode listar as chaves de entradas de cache com

```bash
mol $ cache keys
```

**Opções**
```
-f, --filter <match>  filtra as chaves
```


### Limpar cache

Você limpa o cache com:

```bash
mol $ cache clear
```

isto por padrão remove todas as entradas. Se você quiser remover um subconjunto de entradas, deverá adicionar um `padrão`:

**Limpar com padrão**
```
mol $ cache clear greeter.*
```

### Comandos personalizados
Os comandos personalizados do REPL podem ser definidos nas opções do broker para estender os comandos Moleculer REPL.

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
