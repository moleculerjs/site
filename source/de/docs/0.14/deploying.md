title: Deploying
---

## Docker

### Dockerfile
This is a basic Dockerfile to run Moleculer services

```docker
FROM node:8-alpine

ENV NODE_ENV=production

RUN mkdir /app
WORKDIR /app

COPY package.json .

RUN npm install --production

COPY . .

CMD ["npm", "start"]
```

### Docker Compose

This configuration creates 4 containers:

- Moleculer API Gateway Service
- Moleculer Greeter Service
- NATS server
- Traefik for load balancing the API Gateway

```yaml
version: "3.2"

services:

  api:
    build:
      context: .
    image: moleculer-demo
    env_file: docker-compose.env
    environment:
      SERVICES: api
      PORT: 3000
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
    env_file: docker-compose.env
    environment:
      SERVICES: greeter
    depends_on:
      - nats
    networks:
      - internal

  nats:
    image: nats
    networks:
      - internal
  traefik:
    image: traefik:1.7
    command: --web --docker --docker.domain=docker.localhost --logLevel=INFO --docker.exposedbydefault=false
    ports:
      - "3000:80"
      - "3001:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /dev/null:/traefik.toml
    networks:
      - internal
      - default

networks:
  internal:
```
### Deploying

**Start containers**
```bash
$ docker-compose up -d
```

Access your app on `http://<docker-host>:3000/`. Traefik dashboard UI on `http://<docker-host>:3001/`
