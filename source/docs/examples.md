title: Examples
---
The main repo of Moleculer contains [some examples](https://github.com/ice-services/moleculer/blob/master/examples/).

## Simple
This is a simple demo with a Math service which is able to `add`, `sub`, `mult` and `divide` two numbers.

```bash
$ npm run demo simple
```

[Source code is available on Github](https://github.com/ice-services/moleculer/blob/master/examples/simple/index.js)

## Caching
This example demonstrates how the cacher module works.

```bash
$ npm run demo caching
```

[Source code is available on Github](https://github.com/ice-services/moleculer/blob/master/examples/caching/index.js)

## Middlewares
This example demonstrates how the middleware system works.

```bash
$ npm run demo middlewares
```

[Source code is available on Github](https://github.com/ice-services/moleculer/blob/master/examples/middlewares/index.js)

## Transporters
This example starts two brokers and communicates together via NATS server.

```bash
$ npm run demo transporters
```

[Source code is available on Github](https://github.com/ice-services/moleculer/blob/master/examples/transporter)

## Multiple servers & clients
In this example you can start any servers & clients. The servers serve the `math.add` action and clients call it in a loop.

**Start a server**
```bash
$ node examples/multi-server/server
```

**Start a client**
```bash
$ node examples/multi-server/client
```

[Source code is available on Github](https://github.com/ice-services/moleculer/tree/master/examples/multi-server)

## Load tester
With this example you can start a load test. The server & client will be print how many requests executed in a second.

**Start server**
```bash
$ node examples/loadtest/server
```

**Start & fork clients (count of CPU cores)**
```bash
$ node examples/loadtest/clients
```

[Source code is available on Github](https://github.com/ice-services/moleculer/blob/master/examples/loadtest)
