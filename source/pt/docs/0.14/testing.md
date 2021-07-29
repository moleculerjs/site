title: Testes

---

A implementação de testes (unitários) é uma parte crucial do desenvolvimento de software, pois garante que todos os componentes de uma aplicação funcionem conforme o esperado. Esta página cobre como testar uma aplicação típica baseada em Moleculer.

{% note info Frameworks de Teste %}
Por favor, note que usamos o [Jest](https://jestjs.io/) para testar. No entanto, você também pode usar qualquer outro framework de teste que ofereça as mesmas capacidades.
{% endnote %}

## Estrutura de arquivo comum

O trecho apresentado abaixo é o esqueleto de uma estrutura para escrever testes unitários para um serviço Moleculer.

```js
const { ServiceBroker } = require("moleculer");
// Load service schema
const ServiceSchema = require("../../services/<SERVICE-NAME>.service");

describe("Test '<SERVICE-NAME>'", () => {
    // Create a service broker
    let broker = new ServiceBroker({ logger: false });
    // Create the actual service
    let service = broker.createService(ServiceSchema);

    // Start the broker. It will also init the service
    beforeAll(() => broker.start());
    // Gracefully stop the broker after all tests
    afterAll(() => broker.stop());

    /** Tests go here **/
});
```

Para testar o serviço, duas coisas são `obrigatórias`: a classe `ServiceBroker` e o esquema do serviço que será testado. Em seguida, o que precisa ser feito é criar uma instância do `ServiceBroker` e, depois disso, criar a instância atual do serviço. Então a função auxiliar `beforeAll()` do Jest é usada para iniciar o broker e, depois que todos os testes forem concluídos, o broker é parado com o `afterAll()`.

Com esta configuração posicionada, estamos prontos para escrever os testes de fato.

> DICA: Desative os logs, definindo `logger` como `false` durante a criação do `broker`, para evitar poluir o console.

## Testes unitários

### Ações

#### Simples

Uma [ação](actions.html) típica (porém muito simplista) se parece com a apresentada abaixo:

```js
// services/helper.service.js
module.exports = {
    name: "helper",

    actions: {
        toUpperCase: {
            // Add param validation
            params: {
                name: "string"
            },
            handler(ctx) {
                // Emit an event
                ctx.emit("name.uppercase", ctx.params.name);

                return ctx.params.name.toUpperCase();
            }
        }
    }
};
```

A ação `toUpperCase` do serviço `helper` recebe um parâmetro `name` como entrada e, como um resultado, retorna o `name` maiúsculo. Essa ação também emite um evento (`name.uppercase`) toda vez que é chamado. Além disso, o `toUpperCase` tem uma validação de parâmetro, ele só aceita o parâmetro `name` se for uma string. Então para a ação `toUpperCase` há três coisas que podem ser testadas: o valor de saída que ela produz, se emite um evento e o parâmetro de validação.

**Testes unitários para as ações do serviço `helper`**

```js
const { ServiceBroker, Context } = require("moleculer");
const { ValidationError } = require("moleculer").Errors;
// Load `helper` service schema
const HelperSchema = require("../../services/helper.service");

describe("Test 'helper' actions", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'helper.toUpperCase' action", () => {
        it("should return uppercase name", async () => {
            // call the action
            const result = await broker.call("helper.toUpperCase", {
                name: "John"
            });

            // Check the result
            expect(result).toBe("JOHN");
        });

        it("should reject with a ValidationError", async () => {
            expect.assertions(1);
            try {
                await broker.call("helper.toUpperCase", { name: 123 });
            } catch (err) {
                // Catch the error and see if it's a Validation Error
                expect(err).toBeInstanceOf(ValidationError);
            }
        });

        it("should emit 'name.uppercase' event ", async () => {
            // Spy on context emit function
            jest.spyOn(Context.prototype, "emit");

            // Call the action
            await broker.call("helper.toUpperCase", { name: "john" });

            // Check if the "emit" was called
            expect(Context.prototype.emit).toBeCalledTimes(1);
            expect(Context.prototype.emit).toHaveBeenCalledWith(
                "name.uppercase",
                "john"
            );
        });
    });
});
```

#### Adaptadores DB

Algumas ações persistem os dados que elas recebem. Para testar tais ações é necessário simular (mock, em inglês) o [adaptador do banco](moleculer-db.html). O exemplo abaixo mostra como fazer isso:

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "users",
    // Load the DB Adapter
    // It will add "adapter" property to the "users" service
    mixins: [DbService],

    actions: {
        create: {
            handler(ctx) {
                // Use the "adapter" to store the data
                return this.adapter.insert(ctx.params);
            }
        }
    }
};
```

**Testes unitários para as ações do serviço `users` com banco de dados**

```js
const { ServiceBroker } = require("moleculer");
const UsersSchema = require("../../services/users.service");
const MailSchema = require("../../services/mail.service");

