title: API Gateway
---
## moleculer-web [![npm](https://img.shields.io/npm/v/moleculer-web.svg?maxAge=3600)](https://www.npmjs.com/package/moleculer-web)
The [moleculer-web](https://github.com/moleculerjs/moleculer-web) is the official API gateway service for Moleculer framework. Use it to publish your services.

## Features
* support HTTP & HTTPS
* serve static files
* multiple routes
* support Connect-like middlewares in global-level, route-level and alias-level.
* alias names (with named parameters & REST routes)
* whitelist
* multiple body parsers (json, urlencoded)
* CORS headers
* Rate limiter
* before & after call hooks
* Buffer & Stream handling
* middleware mode (use as a middleware with Express)
* support authorization

## Install
```bash
npm i moleculer-web
```

## Usage

### Run with default settings
This example uses API Gateway service with default settings.
You can access all services (including internal `$node.`) via `http://localhost:3000/`

```js
let { ServiceBroker } = require("moleculer");
let ApiService = require("moleculer-web");

let broker = new ServiceBroker({ logger: console });

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
If you don't want to publish all actions, you can filter them with whitelist option.
You can use [match strings](https://github.com/micromatch/nanomatch) or regexp in list.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            path: "/api",

            whitelist: [
                // Access any actions in 'posts' service
                "posts.*",
                // Access call only the `users.list` action
                "users.list",
                // Access any actions in 'math' service
                /^math\.\w+$/
            ]
        }]
    }
});
```

## Aliases
You can use alias names instead of action names. You can also specify the method. Otherwise it will handle every method types. 

Using named parameters in aliases is possible. Named parameters are defined by prefixing a colon to the parameter name (`:name`).

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

You can make use of custom functions within the declaration of aliases.
```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            aliases: {
                "POST upload"(req, res) {
                    this.parseUploadedFile(req, res);
                }
            }
        }]
    }
});
```

{% note info %}
You have some internal pointer in `req` & `res` to some important instances:
* `req.$service` & `res.$service` is pointed to the service instance.
* `req.$route` & `res.$route` is pointed to the route definition.
* `req.$params` is pointed to the resolved parameters (from query string & post body)
* `req.$alias` is pointed to the alias definition.
* `req.$endpoint` is pointed to the resolved action endpoint. It contains action and nodeID.

E.g., if you would like to access the broker, use `req.$service.broker` path.
{% endnote %}

### Mapping policy
The `route` has a `mappingPolicy` property to handle routes without aliases.

**Available options:**
- `all` - enable to request all routes with or without aliases (default)
- `restrict` - enable to request only the routes with aliases.

```js
broker.createService({
    mixins: [ApiService],

    settings: {
        routes: [{
            mappingPolicy: "restrict",
            aliases: {
                "POST add": "math.add"
            }
        }]
    }
});
```
You can't request the `/math.add` or `/math/add` URLs, only `POST /add`.

## Middlewares
It supports Connect-like middlewares in global-level, route-level & alias-level. Signature: `function(req, res, next) {...}`.

**Example**
```js
broker.createService({
    mixins: [ApiService],
    settings: {
        // Global middlewares. Applied to all routes.
        use: [
            cookieParser(),
            helmet()
        ],

        routes: [
            {
                path: "/",

                // Route-level middlewares.
                use: [
                    compression(),
                    
                    passport.initialize(),
                    passport.session(),

                    serveStatic(path.join(__dirname, "public"))
                ],
                
                aliases: {
                    "GET /secret": [
                        // Alias-level middlewares.
                        auth.isAuthenticated(),
                        auth.hasRole("admin"),
                        "top.secret" // Call the `top.secret` action
                    ]
                }
            }
        ]
    }
});
```

## Serve static files
It serves assets with the [serve-static](https://github.com/expressjs/serve-static) module like ExpressJS.

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
2. Define the `authorize` method of service.

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
You can find a more detailed role-based JWT authorization example in [full example](https://github.com/moleculerjs/moleculer-web/blob/master/examples/full/index.js#L239).
{% endnote %}

## Route hooks
The `route` has before & after call hooks. You can use it to set `ctx.meta`, access `req.headers` or modify the response `data`.

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

## Error handlers
You can add route-level & global-level custom error handlers. 
> In handlers, you must call the `res.end`. Otherwise, the request is unhandled.

```js
broker.createService({
    mixins: [ApiService],
    settings: {

        routes: [{
            path: "/api",

            // Route error handler
            onError(req, res, err) {
                res.setHeader("Content-Type", "application/json; charset=utf-8");
                res.writeHead(500);
                res.end(JSON.stringify(err));
            }
        }],

        // Global error handler
        onError(req, res, err) {
            res.setHeader("Content-Type", "text/plain");
            res.writeHead(501);
            res.end("Global error: " + err.message);
        }		
    }
}
```

## CORS headers
You can use [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) headers in Moleculer-Web service.

**Usage**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {

        // Global CORS settings for all routes
        cors: {
            // Configures the Access-Control-Allow-Origin CORS header.
            origin: "*",
            // Configures the Access-Control-Allow-Methods CORS header. 
            methods: ["GET", "OPTIONS", "POST", "PUT", "DELETE"],
            // Configures the Access-Control-Allow-Headers CORS header.
            allowedHeaders: [],
            // Configures the Access-Control-Expose-Headers CORS header.
            exposedHeaders: [],
            // Configures the Access-Control-Allow-Credentials CORS header.
            credentials: false,
            // Configures the Access-Control-Max-Age CORS header.
            maxAge: 3600
        },

        routes: [{
            path: "/api",

            // Route CORS settings (overwrite global settings)
            cors: {
                origin: ["http://localhost:3000", "https://localhost:4000"],
                methods: ["GET", "OPTIONS", "POST"],
                credentials: true
            },
        }]
    }
});
```

## Rate limiter
The Moleculer-Web has a built-in rate limiter with a memory store.

**Usage**
```js
const svc = broker.createService({
    mixins: [ApiService],

    settings: {
        rateLimit: {
            // How long to keep record of requests in memory (in milliseconds). 
            // Defaults to 60000 (1 min)
            window: 60 * 1000,

            // Max number of requests during window. Defaults to 30
            limit: 30,
            
            // Set rate limit headers to response. Defaults to false
            headers: true,

            // Function used to generate keys. Defaults to: 
            key: (req) => {
                return req.headers["x-forwarded-for"] ||
                    req.connection.remoteAddress ||
                    req.socket.remoteAddress ||
                    req.connection.socket.remoteAddress;
            },
            //StoreFactory: CustomStore
        }
    }
});
```

### Custom Store example
```js
class CustomStore {
    constructor(window, opts) {
        this.hits = new Map();
        this.resetTime = Date.now() + clearPeriod;

        setInterval(() => {
            this.resetTime = Date.now() + clearPeriod;
            this.reset();
        }, clearPeriod);
    }

    /**
     * Increment the counter by key
     *
     * @param {String} key
     * @returns {Number}
     */
    inc(key) {
        let counter = this.hits.get(key) || 0;
        counter++;
        this.hits.set(key, counter);
        return counter;
    }

    /**
     * Reset all counters
     */
    reset() {
        this.hits.clear();
    }
}
```

## ExpressJS middleware usage
You can use Moleculer-Web as a middleware in an [ExpressJS](http://expressjs.com/) application.

**Usage**
```js
const svc = broker.createService({
    mixins: [ApiService],

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


## Full service settings
List of all settings of Moleculer Web service:

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

    // Exposed global path prefix
    path: "/api",
    
    // Global-level middlewares
    use: [
        compression(),
        cookieParser()
    ],
    
    // Logging request parameters with 'info' level
    logRequestParams: "info",
    
    // Logging response data with 'debug' level
    logResponseData: "debug"

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

            // Call the `this.authorize` method before call the action
            authorization: true,
            
            // Route-level middlewares
            uses: [
                helmet(),
                passport.initialize()
            ],

            // Action aliases
            aliases: {
                "POST users": "users.create",
                "health": "$node.health"
            },

            mappingPolicy: "all",

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

            // No authorization
            authorization: false,
            
            // Action aliases
            aliases: {
                "add": "math.add",
                "GET sub": "math.sub",
                "POST divide": "math.div",
                "GET greeter/:name": "test.greeter",
                "GET /": "test.hello",
                "POST upload"(req, res) {
                    this.parseUploadedFile(req, res);
                }
            },

            mappingPolicy: "restrict",
            
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
            },
            
            // Route error handler
            onError(req, res, err) {
                res.setHeader("Content-Type", "text/plain");
                res.writeHead(err.code || 500);
                res.end("Route error: " + err.message);
            }
        }
    ],

    // Folder to server assets (static files)
    assets: {
        // Root folder of assets
        folder: "./examples/www/assets",
        
        // Options to `server-static` module
        options: {}
    },
    // Global error handler
    onError(req, res, err) {
        res.setHeader("Content-Type", "text/plain");
        res.writeHead(err.code || 500);
        res.end("Global error: " + err.message);
    }    
}
```

## Examples
- [Simple](https://github.com/moleculerjs/moleculer-web/blob/master/examples/simple/index.js)
    - simple gateway with default settings.

- [SSL server](https://github.com/moleculerjs/moleculer-web/blob/master/examples/ssl/index.js)
    - open HTTPS server
    - whitelist handling

- [WWW with assets](https://github.com/moleculerjs/moleculer-web/blob/master/examples/www/index.js)
    - serve static files from the `assets` folder
    - whitelist
    - aliases
    - multiple body-parsers

- [Authorization](https://github.com/moleculerjs/moleculer-web/blob/master/examples/authorization/index.js)
    - simple authorization demo
    - set the authorized user to `Context.meta`

- [REST](https://github.com/moleculerjs/moleculer-web/blob/master/examples/rest/index.js)
    - simple server with RESTful aliases
    - example `posts` service with CRUD actions

- [Express](https://github.com/moleculerjs/moleculer-web/blob/master/examples/express/index.js)
    - webserver with Express
    - use moleculer-web as a middleware
    
- [Socket.io](https://github.com/moleculerjs/moleculer-web/blob/master/examples/socket.io/index.js)
    - start socket.io websocket server
    - call action and send back the response via websocket
    - send Moleculer events to the browser via websocket
    
- [Full](https://github.com/moleculerjs/moleculer-web/blob/master/examples/full/index.js)
    - SSL
    - static files
    - middlewares
    - multiple routes with different roles
    - role-based authorization with JWT
    - whitelist
    - aliases with named params
    - multiple body-parsers
    - before & after hooks
    - metrics, statistics & validation from Moleculer
    - custom error handlers

- [Webpack](https://github.com/moleculerjs/moleculer-web/blob/master/examples/webpack)
    - Webpack development environment for client-side developing
    - webpack config file
    - compression
    - static file serving

- [Webpack-Vue](https://github.com/moleculerjs/moleculer-web/blob/master/examples/webpack-vue)
    - Webpack+Vue development environment for VueJS client developing
    - webpack config file
    - Hot-replacement
    - Babel, SASS, SCSS, Vue SFC
