title: FAQ
---

# Core & Common

## How can I start services with Moleculer Runner in debug mode?
Use the following command:
```bash
$ node --inspect=0.0.0.0:9229 node_modules/moleculer/bin/moleculer-runner services
```

## How to add V8 flags for Moleculer Runner?
```bash
$ node --max-old-space-size=8192 node_modules/moleculer/bin/moleculer-runner services
```

# API Gateway (moleculer-web)

## Why am I getting `413 - request entity too large` error message when sending a big POST body?
You should configure the `bodyParsers` to overwrite the default `100kb` POST body limit. [More info](https://github.com/expressjs/body-parser#limit).

```js
module.exports = {
    name: "api",
    settings: {
        routes: [{
            path: "/api",
            
            // Use bodyparser modules
            bodyParsers: {
                json: { limit: "2MB" },
                urlencoded: { extended: true, limit: "2MB" }
            }
        }]
    }
}
```

{% note info Recommendation %}
Use [streaming feature](https://moleculer.services/docs/0.13/actions.html#Streaming) when you want to send big data to a service or receive from a service.
{% endnote %}

## How do I reformat error responses?
You should define an `onError` hook in API Gateway settings. [More info](https://moleculer.services/docs/0.13/moleculer-web.html#Error-handlers).

```js
// api.service.js
module.exports = {
    mixins: [ApiService],
    settings: {
        // Global error handler
        onError(req, res, err) {
            res.setHeader("Content-Type", "application/json");
            res.writeHead(err.code || 500);
            res.end(JSON.stringify({
                success: false,
                message: err.message
            }));
        }		
    }
};
```
