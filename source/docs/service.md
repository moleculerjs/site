title: Service
---
The Service is the other main module in the Moleculer. With the help of this you can define actions.

## Schema
You need to create a schema to define a service. The schema has some main parts (`name`, `version`, `settings`, `actions`, `methods`, `events`).

### Simple service schema
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
The `name` is a mandatory property so it must be defined. It's the first part of actionName when you call it with `broker.call`.

The `version` is an optional property. If you are running multiple version of the same service this needs to be set. It will be a prefix in the actionName.
```js
{
    name: "posts",
    version: 2,
    actions: {
        find() {...}
    }
}
```
You need to call the `find` action as
```js
broker.call("v2.posts.find");
```

## Settings
You can add custom settings to your service under `settings` property in schema. You can reach it in the service via `this.settings`.

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

## Actions
The actions are the callable/public methods of the service. They can be called with `broker.call` method.
The action could be a function (handler) or an object with some properties and with `handler`.
The actions should be placed under `actions` key in the service schema.

```js
{
	name: "math",
	actions: {
        // Simple definition, only the handler function
		add(ctx) {
			return Number(ctx.params.a) + Number(ctx.params.b);
		},

        // Complex definition, set other properties. In this case
        // the `handler` function is required!
		mult: {
            cache: false,
			params: {
				a: "number",
				b: "number"
			},
			handler(ctx) {
                // You can reach action params with `ctx.action.*`
                if (ctx.action.cache)
				    return Number(ctx.params.a) * Number(ctx.params.b);
			}
		}
	}
}
```
You can call these actions as
```js
broker.call("math.add", { a: 5, b: 7 }).then(res => console.log(res));

broker.call("math.mult", { a: 10, b: 31 }).then(res => console.log(res));
```

Inside the action you can sub-call other actions in other services with `ctx.call` method. It is an alias to `broker.call`, just set itself as parent context.
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

## Events
You can subscribe to events and can define event handlers in the schema under `events` key.

```js
{
    name: "users",
    actions: {
        ...
    },

    events: {
        // Subscribe to "user.create" event
        // Same as you subscribe with `broker.on("user.create", ...)` in the `created()` method
        "user.create": function(payload) {
            this.logger.info("Create user...");
            // Do something
        },

        // Subscribe to all "user.*" event
        "user.*": function(payload, sender, eventName) {
            // Do something with payload. The `eventName` contains the original event name. E.g. `user.modified`.
            // The `sender` is the nodeID of sender if the event came from remote node. If the event is local, it'll be `undefined`
        }
    }

}
```

## Methods
You can also create private functions in the Service. They are called as `methods`. These functions are private, can't be called with `broker.call`. But you can call it inside service actions.

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
> The name of method can't be `name`, `version`, `settings`, `schema`, `broker`, `actions`, `logger`, because these words are reserved.

## Lifecycle events
There are some lifecycle service events, that will be triggered by ServiceBroker.

```js
{
    name: "www",
    actions: {...},
    events: {...},
    methods: {...},

    created() {
        // Fired when the service instance created.
    },

    started() {
        // Fired when `broker.start()` called.
    }

    stopped() {
        // Fired when `broker.stop()` called.
    }
}
```

## Mixins
Mixins are a flexible way to distribute reusable functionalities for Moleculer services. A mixin schema can contain any service schemas. When a service uses a mixin, all properties in the mixin will be "mixed" into the service’s own properties.

**Example**

```js
const ApiGwService = require("moleculer-web");

module.exports = {
    name: "api",
    mixins: [ApiGwService]
    settings: {
        // Overwrite the port setting
        port: 8080
    },
    actions: {
        myAction() {
            // Add a new action to apiGwService service
        }
    }
}
```

## Properties of `this`
In service functions the `this` is always binded to the instance of service. It has some properties & methods that you can use in service functions.

| Name | Type |  Description |
| ------- | ----- | ------- |
| `this.name` | `String` | Name of service from schema |
| `this.version` | `Number` | Version of service from schema |
| `this.settings` | `Object` | Settings of service from schema |
| `this.schema` | `Object` | Schema definition of service |
| `this.broker` | `ServiceBroker` | Instance of broker |
| `this.Promise` | `Promise` | Class of Promise (Bluebird) |
| `this.logger` | `Logger` | Logger module |
| `this.actions` | `Object` | Actions of service. *Service can call its own actions directly.* |

## Create a service
There are several ways to create/load a service.

### broker.createService()
Call the `broker.createService` method with the schema of service as argument. You can use this method when developing or testing.

```js
broker.createService({
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
```

### Load service
You can place your service code to a single file and load this file with broker.

**math.service.js**
```js
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
```

**index.js**
```js
// Create broker
let broker = new ServiceBroker();

// Load service
broker.loadService("./math.service");

// Start broker
broker.start();
```

In the service file you can also be create the instance of Service. In this case you need to export a function that returns the instance of [Service](#service).
```js
// Export a function, that the `loadService` will be call it with the instance of ServiceBroker
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
// Export a function, that the `loadService` will be call with the instance of ServiceBroker
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
You can load multiple services from a folder.

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

## Local variables
If you would like to create local properties/variables in service, we recommend to declare them in the `created` handler.

**Example for local properties**
```js
const http = require("http");

// Simple HTTP server service
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
