title: Стартер Moleculer Runner
---

Moleculer Runner - это вспомогательный скрипт, который помогает вам запускать проекты Moleculer. С ним не нужно создавать экземпляр ServiceBroker с опциями. Вместо этого вы можете создать файл `moleculer.config.js` в корне репозитория с опциями брокера. Затем просто запустите `moleculer-runner` в сценарии NPM и он автоматически загрузит конфигурационный файл, создаст брокера и загрузит сервисы. В качестве альтернативы, вы можете объявить задать конфигурацию с помощью переменных среды.


{% note info Production-ready %}
Используйте `moleculer.config.js` во время разработки или для хранения общих параметров. В продакшене вы можете переписать значения с помощью переменных среды!
{% endnote %}

## Синтаксис
```
$ moleculer-runner [options] [service files or directories or glob masks]
```
> Примечание: Он работает только из NPM скриптов. Для прямого вызова непосредственно из консоли, используйте `./node_modules/.bin/moleculer-runner --repl` или `node ./node_modules/moleculer/bin/moleculer-runner.js --repl`.

## Параметры

| Параметр                       | Тип       | По умолчанию | Описание                                                                               |
| ------------------------------ | --------- | ------------ | -------------------------------------------------------------------------------------- |
| `-r`, `--repl`                 | `Boolean` | `false`      | Если true, то после запуска брокер переключается в режим [REPL](moleculer-repl.html).  |
| `-s`, `--silent`               | `Boolean` | `false`      | Отключить журнал брокера. Ничего не выводить в консоль.                                |
| `-H`, `--hot`                  | `Boolean` | `false`      | Горячая перезагрузка при изменении исходных файлов.                                    |
| `-c`, `--config <file>`  | `String`  | `null`       | Загрузить файл конфигурации из другого пути или другого имени файла.                   |
| `-e`, `--env`                  | `Boolean` | `false`      | Загрузить переменные окружения из файла '.env' из текущей папки.                       |
| `-E`, `--envfile <file>` | `String`  | `null`       | Загрузить переменные окружения из указанного файла.                                    |
| `-i`, `--instances`            | `Number`  | `null`       | Запустить [number] экземпляров узлов или `max` для всех ядер cpu (с модулем `cluster`) |


**Примеры сценариев NPM**
```js
{
    "scripts": {
        "dev": "moleculer-runner --repl --hot --config moleculer.dev.config.js services",
        "start": "moleculer-runner --instances=max services"
    }
}
```
Скрипт `dev` загружает конфигурацию из файла `moleculer.dev.config.js` и запускает все службы из папки `services`, включает горячую перезагрузку и переключается в режим REPL. Запустите команду `npm run dev`.

Скрипт `start` загружает конфигурационный файл `moleculer.config.js` если он существует, иначе загружает параметры только из переменных среды. Запускает 4 экземпляра брокера, затем они запускают все службы из папки `services`. Запустите команду `npm start`.

## Логика загрузки конфигурации
Стартер делает следующие шаги для загрузки и слияния параметров конфигурации:

1. Он загружает файл конфигурации, определенный в настройках CLI. Если он не существует, он бросает ошибку.
2. Если не определено, он загружает файл `moleculer.config.js` из текущего каталога. Если он не существует, он загружает файл `moleculer.config.json`.
3. После загрузки файла конфигурации, он объединяет параметры по умолчанию для ServiceBroker.
4. Стартер просматривает параметры шаг за шагом и пытается перезаписать их из переменных среды. Если в файле конфигурации `logLevel: "warn"`, а переменная окружения `LOGLEVEL=debug`, то стартер перезапишет параметр, и в результате получится: `logLevel: "debug"`.

