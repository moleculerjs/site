title: Testing

---

Writing (unit) tests is a crucial part of software development as it ensures that all of the components of our application work as expected. This page covers how to test a typical Moleculer-based application.

{% note info Testing Frameworks %}
Please note that we use [Jest](https://jestjs.io/) for testing. However, you can also use any other testing framework that offers the same capabilities.
{% endnote %}

## Common File Structure

The snippet code presented bellow is a skeleton file structure for writing unit tests for a Moleculer service.

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

To test the service two things are `required`: the `ServiceBroker` class and the schema of the service that is going to be tested. Next thing to do is to create a instance of `ServiceBroker` and, after that, create the actual instance of the service. Then Jest's `beforeAll()` helper function is used that starts the service broker and, after all tests are complete, the broker is stopped with the `afterAll()`.

With this setup in place we are ready to write the actual tests.

> TIP: Disable the logs, by passing `logger` to `false` params during `broker` creation, to avoid polluting the console.

## Unit Tests

### Actions

A typical (yet very simplistic) action looks like the one presented in the snippet bellow:

```js
// services/helper.service.js
module.exports = {
    name: "helper",

    actions: {
        toUpperCase: {
            params: {
                name: "string"
            },
            handler(ctx) {
                this.broker.emit("name.uppercase", ctx.params.name);

                return ctx.params.name.toUpperCase();
            }
        }
    }
};
```

The `toUpperCase` action of `helper` service receives a parameter `name` as input and, as a result, it return the uppercase `name`. This action also emits an `name.uppercase` every time it's called. Moreover, the `toUpperCase` has some parameter validation, it only accepts `name` parameter if it's a string. So for the `toUpperCase` action there are three things that could be tested: the output value that it produces, if it emits an event and the validation.

```js
const { ServiceBroker } = require("moleculer");
const { ValidationError } = require("moleculer").Errors;
// Load `helper` service schema
const HelperSchema = require("../../services/helper.service");

describe("Test 'helper' actions", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'helper.toUpperCase' action", () => {
        it("should reject an ValidationError", async () => {
            const result = await broker.call("helper.toUpperCase", {
                name: "John"
            });

            expect(result).toBe("JOHN");
        });

        it("should reject an ValidationError", async () => {
            expect.assertions(1);
            try {
                await broker.call("helper.toUpperCase", { name: 123 });
            } catch (err) {
                expect(err).toBeInstanceOf(ValidationError);
            }
        });

        it("should emit 'helper.toUpperCase' event ", async () => {
            expect.assertions(2);

            // Mock the emit method
            broker.emit = jest.fn();

            // Call the action
            await broker.call("helper.toUpperCase", { name: "john" });

            // Check if it was called
            expect(broker.emit).toBeCalledTimes(1);
            expect(broker.emit).toHaveBeenCalledWith("name.uppercase", "john");

            broker.emit.mockRestore();
        });
    });
});
```

### Events

```js
module.exports = {
    name: "helper",

    /** actions **/

    events: {
        async "helper.sum"(ctx) {
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

```js
describe("Test 'helper' events", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'helper.sum' event", () => {
        it("should call the event handler", async () => {
            service.sum = jest.fn();

            await service.emitLocalEventHandler("helper.sum", { a: 5, b: 5 });
            expect(service.sum).toBeCalledTimes(1);
            expect(service.sum).toBeCalledWith(5, 5);

            service.sum.mockRestore();
        });
    });
});
```

### Methods

```js
module.exports = {
    name: "helper",

    /** actions, events **/

    methods: {
        sum(a, b) {
            return a + b;
        }
    }
};
```

```js
describe("Test 'helper' methods", () => {
    let broker = new ServiceBroker({ logger: false });
    let service = broker.createService(HelperSchema);
    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'sum' method", () => {
        it("should add two numbers", () => {
            // Make a direct call the "sum"
            const result = service.sum(1, 2);

            expect(result).toBe(3);
        });
    });
});
```

### Local Variables

```js
module.exports = {
    name: "helper",

    /** actions, events, methods **/

    created() {
        this.someValue = 123;
    }
};
```

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

### Services

```js
// users.service.js
module.exports = {
    name: "users",

    actions: {
        notify: {
            handler(ctx) {
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

```js
const { ServiceBroker } = require("moleculer");
const UsersSchema = require("../../services/users.service");
const MailSchema = require("../../services/mail.service");

describe("Test 'users' service", () => {
    let broker = new ServiceBroker({ logger: false });
    let usersService = broker.createService(UsersSchema);

    const fakeSend = jest.fn(() => Promise.resolve("Fake Mail Sent"));
    MailSchema.actions.send = fakeSend;
    let mailService = broker.createService(MailSchema);

    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'users.notify' action", () => {
        it("should notify the user", async () => {
            //expect.assertions(2);

            let result = await broker.call("users.notify");

            expect(result).toBe("Fake Mail Sent");
            expect(fakeSend).toBeCalledTimes(1);
        });
    });
});
```

### API Gateway

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

                whitelist: ["**"],

                aliases: {
                    "GET users/status": "users.status"
                }
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
            handler(ctx) {
                // Check the status
                return { status: "Active" };
            }
        }
    }
};
```

```js
process.env.PORT = 0; // Use random ports

const request = require("supertest");
const { ServiceBroker } = require("moleculer");
// Load service schemas
const APISchema = require("../../services/api.service");
const UsersSchema = require("../../services/users.service");

describe("Test 'api' endpoints", () => {
    let broker = new ServiceBroker({ logger: false });
    // create services
    let usersService = broker.createService(UsersSchema);
    let apiService = broker.createService(APISchema);

    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    it("test '/api/users/status'", async () => {
        return request(apiService.server)
            .get("/api/users/status")
            .then(res => {
                expect(res.body).toEqual({ status: "Active" });
            });
    });

    it("test '/api/unknown'", async () => {
        return request(apiService.server)
            .get("/api/unknown")
            .then(res => {
                expect(res.statusCode).toBe(404);
            });
    });
});
```

### DB Adapters

```js
const DbService = require("moleculer-db");

module.exports = {
    name: "users",

    mixins: [DbService],

    actions: {
        create: {
            handler(ctx) {
                return this.adapter.insert(ctx.params);
            }
        }
    }
};
```

```js
const { ServiceBroker } = require("moleculer");
const UsersSchema = require("../../services/users.service");
const MailSchema = require("../../services/mail.service");

describe("Test 'users' service", () => {
    let broker = new ServiceBroker({ logger: false });
    let usersService = broker.createService(UsersSchema);

    const fakeSend = jest.fn(params =>
        Promise.resolve({ id: 123, name: params.name })
    );

    beforeAll(() => broker.start());
    afterAll(() => broker.stop());

    describe("Test 'users.create' action", () => {
        it("should create new user", async () => {
            expect.assertions(1);

            usersService.adapter.insert = fakeSend;

            let result = await broker.call("users.create", { name: "John" });

            expect(result).toEqual({ id: 123, name: "John" });
        });
    });
});
```
