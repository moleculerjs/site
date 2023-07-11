title: Exemplos
---

## Exemplos de projetos

### Servidor de backend Realworld
Esse é um exemplo de um servidor backend [RealWorld.io](https://realworld.io/) construído com o framework de microserviços Moleculer.

**Principais recursos**
- 7 microserviços
- NeDB ou banco de dados MongoDB sem Mongoose
- Login de usuário & cadastro
- Autenticação de usuário com JWT
- Cache de memória
- Arquivos do Docker

**Repo: https://github.com/moleculerjs/moleculer-examples/tree/master/conduit#readme**

### Blog
Este é um exemplo simples de blog.

**Principais recursos**
- Arquivos do Docker
- Servidor www ExpressJS com o Pug template engine
- Banco de dados MongoDB com módulos [moleculer-db](https://github.com/moleculerjs/moleculer-db) e [moleculer-db-adapter-mongoose](https://github.com/moleculerjs/moleculer-db/tree/master/packages/moleculer-db-adapter-mongoose)
- NATS transporter
- Cache Redis
- [Traefik](https://traefik.io/) proxy reverso (em micro arquitetura)
- frontend estático

**Repo: https://github.com/moleculerjs/moleculer-examples/blob/master/blog#readme**

## Exemplos curtos
O repositório principal do Moleculer contém [alguns exemplos](https://github.com/moleculerjs/moleculer/blob/master/examples/).
{% note info %}
Para experimentá-los, no início, você deve clonar o repositório Moleculer com o seguinte comando:

`git clone https://github.com/moleculerjs/moleculer.git`
{% endnote %}

### Simples
Esta é uma demonstração simples com um serviço matemático que pode `somar`, `subtrair`, `multiplicar` e `dividir ` dois números.

```bash
$ npm run demo simple
```

[O código fonte está disponível no Github](https://github.com/moleculerjs/moleculer/blob/master/examples/simple/index.js)

### Nós de servidor & cliente
Neste exemplo, você pode iniciar quaisquer servidores & clientes. Os servidores servem a ação `math.add` e os clientes a chamam em um loop. Você pode iniciar várias instâncias de ambos. *Eles usam o transporte TCP, mas você pode alterá-lo na variável de ambiente `TRANSPORTER`.*

**Iniciar um servidor**
```bash
$ node examples/client-server/server
```

**Iniciar um cliente**
```bash
$ node examples/client-server/client
```

[O código fonte está disponível no Github](https://github.com/moleculerjs/moleculer/tree/master/examples/client-server)

### Middlewares
Este exemplo demonstra como o sistema de middleware funciona.

```bash
$ npm run demo middlewares
```

[O código fonte está disponível no Github](https://github.com/moleculerjs/moleculer/blob/master/examples/middlewares/index.js)

### Runner
This example shows how you can start a broker and load services with [Moleculer Runner](./runner.html)

```bash
$ node ./bin/moleculer-runner.js -c examples/runner/moleculer.config.js -r examples/user.service.js
```
Inicia um broker com as opções contidas em `moleculer.config.js`, carrega o serviço de usuário de `user.service.js` e muda para o modo REPL.

[O código fonte está disponível no Github](https://github.com/moleculerjs/moleculer/blob/master/examples/runner)

### Teste de carga
Com este exemplo, você pode começar um teste de carga. Servidor & cliente exibem quantas solicitações foram executadas em um segundo.

**Iniciar um servidor**
```bash
$ node examples/loadtest/server
```

**Inicia & divide clientes (quantidade de núcleos do CPU)**
```bash
$ node examples/loadtest/clients
```

[O código fonte está disponível no Github](https://github.com/moleculerjs/moleculer/blob/master/examples/loadtest)
