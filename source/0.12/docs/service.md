title: Service
---
The Service represents a microservice in the Moleculer. You can define actions and subscribe to events. To create a service you need to define a schema. The service schema is similar to [a component of VueJS](https://vuejs.org/v2/guide/components.html#What-are-Components).

## Schema
The schema has some main parts: `name`, `version`, `settings`, `actions`, `methods`, `events`.

### Simple service schema to define two actions
```js
{
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },

        sub(ctx) {
            return Number(ctx.params.a) - Number(ctx.params.b);
        }
    }
}
```

## Base properties
The Service has some base properties in the schema.
```js
{
    name: "posts",
    version: 1
}
```
The `name` is a mandatory property so it must be defined. It's the first part of action name when you call it with `broker.call`.

> To disable service name prefixing set `$noServiceNamePrefix: true` in Service settings.

The `version` is an optional property. Use it to run multiple version from the same service. It is a prefix in the actionName. It can be a `Number` or a `String`.
```js
{
    name: "posts",
    version: 2,
    actions: {
        find() {...}
    }
}
```
You can call this `find` action on version `2` service:
```js
broker.call("v2.posts.find");
```
{% note info REST call %}
If you are using our [Moleculer Web](moleculer-web.html) module, you can request it as `GET /v2/posts/find`.
{% endnote %}

> To disable version prefixing set `$noVersionPrefix: true` in Service settings.

## Settings
The `settings` property is a store, where you can store every settings/options to your service. You can reach it via `this.settings` inside the service.

```js
{
    name: "mailer",
    settings: {
        transport: "mailgun"
    },

    action: {
        send(ctx) {
            if (this.settings.transport == "mailgun") {
                ...
            }
        }
    }
}
```
> The `settings` is also obtainable on remote nodes. It is transferred during service discovering.

## Internal settings
There are some internal settings which are used by core modules. These setting names start with `$` _(dollar sign)_.

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `$noVersionPrefix` | `Boolean` | `false` | Disable version prefixing in action names. |
| `$noServiceNamePrefix` | `Boolean` | `false` | Disable service name prefixing in action names. |
| `$dependencyTimeout` | `Number` | `0` | Timeout for dependency waiting. |

## Mixins
Mixins are a flexible way to distribute reusable functionalities for Moleculer services. The Service constructor merges these mixins with the current schema. It is to extend an other service in your service. When a service uses mixins, all properties in the mixin will be "mixed" into the current service.

**Example how to extend `moleculer-web` service**

```js
const ApiGwService = require("moleculer-web");

module.exports = {
    name: "api",
    mixins: [ApiGwService]
    settings: {
        // Change port setting
        port: 8080
    },
    actions: {
        myAction() {
            // Add a new action to apiGwService service
        }
    }
}
```
The above example creates an `api` service which inherits all from `ApiGwService` but overwrite the port setting and extend it with a new `myAction` action.

### Merge algorithm
The merge algorithm depends on the property type.

| Property | Algorithm |
|----------|-----------|
| `name`, `version` | Merge & overwrite. |
| `settings` | Extend with [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep). |
| `actions` | Extend with [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep). _You can disable an action from mixin if you set to `false` in your service._ |
| `methods` | Merge & overwrite. |
| `events` | Concatenate listeners. |
| `created`, `started`, `stopped` | Concatenate listeners. |
| `mixins` | Concatenate listeners. |
| any other | Merge & overwrite. |

{% note info Merge algorithm examples %}
__Merge & overwrite__: if serviceA has `a: 5`, `b: 8` and serviceB has `c: 10`, `b: 15`, the mixed service will have `a: 5`, `b: 15` and `c: 10`.
__Concatenate__: if serviceA & serviceB subscribe to `users.created` event, both event handler will be called when the `users.created` event emitted.
{% endnote %}

## Actions
The actions are the callable/public methods of the service. They are callable with `broker.call`.
The action could be a function (shorthand for handler) or an object with some properties above all with the `handler`.
The actions should be placed under the `actions` key in the schema.

```js
module.exports = {
    name: "math",
    actions: {
        // Shorthand definition, only the handler function
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },

        // Normal definition with other properties. In this case
        // the `handler` function is required!
        mult: {
            cache: false,
            params: {
                a: "number",
                b: "number"
            },
            handler(ctx) {
                // The action properties are accessible as `ctx.action.*`
                if (!ctx.action.cache)
                    return Number(ctx.params.a) * Number(ctx.params.b);
            }
        }
    }
};
```
You can call the above actions as
```js
const res = await broker.call("math.add", { a: 5, b: 7 });
const res = await broker.call("math.mult", { a: 10, b: 31 });
```

Inside the action you can call other nested actions in other services with `ctx.call` method. It is an alias to `broker.call`, just set itself as parent context (due tracing).
```js
module.exports = {
    name: "posts",
    actions: {
        async get(ctx) {
            // Find a post by ID
            let post = posts[ctx.params.id];

            // Populate the post.author field through "users" service
            // Call the "users.get" action with author ID
            const user = await ctx.call("users.get", { id: post.author });
            if (user) {
                // Replace the author ID with the received user object
                post.author = user;
            }

            return post;
        }
    }
};
```
> In handlers the `this` is always pointed to the Service instance.


## Events
You can subscribe to events under the `events` key.

```js
module.exports = {
    name: "report",

    events: {
        // Subscribe to "user.created" event
        "user.created"(payload) {
            this.logger.info("User created:", payload);
            // Do something
        },

        // Subscribe to all "user.*" event
        "user.*"(payload, sender, eventName) {
            // Do something with payload. The `eventName` contains
            // the original event name. E.g. `user.modified`.
            // The `sender` is the nodeID of sender.
        }

        // Subscribe to a local event
        "$node.connected"({ node }) {
            this.logger.info(`Node '${node.id}' is connected!`);
        }
    }
};
```
> In handlers the `this` is always pointed to the Service instance.

### Grouping 
The broker groups the event listeners by group name. By default, The group name is the service name. But you can change it in the event definition.

```js
module.exports = {
    name: "payment",
    events: {
        "order.created": {
            // Register handler to the "other" group instead of "payment" group.
            group: "other",
            handler(payload) {
                // ...
            }
        }
    }
}
```

## Methods
You can also create private methods in the Service. They are under the `methods` key. These functions are private, can't be called with `broker.call`. But you can call it inside service (from action handlers, event handlers and lifecycle event handlers).

**Usage**
```js
module.exports = {
    name: "mailer",
    actions: {
        send(ctx) {
            // Call the `sendMail` method
            return this.sendMail(ctx.params.recipients, ctx.params.subject, ctx.params.body);
        }
    },

    methods: {
        // Send an email to recipients
        sendMail(recipients, subject, body) {
            return new Promise((resolve, reject) => {
                ...
            });
        }
    }
};
```
> The name of the method can't be `name`, `version`, `settings`, `schema`, `broker`, `actions`, `logger`, because these words are reserved in the schema.

> In methods the `this` is always pointed to the Service instance.

## Lifecycle events
There are some lifecycle service events, that will be triggered by broker.

```js
module.exports = {
    name: "www",
    actions: {...},
    events: {...},
    methods: {...},

    created() {
        // Fired when the service instance created. (broker.loadService or broker.createService)
    },

    async started() {
        // Fired when `broker.start()` called.
    }

    async stopped() {
        // Fired when `broker.stop()` called.
    }
};
```
## Dependencies
If your service depends on other services, use the `dependencies` property in the schema. The service can wait for other services before starting. _It uses the broker `waitForServices` method._

```js
module.exports = {
  name: "posts",
  settings: {
      $dependencyTimeout: 30000 // Default: 0 - no timeout
  },
  dependencies: [
      "likes", // shorthand w/o version
      { name: "users", version: 2 }, // with numeric version
      { name: "comments", version: "staging" } // with string version
  ],
  async started() {
      this.logger.info("It will be called after all dependent services are available.");
      const users = await this.broker.call("users.list");
  }
  ....
}
```
The `started` service handler is called once the `likes`, `users` and `comments` services are available (either the local or remote nodes).

## Metadata

The `Service` schema has a `metadata` property. You can store here any meta information about service. You can access it as `this.metadata` inside service functions.
_Moleculer modules don't use it. You can store it whatever you want._

```js
module.exports = {
    name: "posts",
    settings: {},
    metadata: {
        scalable: true,
        priority: 5
    },

    actions: { ... }
};
```

> The `metadata` is transferred among other nodes, you can access it via `$node.services` on other nodes.

## Properties of `this`
In service functions, `this` is always pointed to the Service instance. It has some properties & methods which you can use in your service functions.

| Name | Type |  Description |
| ------- | ----- | ------- |
| `this.name` | `String` | Name of service (from schema) |
| `this.version` | `Number` or `String` | Version of service (from schema) |
| `this.settings` | `Object` | Settings of service (from schema) |
| `this.metadata` | `Object` | Metadata of service (from schema) |
| `this.schema` | `Object` | Schema definition of service |
| `this.broker` | `ServiceBroker` | Instance of broker |
| `this.Promise` | `Promise` | Class of Promise (Bluebird) |
| `this.logger` | `Logger` | Logger instance |
| `this.actions` | `Object` | Actions of service. *Service can call own actions directly but it is not recommended. Use the `ctx.call` instead!* |
| `this.waitForServices` | `Function` | Link to ['broker.waitForServices' method](broker.html#Wait-for-services) |

## Create a service
There are several ways to create and load a service.

### broker.createService()
Call the `broker.createService` method with the schema of service as the first argument. It's simple & fast. Use it when you are developing or prototyping.

```js
broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});
```

### Load service from file
The recommended way is to place your service code into a single file and load it with the broker.

{% codeblock lang:js math.service.js %}
// Export the schema of service
module.exports = {
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        },
        sub(ctx) {
            return Number(ctx.params.a) - Number(ctx.params.b);
        }
    }
}
{% endcodeblock %}

