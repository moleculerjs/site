title: Moleculer Runner
---

Moleculer Runner is a helper script that helps you running Moleculer projects. With it you don't need to create a ServiceBroker instance with options. Instead you can create a `moleculer.config.js` file in the root of repo with broker options. Then simply call the `moleculer-runner` in NPM script and it will automatically load the configuration file, create the broker and load the services. Alternatively, you can declare your configuration as environment variables.


{% note info Production-ready %}
Use the `moleculer.config.js` during development or store common options. In production, you can overwrite the values with the environment variables!
{% endnote %}

## Syntax
```
$ moleculer-runner [options] [service files or directories or glob masks]
```
> Note: It runs in this format in NPM scripts only. To call it directly from your console, use the `./node_modules/.bin/moleculer-runner --repl` or `node ./node_modules/moleculer/bin/moleculer-runner.js --repl` format.

## Options

| Option                         | Type      | Default | Описание                                                                          |
| ------------------------------ | --------- | ------- | --------------------------------------------------------------------------------- |
| `-r`, `--repl`                 | `Boolean` | `false` | If true, it switches to [REPL](moleculer-repl.html) mode after broker started.    |
| `-s`, `--silent`               | `Boolean` | `false` | Disable the broker logger. It prints nothing to the console.                      |
| `-H`, `--hot`                  | `Boolean` | `false` | Hot reload services when they change.                                             |
| `-c`, `--config <file>`  | `String`  | `null`  | Load configuration file from a different path or a different filename.            |
| `-e`, `--env`                  | `Boolean` | `false` | Load envorinment variables from the '.env' file from the current folder.          |
| `-E`, `--envfile <file>` | `String`  | `null`  | Load envorinment variables from the specified file.                               |
| `-i`, `--instances`            | `Number`  | `null`  | Launch [number] node instances or `max` for all cpu cores (with `cluster` module) |


**Example NPM scripts**
```js
{
    "scripts": {
        "dev": "moleculer-runner --repl --hot --config moleculer.dev.config.js services",
        "start": "moleculer-runner --instances=max services"
    }
}
```
The `dev` script loads development configurations from the `moleculer.dev.config.js` file, start all services from the `services` folder, enable hot-reloading and switches to REPL mode. Run it with the `npm run dev` command.

The `start` script is to load the default `moleculer.config.js` file if it exists, otherwise only loads options from environment variables. Starts 4 instances of broker, then they start all services from the `services` folder. Run it with `npm start` command.

## Configuration loading logic
The runner does the following steps to load & merge configurations:

1. It loads config file defined in CLI options. If it does not exist, it throws an error.
2. If not defined, it loads the `moleculer.config.js` file from the current directory. If it does not exist, it loads the `moleculer.config.json` file.
3. Once a config file has been loaded, it merges options with the default options of the ServiceBroker.
4. The runner observes the options step by step and tries to overwrite them from environment variables. Once `logLevel: "warn"` is set in the config file, but the `LOGLEVEL=debug` environment variable is defined, the runner overwrites it, and it results: `logLevel: "debug"`.

> To overwrite broker's deeply nested default options, which are not present in `moleculer.config.js`, via environment variables, use the `MOL_` prefix and double underscore `__` for nested properties in `.env` file. For example, to set the [cacher prefix](caching.html#Built-in-cachers) to `MOL` you should declare as `MOL_CACHER__OPTIONS__PREFIX=MOL`.

### Configuration file
The structure of the configuration file is the same as that of the [broker options](configuration.html#Broker-options). Every property has the same name.

**Example config file**
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

### Environment variables
The runner transforms the property names to uppercase. If nested, the runner concatenates names with `_`.

**Example environment variables**
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
4. Check the CLI arguments. If filename found, it loads them. If directory found, it loads them. It glob pattern found, it applies and load the found files.
> Please note: shorthand names can also be used in `SERVICES` env var.

**Example**
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

**Example**
```sh
# Load the default .env file from current directory
$ moleculer-runner --env

# Load the specified .my-env file
$ moleculer-runner --envfile .my-env
```

{% note info Dependencies %}
To use this feature install the `dotenv` module with `npm install dotenv --save` command.
{% endnote %}
