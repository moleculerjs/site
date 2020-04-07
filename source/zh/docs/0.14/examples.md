title: Examples
---

## 项目示例

### Realworld 后端服务器
这是一个使用 Moleculer 编写的 [RealWorld.io](https://realworld.io/) 示例后端服务器。

**Key features**
- 7 microservices
- NeDB or MongoDB database without Mongoose
- User login & signup
- User authentication with JWT
- Memory caching
- Docker files

**Repo: https://github.com/moleculerjs/moleculer-examples/tree/master/conduit#readme**

### Blog
This is a simple blog example.

**Key features**
- Docker files
- ExpressJS www server with Pug template engine
- MongoDB database with [moleculer-db](https://github.com/moleculerjs/moleculer-db) and [moleculer-db-adapter-mongoose](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongoose) modules
- NATS transporter
- Redis cacher
- [Traefik](https://traefik.io/) reverse proxy (in micro arch)
- static frontend

**Repo: https://github.com/moleculerjs/moleculer-examples/blob/master/blog#readme**

## Short examples
The main Moleculer repository contains [some examples](https://github.com/moleculerjs/moleculer/blob/master/examples/).
{% note info %}
To try them, at first, you should clone the Moleculer repo with the following command:

`git clone https://github.com/moleculerjs/moleculer.git`
{% endnote %}

### Simple
This is a simple demo with a Math service which can `add`, `sub`, `mult` and `divide` two numbers.

```bash
$ npm run demo simple
```

[Source code is available on Github](https://github.com/moleculerjs/moleculer/blob/master/examples/simple/index.js)

### Server & client nodes
In this example, you can start any servers & clients. The servers serve the `math.add` action and clients call it in a loop. You can start multiple instances from both. *They use TCP transporter, but you can change it with `TRANSPORTER` env variable.*

**Start a server**
```bash
$ node examples/client-server/server
```

**Start a client**
```bash
$ node examples/client-server/client
```

[Source code is available on Github](https://github.com/moleculerjs/moleculer/tree/master/examples/client-server)

### Middlewares
This example demonstrates how the middleware system works.

```bash
$ npm run demo middlewares
```

[Source code is available on Github](https://github.com/moleculerjs/moleculer/blob/master/examples/middlewares/index.js)

### Runner
This example shows how you can start a broker and load services with [Moleculer Runner](moleculer-runner.html).

```bash
$ node ./bin/moleculer-runner.js -c examples/runner/moleculer.config.js -r examples/user.service.js
```
It starts a broker with options from `moleculer.config.js`, loads the user service from `user.service.js` file and switch to REPL mode.

[Source code is available on Github](https://github.com/moleculerjs/moleculer/blob/master/examples/runner)

### Load tester
With this example, you can start a load test. The server & client prints how many requests executed in a second.

**Start server**
```bash
$ node examples/loadtest/server
```

**Start & fork clients (number of CPU cores)**
```bash
$ node examples/loadtest/clients
```

[Source code is available on Github](https://github.com/moleculerjs/moleculer/blob/master/examples/loadtest)

