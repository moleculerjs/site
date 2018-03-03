title: Docker
---

## Dockerfile to run Moleculer services

```docker
FROM node:8-alpine

RUN mkdir /app
WORKDIR /app

COPY package.json .

RUN npm install --production

COPY . .

CMD ["npm", "start"]
```

## Docker Compose file to run Moleculer services with NATS & Traefik (load balancing the API Gateway)
```yaml
version: "3.0"

services:
  # API Gateway
  www:
    image: moleculer-app
    env_file: env
    environment:
      NODEID: "node-www"
      SERVICES: www
      PORT: 4000
    links:
      - nats
      - redis
    depends_on:
      - nats
      - redis
    labels:
      - "traefik.enable=true"   
      - "traefik.backend=www"
      - "traefik.port=4000"
      - "traefik.frontend.entryPoints=http"
      - "traefik.frontend.rule=PathPrefix:/"

  # Posts service
  posts:
    image: moleculer-app
    env_file: env
    environment:
      NODEID: "node-posts"
      SERVICES: posts
    links:
      - nats
      - redis
      - mongo
    depends_on:
      - nats
      - redis
      - mongo

  # Users service
  users:
    image: moleculer-app
    env_file: env
    environment:
      NODEID: "node-users"
      SERVICES: users
    links:
      - nats
      - redis
      - mongo
    depends_on:
      - nats
      - redis
      - mongo

  # NATS server
  nats:
    image: nats

  # Redis server
  redis:
    image: redis:alpine

  # MongoDB server
  mongo:
    image: mongo
    volumes:
      - ../../db:/data/db

  # Traefik server
  traefik:
    image: traefik
    command: --web --docker --docker.domain=docker.localhost --logLevel=INFO --docker.exposedbydefault=false
    ports:
      - "3000:80"
      - "3001:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /dev/null:/traefik.toml
```

**Start containers**
```bash
$ docker-compose up -d
```

You can access your app on `http://<docker-host>/`. Traefik dashboard UI on `http://<docker-host>:8080/`
