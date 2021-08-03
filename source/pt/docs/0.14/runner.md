title: Moleculer Runner
---

Moleculer Runner é um script auxiliar que ajuda você a executar projetos do Moleculer. Com isso você não precisa criar uma instância do ServiceBroker preenchendo as opções. Em vez disso, você pode criar um arquivo `moleculer.config.js` na raiz do repositório com as opções do broker. Então simplesmente chame o `moleculer-runner` via NPM script e ele irá carregar automaticamente o arquivo de configuração, criar o broker e inicializar os serviços. Como alternativa, você pode declarar sua configuração como variáveis de ambiente.


{% note info Production-ready %}
Use o `moleculer.config.js` durante o desenvolvimento ou armazene opções comuns. Em produção, você pode substituir os valores com as variáveis de ambiente!
{% endnote %}

## Sintaxe
```
$ moleculer-runner [options] [arquivos de serviço ou pastas ou máscaras]
```
> Nota: Ele é executado neste formato somente em scripts NPM. Para chamá-lo diretamente do seu console, use o formato `./node_modules/.bin/moleculer-runner --repl` ou `node ./node_modules/moleculer/bin/moleculer-runner.js --repl`.

## Opções

| Opção                          | Tipo      | Padrão  | Descrição                                                                                       |
| ------------------------------ | --------- | ------- | ----------------------------------------------------------------------------------------------- |
| `-r`, `--repl`                 | `Boolean` | `false` | Se verdadeiro, ele alterna para o modo [REPL](moleculer-repl.html) após o início do broker.     |
| `-s`, `--silent`               | `Boolean` | `false` | Desabilitar o log do broker. Não exibe nada ao console.                                         |
| `-H`, `--hot`                  | `Boolean` | `false` | Recarrega automaticamente os serviços quando há alteração.                                      |
| `-c`, `--config <file>`  | `String`  | `null`  | Carregar arquivo de configuração de um caminho diferente ou um nome de arquivo diferente.       |
| `-e`, `--env`                  | `Boolean` | `false` | Carregar variáveis de ambiente a partir do arquivo '.env' da pasta atual.                       |
| `-E`, `--envfile <file>` | `String`  | `null`  | Carregar variáveis de ambiente a partir do arquivo especificado.                                |
| `-i`, `--instances`            | `Number`  | `null`  | Inicie [number] instâncias do nó ou `max` para todos os núcleos de cpu (com o módulo `cluster`) |


**Exemplos de scripts NPM**
```js
{
    "scripts": {
        "dev": "moleculer-runner --repl --hot --config moleculer.dev.config.js services",
        "start": "moleculer-runner --instances=max services"
    }
}
```
O script `dev` carrega configurações de desenvolvimento do arquivo `moleculer.dev.config.js`, inicializa todos os serviços a partir da pasta `services`, habilita o recarregamento automático e alterna para o modo REPL. Execute-o com o comando `npm run dev`.

O script `start` é para carregar o arquivo padrão `moleculer.config.js` se ele existir, caso contrário só carrega opções de variáveis de ambiente. Inicia 4 instâncias do broker, e em seguida inicializa todos os serviços na pasta `services`. Execute-o com o comando `npm start`.

## Lógica de carregamento das configurações
O runner faz os seguintes passos para carregar & mesclar as configurações:

1. Carrega o arquivo de configuração definido na variável de ambiente `MOLECULER_CONFIG`. Se não existe, retorna um erro.
2. Carrega o arquivo de configuração definido nas opções do CLI. Se não existe, retorna um erro. Observe que `MOLECULER_CONFIG` tem prioridade sobre CLI significando que se ambas forem definidas `MOLECULER_CONFIG` é a que será usada.
3. Se não estiver definido, irá carregar o arquivo `moleculer.config.js` do diretório atual. Se ele não existir, carrega o arquivo `moleculer.config.json`.
4. Uma vez que um arquivo de configuração foi carregado, ele mescla as opções com as opções padrão do ServiceBroker.
5. O runner observa as opções uma a uma e tenta substituí-las por variáveis de ambiente. Uma vez que o `logLevel: "warn"` é definido no arquivo de configuração, mas a variável de ambiente `LOGLEVEL=debug` é definida, o runner sobrescreve e o resultado é: `logLevel: "debug"`.

