title: Примеры
---

## Примеры проекта

### Бэкэнд сервер Realworld
Это [RealWorld.io](https://realworld.io/) пример бэкэнд сервера с применением микросервисного фреймворка Moleculer.

**Ключевые функции**
- 7 микросервисов
- База данных NeDB или MongoDB без Mongoose
- Авторизация пользователя & регистрация
- Аутентификация пользователя с помощью JWT
- Кэширование памяти
- Файлы Docker

**Repo: https://github.com/moleculerjs/moleculer-examples/tree/master/conduit#readme**

### Блог
Это простой пример блога.

**Ключевые функции**
- Файлы Docker
- Веб-сервер на ExpressJS с движком шаблонов Pug
- База данных MongoDB с модулями [moleculer-db](https://github.com/moleculerjs/moleculer-db) и [moleculer-db-adapter-mongoose](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongoose)
- Транспорт NATS
- Кэш Redis
- [Traefik](https://traefik.io/) обратный прокси (микроархитектура)
- статический фронтенд

**Repo: https://github.com/moleculerjs/moleculer-examples/blob/master/blog#readme**

## Краткие примеры
Главный репозиторий Moleculer содержит [некоторые примеры](https://github.com/moleculerjs/moleculer/blob/master/examples/).
{% note info %}
Чтобы попробовать их, сначала необходимо клонировать репозиторий Moleculer со следующей командой:

`git clone https://github.com/moleculerjs/moleculer.git`
{% endnote %}

### Простой пример
Это простое демо с математическим сервисом, который может ` add`, `sub`, `mult` и `divide` два числа.

```bash
$ npm run demo simple
```

[Исходный код доступен на Github](https://github.com/moleculerjs/moleculer/blob/master/examples/simple/index.js)

### Сервер & клиентские узлы
В этом примере можно запустить любые серверы & клиенты. Серверы обрабатывают `math.add` действие, а клиенты вызывают его в цикле. Вы можете запустить несколько экземпляров серверов и клиентов. *Они используют TCP транспорт, но его можно изменить с помощью переменной `TRANSPORTER`.*

**Запуск сервера**
```bash
$ node examples/client-server/server
```

**Запуск клиента**
```bash
$ node examples/client-server/client
```

[Исходный код доступен на Github](https://github.com/moleculerjs/moleculer/tree/master/examples/client-server)

### Middlewares
В этом примере показано, как работает middleware система.

```bash
$ npm run demo middlewares
```

[Исходный код доступен на Github](https://github.com/moleculerjs/moleculer/blob/master/examples/middlewares/index.js)

### Runner
Этот пример показывает, как запустить брокер и загрузить сервисы с помощью [Moleculer Runner](moleculer-runner.html).

```bash
$ node ./bin/moleculer-runner.js -c examples/runner/moleculer.config.js -r examples/user.service.js
```
Команда запускает брокер с опциями `moleculer.config.js`, загружает пользовательский сервис из файла `user.service.js` и переключается в режим REPL.

[Исходный код доступен на Github](https://github.com/moleculerjs/moleculer/blob/master/examples/runner)

### Тестирование нагрузки
С помощью этого примера можете запустить нагрузочный тест. Сервер & клиент вывод количество выполняемых запросов за секунду.

**Запуск сервера**
```bash
$ node examples/loadtest/server
```

**Запуск & клонирование клиентов (по количеству ядер процессора)**
```bash
$ node examples/loadtest/clients
```

[Исходный код доступен на Github](https://github.com/moleculerjs/moleculer/blob/master/examples/loadtest)

