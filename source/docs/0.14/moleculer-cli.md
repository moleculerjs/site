title: Command Line Tool
---

## moleculer-cli [![npm](https://img.shields.io/npm/v/moleculer-cli.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-cli)
This is a [command-line tool](https://github.com/moleculerjs/moleculer-cli) for Moleculer to help developing & testing.

## Install

``` bash
$ npm i -g moleculer-cli
```

## Commands

## Init
The `init` command is used to scaffold a new Moleculer project.

``` bash
$ moleculer init project my-project
```
The above command downloads the template from [moleculerjs/moleculer-template-project](https://github.com/moleculerjs/moleculer-template-project), prompts some information and generates a new module to the `./my-project` folder.

#### [Official templates](https://github.com/topics/moleculer-template)

* [**project**](https://github.com/moleculerjs/moleculer-template-project) - Generate a common Moleculer-based project. *Use it if you want to start a new project which is based on Moleculer framework*
	* sample service (`greeter`)
	* official [API Gateway](https://github.com/moleculerjs/moleculer-web) (optional)
	* Docker & Docker Compose files
	* tests & coverage with [Jest](http://facebook.github.io/jest/)
	* lint with [ESLint](http://eslint.org/)


* [**nano**](https://github.com/moleculerjs/moleculer-template-nano) - Minimal project template for one microservice. *Use it if you want to create a microservice which connect to others via transporter*
	* sample service (`greeter`)
	* Docker & Docker Compose files
	* tests & coverage with [Jest](http://facebook.github.io/jest/)
	* lint with [ESLint](http://eslint.org/)
	* Minimal Docker file


* [**module**](https://github.com/moleculerjs/moleculer-template-module) - Generate a new Moleculer module project (e.g.: `moleculer-xyz`). *Use it if you want to create a module for Moleculer framework*
	* empty service skeleton
	* examples skeleton
	* readme skeleton
	* tests & coverage with [Jest](http://facebook.github.io/jest/)
	* lint with [ESLint](http://eslint.org/)

### Custom templates

``` bash
$ moleculer init username/repo my-project
```
Where username/repo is the GitHub repo shorthand for your fork.

The shorthand repo notation is passed to [download-git-repo](https://github.com/flipxfx/download-git-repo) so it can be `bitbucket:username/repo` for a Bitbucket repo and `username/repo#branch` for tags or branches.

### Local Templates

Instead of a GitHub repo, use a template from local filesystem:
``` bash
$ moleculer init ./path/to-custom-template my-project
```

### Template aliases

To simplify usage of custom templates (local and remote), it is possible to register an alias and use that afterwards instead of the whole repository url.
```bash
$ moleculer alias-template myAlias somegithubuser/reponame
$ moleculer alias-template otherAlias ./path/to/some-local/custom/template


$ moleculer init myAlias my-project
```
All registered template aliases are stored in the file `~/.moleculer-templates.json` and can also be edited manually.

### Creating Custom Templates

Moleculer templates consist of a `meta.js` file and a `template` directory.

##### `meta.js`

The `meta.js` file exports a function that returns an object defining the Moleculer CLI init interface. The function takes a parameter `values` that gives access to external values passed in from the CLI. The object has several keys which are explained below.

The `questions` property is an array of objects defining the questions asked in the init process. These objects are [Inquirer.js objects](https://github.com/SBoudrias/Inquirer.js#objects). Data collected here is stored in the Metalsmith `metadata` object.

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

**Options**
```
  --config, -c   Load configuration from a file           [string] [default: ""]
  --ns           Namespace                                [string] [default: ""]
  --id           NodeID                                 [string] [default: null]
  --metrics, -m  Enable metrics                       [boolean] [default: false]
  --hot, -h      Enable hot-reload                    [boolean] [default: false]
  --cb           Enable circuit breaker               [boolean] [default: false]
  --commands     Custom REPL command file mask          [string] [default: null]
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

**Options**
```
  --config, -c   Load configuration from a file           [string] [default: ""]
  --ns           Namespace                                [string] [default: ""]
  --id           NodeID                                 [string] [default: null]
  --metrics, -m  Enable metrics                       [boolean] [default: false]
  --hot, -h      Enable hot-reload                    [boolean] [default: false]
  --cb           Enable circuit breaker               [boolean] [default: false]
  --serializer   Serializer                             [string] [default: null]
  --commands     Custom REPL command file mask          [string] [default: null]
```

## Call
The `call` command can be used establish a connection with a Moleculer project and call an action with parameters. The result (stringified JSON) will be printed to the console. This means that you can process the result with another tool. The calling parameters should start with `@` prefix and the meta parameters should start with `#` prefix.

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

>The transporter can be defined via `TRANSPORTER` environment variable, as well.

**Example with transporter env var**
```bash
TRANSPORTER=nats://localhost:42222 moleculer call math.add --@a 5 --@b 3
```

## Emit
The `emit` command can be used establish a connection with a Moleculer project and emit an event with a payload. The calling parameters should start with `@` prefix and the meta parameters should start with `#` prefix.

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

>The transporter can be defined via `TRANSPORTER` environment variable, as well.

**Example with transporter env var**
```bash
TRANSPORTER=nats://localhost:42222 moleculer call math.add --@a 5 --@b 3
```