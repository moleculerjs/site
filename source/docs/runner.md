title: Project runner
---
_Added in: v0.8.0_

There is a project runner helper script in the Moleculer project. You can use it if you want to create small repos for services. In this case you needn't to create a ServiceBroker with options. Just create a `moleculer.config.js` or `moleculer.config.json` file in the root of repo fill it with your options and call the `moleculer-runner` within the NPM scripts.
As an other solution you can put it to the environment variables instead of putting options to file.

{% note info Production-ready %}
In production we recommend to put options to the environment variables! Use the `moleculer.config.js` only in development.
{% endnote %}

## Syntax
```
$ moleculer-runner [options] [service files or directories]
```
> Please note! It's working in this format in NPM scripts. If you want to call it directly from your console, use the `./node_modules/.bin/moleculer-runner --repl` format.

## Options

| Option | Type | Default | Description |
| ------ | ----- | ------- | ---------- |
| `-r`, `--repl` | `Boolean` | `false` | If true, it will switch to [REPL](moleculer-repl.html) mode after broker started. |
| `-s`, `--silent` | `Boolean` | `false` | Disable the logger of broker. It won't print anything to the console. |
| `-c`, `--config <file>` | `String` | `null` | Use it if you store your configuration file in different path or with different filename. |


**Example NPM scripts**
```js
{
    "scripts": {
        "dev": "moleculer-runner --repl --config moleculer.dev.config.js services",
        "start": "moleculer-runner services"
    }
}
```
As you can see above we defined two scripts. The `dev` script load the development configurations from the `moleculer.dev.config.js` file, start all your services from the `services` folder and switch to REPL mode. You can call it with `npm run dev` command.
The `start` script is try to load the default `moleculer.config.js` file if it exists, or load options from environment variables. After that, start all your services from the `services` folder. You can call it with `npm start` command.

## Configuration loading logic
The runner does the following steps to load & merge configurations:

1. If you defined config file in CLI options, try to load it. If it's not exist, throw an error.
2. If you not defined, try to load the `moleculer.config.js` file from the current directory. If it's not exist try to load the `moleculer.config.json` file.
3. If it found any config file, load it and merge options with the default options of the [ServiceBroker](broker.html).
4. The runner walks through the options and try to override them from environment variables. So if you set `logLevel: "warn"` in the config file, but define the `LOGLEVEL=debug` environment variable, the runner will override it and the result will be `logLevel: "debug"`.

### Configuration file
The structure of the configuration file is same as the broker options. Every property has the same name. Use shorthand formats in `transporter`, `cacher` and `serializer` options.

**Example config file**
```js
module.exports = {
    nodeID: "node-test",
    logger: true,
    logLevel: "debug",

    transporter: "nats://localhost:4222",
    requestTimeout: 5 * 1000,

    circuitBreaker: {
        enabled: true
    },

    metrics: true,
    statistics: true
};
```

### Environment variables
The runner transforms the property names to uppercase. If it is a nested property, it joins names with `_`

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
STATISTICS=true
```

## Services loading logic
If you define service files or folders in CLI arguments, the runner will try to load them. If you define folder(s), the runner will load all services `*.service.js` from this folder(s). You can define services & service folder with `SERVICES` and `SERVICEDIR` environment variables.

 1. If it find `SERVICEDIR` env, but isn't find `SERVICES` env, it'll load all services from the `SERVICEDIR` directory.
 2. If it find `SERVICEDIR` & `SERVICES` env, it'll load the specified services from the `SERVICEDIR` directory.
 3. If it's not find `SERVICEDIR` env but find `SERVICES` env, load the specified services from the current directory.


 **Example**
 ```
 SERVICEDIR=services
 SERVICES=math,post,user
 ```
 It will load the `math.service.js`, `post.service.js` and `user.service.js` files from the `services` folder.

  ```
 SERVICEDIR=my-services
 ```
 It will load all `*.service.js` files from the `my-services` folder.