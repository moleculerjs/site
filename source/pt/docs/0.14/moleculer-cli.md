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

A notação curta de repositório é passada para [download-git-repo](https://gitlab.com/flippidippi/download-git-repo) de modo que pode ser `bitbucket:username/repo` para um repositório do Bitbucket e `username/repo#branch` para tags ou branches.

### Templates locais

Em vez de um repositório GitHub, use um template do sistema de arquivos local:
``` bash
$ moleculer init ./path/to-custom-template my-project
```

### Alias de Template

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

A propriedade `questions` é uma matriz de objetos que definem as questões feitas no processo de iniciação. Esses objetos são objetos [Inquirer.js](https://github.com/SBoudrias/Inquirer.js#objects). Dados coletados aqui são armazenados no objeto `metadata` do Metalsmith.

A propriedade `metalsmith` permite que código personalizado seja executado em diferentes pontos do processo de transformação. A função `before` será executada antes da execução da transformação, a função `after` é executada depois que a transformação é executada, e a função `complete` é executada depois que a transformação é executada e os arquivos são copiados para o diretório de destino.

As funções `metalsmith` levam um argumento `metalsmith` que faz referência ao objeto [Metalsmith](https://github.com/segmentio/metalsmith#metalsmith). Um uso comum é obter os metadados do Metalsmith chamando `metalsmith.metadata()` e, em seguida, adicionar ou modificar propriedades no objeto de metadados, então ele estará disponível para o resto da transformação.

O objeto `filters` recebe um conjunto de chaves correspondentes a um caminho e um valor que corresponde ao nome de uma variável de pergunta. Se o valor da variável da questão é `false`, o caminho especificado será ignorado durante a transformação e esses arquivos não serão adicionados ao projeto que está sendo inicializado.

A propriedade `completeMessage` recebe uma string multi linha que será exibida após a inicialização ser concluída.

##### `template`

O diretório `template` contém arquivos que serão transformados usando [Handlebars](https://handlebarsjs.com/) e copiados para o diretório de destino. Handlebars recebem o objeto `metadata` do Metalsmith para ser a fonte para substituição de string.

Handlebars também podem transformar nomes de arquivos.

## Start
Este comando inicia um novo `ServiceBroker` localmente e alterna para o modo REPL.
```bash
$ moleculer start
```

**Opções**
```
  --version     Exibe o número da versão                                    [boolean]
  --help        Exibe a ajuda                                              [boolean]
  --config, -c  Carrega configurações de um arquivo            [string] [default: ""]
  --ns          Namespace                                 [string] [default: ""]
  --level       Nível de log                         [string] [default: "info"]
  --id          NodeID                                  [string] [default: null]
  --hot, -h     Habilitar hot-reload                     [boolean] [default: false]
  --commands    Máscara de arquivos com comandos REPL customizados (ex.: ./commands/*.js)
                                                        [string] [default: null]
```

## Connect
Este comando inicia um novo `ServiceBroker`, conecta-se a um servidor de transporte e muda para o modo REPL.
```bash
# Conectar com TCP transporter
$ moleculer connect

# Conectar com NATS
$ moleculer connect nats://localhost:4222

# Conectar com Redis
$ moleculer connect redis://localhost

# Conectar com MQTT
$ moleculer connect mqtt://localhost

# Conectar com AMQP
$ moleculer connect amqp://localhost:5672

# Carregar todas as opções do arquivo de configuração
$ moleculer connect --config ./moleculer.config.js
```

**Opções**
```
  --version     Exibe o número da versão                                    [boolean]
  --help        Exibe a ajuda                                              [boolean]
  --config, -c  Carrega configurações de um arquivo            [string] [default: ""]
  --ns          Namespace                                 [string] [default: ""]
  --level       Nível de log                         [string] [default: "info"]
  --id          NodeID                                  [string] [default: null]
  --hot, -h     Habilitar hot-reload                     [boolean] [default: false]
  --serializer  Serializador                              [string] [default: null]
  --commands    Máscara de arquivos com comandos REPL customizados (ex.: ./commands/*.js)
                                                        [string] [default: null]
```

## Call
O comando `call` pode ser utilizado para estabelecer uma conexão com um projeto Moleculer e chamar uma ação com parâmetros. O resultado (JSON string) será impresso no console. Isto significa que você pode processar o resultado com outra ferramenta. Os parâmetros de chamada devem iniciar com prefixo `@` e os parâmetros meta devem iniciar com prefixo `#`.

**Opções**
```
  --version     Exibe o número da versão                                    [boolean]
  --help        Exibe a ajuda                                              [boolean]
  --config, -c  Carrega configurações de um arquivo            [string] [default: ""]
  --transporter, -t  String de conexão do módulo de transporte (NATS, nats://127.0.0.1:4222,
                     ...etc)                            [string] [default: null]
  --ns               Namespace                            [string] [default: ""]
  --level            Nível de log                  [string] [default: "silent"]
  --id               NodeID                             [string] [default: null]
  --serializer       Serializador                         [string] [default: null]
```

**Exemplo com parâmetros**
```bash
moleculer call math.add --transporter NATS --@a 5 --@b 3
```

**Exemplo com parâmetros & meta**
```bash
moleculer call math.add --transporter NATS --@a 5 --@b 3 --#meta-key MyMetaValue
```

**Exemplo com pós-processamento do resultado com [jq](https://stedolan.github.io/jq/)**
```bash
moleculer call "\$node.health" | jq '.mem.free'
```
> O módulo de transporte pode ser definido através de uma variável de ambiente `TRANSPORTER` também.

**Exemplo com o módulo de transporte em variável de ambiente**
```bash
TRANSPORTER=nats://localhost:42222 moleculer call math.add --@a 5 --@b 3
```

## Emit
O comando `emit` pode ser utilizado para estabelecer uma conexão com um projeto Moleculer e emitir um evento com um payload. Os parâmetros de chamada devem iniciar com prefixo `@` e os parâmetros meta devem iniciar com prefixo `#`.

**Opções**
```
  --version     Exibe o número da versão                                    [boolean]
  --help        Exibe a ajuda                                              [boolean]
  --config, -c  Carrega configurações de um arquivo            [string] [default: ""]
  --transporter, -t  String de conexão do módulo de transporte (NATS, nats://127.0.0.1:4222,
                     ...etc)                            [string] [default: null]
  --ns               Namespace                            [string] [default: ""]
  --level            Nível de log                  [string] [default: "silent"]
  --id               NodeID                             [string] [default: null]
  --serializer       Serializador                         [string] [default: null]
  --broadcast, -b    Envia evento broadcast             [boolean] [default: false]
  --group, -g        Grupo de eventos                       [string] [default: null]
```

**Exemplo com parâmetros**
```bash
moleculer emit user.created --transporter NATS --@id 3 --@name John
```

**Exemplo com parâmetros & meta**
```bash
moleculer emit math.add --transporter NATS --@id 3 --@name John --#meta-key MyMetaValue
```

**Exemplo com broadcast & grupos**
```bash
moleculer emit math.add --transporter NATS --broadcast --@id 3 --@name John --group accounts
```

**Exemplo com vários grupos**
```bash
moleculer emit math.add --transporter NATS --broadcast --@id 3 --@name John --group accounts --group mail
```
> O módulo de transporte pode ser definido através de uma variável de ambiente `TRANSPORTER` também.

**Exemplo com o módulo de transporte em variável de ambiente**
```bash
TRANSPORTER=nats://localhost:42222 moleculer call math.add --@a 5 --@b 3
```
