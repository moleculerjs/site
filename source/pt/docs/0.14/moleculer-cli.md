title: Ferramenta de Linha de Comando
---

## moleculer-cli [![npm](https://img.shields.io/npm/v/moleculer-cli.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-cli)
Esta é uma [ferramenta de linha de comando](https://github.com/moleculerjs/moleculer-cli) para o Moleculer ajudar no desenvolvimento & testes.

## Instalação

``` bash
$ npm i -g moleculer-cli
```

## Comandos

## Init
O comando `init` é usado para fazer um novo projeto Moleculer.

``` bash
$ moleculer init project my-project
```
O comando acima baixa o modelo de [moleculerjs/moleculer-template-project](https://github.com/moleculerjs/moleculer-template-project), pede algumas informações e gera um novo módulo para a pasta `./my-project`.

### Respostas a partir de um arquivo
Você pode colocar as respostas em um arquivo JSON e carrega-lo com o argumento `--answers`. Isto pode ser útil para gerar o projeto programaticamente.

```bash
$ moleculer init project my-project --answers ./answers.json
```

### Desativar a instalação de dependências
Você pode desativar a instalação automática de dependências NPM com o argumento `--no-install`. Isto pode ser útil para gerar o projeto programaticamente.

```bash
$ moleculer init project my-project --answers ./answers.json --no-install
```

### [Templates oficiais](https://github.com/topics/moleculer-template)

* [**project**](https://github.com/moleculerjs/moleculer-template-project) - Gera um projeto base Moleculer. *Use-o se você quiser iniciar um novo projeto que seja baseado no framework Moleculer*
    * serviço de exemplo (`greeter`)
    * [API Gateway](https://github.com/moleculerjs/moleculer-web) (opcional)
    * Arquivos Docker & Docker Compose
    * Testes & cobertura com [Jest](http://facebook.github.io/jest/)
    * Lint com [ESLint](http://eslint.org/)


* [**nano**](https://github.com/moleculerjs/moleculer-template-nano) - Modelo mínimo de projeto para um microsserviço. *Use-o se desejar criar um microsserviço que se conecte aos outros através do módulo de transporte*
    * serviço de exemplo (`greeter`)
    * Arquivos Docker & Docker Compose
    * Testes & cobertura com [Jest](http://facebook.github.io/jest/)
    * Lint com [ESLint](http://eslint.org/)
    * Arquivo Docker mínimo


* [**module**](https://github.com/moleculerjs/moleculer-template-module) - Gerar um novo projeto de módulo de Moleculer (e.g.: `moleculer-xyz`). *Use-o se você deseja criar um módulo para o framework Moleculer*
    * esqueleto vazio de serviço
    * esqueleto de exemplos
    * esqueleto de Read Me
    * Testes & cobertura com [Jest](http://facebook.github.io/jest/)
    * Lint com [ESLint](http://eslint.org/)

### Templates personalizados

``` bash
$ moleculer init username/repo my-project
```
Onde username/repo é o repositório do GitHub abreviado para seu diretório.

A notação curta de repositório é passada para [download-git-repo](https://github.com/flipxfx/download-git-repo) de modo que seja `bitbucket:username/repo` para um repositório do Bitbucket e `username/repo#branch` para tags ou branches.

### Templates locais

Em vez de um repositório GitHub, use um template do sistema de arquivos local:
``` bash
$ moleculer init ./path/to-custom-template my-project
```

### Template aliases

Para simplificar o uso de templates personalizados (local e remoto), é possível registrar um alias e usá-lo depois em vez de todo o Url do repositório.
```bash
$ moleculer alias-template myAlias somegithubuser/reponame
$ moleculer alias-template otherAlias ./path/to/some-local/custom/template


$ moleculer init myAlias my-project
```
Todos os alias de template registrados são armazenados no arquivo `~/.moleculer-templates.json` e também podem ser editados manualmente.

### Criando Templates Personalizados

Templates do Moleculer consistem em um arquivo `meta.js` e um diretório `template`.

##### `meta.js`

O arquivo `meta.js` exporta uma função que retorna um objeto que define a interface init do Moleculer CLI. A função recebe um parâmetro `values` que dá acesso aos valores externos passados pelo CLI. O objeto possui várias chaves que são explicadas abaixo.

A propriedade `questions` é uma matriz de objetos que definem as questões feitas no processo de iniciação. Esses objetos são objetos [Inquirer.js](https://github.com/SBoudrias/Inquirer.js#objects). Data collected here is stored in the Metalsmith `metadata` object.

The `metalsmith` property allows custom code to be executed at different points in the transformation process. The `before` function executes before the transformation is run, the `after` function executes after the transformation is run, and the `complete` function executes after the transformation is run and the files are copied to the destination directory.

The `metalsmith` functions take an argument `metalsmith` which gives a reference to the [Metalsmith](https://github.com/segmentio/metalsmith#metalsmith) object. A common use is to get the Metalsmith metadata by calling `metalsmith.metadata()` and then adding or mutating properties on the metadata object so it will be available for the rest of the transformation.

The `filters` object takes a set of keys matching a path and a value matching the name of a question variable. If the question variable's value is `false`, the specified path will be ignored during the transformation and those files will not be added to the project being intialized.

The `completeMessage` property takes a multiline string that will be displayed after the initialization is completed.

##### `template`

The `template` directory contains files which will be transformed using [Handlebars](https://handlebarsjs.com/) and then copied to the destination directory. Handlebars is given the `metadata` object from Metalsmith to be the source for string replacement.

Handlebars can also transform file names.

## Start
This command starts a new `ServiceBroker` locally and switches to REPL mode.
```bash
$ moleculer start
```

**Opções**
```
  --version     Show version number                                    [boolean]
  --help        Show help                                              [boolean]
  --config, -c  Load configuration from a file            [string] [default: ""]
  --ns          Namespace                                 [string] [default: ""]
  --level       Logging level                         [string] [default: "info"]
  --id          NodeID                                  [string] [default: null]
  --hot, -h     Enable hot-reload                     [boolean] [default: false]
  --commands    Custom REPL command file mask (e.g.: ./commands/*.js)
                                                        [string] [default: null]
```

## Connect
This command starts a new `ServiceBroker`, connects to a transporter server and switches to REPL mode.
```bash
# Connect with TCP transporter
$ moleculer connect

# Connect to NATS
$ moleculer connect nats://localhost:4222

# Connect to Redis
$ moleculer connect redis://localhost

# Connect to MQTT
$ moleculer connect mqtt://localhost

# Connect to AMQP
$ moleculer connect amqp://localhost:5672

# Load all options from config file
$ moleculer connect --config ./moleculer.config.js
```

**Opções**
```
  --version     Show version number                                    [boolean]
  --help        Show help                                              [boolean]
  --config, -c  Load configuration from a file            [string] [default: ""]
  --ns          Namespace                                 [string] [default: ""]
  --level       Logging level                         [string] [default: "info"]
  --id          NodeID                                  [string] [default: null]
  --hot, -h     Enable hot-reload                     [boolean] [default: false]
  --serializer  Serializer                              [string] [default: null]
  --commands    Custom REPL command file mask (e.g.: ./commands/*.js)
                                                        [string] [default: null]
```

## Call
The `call` command can be used establish a connection with a Moleculer project and call an action with parameters. The result (stringified JSON) will be printed to the console. This means that you can process the result with another tool. The calling parameters should start with `@` prefix and the meta parameters should start with `#` prefix.

**Opções**
```
  --version          Show version number                               [boolean]
  --help             Show help                                         [boolean]
  --config, -c       Load configuration from a file       [string] [default: ""]
  --transporter, -t  Transporter connection string (NATS, nats://127.0.0.1:4222,
                     ...etc)                            [string] [default: null]
  --ns               Namespace                            [string] [default: ""]
  --level            Logging level                  [string] [default: "silent"]
  --id               NodeID                             [string] [default: null]
  --serializer       Serializer                         [string] [default: null]
```

**Example with params**
```bash
moleculer call math.add --transporter NATS --@a 5 --@b 3
```

**Example with params & meta**
```bash
moleculer call math.add --transporter NATS --@a 5 --@b 3 --#meta-key MyMetaValue
```

**Example with post processing the result with [jq](https://stedolan.github.io/jq/)**
```bash
moleculer call "\$node.health" | jq '.mem.free'
```
> The transporter can be defined via `TRANSPORTER` environment variable, as well.

**Example with transporter env var**
```bash
TRANSPORTER=nats://localhost:42222 moleculer call math.add --@a 5 --@b 3
```

## Emit
The `emit` command can be used establish a connection with a Moleculer project and emit an event with a payload. The calling parameters should start with `@` prefix and the meta parameters should start with `#` prefix.

**Opções**
```
  --version          Show version number                               [boolean]
  --help             Show help                                         [boolean]
  --config, -c       Load configuration from a file       [string] [default: ""]
  --transporter, -t  Transporter connection string (NATS, nats://127.0.0.1:4222,
                     ...etc)                            [string] [default: null]
  --ns               Namespace                            [string] [default: ""]
  --level            Logging level                  [string] [default: "silent"]
  --id               NodeID                             [string] [default: null]
  --serializer       Serializer                         [string] [default: null]
  --broadcast, -b    Send broadcast event             [boolean] [default: false]
  --group, -g        Event groups                       [string] [default: null]
```

**Example with params**
```bash
moleculer emit user.created --transporter NATS --@id 3 --@name John
```

**Example with params & meta**
```bash
moleculer emit math.add --transporter NATS --@id 3 --@name John --#meta-key MyMetaValue
```

**Example with broadcast & groups**
```bash
moleculer emit math.add --transporter NATS --broadcast --@id 3 --@name John --group accounts
```

**Example with multi groups**
```bash
moleculer emit math.add --transporter NATS --broadcast --@id 3 --@name John --group accounts --group mail
```
> The transporter can be defined via `TRANSPORTER` environment variable, as well.

**Example with transporter env var**
```bash
TRANSPORTER=nats://localhost:42222 moleculer call math.add --@a 5 --@b 3
```