> Para sobrescrever as opções padrão profundamente aninhadas do broker, que não estão presentes no `moleculer.config.js`, através de variáveis de ambiente, use o prefixo `MOL_` e sublinhado duplo `__` para propriedades aninhadas no arquivo `.env`. Por exemplo, para definir o [prefixo de cache](caching.html#Built-in-cachers) para `MOL`, você deve declarar como `MOL_CACHER__OPTIONS__PREFIX=MOL`.

### Arquivo de configuração
A estrutura do arquivo de configuração é a mesma que as [opções do broker](configuration.html#Broker-options). Todas as propriedades têm o mesmo nome.

**Exemplo de arquivo de configuração**
```js
// moleculer.config.js
module.exports = {
    nodeID: "node-test",
    logger: true,
    logLevel: "debug",

    transporter: "nats://localhost:4222",
    requestTimeout: 5 * 1000,

    circuitBreaker: {
        enabled: true
    },

    metrics: true
};
```


### Arquivo de configuração assíncrono

Moleculer Runner também suporta arquivos de configuração assíncronos. Neste caso `moleculer.config.js` deve exportar uma `Function` que retorne uma `Promise` (ou você pode usar `async/await`).

```js
// moleculer.config.js
const fetch = require("node-fetch");

module.exports = async function() {
    const res = await fetch("https://pastebin.com/raw/SLZRqfHX");
    return await res.json();
};
```

### Variáveis de ambiente
O runner transforma os nomes das propriedades em maiúsculas. Se aninhado, o runner concatena nomes com `_`.

**Exemplos de variáveis de ambiente**
```bash
NODEID=node-test
LOGGER=true
LOGLEVEL=debug

# Shorthand transporter
TRANSPORTER=nats://localhost:4222
REQUESTTIMEOUT=5000

# Nested property
CIRCUITBREAKER_ENABLED=true

METRICS=true
```

## Services loading logic
The runner loads service files or folders defined in CLI arguments. If you define folder(s), the runner loads all services `**/*.service.js` from specified one(s) (including sub-folders too). Services & service folder can be loaded with `SERVICES` and `SERVICEDIR` environment variables.

**Loading steps:**
1. If `SERVICEDIR` env found, but no `SERVICES` env, it loads all services from the `SERVICEDIR` directory.
2. If `SERVICEDIR` & `SERVICES` env found, it loads the specified services from the `SERVICEDIR` directory.
3. If no `SERVICEDIR`, but `SERVICES` env found, it loads the specified services from the current directory.
4. Check the CLI arguments. If filename found, it loads them. If directory found, it loads them. If glob pattern found, it applies and load the found files.
> Please note: shorthand names can also be used in `SERVICES` env var.

**Exemplo**
```
SERVICEDIR=services
SERVICES=math,post,user
```
It loads the `math.service.js`, `post.service.js` and `user.service.js` files from the `services` folder.

```
SERVICEDIR=my-services
```
It loads all `*.service.js` files from the `my-services` folder (including sub-folders too).

### Glob patterns
If you want to be more specific, use glob patterns. It is useful when loading all services except certain ones.

```bash
$ moleculer-runner services !services/others/**/*.service.js services/others/mandatory/main.service.js
```

**Explanations:**
- `services` - legacy mode. Load all services from the `services` folder with `**/*.service.js` file mask.
- `!services/others/**/*.service.js` - skip all services in the `services/others` folder and sub-folders.
- `services/others/mandatory/main.service.js` - load the exact service.

> The glob patterns work in the `SERVICES` enviroment variables, as well.

## Built-in clustering

Moleculer Runner has a built-in clustering function to start multiple instances from your broker.

Example to start all services from the `services` folder in 4 instances.
```bash
$ moleculer-runner --instances 4 services
```

{% note info Clustered Node ID %}
The `nodeID` will be suffixed with the worker ID. E.g. if you define `my-node` nodeID in options, and starts 4 instances, the instance nodeIDs will be `my-node-1`, `my-node-2`, `my-node-3`, `my-node-4`.
{% endnote %}

## .env files

Moleculer runner can load `.env` file at starting. There are two new cli options to load env file:

* `-e, --env` - Load envorinment variables from the '.env' file from the current folder.
* `-E, --envfile <filename>` - Load envorinment variables from the specified file.

**Exemplo**
```sh
# Load the default .env file from current directory
$ moleculer-runner --env

# Load the specified .my-env file
$ moleculer-runner --envfile .my-env
```

{% note info Dependencies %}
To use this feature install the `dotenv` module with `npm install dotenv --save` command.
{% endnote %}
