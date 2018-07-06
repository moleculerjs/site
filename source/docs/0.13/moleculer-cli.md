title: Command Line Tool
---

## moleculer-cli [![npm](https://img.shields.io/npm/v/moleculer-cli.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-cli)
This is a [command-line tool](https://github.com/moleculerjs/moleculer-cli) for Moleculer to help developing & testing.

## Install

``` bash
$ npm i -g moleculer-cli
```

## Commands

### Init a new project
Scaffold a new Moleculer project.

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

#### Custom templates

``` bash
$ moleculer init username/repo my-project
```
Where username/repo is the GitHub repo shorthand for your fork.

The shorthand repo notation is passed to [download-git-repo](https://github.com/flipxfx/download-git-repo) so it can be `bitbucket:username/repo` for a Bitbucket repo and `username/repo#branch` for tags or branches.

#### Local Templates

Instead of a GitHub repo, use a template from local filesystem:
``` bash
$ moleculer init ./path/to-custom-template my-project
```

### Start a broker locally
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

### Start a broker and connect to a transporter
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
