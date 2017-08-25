title: API Gateway
---
## moleculer-web [![npm](https://img.shields.io/npm/v/moleculer-web.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-web)
The [moleculer-web](https://github.com/ice-services/moleculer-web) is the official API gateway service for Moleculer framework. Use it to publish your services.

## Features
* support HTTP & HTTPS
* serve static files
* multiple routes
* alias names (with named parameters & REST routes)
* whitelist
* multiple body parsers (json, urlencoded)
* Buffer & Stream handling
* before & after call hooks
* middleware mode (use as a middleware with Express)
* support authorization

## Install
```bash
npm install moleculer-web --save
```

## Usage

### Run with default settings
This example uses API Gateway service with default settings.
You can access to all services (including internal `$node.`) via `http://localhost:3000/`

```js
let { ServiceBroker } = require("moleculer");
let ApiService = require("moleculer-web");

let broker = new ServiceBroker({ logger: console });

// Load your services
broker.loadService(...);

// Load API Gateway
broker.createService(ApiService);

// Start server
broker.start();
```

**Example URLs:**	
- Call `test.hello` action: `http://localhost:3000/test/hello`
- Call `math.add` action with params: `http://localhost:3000/math/add?a=25&b=13`

- Get health info of node: `http://localhost:3000/~node/health`
- List all actions: `http://localhost:3000/~node/actions`

## Whitelist
If you don't want to public all actions, you can filter them with whitelist option.
You can use [match strings](https://github.com/micromatch/nanomatch) or regexp in list.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            path: "/api",

            whitelist: [
                // Access to any actions in 'posts' service
                "posts.*",
                // Access to call only the `users.list` action
                "users.list",
                // Access to any actions in 'math' service
                /^math\.\w+$/
            ]
        }]
    }
});
```

## Aliases
You can use alias names instead of action names. You can also specify the method. Otherwise it will handle every method types. 

It is possible to use named parameters in aliases. Named parameters are defined by prefixing a colon to the parameter name (`:name`).

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                // Call `auth.login` action with `GET /login` or `POST /login`
                "login": "auth.login"

                // Restrict the request method
                "POST users": "users.create",

                // The `name` comes from named param. 
                // You can access it with `ctx.params.name` in action
                "GET greeter/:name": "test.greeter",
            }
        }]
    }
});
```

{% note info %}
The named parameter is handled with [path-to-regexp](https://github.com/pillarjs/path-to-regexp) module. Therefore you can use [optional](https://github.com/pillarjs/path-to-regexp#optional) and [repeated](https://github.com/pillarjs/path-to-regexp#zero-or-more) parameters as well.
{% endnote %}


You can also create RESTful APIs.
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "GET users": "users.list",
                "GET users/:id": "users.get",
                "POST users": "users.create",
                "PUT users/:id": "users.update",
                "DELETE users/:id": "users.remove"
            }
        }]
    }
});
```

For REST routes you can also use this simple shorthand alias:
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "REST users": "users"
            }
        }]
    }
});
```
{% note warn %}
To use this shorthand alias you need to create a service which has `list`, `get`, `create`, `update` and `remove` actions.
{% endnote %}

## Serve static files
It can serve assets files with the [serve-static](https://github.com/expressjs/serve-static) module like ExpressJS.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        assets: {
            // Root folder of assets
            folder: "./assets",

            // Further options to `server-static` module
            options: {}
        }		
    }
});
```

## Calling options
The `route` has a `callOptions` property which is passed to `broker.call`. So you can set `timeout`, `retryCount` or `fallbackResponse` options for routes. [Read more about calling options](broker.html#Call-services)

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{

            callOptions: {
                timeout: 500,
                retryCount: 0,
                fallbackResponse(ctx, err) { ... }
            }

        }]		
    }
});
```

## Multiple routes 
You can create multiple routes with different prefix, whitelist, alias, calling options & authorization.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [
            {
                path: "/admin",

                authorization: true,

                whitelist: [
                    "$node.*",
                    "users.*",
                ]
            },
            {
                path: "/",

                whitelist: [
                    "posts.*",
                    "math.*",
                ]
            }
        ]
    }
});
```

## Authorization
You can implement authorization. For this you have to do 2 things.
1. Set `authorization: true` in your routes
2. Define the `authorize` method in service.

**Example authorization**
```js
const E = require("moleculer-web").Errors;

broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            // First thing
            authorization: true
        }]
    },

    methods: {
        // Second thing
        authorize(ctx, route, req, res) {
            // Read the token from header
            let auth = req.headers["authorization"];
            if (auth && auth.startsWith("Bearer")) {
                let token = auth.slice(7);

                // Check the token
                if (token == "123456") {
                    // Set the authorized user entity to `ctx.meta`
                    ctx.meta.user = { id: 1, name: "John Doe" };
                    return Promise.resolve(ctx);

                } else {
                    // Invalid token
                    return Promise.reject(new E.UnAuthorizedError(E.ERR_INVALID_TOKEN));
                }

            } else {
                // No token
                return Promise.reject(new E.UnAuthorizedError(E.ERR_NO_TOKEN));
            }
        }

    }
}
```

{% note info %}
You can find a more detailed role-based JWT authorization example in [full example](https://github.com/ice-services/moleculer-web/blob/master/examples/full/index.js#L239).
{% endnote %}

## Route hooks
The `route` has before & after call hooks. You can use it to set `ctx.meta`, access to `req.headers` or modify the response `data`.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [
            {
                path: "/",

                onBeforeCall(ctx, route, req, res) {
                    // Set request headers to context meta
                    ctx.meta.userAgent = req.headers["user-agent"];
                },

                onAfterCall(ctx, route, req, res, data) {
                    // Async function which return with Promise
                    return doSomething(ctx, res, data);
                }
            }
        ]
    }
});
```

## ExpressJS middleware usage
You can use Moleculer-Web as a middleware for [ExpressJS](http://expressjs.com/).

**Usage**
```js
const svc = broker.createService(ApiGatewayService, {
    settings: {
        middleware: true
    }
});

// Create Express application
const app = express();

// Use ApiGateway as middleware
app.use("/api", svc.express());

// Listening
app.listen(3000);

// Start server
broker.start();
```


## Service settings
List of all settings of Moleculer Web servie

```js
settings: {

    // Exposed port
    port: 3000,

    // Exposed IP
    ip: "0.0.0.0",

    // HTTPS server with certificate
    https: {
        key: fs.readFileSync("ssl/key.pem"),
        cert: fs.readFileSync("ssl/cert.pem")
    },

    // Middleware mode (for ExpressJS)
    middleware: false,

    // Exposed path prefix
    path: "/api",

    // Routes
    routes: [
        {
            // Path prefix to this route  (full path: /api/admin )
            path: "/admin",

            // Whitelist of actions (array of string mask or regex)
            whitelist: [
                "users.get",
                "$node.*"
            ],

            // It will call the `this.authorize` method before call the action
            authorization: true,

            // Action aliases
            aliases: {
                "POST users": "users.create",
                "health": "$node.health"
            },

            // Use bodyparser module
            bodyParsers: {
                json: true,
                urlencoded: { extended: true }
            }
        },
        {
            // Path prefix to this route  (full path: /api )
            path: "",

            // Whitelist of actions (array of string mask or regex)
            whitelist: [
                "posts.*",
                "file.*",
                /^math\.\w+$/
            ],

            // No need authorization
            authorization: false,
            
            // Action aliases
            aliases: {
                "add": "math.add",
                "GET sub": "math.sub",
                "POST divide": "math.div",
                "GET greeter/:name": "test.greeter",
                "GET /": "test.hello"                
            },
            
            // Use bodyparser module
            bodyParsers: {
                json: false,
                urlencoded: { extended: true }
            },

            // Calling options
            callOptions: {
                timeout: 3000,
                fallbackResponse: "Static fallback response"
            },

            // Call before `broker.call`
            onBeforeCall(ctx, route, req, res) {
                ctx.meta.userAgent = req.headers["user-agent"];
            },

            // Call after `broker.call` and before send back the response
            onAfterCall(ctx, route, req, res, data) {
                res.setHeader("X-Custom-Header", "123456");
            }            
        }
    ],

    // Folder to server assets (static files)
    assets: {

        // Root folder of assets
        folder: "./examples/www/assets",
        
        // Options to `server-static` module
        options: {}
    }
}
```

## Examples
- [Simple](https://github.com/ice-services/moleculer-web/blob/master/examples/simple/index.js)
    - simple gateway with default settings.

- [SSL server](https://github.com/ice-services/moleculer-web/blob/master/examples/ssl/index.js)
    - open HTTPS server
    - whitelist handling

- [WWW with assets](https://github.com/ice-services/moleculer-web/blob/master/examples/www/index.js)
    - serve static files from the `assets` folder
    - whitelist
    - aliases
    - multiple body-parsers

- [Authorization](https://github.com/ice-services/moleculer-web/blob/master/examples/authorization/index.js)
    - simple authorization demo
    - set the authorized user to `Context.meta`

- [REST](https://github.com/ice-services/moleculer-web/blob/master/examples/rest/index.js)
    - simple server with RESTful aliases
    - example `posts` service with CRUD actions

- [Express](https://github.com/ice-services/moleculer-web/blob/master/examples/express/index.js)
    - webserver with Express
    - use moleculer-web as a middleware
    
- [Socket.io](https://github.com/ice-services/moleculer-web/blob/master/examples/socket.io/index.js)
    - start socket.io websocket server
    - call action and send back the response via websocket
    - send Moleculer events to the browser via websocket
    
- [Full](https://github.com/ice-services/moleculer-web/blob/master/examples/full/index.js)
    - SSL
    - static files
    - multiple routes with different roles
    - role-based authorization with JWT
    - whitelist
    - aliases with named params
    - multiple body-parsers
    - before & after hooks
    - metrics, statistics & validation from Moleculer

