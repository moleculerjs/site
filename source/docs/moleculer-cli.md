title: Command Line Tool
---

## moleculer-cli [![npm](https://img.shields.io/npm/v/moleculer-cli.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-cli)
This is a [command-line tool](https://github.com/ice-services/moleculer-cli) for Moleculer to help developing & testing.

## Install

``` bash
$ npm install -g moleculer-cli
```

## Commands

### Init a new project
With this command you can scaffold a new Moleculer project.

``` bash
$ moleculer init module my-module
```
The above command downloads the template from [ice-services/moleculer-template-module](https://github.com/ice-services/moleculer-template-module), prompts some information and generates a new module to the `./my-module` folder.

#### Official templates

* [**module**](https://github.com/ice-services/moleculer-template-module) - Generate a new Moleculer module project (e.g.: `moleculer-xyz`). *Use it if you want to create a module for Moleculer framework*
	* empty service skeleton
	* examples skeleton
	* readme skeleton
	* tests & coverage with [Jest](http://facebook.github.io/jest/)
	* lint with [ESLint](http://eslint.org/)


* [**project-simple**](https://github.com/ice-services/moleculer-template-project-simple) - Generate a simple Moleculer-based project. *Use it if you want to start a new project which is based on Moleculer framework*
	* sample service (`greeter`)
	* official [API Gateway](https://github.com/ice-services/moleculer-web) (optional)
	* tests & coverage with [Jest](http://facebook.github.io/jest/)
	* lint with [ESLint](http://eslint.org/)


* [**nano**](https://github.com/ice-services/moleculer-template-nano) - Minimal project template for one microservice. *Use it if you want to create a microservice which connect to others via transporter*
	* sample service (`greeter`)
	* tests & coverage with [Jest](http://facebook.github.io/jest/)
	* lint with [ESLint](http://eslint.org/)
	* Minimal Docker file

#### Custom templates

``` bash
$ moleculer init username/repo my-project
```
Where username/repo is the GitHub repo shorthand for your fork.

The shorthand repo notation is passed to [download-git-repo](https://github.com/flipxfx/download-git-repo) so you can also use things like bitbucket:username/repo for a Bitbucket repo and username/repo#branch for tags or branches.

#### Local Templates

Instead of a GitHub repo, use a template from local filesystem:
``` bash
$ moleculer init ./path/to-custom-template my-project
```

### Start a broker locally
This command start a new ServiceBroker locally and switch to REPL mode.
```bash
$ moleculer start
```

**Options**
```
  --ns           Namespace                                [string] [default: ""]
  --id           NodeID                                 [string] [default: null]
  --metrics, -m  Enable metrics                       [boolean] [default: false]
  --hot, -h      Enable hot-reload                    [boolean] [default: false]
  --cb           Enable circuit breaker               [boolean] [default: false]
```

### Start a broker and connect to a transporter
This command start a new ServiceBroker, connect to a transporter server and switch to REPL mode.
```bash
# Connect to local NATS (default)
$ moleculer connect nats://localhost:4222
# or without URI
$ moleculer connect

# Connect to Redis
$ moleculer connect redis://localhost

# Connect to MQTT
$ moleculer connect mqtt://localhost

# Connect to AMQP
$ moleculer connect amqp://localhost:5672
```

**Options**
```
  --ns           Namespace                                [string] [default: ""]
  --id           NodeID                                 [string] [default: null]
  --metrics, -m  Enable metrics                       [boolean] [default: false]
  --hot, -h      Enable hot-reload                    [boolean] [default: false]
  --cb           Enable circuit breaker               [boolean] [default: false]
  --serializer   Serializer                             [string] [default: null]
```
