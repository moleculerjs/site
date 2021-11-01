title: Стартер Moleculer Runner
---

Moleculer Runner is a helper script that helps you run Moleculer projects. With it, you don't need to create a ServiceBroker instance with options. Instead, you can create a `moleculer.config.js` file in the root of repo with broker options. Then simply call the `moleculer-runner` in NPM script, and it will automatically load the configuration file, create the broker and load the services. В качестве альтернативы, вы можете объявить задать конфигурацию с помощью переменных среды.


{% note info Production-ready %}
Используйте `moleculer.config.js` во время разработки или для хранения общих параметров. В продакшене вы можете переписать значения с помощью переменных среды!
{% endnote %}

## Синтаксис
```
$ moleculer-runner [параметры] [файлы сервисов или директории или глоабльный шаблон]
```
> Примечание: работает только из NPM скриптов. Для прямого вызова непосредственно из консоли, используйте `./node_modules/.bin/moleculer-runner --repl` или `node ./node_modules/moleculer/bin/moleculer-runner.js --repl`.

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

1. Load the config file defined in `MOLECULER_CONFIG` environment variable. Если он не существует, он бросает ошибку.
2. Он загружает файл конфигурации, определенный в настройках CLI. Если он не существует, он бросает ошибку. Note that `MOLECULER_CONFIG` has priority over CLI meaning that if both are defined `MOLECULER_CONFIG` is the one that's going to be used.
3. Если не определено, он загружает файл `moleculer.config.js` из текущего каталога. Если он не существует, он загружает файл `moleculer.config.json`.
4. После загрузки файла конфигурации, он объединяет параметры по умолчанию для ServiceBroker.
5. Стартер просматривает параметры шаг за шагом и пытается перезаписать их из переменных среды. Если в файле конфигурации `logLevel: "warn"`, а переменная окружения `LOGLEVEL=debug`, то стартер перезапишет параметр, и в результате получится: `logLevel: "debug"`.

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


### Асинхронный файл конфигурации

Moleculer Runner также поддерживает асинхронные конфигурационные файлы. В этом случае `moleculer.config.js` должен экспортировать `Функцию`, которая возвращает `Promise` (или можно использовать `async/await`).

```js
// moleculer.config.js
const fetch = require("node-fetch");

module.exports = async function() {
    const res = await fetch("https://pastebin.com/raw/SLZRqfHX");
    return await res.json();
};
```
> This function runs with the `MoleculerRunner` instance as the `this` context. Useful if you need to access the flags passed to the runner. Check the [MoleculerRunner](https://github.com/moleculerjs/moleculer/blob/master/src/runner.js) source more details.

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
Runner загружает файлы или папки, определенные в аргументах CLI. Если вы определяете папку(и), runner загружает все сервисы `**/*.service.js` из них (включая также вложенные папки). Сервисы & и сервисные папки могут быть загружены с помощью переменных окружения `SERVICES` и `SERVICEDIR`.

**Очерёдность загрузки:**
1. Если задана переменная окружения `SERVICEDIR`, но не задана `SERVICES`, то производится загрузка всех сервисов из каталога `SERVICEDIR`.
2. Если заданы обе переменные окружения `SERVICEDIR` & `SERVICES`, то производится загрузка из директорий, указанных в `SERVICEDIR`.
3. Если не задана `SERVICEDIR`, но задана `SERVICES`, то производится загрузка указанных сервисов из текущей директории.
4. Проверка аргументов CLI. При обнаружении имён файлов производится их загрузка. Если задан каталог, то производится загрузка из него. Если задан глобальный шаблон, то он применяется и производится загрузка найденных файлов.
> Обратите внимание: короткие имена также могут быть использованы в перемнной окружения `СЕРВИСЫ`.

**Пример**
```
SERVICEDIR=services
SERVICES=math,post,user
```
Загрузит `math.service.js`, `post.service.js` и `user.service.js` файлы из папки `services`.

```
SERVICEDIR=my-services
```
Производится загрузка всех файлов `*.service.js` из папки `my-services` (включая также вложенные папки).

### Глобальные шаблоны
Использование глобальных шаблонов позволяет делать запуск более гибким. Это полезно при загрузке всех сервисов, за исключением некоторых из них.

```bash
$ moleculer-runner services !services/others/**/*.service.js services/others/mandatory/main.service.js
```

**Пояснения:**
- ` services` - устаревший режим. Загрузка всех сервисы из папки `services` с помощью маски файлов `**/*.service.js`.
- `!services/others/**/*.service.js` - пропустить все сервисы в папке `services/others` и её подпапках.
- `services/others/mandatory/main.service.js` - загрузите только указанный сервис.

> The glob patterns work in the `SERVICES` environment variables, as well.

## Встроенная кластеризация

Moleculer Runner имеет встроенную функцию кластеризации для запуска нескольких экземпляров вашего брокера.

Пример запуска всех служб из папки `services` в 4 экземплярах.
```bash
$ moleculer-runner --instances 4 services
```

{% note info Clustered Node ID %}
К `nodeID` будут добавлены идентификаторы воркеров в виде суффикса. Например, если nodeID задан как `my-node`, и запущено 4 экземпляра, то экземпляры будут иметь следующие идентификаторы: `my-node-1`, `my-node-2`, `my-node-3`, `my-node-4`.
{% endnote %}

## .env файлы

Стартер может загрузить `.env` файл при запуске. Есть две новых CLI опции для загрузки env файла:

* `-e, --env` - Load environment variables from the '.env' file from the current folder.
* `-E, --envfile <filename>` - Load environment variables from the specified file.

**Пример**
```sh
# загрузит .env файл из текущей директории
$ moleculer-runner --env

# загрузит указанный .my-env файл
$ moleculer-runner --envfile .my-env
```

{% note info Зависимости %}
To use this feature, install the `dotenv` module with `npm install dotenv --save` command.
{% endnote %}
