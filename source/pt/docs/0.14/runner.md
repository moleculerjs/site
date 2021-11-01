title: Moleculer Runner
---

Moleculer Runner is a helper script that helps you run Moleculer projects. With it, you don't need to create a ServiceBroker instance with options. Instead, you can create a `moleculer.config.js` file in the root of repo with broker options. Then simply call the `moleculer-runner` in NPM script, and it will automatically load the configuration file, create the broker and load the services. Como alternativa, você pode declarar sua configuração como variáveis de ambiente.


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
> This function runs with the `MoleculerRunner` instance as the `this` context. Useful if you need to access the flags passed to the runner. Check the [MoleculerRunner](https://github.com/moleculerjs/moleculer/blob/master/src/runner.js) source more details.

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

## Lógica de carregamento de serviços
O runner carrega arquivos de serviço ou pastas definidas nos argumentos CLI. Se você definir pasta(s), o runner carrega todos os serviços `**/*.service.js` a partir da(s) especificada(s) (incluindo subpastas também). Os serviços & a pasta de serviços podem ser carregados com as variáveis de ambiente `SERVICES` e `SERVICEDIR`.

**Etapas do carregamento:**
1. Se `SERVICEDIR` for encontrado no env, mas nenhum `SERVICES` existe no env, ele carrega todos os serviços do diretório `SERVICEDIR`.
2. Se `SERVICEDIR` & `SERVICES` for encontrado no env, ele carrega todos os serviços do diretório `SERVICEDIR`.
3. Se nenhum `SERVICEDIR` for encontrado no env, mas `SERVICES` for encontrado, ele carrega os serviços especificados do diretório atual.
4. Verifica os argumentos do CLI. Se o nome do arquivo for encontrado, é carregado. Se o diretório for encontrado, é carregado. Se um padrão de máscara for encontrado, ele aplica e carrega os arquivos encontrados.
> Por favor, note: nomes abreviados também podem ser usados nas variáveis de ambiente `SERVICES`.

**Exemplo**
```
SERVICEDIR=services
SERVICES=math,post,user
```
Ele carrega os arquivos `math.service.js`, `post.service.js` e `user.service.js` da pasta `services`.

```
SERVICEDIR=my-services
```
Ele carrega todos os arquivos `*.service.js` da pasta `my-services` (incluindo subpastas também).

### Padrões Glob
Se você quiser ser mais específico, use os padrões glob. É útil para carregar todos os serviços, exceto alguns deles.

```bash
$ moleculer-runner services !services/others/**/*.service.js services/others/mandatory/main.service.js
```

**Explicações:**
- `services` - modo legado. Carrega todos os serviços da pasta `services` com uma máscara de arquivo `**/*.service.js`.
- `!services/others/**/*.service.js` - ignora todos os serviços na pasta `services/others` e suas sub-pastas.
- `services/others/mandatory/main.service.js` - carrega o serviço exato.

> The glob patterns work in the `SERVICES` environment variables, as well.

## Cluster integrado

O Moleculer Runner possui uma função cluster integrado para iniciar várias instâncias do seu broker.

Exemplo para iniciar todos os serviços da pasta `services` em 4 instâncias.
```bash
$ moleculer-runner --instances 4 services
```

{% note info Clustered Node ID %}
O `nodeID` será sufixo com o worker ID. Ex.: se você definir `my-node` como nodeID em opções, e inicia 4 instâncias, os nodeIDs de instância serão `my-node-1`, `my-node-2`, `my-node-3`, `my-node-4`.
{% endnote %}

## Arquivos env

O Moleculer runner pode carregar o arquivo `.env` ao iniciar. Existem duas novas opções para carregar arquivo env:

* `-e, --env` - Load environment variables from the '.env' file from the current folder.
* `-E, --envfile <filename>` - Load environment variables from the specified file.

**Exemplo**
```sh
# Load the default .env file from current directory
$ moleculer-runner --env

# Load the specified .my-env file
$ moleculer-runner --envfile .my-env
```

{% note info Dependencies %}
To use this feature, install the `dotenv` module with `npm install dotenv --save` command.
{% endnote %}