> Чтобы перезаписать глубоко вложенные параметры брокера по умолчанию, которые отсутствуют в `moleculer.config.js`, используются переменные среды, с префиксом `MOL_` и двойным подчеркиванием `__` для вложенных свойств в файле `.env`. Например, для установки префикса [cacher prefix](caching.html#Built-in-cachers) в `MOL` необходимо объявить `MOL_CACHER__OPTIONS__PREFIX=MOL`.

### Файл конфигурации
Структура конфигурационного файла совпадает с структурой [параметров брокера](configuration.html#Broker-options). Каждое свойство имеет такое же имя.

**Пример файла конфигурации**
```js
// moleculer.config.js
module.exports = {
    nodeID: "node-test",
    logger: true,
    logLevel: "debug",

    transporter: "nats://localhost:4222",
    requestTimeout: 5 * 1000,

    circuitBreaker: {
        enabled: true
    },

    metrics: true
};
```

### Переменные окружения
Стартер преобразует имена свойств в верхний регистр. Имена вложенных параметров объединяются символом `_`.

**Пример переменных окружения**
```bash
NODEID=node-test
LOGGER=true
LOGLEVEL=debug

# короткое объявление транспорта
TRANSPORTER=nats://localhost:4222
REQUESTTIMEOUT=5000

# вложенное свойство
CIRCUITBREAKER_ENABLED=true

METRICS=true
```

## Логика загрузки служб
The runner loads service files or folders defined in CLI arguments. If you define folder(s), the runner loads all services `**/*.service.js` from specified one(s) (including sub-folders too). Services & service folder can be loaded with `SERVICES` and `SERVICEDIR` environment variables.

**Loading steps:**
1. If `SERVICEDIR` env found, but no `SERVICES` env, it loads all services from the `SERVICEDIR` directory.
2. If `SERVICEDIR` & `SERVICES` env found, it loads the specified services from the `SERVICEDIR` directory.
3. If no `SERVICEDIR`, but `SERVICES` env found, it loads the specified services from the current directory.
4. Check the CLI arguments. If filename found, it loads them. If directory found, it loads them. It glob pattern found, it applies and load the found files.
> Please note: shorthand names can also be used in `SERVICES` env var.

**Пример**
```
SERVICEDIR=services
SERVICES=math,post,user
```
Загрузит `math.service.js`, `post.service.js` и `user.service.js` файлы из папки `services`.

```
SERVICEDIR=my-services
```
It loads all `*.service.js` files from the `my-services` folder (including sub-folders too).

### Glob patterns
If you want to be more specific, use glob patterns. It is useful when loading all services except certain ones.

```bash
$ moleculer-runner services !services/others/**/*.service.js services/others/mandatory/main.service.js
```

**Explanations:**
- `services` - legacy mode. Load all services from the `services` folder with `**/*.service.js` file mask.
- `!services/others/**/*.service.js` - skip all services in the `services/others` folder and sub-folders.
- `services/others/mandatory/main.service.js` - load the exact service.

> The glob patterns work in the `SERVICES` enviroment variables, as well.

## Built-in clustering

Moleculer Runner has a built-in clustering function to start multiple instances from your broker.

Example to start all services from the `services` folder in 4 instances.
```bash
$ moleculer-runner --instances 4 services
```

{% note info Clustered Node ID %}
The `nodeID` will be suffixed with the worker ID. E.g. if you define `my-node` nodeID in options, and starts 4 instances, the instance nodeIDs will be `my-node-1`, `my-node-2`, `my-node-3`, `my-node-4`.
{% endnote %}

## .env файлы

Стартер может загрузить `.env` файл при запуске. Есть две новых CLI опции для загрузки env файла:

* `-e, --env` - Load envorinment variables from the '.env' file from the current folder.
* `-E, --envfile <filename>` - Load envorinment variables from the specified file.

**Примеры**
```sh
# загрузит .env файл из текущей директории
$ moleculer-runner --env

# загрузит указанный .my-env файл
$ moleculer-runner --envfile .my-env
```

{% note info Зависимости %}
Чтобы использовать эту функцию, установите модуль `dotenv` командой `npm install dotenv --save`.
{% endnote %}
