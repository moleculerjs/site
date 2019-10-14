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

## What happens if I emit an event and the service with the event handler is offline?
Moleculer events are fire and forget meaning the if the service is offline the event will be lost. If you want persistent events you should look for the transporters that offer this kind of capabilities.

## Why the broker exits without any error when I start my service?
If there is no continuously running process (e.g., transporter connection, API gateway, DB connection) that keeps event loop running then the process will exit. It's normal behavior and not a bug. If you want to keep your service broker running then you should keep the event look "busy". Try to enable the transporter in `moleculer.config.js`.

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

# DB Adapters (moleculer-db)
## How can I manage multiple entities/tables per service?
At the moment, [Moleculer DB](moleculer-db.html) only supports [one model per service](https://microservices.io/patterns/data/database-per-service.html). This design works well if you are using a NoSQL database, especially Document database, because you can easily nest all child entities. However, for SQL databases things get tricky because you can have multiple and complex relations between the entities/tables. Due to this, its difficult (with the current workforce) to create a solution that will work for everyone. Therefore, for scenarios with multiple entities and relationships you will have to write your own adapter.


## `moleculer-db` violates Domain-Driven Design (DDD)?
`moleculer-db` is a simple (and optional) service mixin to handle one DB entity/table. By no means it obliges or forces you to change your mindset or your way of implementing/modeling things. If the features provided by the `moleculer-db` don't fit your needs then you should write your own service with custom actions.
