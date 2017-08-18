title: Service
---
The Service represents a microservice in the Moleculer. You can define actions and subscribe to events. To create a service you need to define a schema. The service schema is similar as [a component of VueJS](https://vuejs.org/v2/guide/components.html#What-are-Components).

## Schema
The schema has some main parts: `name`, `version`, `settings`, `actions`, `methods`, `events`, `created`, `started`, `stopped`.

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

> You can disable service name prefixing with the `$noServiceNamePrefix: true` setting in Service settings.

The `version` is an optional property. If you are running multiple version of the same service this needs to be set. It will be a prefix in the actionName. It can be a `Number` or a `String`. 
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

> You can disable version prefixing with the `$noVersionPrefix: true` setting in Service settings.

## Settings
The `settings` property is a store, where you can store every settings/options to your service. You can reach it inside the service via `this.settings`.

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
> The settings is also obtainable on remote nodes. It is transferred during service discovering.

## Internal settings
There are some internal settings which is used by core modules. These settings name starts with `$` sign.

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `$noVersionPrefix` | `Boolean` | `false` | Disable version prefixing in action names. |
| `$noServiceNamePrefix` | `Boolean` | `false` | Disable service name prefixing in action names. |

## Mixins
Mixins are a flexible way to distribute reusable functionalities for Moleculer services. The Service constructor merges these mixins with the Service schema. It is to reuse an other Service in your service or you can extend an other Service. When a service uses mixins, all properties in the mixin will be "mixed" into the service’s own properties.

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
The above example creates an `api` service which is inherit all from `ApiGwService` but overwrite the port setting and add a new `myAction` action. 

### Merge algorithm
The merge algorith depends of the property type.

| Property | Algorithm |
|----------|-----------|
| `name`, `version` | Merge & overwrite. |
| `settings` | Extend with [defaultsDeep](https://lodash.com/docs/4.17.4#defaultsDeep). |
| `actions` | Merge & overwrite. _You can disable an action from mixin if you set to `false` in your service._ |
| `methods` | Merge & overwrite. |
| `events` | Concatenate. |
| `created`, `started`, `stopped` | Concatenate. |
| `mixins` | Concatenate. |
| any other | Merge & overwrite. |

{% note %}
__Merge & overwrite__: if serviceA has `a: 5`, `b: 8` and serviceB has `c: 10`, `b: 15`, the mixed service will have `a: 5`, `b: 15` and `c: 10`.
__Concatenate__: if serviceA & serviceB subscribe to `users.created` event, both event handler will be called when the `users.created` event emitted.
{% endnote %}

## Actions
The actions are the callable/public methods of the service. It becomes callable with `broker.call`.
The action could be a function (shorthand for handler) or an object with some properties above all with the `handler`.
The actions should be placed under the `actions` key.

```js
{
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
                // The action params becomes accessible as `ctx.action.*`
                if (!ctx.action.cache)
                    return Number(ctx.params.a) * Number(ctx.params.b);
            }
        }
    }
}
```
You can call the above actions as
```js
broker.call("math.add", { a: 5, b: 7 }).then(res => console.log(res));
broker.call("math.mult", { a: 10, b: 31 }).then(res => console.log(res));
```

Inside the action you can call other actions in other services with `ctx.call` method. It is an alias to `broker.call`, just set itself as parent context (due to metrics).
```js
{
    name: "posts",
    actions: {
        get(ctx) => {
            // Find a post by ID
            let post = posts[ctx.params.id];

            // Populate the post.author field through "users" service
            // Call the "users.get" action with author ID
            return ctx.call("users.get", { id: post.author }).then(user => {
                if (user) {
                    // Replace the author ID with the received user object
                    post.author = user;
                }

                return post;
            })
        }
    }
}
```
> In handlers the `this` is pointed to the Service instance.


## Events
You can subscribe to events and can define event handlers under the `events` key.

```js
{
    name: "report",
    actions: {
        ...
    },

    events: {
        // Subscribe to "user.created" event
        // Same as you subscribe as `broker.on("user.created", ...)` 
        // in the `created()` method
        "user.created": function(payload) {
            this.logger.info("User created:", payload);
            // Do something
        },

        // Subscribe to all "user.*" event
        "user.*": function(payload, sender, eventName) {
            // Do something with payload. The `eventName` contains 
            // the original event name. E.g. `user.modified`.
            // The `sender` is the nodeID of sender.
        }
    }

}
```
> In handlers the `this` is pointed to the Service instance.

## Methods
You can also create private functions in the Service. They are called as `methods`. These functions are private, can't be called with `broker.call`. But you can call it inside service (from action handlers, event handlers or lifecycle event handlers).

**Usage**
```js
{
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
}
```
> The name of the method can't be `name`, `version`, `settings`, `schema`, `broker`, `actions`, `logger`, because these words are reserved in the schema.

> In methods the `this` is pointed to the Service instance.

## Lifecycle events
There are some lifecycle service events, that will be triggered by broker.

```js
{
    name: "www",
    actions: {...},
    events: {...},
    methods: {...},

    created() {
        // Fired when the service instance created. (broker.loadService or broker.createService)
    },

    started() {
        // Fired when `broker.start()` called.
    }

    stopped() {
        // Fired when `broker.stop()` called.
    }
}
```

## Properties of `this`
In service functions the `this` is always pointed to the Service instance. It has some properties & methods which you can use in your service functions.

| Name | Type |  Description |
| ------- | ----- | ------- |
| `this.name` | `String` | Name of service (from schema) |
| `this.version` | `Number` or `String` | Version of service (from schema) |
| `this.settings` | `Object` | Settings of service (from schema) |
| `this.schema` | `Object` | Schema definition of service |
| `this.broker` | `ServiceBroker` | Instance of broker |
| `this.Promise` | `Promise` | Class of Promise (Bluebird) |
| `this.logger` | `Logger` | Logger instance |
| `this.actions` | `Object` | Actions of service. *Service can call own actions directly but it is not recommended. Use the `ctx.call` instead!* |

## Create a service
There are several ways to create/load a service.

### broker.createService()
Call the `broker.createService` method with the schema of service as argument. It's simple & fast. Use it when you are developing or prototyping.

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
The recommended way (in production) is to place your service code to a single file and load this file with the broker.

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

In the service file you can also be create the Service instance. In this case you need to export a function that returns the instance of [Service](#service).
```js
// Export a function, that the `loadService` will be call it with the Service instanceBroker
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

Or create a function that returns with the schema of service
```js
// Export a function, that the `loadService` will be call with the Service instanceBroker
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
If you have many services (and you will have) we suggest to place them to a `services` folder and load all of them with the `broker.loadServices` method.

**Syntax**
```js
broker.loadServices(folder = "./services", fileMask = "*.service.js");
```

**Example**
```js
// Load every *.service.js file from the "./services" folder
broker.loadServices();

// Load every *.service.js file from the current folder
broker.loadServices("./");

// Load every user*.service.js file from the "./svc" folder
broker.loadServices("./svc", "user*.service.js");
```

### Load with Moleculer Runner (recommended)
We recommend to use the new [Moleculer Runner](runner.html) to start a ServiceBroker and load services. [Read more about Moleculer Runner](runner.html).

## Hot reloading services
When you are developing your microservices project would be useful a hot reload function which reload your services when you modify it. Moleculer has a built-in hot-reloading function. You can enable it in broker options or in [Moleculer Runner](runner.html).
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

{% note warn Please note %}
Hot reloading function is working only with Moleculer Runner or if you load your services with `broker.loadService` or `broker.loadServices`.
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
It is important to be aware that you can't use such variable names which are reserved in service or names of your methods! E.g. `this.name`, `this.version`, `this.settings`, `this.schema`...etc.  
{% endnote %}