title: Развертывание
---

## Развёртывание с помощью Docker
Приведенный ниже пример показывает, как использовать [moleculer-runner](runner.html) и Docker для развертывания служб Moleculer в нескольких контейнерах.

{% note info %}
Заметим, что moleculer-runner способен считывать переменные среды, которые широко используются при развертывании Docker. [Подробная информация о логике загрузки конфигурации](runner.html#Configuration-loading-logic).
{% endnote %}

> Docker файл из проекта [moleculer-demo](usage.html#Create-a-Moleculer-project).

> For mode detailed info about Docker and Kubernetes please check the [docker demo](https://github.com/moleculerjs/docker-demo) repository.

### Dockerfile
Dockerfile для запуска сервисов Moleculer

```docker
FROM node:current-alpine

ENV NODE_ENV=production

RUN mkdir /app
WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install --production

COPY . .

CMD ["npm", "start"]
```

### Docker Compose
Запуск сервисов с использованием NATS и Traefik (балансировка нагрузки на API шлюз)

Установка необходимых переменных среды. **docker-compose.env**
```bash
NAMESPACE=
LOGGER=true
LOGLEVEL=info
SERVICEDIR=services # Inform moleculer runner about the location of service files

TRANSPORTER=nats://nats:4222 # Set transporter in all containers
MONGO_URI=mongodb://mongo/project-demo # Set MongoDB URI

```

Настройка контейнеров. **docker-compose.yml**
```yaml
version: "3.3"

services:

  api:
    build:
      context: .
    image: project-demo
    env_file: docker-compose.env
    environment:
      SERVICES: api # Moleculer Runner will start only the 'api' service in this container
      PORT: 3000    # Port of API gateway
    depends_on:
      - nats
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api-gw.rule=PathPrefix(`/`)"
      - "traefik.http.services.api-gw.loadbalancer.server.port=3000"
    networks:
      - internal

  greeter:
    build:
      context: .
    image: project-demo
    env_file: docker-compose.env
    environment:
      SERVICES: greeter # Moleculer Runner will start only the 'greeter' service in this container
    depends_on:
      - nats
    networks:
      - internal

  products:
    build:
      context: .
    image: project-demo
    env_file: docker-compose.env
    environment:
      SERVICES: products # Moleculer Runner will start only the 'products' service in this container
    depends_on:
      - mongo
      - nats
    networks:
      - internal

  mongo:
    image: mongo:4
    volumes:
      - data:/data/db
    networks:
      - internal

  nats:
    image: nats:2
    networks:
      - internal

  traefik:
    image: traefik:v2.1
    command:
      - "--api.insecure=true" # Don't do that in production!
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
    ports:
      - 3000:80
      - 3001:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - internal
      - default

networks:
  internal:

volumes:
  data:
```

**Запуск контейнеров**
```bash
$ docker-compose up -d
```

Получите доступ к приложению по адресу `http://<docker-host>:3000/`. Панель управления Traefik `http://<docker-host>:3001/`

## Развертывание в Kubernetes
Члены сообщества Moleculer [работают](https://github.com/moleculerjs/moleculer/issues/512) над интеграцией Kubernetes. Вы можете проверить [пошаговую инструкцию](https://dankuida.com/moleculer-deployment-thoughts-8e0fc8c0fb07) от [dkuida](https://github.com/dkuida), [примеры кода](https://github.com/lehno/moleculer-k8s-examples) от [lehno](https://github.com/lehno) и [инструкцию по развертыванию](https://gist.github.com/tobydeh/0aa33a5b672821f777165159b6a22cc5) от [tobydeh](https://github.com/tobydeh).
