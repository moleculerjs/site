title: Utilização
---
# Instalar Moleculer

Moleculer pode ser instalado com `npm` ou `yarn`.

```bash
$ npm i moleculer --save
```

# Crie o seu primeiro microsserviço
Este exemplo básico mostra como criar um pequeno serviço `math` para adicionar dois números e chamá-lo localmente.

```js
const { ServiceBroker } = require("moleculer");

// Cria um ServiceBroker
const broker = new ServiceBroker();

// Define um serviço
broker.createService({
    name: "math",
    actions: {
        add(ctx) {
            return Number(ctx.params.a) + Number(ctx.params.b);
        }
    }
});

// Inicia o broker
broker.start()
    // Chama o serviço
    .then(() => broker.call("math.add", { a: 5, b: 3 }))
    // Exibe a resposta
    .then(res => console.log("5 + 3 =", res))
    .catch(err => console.error(`Error occured! ${err.message}`));
```

{% note info Experimente em seu navegador! %}
Abra este exemplo no [Runkit!](https://runkit.com/icebob/moleculer-usage)
{% endnote %}

# Criar um projeto Moleculer
Neste exemplo, usamos a ferramenta oficial [Moleculer CLI](moleculer-cli.html) para criar um novo projeto de microsserviços baseado em Moleculer com um serviço de exemplo e uma API Gateway para chamá-lo do navegador via REST API.

1. Instale `moleculer-cli` globalmente
    ```bash
    $ npm i moleculer-cli -g
    ```
2. Criar um novo projeto (chamado `moleculer-demo`)
    ```bash
    $ moleculer init project moleculer-demo
    ```
 <div align="center"><img src="assets/usage/usage-demo-1.gif" /></div>

    > Pressione `ENTER` para todas as perguntas _(aceite as respostas sugeridas)_    
    
    {% note warn %}
    Não se esqueça de instalar e iniciar o [Servidor NATS](https://docs.nats.io/nats-server/installation). Caso contrário, você receberá o seguinte erro:
    `erro NATS. Não foi possível conectar ao servidor: Error: connect ECONNREFUSED 127.0.0.1:4222`
    {% endnote %}

3. Abrir pasta do projeto
    ```bash
    $ cd moleculer-demo
    ```

4. Iniciar projeto
    ```bash
    $ npm run dev
    ```


<div align="center">
  <img src="assets/usage/usage-demo-2.gif" />
</div>

5. Abra o link [http://localhost:3000/](http://localhost:3000/) no seu navegador. Uma página inicial será exibida contendo dois links para chamar o serviço `greeter` via [API gateway](https://github.com/moleculerjs/moleculer-web).

{% note info Parabéns! %}
Você acabou de criar seu primeiro projeto de microsserviços baseado em Moleculer! Em seguida, confira a página de [conceitos básicos do Moleculer](concepts.html) para se familiarizar com eles e ver como eles se encaixam juntos. Caso contrário, confira nossos [exemplos](examples.html) ou [projetos de demonstração](https://github.com/moleculerjs/moleculer-examples).
{% endnote %}

Você também pode verificar o vídeo abaixo que explica o funcionamento do projeto que você acabou de criar. <iframe width="730" height="410" src="https://www.youtube.com/embed/t4YR6MWrugw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen mark="crwd-mark"></iframe>


# Moleculer Demo Playground
Se você não deseja instalar [moleculer-demo](usage.html#Create-a-Moleculer-project) em seu computador, você pode usar o playground. <iframe src="https://codesandbox.io/embed/github/moleculerjs/sandbox-moleculer-project/tree/master/?fontsize=14" title="moleculer-project" allow="geolocation; microphone; camera; midi; vr; accelerometer; gyroscope; payment; ambient-light-sensor; encrypted-media" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin" mark="crwd-mark"></iframe>