Load it with broker:
{% codeblock lang:js index.js %}
// Create broker
let broker = new ServiceBroker();

// Load service
broker.loadService("./math.service");

// Start broker
broker.start();
{% endcodeblock %}

In the service file you can also create the Service instance. In this case, you have to export a function which returns the instance of [Service](#service).
```js
// Export a function, the `loadService` will call it with the ServiceBroker instance.
module.exports = function(broker) {
    return new Service(broker, {
        name: "math",
        actions: {
            add(ctx) {
                return Number(ctx.params.a) + Number(ctx.params.b);
            },
            sub(ctx) {
                return Number(ctx.params.a) - Number(ctx.params.b);
            }
        }
    });
}
```

Or create a function which returns with the schema of service
```js
// Export a function, the `loadService` will call with the ServiceBroker instance.
module.exports = function() {
    let users = [....];

    return {
        name: "math",
        actions: {
            create(ctx) {
                users.push(ctx.params);
            }
        }
    };
}
```

### Load multiple services from a folder
If you have many services (and you will have) we suggest to put them to a `services` folder and load all of them with the `broker.loadServices` method.

**Syntax**
```js
broker.loadServices(folder = "./services", fileMask = "**/*.service.js");
```

**Example**
```js
// Load every *.service.js file from the "./services" folder (including subfolders)
broker.loadServices();

// Load every *.service.js file from the current folder (including subfolders)
broker.loadServices("./");

// Load every user*.service.js file from the "./svc" folder
broker.loadServices("./svc", "user*.service.js");
```

### Load with Moleculer Runner (recommended)
We recommend to use the [Moleculer Runner](runner.html) to start a ServiceBroker and load services. [Read more about Moleculer Runner](runner.html). It is the easiest way to start a node.

## Hot reloading services
When you are developing your microservices project would be useful a hot reload function which reloads your services when you modify it. Moleculer has a built-in hot-reloading function. You can enable it in broker options or in [Moleculer Runner](runner.html).
[Demo video how it works.](https://www.youtube.com/watch?v=l9FsAvje4F4)

**Usage**

```js
let broker = new ServiceBroker({
    logger: console,
    hotReload: true
});

broker.loadService("./services/test.service.js");
```

**Usage with Moleculer Runner**

Turn it on with `--hot` or `-H` flags.

```bash
$ moleculer-runner --hot ./services/test.service.js
```

{% note info %}
Hot reloading function is working only with Moleculer Runner or if you load your services with `broker.loadService` or `broker.loadServices`. It doesn't work with `broker.createService`.
{% endnote %}

{% note info %}
Hot reloading is only watch the `service.js` file. If you are using additional JS files in your services and they are changed, broker won't detect it. In this case it is better to use [nodemon](https://github.com/remy/nodemon) to restart all services and broker.
{% endnote %}

## Local variables
If you would like to use local properties/variables in your service, declare them in the `created` event handler.

**Example for local variables**
```js
const http = require("http");

module.exports = {
    name: "www",

    settings: {
        port: 3000
    },

    created() {
        // Create HTTP server
        this.server = http.createServer(this.httpHandler);
    },

    started() {
        // Listening...
        this.server.listen(this.settings.port);
    },

    stopped() {
        // Stop server
        this.server.close();
    },

    methods() {
        // HTTP handler
        httpHandler(req, res) {
            res.end("Hello Moleculer!");
        }
    }
}
```
{% note warn Naming restriction %}
It is important to be aware that you can't use variable name which is reserved for service or coincides with your method names! E.g. `this.name`, `this.version`, `this.settings`, `this.schema`...etc.  
{% endnote %}

## ES6 classes
If you like better ES6 classes than Moleculer service schema, you can write your services in ES6 classes. There are two ways to do it.

### Native ES6 classes with schema parsing

Define `actions` and `events` handlers as class methods. Call the `parseServiceSchema` method in constructor with schema definition where the handlers pointed to these class methods.
```js
const Service = require("moleculer").Service;

class GreeterService extends Service {

    constructor(broker) {
        super(broker);

        this.parseServiceSchema({
            name: "greeter",
            version: "v2",
            meta: {
                scalable: true
            },
            dependencies: [
                "auth",
                "users"
            ],

            settings: {
                upperCase: true
            },
            actions: {
                hello: this.hello,
                welcome: {
                    cache: {
                        keys: ["name"]
                    },
                    params: {
                        name: "string"
                    },
                    handler: this.welcome
                }
            },
            events: {
                "user.created": this.userCreated
            },
            created: this.serviceCreated,
            started: this.serviceStarted,
            stopped: this.serviceStopped,
        });
    }

    // Action handler
    hello() {
        return "Hello Moleculer";
    }

    // Action handler
    welcome(ctx) {
        return this.sayWelcome(ctx.params.name);
    }

    // Private method
    sayWelcome(name) {
        this.logger.info("Say hello to", name);
        return `Welcome, ${this.settings.upperCase ? name.toUpperCase() : name}`;
    }

    // Event handler
    userCreated(user) {
        this.broker.call("mail.send", { user });
    }

    serviceCreated() {
        this.logger.info("ES6 Service created.");
    }

    serviceStarted() {
        this.logger.info("ES6 Service started.");
    }

    serviceStopped() {
        this.logger.info("ES6 Service stopped.");
    }
}

module.exports = GreeterService;
```

### Use decorators
Thanks for [@ColonelBundy](https://github.com/ColonelBundy), you can use ES7/TS decorators as well: [moleculer-decorators](https://github.com/ColonelBundy/moleculer-decorators)

{% note info Need a compiler %}
Please note, you need to use Typescript or Babel to compile decorators.
{% endnote %}

**Example service**
```js
const moleculer = require('moleculer');
const { Service, Action, Event, Method } = require('moleculer-decorators');
const web = require('moleculer-web');
const broker = new moleculer.ServiceBroker({
    logger: console,
    logLevel: "debug",
});

@Service({
    mixins: [web],
    settings: {
        port: 3000,
        routes: [
            //...
        ]
    }
})
class MyService {
    @Action()
    Login(ctx) {
        //...
    }

    // With options
    @Action({
        cache: false,
        params: {
            a: "number",
            b: "number"
        }
    })
    Login2(ctx) {
        //...
    }

    @Event
    'event.name'(payload, sender, eventName) {
        //...
    }

    @Method
    authorize(ctx, route, req, res) {
        //...
    }

    hello() { // Private
        //...
    }

    started() { // Reserved for moleculer, fired when started
        //...
    }

    created() { // Reserved for moleculer, fired when created
        //...
    }

    stopped() { // Reserved for moleculer, fired when stopped
        //...
    }
}

broker.createService(MyService);
broker.start();
```
