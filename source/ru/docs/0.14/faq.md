title: Вопросы и Ответы
---

# Ядро & Общие

## Почему я получаю `NATS ошибку. Could not connect to server: Error: connect ECONNREFUSED 127.0.0.1:4222` сообщение об ошибке при запуске моего проекта?
Сервер NATS не является частью Moleculer. Его необходимо установить & запустить перед запуском проекта. Скачать можно отсюда https://nats.io/download/nats-io/nats-server/
```
[7480] 2019/10/06 14:18:05.801763 [INF] Starting nats-server version 2.0.0
[7480] 2019/10/06 14:18:05.805763 [INF] Git commit [not set]
[7480] 2019/10/06 14:18:05.809763 [INF] Listening for client connections on 0.0.0.0:4222
[7480] 2019/10/06 14:18:05.809763 [INF] Server id is NCHICRYD3SMATIT6QMO557ZDHQUY5JUYPO25TK4SAQYP7IPCIOGKTIRU
[7480] 2019/10/06 14:18:05.810763 [INF] Server is ready
```

## Как запустить сервисы с Moleculer Runner в режиме отладки?
Используйте следующую команду:
```bash
$ node --inspect=0.0.0.0:9229 node_modules/moleculer/bin/moleculer-runner services
```

## Как добавить флаги V8 для Moleculer Runner?
```bash
$ node --max-old-space-size=8192 node_modules/moleculer/bin/moleculer-runner services
```

## Что произойдет, если будет сгенерировано событие, а сервис с обработчиком этого события недоступен/выключен?
События Молекулера следуют принципу выпустил и забыл, что в свою очередь означает, если служба не в сети - событие будет потеряно. If you want persistent events you should look for the transporters that offer this kind of capabilities.

## Why the broker exits without any error when I start my service?
If there is no continuously running process (e.g., transporter connection, API gateway, DB connection) that keeps event loop running then the process will exit. It's normal behavior and not a bug. If you want to keep your service broker running then you should keep the event loop "busy". Try to enable the transporter in `moleculer.config.js`.

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
