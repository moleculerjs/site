title: Moleculer-web
---
## Official API Gateway [![npm](https://img.shields.io/npm/v/moleculer-web.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-web)
The [moleculer-web](https://github.com/ice-services/moleculer-web) is the official API gateway service for Moleculer framework. Use it to publish your services.

## Features
* support HTTP & HTTPS
* serve static files
* multiple routes
* alias names
* whitelist
* multiple body parsers (json, urlencoded)
* Buffer & Stream handling
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

### Whitelist
If you don't want to public all actions, you can filter them with a whitelist.
You can use [match strings](https://github.com/micromatch/nanomatch) or regexp.

```js
broker.createService({
	mixins: ApiService,

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

### Aliases
You can use alias names instead of action names.

```js
broker.createService({
	mixins: ApiService,

    settings: {
        routes: [{
            aliases: {
                // Call `auth.login` action with `GET /login` or `POST /login`
                "login": "auth.login"

                // Restrict the request method
                "POST users": "users.create",
            }
        }]
    }
});
```

With this you can create RESTful APIs.

```js
broker.createService({
	mixins: ApiService,

    settings: {
        routes: [{
            aliases: {
                "GET users": "users.list",
                "POST users": "users.create",
                "PUT users": "users.update",
                "DELETE users": "users.remove",
            }
        }]
    }
});
```

### Serve static files
Serve assets files with the [serve-static](https://github.com/expressjs/serve-static) module like ExpressJS.

```js
broker.createService({
	mixins: ApiService,

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

### Multiple routes 
You can create multiple routes with different prefix, whitelist, alias & authorization

```js
broker.createService({
	mixins: ApiService,

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

### Authorization
You can implement your authorization method to Moleculer Web. For this you have to do 2 things.
1. Set `authorization: true` in your routes
2. Define the `authorize` method.

{% note info %}
You can find a more detailed role-based JWT authorization example in [full example](/examples/full)
{% endnote %}

**Example authorization**
```js
broker.createService({
	mixins: ApiService,

    settings: {
        routes: [{
            // First thing
            authorization: true,
        }]
    },

    methods: {
        // Second thing
        authorize(ctx, req, res) {
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
                    return Promise.reject(
                        new MoleculerError("Unauthorized! Invalid token", 401));
                }

            } else {
                // No token
                return Promise.reject(
                    new MoleculerError("Unauthorized! Missing token", 401));
            }
        }

    }
}
```


### ExpressJS middleware usage
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
            },
            
            // Use bodyparser module
            bodyParsers: {
                json: false,
                urlencoded: { extended: true }
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

- [Express](https://github.com/ice-services/moleculer-web/blob/master/examples/express/index.js)
    - webserver with Express
    - use moleculer-web as a middleware

- [Full](https://github.com/ice-services/moleculer-web/blob/master/examples/full/index.js)
    - SSL
    - static files
    - multiple routes with different roles
    - role-based authorization with JWT
    - whitelist
    - aliases
    - multiple body-parsers
    - metrics, statistics & validation from Moleculer

