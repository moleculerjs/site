title: Testing

---

Writing (unit) tests is a crucial part of software development as it ensures that all the components of an application work as expected. This page covers how to test a typical Moleculer-based application.

{% note info Testing Frameworks %}
Please note that we use [Jest](https://jestjs.io/) for testing. However, you can also use any other testing framework that offers the same capabilities.
{% endnote %}

## Common File Structure

The snippet presented bellow is a skeleton structure for writing unit tests for a Moleculer service.

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

To test the service two things are `required`: the `ServiceBroker` class and the schema of the service that is going to be tested. Next thing to do is to create an instance of `ServiceBroker` and, after that, create the actual instance of the service. Then Jest's `beforeAll()` helper function is used to start the service broker and, after all tests are complete the broker is stopped with the `afterAll()`.

With this setup in place we are ready to write the actual tests.

> TIP: Disable the logs, by setting `logger` to `false` during `broker` creation, to avoid polluting the console.

## Unit Tests

### Действия

#### Простой пример

A typical (yet very simplistic) [action](actions.html) looks like the one presented bellow:

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

The `toUpperCase` action of `helper` service receives a parameter `name` as input and, as a result, returns the uppercase `name`. This action also emits an (`name.uppercase`) event every time it's called. Moreover, the `toUpperCase` has some parameter validation, it only accepts `name` parameter if it's a string. So for the `toUpperCase` action there are three things that could be tested: the output value that it produces, if it emits an event and the parameter validation.

**Unit tests for the `helper` service actions**

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

#### Адаптеры БД

Some actions persist the data that they receive. To test such actions it is necessary to mock the [DB adapter](moleculer-db.html). The example below shows how to do it:

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

**Unit tests for the `users` service actions with DB**

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

### События

[Events](events.html) are tricky to test as they are fire-and-forget, i.e., they don't return any values. However, it is possible to test the "internal" behavior of an event. For this kind of tests the `Service` class implements a helper function called `emitLocalEventHandler` that allows to call the event handler directly.

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

**Unit tests for the `helper` service events**

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

### Methods

[Methods](services.html#Methods) are private functions that are only available within the service scope. This means that it's not possible to call them from other services or use the broker to do it. So to test a certain method we need to call it directly from the service instance that implements it.

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

**Unit tests for the `helper` service methods**

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

### Local Variables

Just as [methods](#Methods), [local variables](services.html#Local-Variables) are also only available within the service scope. This means that to test them we need to use the same strategy that is used in methods tests.

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

### Сервисы

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

### Шлюз API

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