describe("Test 'users' service", () => {
    let broker = new ServiceBroker({ logger: false });
    let usersService = broker.createService(UsersSchema);

    // Create a mock insert function
    const mockInsert = jest.fn(params =>
        Promise.resolve({ id: 123, name: params.name })
    );

    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'users.create' action", () => {
        it("should create new user", async () => {
            // Replace adapter's insert with a mock
            usersService.adapter.insert = mockInsert;

            // Call the action
            let result = await broker.call("users.create", { name: "John" });

            // Check the result
            expect(result).toEqual({ id: 123, name: "John" });
            // Check if mock was called
            expect(mockInsert).toBeCalledTimes(1);
            expect(mockInsert).toBeCalledWith({ name: "John" });
        });
    });
});
```

### Eventos

[Eventos](events.html) são complicados para testar porque são chamados e esquecidos, ou seja, eles não retornam nenhum valor. No entanto, é possível testar o comportamento "interno" de um evento. Para esse tipo de testes a classe `Service` implementa uma função auxiliar chamada `emitLocalEventHandler` que permite chamar o manipulador de eventos diretamente.

```js
module.exports = {
    name: "helper",

    events: {
        async "helper.sum"(ctx) {
            // Calls the sum method
            return this.sum(ctx.params.a, ctx.params.b);
        }
    },

    methods: {
        sum(a, b) {
            return a + b;
        }
    }
};
```

**Testes unitários para os eventos do serviço `helper`**

```js
describe("Test 'helper' events", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'helper.sum' event", () => {
        it("should call the event handler", async () => {
            // Mock the "sum" method
            service.sum = jest.fn();

            // Call the "helper.sum" handler
            await service.emitLocalEventHandler("helper.sum", { a: 5, b: 5 });
            // Check if "sum" method was called
            expect(service.sum).toBeCalledTimes(1);
            expect(service.sum).toBeCalledWith(5, 5);

            // Restore the "sum" method
            service.sum.mockRestore();
        });
    });
});
```

### Métodos

Os [métodos](services.html#Methods) são funções privadas que estão disponíveis apenas no escopo do serviço. Isso significa que não é possível chamá-los de outros serviços ou usar o broker para fazer isso. Portanto, para testar um determinado método, precisamos de chamá-lo diretamente da instância de serviço que o implementa.

```js
module.exports = {
    name: "helper",

    methods: {
        sum(a, b) {
            return a + b;
        }
    }
};
```

**Testes unitários para os métodos do serviço `helper`**

```js
describe("Test 'helper' methods", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'sum' method", () => {
        it("should add two numbers", () => {
            // Make a direct call of "sum" method
            const result = service.sum(1, 2);

            expect(result).toBe(3);
        });
    });
});
```

### Variáveis Locais

Assim como os [métodos](#Methods), [variáveis locais](services.html#Local-Variables) também estão disponíveis somente no escopo do serviço. Isto significa que, para testá-los, temos de utilizar a mesma estratégia que é utilizada nos testes de método.

```js
module.exports = {
    name: "helper",

    /** actions, events, methods **/

    created() {
        this.someValue = 123;
    }
};
```

**Unit tests for the `helper` service local variables**

```js
describe("Test 'helper' local variables", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    it("should init 'someValue'", () => {
        expect(service.someValue).toBe(123);
    });
});
```

## Integration Tests

Integration tests involve testing two (or more) services to ensure that the interactions between them work properly.

### Serviços

Situations when one service depends on another one are very common. The example bellow shows that `notify` action of `users` service depends on the `mail` service. This means that to test the `notify` action we need to mock the `send` action of `email` service.

```js
// users.service.js
module.exports = {
    name: "users",

    actions: {
        notify: {
            handler(ctx) {
                // Depends on "mail" service
                return ctx.call("mail.send", { message: "Hi there!" });
            }
        }
    }
};
```

```js
// mail.service.js
module.exports = {
    name: "mail",

    actions: {
        send: {
            handler(ctx) {
                // Send email...
                return "Email Sent";
            }
        }
    }
};
```

**Integration tests for `users` service**

```js
const { ServiceBroker } = require("moleculer");
const UsersSchema = require("../../services/users.service");
const MailSchema = require("../../services/mail.service");

