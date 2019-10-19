title: Deploying
---

## Docker deployment
The example below shows how to use [moleculer-runner](runner.html) and Docker to deploy Moleculer services across multiple containers.

{% note info %}
Note that moleculer-runner is capable of reading environment variables, which are heavily used in Docker deployments. [More info about runner's configuration loading logic](runner.html#Configuration-loading-logic).
{% endnote %}

> The Docker files shown here are from [moleculer-demo](usage.html#Create-a-Moleculer-project) project.

### Dockerfile
Dockerfile to run Moleculer services

```docker
FROM node:8-alpine

ENV NODE_ENV=production

RUN mkdir /app
WORKDIR /app

COPY package.json .

RUN npm install --production

COPY . .

CMD ["npm", "start"]  # Execute moleculer-runner
```

### Docker Compose
Docker compose files to run Moleculer services with NATS & Traefik (load balancing the API Gateway)

Set the necessary environment variables. **docker-compose.env**
```bash
NAMESPACE=
LOGGER=true
LOGLEVEL=info
SERVICEDIR=services           # Inform runner about the location of service files

TRANSPORTER=nats://nats:4222  # Set transporter in all containers
```

Configure the containers. **docker-compose.yml**
```yaml
version: "3.2"

services:

  api:
    build:
      context: .
    image: moleculer-demo
    container_name: moleculer-demo-api
    env_file: docker-compose.env
    environment:
      SERVICES: api # Runner will start only the 'api' service in this container
      PORT: 3000    # Port of API gateway
    depends_on:
      - nats
    labels:
      - "traefik.enable=true"
      - "traefik.backend=api"
      - "traefik.port=3000"
      - "traefik.frontend.entryPoints=http"
      - "traefik.frontend.rule=PathPrefix:/"
    networks:
      - internal

  greeter:
    build:
      context: .
    image: moleculer-demo
    container_name: moleculer-demo-greeter
    env_file: docker-compose.env
    environment:
      SERVICES: greeter # Runner will start only the 'greeter' service in this container
    labels:
      - "traefik.enable=false"
    depends_on:
      - nats
    networks:
      - internal

  nats:
    image: nats
    labels:
      - "traefik.enable=false"
    networks:
      - internal

  traefik:
    image: traefik:1.7
    container_name: traefik
    command:
      - "--api"
      - "--docker"
      - "--docker.watch"
    labels:
      - "traefik.enable=true"
      - "traefik.backend=traefik"
      - "traefik.port=8080"
    ports:
      - 3000:80
      - 3001:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /dev/null:/traefik.toml
    networks:
      - internal
      - default

networks:
  internal:

```

**Start containers**
```bash
$ docker-compose up -d
```

Access your app on `http://<docker-host>:3000/`. Traefik dashboard UI on `http://<docker-host>:3001/`

## Kubernetes deployment
Moleculer community members are [working on](https://github.com/moleculerjs/moleculer/issues/512) Kubernetes integration. You can check [dkuida](https://github.com/dkuida)'s [step by step tutorial](https://dankuida.com/moleculer-deployment-thoughts-8e0fc8c0fb07), [lehno](https://github.com/lehno)'s [code samples](https://github.com/lehno/moleculer-k8s-examples) and [tobydeh](https://github.com/tobydeh)'s [deployment guide](https://gist.github.com/tobydeh/0aa33a5b672821f777165159b6a22cc5).
