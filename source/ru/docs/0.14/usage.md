title: Использование
---
# Установка Moleculer

Moleculer может быть установлен с помощью `npm` или `yarn`.

```bash
$ npm i moleculer --save
```

# Создайте свой первый микросервис
Этот простой пример показывает, как создать маленький сервис `math` для сложения двух чисел и локального вызова.

```js
const { ServiceBroker } = require("moleculer");

// создание брокера
const broker = new ServiceBroker();

// определение сервиса
broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});

// запуск брокера
broker.start()
    // вызов сервиса
    .then(() => broker.call("math.add", { a: 5, b: 3 }))
    // вывод ответа
    .then(res => console.log("5 + 3 =", res))
    .catch(err => console.error(`Error occured! ${err.message}`));
```

{% note info Try it in your browser! %}
Откройте этот пример на [Runkit!](https://runkit.com/icebob/moleculer-usage)
{% endnote %}

# Создание проекта Moleculer
В этом примере мы используем официальный [консольную программу Moleculer CLI](moleculer-cli.html) для создания нового микросервисного проекта с сервисом и API шлюзом для вызова его из браузера через REST API.

1. Установите `moleculer-cli` глобально
    ```bash
    $ npm i moleculer-cli -g
    ```
2. Создать новый проект (с именем `moleculer-demo`)
    ```bash
    $ moleculer init project moleculer-demo
    ```
 <div align="center"><img src="assets/usage/usage-demo-1.gif" /></div>

    > Press `ENTER` to all questions _(accept default answers)_    
    
    {% note warn %}
    Don't forget to install and start [NATS Server](https://docs.nats.io/nats-server/installation). Иначе вы получите следующую ошибку:
    `NATS error. Could not connect to server: Error: connect ECONNREFUSED 127.0.0.1:4222`
    {% endnote %}

3. Откройте папку проекта
    ```bash
    $ cd moleculer-demo
    ```

4. Запустите проект
    ```bash
    $ npm run dev
    ```


<div align="center">
  <img src="assets/usage/usage-demo-2.gif" />
</div>

5. Откройте ссылку [http://localhost:3000/](http://localhost:3000/) в вашем браузере. Он покажет стартовую страницу, которая содержит две ссылки для вызова службы `greeter` через [API шлюз](https://github.com/moleculerjs/moleculer-web).

{% note info Поздравляем! %}
Вы только что создали свой первый проект на основе микросервисов Moleculer! Далее посмотрите страницу [основы работы](concepts.html) Moleculer, чтобы познакомиться с ними и посмотреть, как они взаимодействуют друг с другом. Или изучите наши [примеры](examples.html) и [демо проекты](https://github.com/moleculerjs/moleculer-examples).
{% endnote %}

Вы также можете посмотреть видео ниже, в котором объясняются устройство только что созданного проекта. <iframe width="730" height="410" src="https://www.youtube.com/embed/t4YR6MWrugw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen mark="crwd-mark"></iframe>


# Moleculer демонстрационная площадка
Если вы не хотите устанавливать на свой компьютер [moleculer-demo](usage.html#Create-a-Moleculer-project), то вы можете использовать интерактивную игровую площадку. <iframe src="https://codesandbox.io/embed/github/moleculerjs/sandbox-moleculer-project/tree/master/?fontsize=14" title="moleculer-project" allow="geolocation; microphone; camera; midi; vr; accelerometer; gyroscope; payment; ambient-light-sensor; encrypted-media" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin" mark="crwd-mark"></iframe>
