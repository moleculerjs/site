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
События Молекулера следуют принципу выпустил и забыл, что в свою очередь означает, если служба не в сети - событие будет потеряно. Если существует необходимость в персистентных событиях, следует использовать транспорт, предоставляющий такой функционал.

## Почему при запуске сервиса брокер завершат работу без каких-либо ошибок?
Если не запущен постоянный процесс (например, подключения к транспорту, API шлюз, соединение с базой данных), который поддерживает event loop в рабочем состоянии, то процесс Moleculer завершится. Это нормальное поведение, а не баг. Для того, чтобы процесс брокера постоянно выполнялся, необходимо поддерживать event loop в состоянии "занято". Можно попробовать включить транспорт в `moleculer.config.js`.

# API шлюз (moleculer-web)

## Почему я получаю сообщение об ошибке `413 - request entity too large`, когда делаю POST запрос с большим объёмом данных в body?
Следует настроить параметр `bodyParsers`, чтобы перезаписать значение по умолчанию, установленное в `100kb` для body в POST запросе. [Подробнее](https://github.com/expressjs/body-parser#limit).

```js
module.exports = {
    name: "api",
    settings: {
        routes: [{
            path: "/api",

            // Использовать bodyparser модули
            bodyParsers: {
                json: { limit: "2MB" },
                urlencoded: { extended: true, limit: "2MB" }
            }
        }]
    }
}
```

{% note info Recommendation %}
Для передачи сервису данных большого объёма или при получении таковых от сервиса, используйте функцию [потокового вещания](https://moleculer.services/docs/0.13/actions.html#Streaming).
{% endnote %}

## Как изменить формат ответных ошибок?
Необходимо определить хук `onError` в настройках шлюза API. [Подробнее](https://moleculer.services/docs/0.13/moleculer-web.html#Error-handlers).

```js
// api.service.js
module.exports = {
    mixins: [ApiService],
    settings: {
        // Глобальный обработчик ошибок
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

## Почему я получаю `502 - Bad Gateway` когда api-шлюз находится за ALB (балансировщик нагрузки приложений) на AWS?
Необходимо настроить keepAliveTimeouts на HTTP-сервере. Можно получить доступ к экземпляру сервера HTTP в `created()` функции api-шлюза. Больше информации [здесь](https://github.com/moleculerjs/moleculer-web/issues/226).

```js
модуль. xports = {
    mixins: [ApiService],

    created() {
        // Убедитесь, что все неактивные подключения разорваны средствами ALB, установив значение на несколько секунд больше чем тайм-аут простоя ALB.
        this.server.keepAliveTimeout = 65000;
        // Убедитесь, что заголовки таймаута установлены выше, чем keepAliveTimeout из-за  регрессионной ошибки nodejs: https://github. om/nodejs/node/issues/27363
        this.server.headersTimeout = 66000;
    }
};
```


# Адаптеры баз данных (moleculer-db)
## Как я могу управлять несколькими сущностями/таблицами по сервису?
На данный момент [Moleculer DB](moleculer-db.html) поддерживает только [одну модель на сервис](https://microservices.io/patterns/data/database-per-service.html). Такой дизайн хорошо работает при использовании NoSQL баз данных, особенно для Документных баз данных, так как вы можете легко сгруппировать все дочерние сущности. Однако, в случае SQL всё становится сложнее, потому что может присутствовать множество сложных взаимосвязей между сущностями/таблицами. В связи с этим, трудно (имеющимися ресурсами) разработать более общее и подходящее всем решение. Поэтому для сценариев с несколькими сущностями и взаимосвязями следует релизовать собственный адаптер базы данных.


## `moleculer-db` нарушает Domain-Driven Design (DDD)?
`moleculer-db` - это простая (и опциональная) примесь сервиса для обработки одной сущности/таблицы БД. Это ни в коем случае не обязывает вас менять подход или способ реализации/проектирования сервисов. Если функциональность примеси `moleculer-db` не соответствует требованиям вашего проекта, тогда следует реализовать собственный сервис с кастомными действиями.