describe("Test 'users' service", () => {
    let broker = new ServiceBroker({ logger: false });
    let usersService = broker.createService(UsersSchema);

    // Create a mock of "send" action
    const mockSend = jest.fn(() => Promise.resolve("Fake Mail Sent"));
    // Replace "send" action with a mock in "mail" schema
    MailSchema.actions.send = mockSend;
    // Start the "mail" service
    let mailService = broker.createService(MailSchema);

    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'users.notify' action", () => {
        it("should notify the user", async () => {
            let result = await broker.call("users.notify");

            expect(result).toBe("Fake Mail Sent");
            // Check if mock was called
            expect(mockSend).toBeCalledTimes(1);
        });
    });
});
```

### API Gateway

The logic that our services implement is also usually available via [API gateway](moleculer-web.html). This means that we also need to write integration tests for the API gateway. The example bellows show to to it:

{% note info Testing Frameworks %}
Please note that for the API gateway tests we use [supertest](https://github.com/visionmedia/supertest). Again, this is not mandatory and you can use any other tool that offers the same capabilities.
{% endnote %}

```js
// api.service.js
const ApiGateway = require("moleculer-web");

module.exports = {
    name: "api",
    mixins: [ApiGateway],

    settings: {
        port: process.env.PORT || 3000,
        routes: [
            {
                path: "/api",

                whitelist: ["**"]
            }
        ]
    }
};
```

```js
// users.service.js
module.exports = {
    name: "users",

    actions: {
        status: {
            // Make action callable via API gateway
            rest: "/users/status",
            handler(ctx) {
                // Check the status...
                return { status: "Active" };
            }
        }
    }
};
```

**API integration tests**

```js
process.env.PORT = 0; // Use random ports during tests

const request = require("supertest");
const { ServiceBroker } = require("moleculer");
// Load service schemas
const APISchema = require("../../services/api.service");
const UsersSchema = require("../../services/users.service");

describe("Test 'api' endpoints", () => {
    let broker = new ServiceBroker({ logger: false });
    let usersService = broker.createService(UsersSchema);
    let apiService = broker.createService(APISchema);

    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    it("test '/api/users/status'", () => {
        return request(apiService.server)
            .get("/api/users/status")
            .then(res => {
                expect(res.body).toEqual({ status: "Active" });
            });
    });

    it("test '/api/unknown-route'", () => {
        return request(apiService.server)
            .get("/api/unknown-route")
            .then(res => {
                expect(res.statusCode).toBe(404);
            });
    });
});
```
