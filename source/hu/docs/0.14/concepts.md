title: Alapfogalmak
---

Ez az útmutató minden Moleculer alkalmazás alapfogalmait tartalmazza.

## Szolgáltatás
A [szolgáltatás](services.html) egy egyszerű JavaScript modul, amely egy komplex alkalmazás egy részét tartalmazza. Elszigetelt és önálló, ami azt jelenti, hogy még ha le is áll vagy összeomlik, a többi szolgáltatást ez nem érinti.

## Csomópont
A csomópont egy helyi vagy külső hálózaton futó egyszerű operációs rendszerfolyamat. Egy csomópont egyetlen példánya egy vagy több szolgáltatásnak is otthont adhat.

### Helyi szolgáltatások
Az egy csomóponton futó két (vagy több) szolgáltatás helyi szolgáltatásnak minősül. Megosztják a hardver erőforrásokat, és a helyi buszon kommunikálnak egymással, nincs hálózati késleltetés (a [transzportert](#Transporter) nem használják).

### Távoli szolgáltatások
A több csomóponton elosztott szolgáltatások távoli szolgáltatásnak minősülnek. Ebben az esetben a kommunikáció [transzporteren](#Transporter) keresztül történik.

## Service Broker
A [Service Broker](broker.html) a Moleculer szíve. Felelős a szolgáltatások (helyi és távoli) közötti irányításért és kommunikációért. Minden csomópontnak rendelkeznie kell a Service Broker egy példányával.

## Transzporter
A [Transporter](networking.html) egy kommunikációs busz, amelyet a szolgáltatások használnak az üzenetek cseréjére. Eseményeket, kéréseket és válaszokat továbbít.

## Átjáró
Az [API Gateway](moleculer-web.html) a Moleculer szolgáltatásait tárja a végfelhasználók elé. Az átjáró egy hagyományos Moleculer szolgáltatás, amely egy (HTTP, WebSockets stb.) kiszolgálót futtat. Kezeli a bejövő kéréseket, leképezi őket szolgáltatáshívásokká, majd megfelelő válaszokat küld vissza.

## Átfogó nézet
Nincs is jobb egy példánál, hogy lássuk, hogyan illeszkednek egymáshoz ezek a fogalmak. Vegyünk tehát egy hipotetikus webáruházat, amely csak a termékeit listázza. Valójában semmit sem árul online.

### Architektúra

Architektúra szempontból az online áruház 2 független szolgáltatás kompozíciójának tekinthető: a `termékszolgáltatás` és az `átjáró` szolgáltatás. Az első a termékek tárolásáért és kezeléséért felelős, míg a második egyszerűen fogadja a felhasználók kéréseit, és továbbítja azokat a `termékszolgáltatásnak`.

Most nézzük meg, hogyan hozható létre ez a feltételezett áruház a Moleculer segítségével.

Annak érdekében, hogy rendszerünk ellenálló legyen a hibákkal szemben, a `termékeket` és az `átjáró` szolgáltatásokat dedikált [csomópontokon](#Node) (`node-1` és `node-2`) fogjuk futtatni. Ha emlékszik, a szolgáltatások dedikált csomópontokon történő futtatása azt jelenti, hogy a szolgáltatások közötti kommunikációhoz a [transzporter](#Transporter) modulra van szükség. A Moleculer által támogatott legtöbb transzporter egy üzenetközvetítőre támaszkodik a szolgáltatások közötti kommunikációhoz, ezért szükségünk lesz egy ilyen modulra. Összességében a tárolónk belső architektúráját az alábbi ábra mutatja be.

Feltételezve, hogy a szolgáltatásaink működnek, az online áruház kiszolgálhatja a felhasználók kéréseit. Lássuk tehát, mi történik valójában egy olyan kérés esetén, amely az összes elérhető termék listázására irányul. Először is, a kérést (`GET /products`) a `node-1` csomóponton futó HTTP-kiszolgáló fogadja. A beérkező kérést a HTTP-kiszolgáló egyszerűen továbbítja a [gateway](#Gateway) szolgáltatásnak, amely elvégzi az összes feldolgozást és leképezést. Ebben az esetben a felhasználó kérését a `products` szolgáltatás `listProducts` műveletére képezi le.  Ezután a kérés átkerül a [brókerhez](#Service-Broker), amely ellenőrzi, hogy a `products` szolgáltatás [helyi](#Local-Services) vagy [távoli](#Remote-Services) szolgáltatás-e. Ebben az esetben a `products` szolgáltatás távoli, így a brókernek a kérés továbbításához a [transzporter](#Transporter) modult kell használnia. A transzporter egyszerűen elkapja a kérést, és elküldi a kommunikációs buszon keresztül. Mivel mindkét csomópont (`node-1` and `node-2`) ugyanahhoz a kommunikációs buszhoz (üzenetközvetítő) csatlakozik, a kérés sikeresen kézbesítésre kerül a `node-2` számára. A fogadás után a `node-2` csomópont brókere elemzi a beérkező kérést, és továbbítja azt a `products` szolgáltatáshoz. Végül a `products` szolgáltatás meghívja a `listProducts` műveletet, és visszaküldi az összes elérhető termék listáját. A választ egyszerűen továbbítja vissza a végfelhasználónak. A választ egyszerűen továbbítja vissza a végfelhasználónak.

**Flow of user's request**
<div align="center">
    <img src="assets/overview.svg" alt="Architecture Overview" />
</div>

All the details that we've just seen might seem scary and complicated but you don't need to be afraid. Moleculer does all the heavy lifting for you! You (the developer) only need to focus on the application logic. Take a look at the actual [implementation](#Implementation) of our online store.

### Implementation
Now that we've defined the architecture of our shop, let's implement it. We're going to use NATS, an open source messaging system, as a communication bus. So go ahead and get the latest version of [NATS Server](https://nats.io/download/nats-io/nats-server/). Run it with the default settings. You should get the following message:

```
[18141] 2016/10/31 13:13:40.732616 [INF] Starting nats-server version 0.9.4
[18141] 2016/10/31 13:13:40.732704 [INF] Listening for client connections on 0.0.0.0:4222
[18141] 2016/10/31 13:13:40.732967 [INF] Server is ready
```

Next, create a new directory for our application, create a new `package.json` and install the dependencies. We´re going to use `moleculer` to create our services, `moleculer-web` as the HTTP gateway and `nats` for communication. In the end your `package.json` should look like this:

```json
// package.json
{
  "name": "moleculer-store",
  "dependencies": {
    "moleculer": "^0.14.0",
    "moleculer-web": "^0.9.0",
    "nats": "^1.3.2"
  }
}
```

Finally, we need to configure the brokers and create our services. So let's create a new file (`index.js`) and do it:
```javascript
// index.js
const { ServiceBroker } = require("moleculer");
const HTTPServer = require("moleculer-web");

// Create the broker for node-1
// Define nodeID and set the communication bus
const brokerNode1 = new ServiceBroker({
  nodeID: "node-1",
  transporter: "NATS"
});

// Create the "gateway" service
brokerNode1.createService({
  // Define service name
  name: "gateway",
  // Load the HTTP server
  mixins: [HTTPServer],

  settings: {
    routes: [
      {
        aliases: {
          // When the "GET /products" request is made the "listProducts" action of "products" service is executed
          "GET /products": "products.listProducts"
        }
      }
    ]
  }
});

// Create the broker for node-2
// Define nodeID and set the communication bus
const brokerNode2 = new ServiceBroker({
  nodeID: "node-2",
  transporter: "NATS"
});

// Create the "products" service
brokerNode2.createService({
  // Define service name
  name: "products",

  actions: {
    // Define service action that returns the available products
    listProducts(ctx) {
      return [
        { name: "Apples", price: 5 },
        { name: "Oranges", price: 3 },
        { name: "Bananas", price: 2 }
      ];
    }
  }
});

// Start both brokers
Promise.all([brokerNode1.start(), brokerNode2.start()]);
```
Now run `node index.js` in your terminal and open the link [`http://localhost:3000/products`](http://localhost:3000/products). You should get the following response:
```json
[
    { "name": "Apples", "price": 5 },
    { "name": "Oranges", "price": 3 },
    { "name": "Bananas", "price": 2 }
]
```

With just a couple dozen of lines of code we've created 2 isolated services capable of serving user's requests and list the products. Moreover, our services can be easily scaled to become resilient and fault-tolerant. Impressive, right?

Head out to the [Documentation](broker.html) section for more details or check the [Examples](examples.html) page for more complex examples.