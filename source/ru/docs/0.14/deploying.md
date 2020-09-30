title: Развертывание
---

## Развёртывание с помощью Docker
Приведенный ниже пример показывает, как использовать [moleculer-runner](runner.html) и Docker для развертывания служб Moleculer в нескольких контейнерах.

{% note info %}
Заметим, что moleculer-runner способен считывать переменные среды, которые широко используются при развертывании Docker. [Подробная информация о логике загрузки конфигурации](runner.html#Configuration-loading-logic).
{% endnote %}

> Docker файл из проекта [moleculer-demo](usage.html#Create-a-Moleculer-project).

### Dockerfile
Dockerfile для запуска сервисов Moleculer

```docker
FROM node:8-alpine

ENV NODE_ENV=production

RUN mkdir /app
WORKDIR /app

COPY package.json .

RUN npm install --production

COPY . .

# Execute moleculer-runner
CMD ["node", "./node_modules/moleculer/bin/moleculer-runner.js"]
```

### Docker Compose
Запуск сервисов с использованием NATS и Traefik (балансировка нагрузки на API шлюз)

Установка необходимых переменных среды. **docker-compose.env**
```bash
NAMESPACE=
LOGGER=true
LOGLEVEL=info
SERVICEDIR=services           # указывает расположение файлов сервисов

TRANSPORTER=nats://nats:4222  # установить транспорт для всех контейнеров
```

Настройка контейнеров. **docker-compose.yml**
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
      SERVICES: api # запустить только сервис 'api' в этом контейнере
      PORT: 3000    # порт для API шлюза
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
      SERVICES: greeter # запустить только сервис 'greeter' в этом контейнере
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

**Запуск контейнеров**
```bash
$ docker-compose up -d
```

Получите доступ к приложению по адресу `http://<docker-host>:3000/`. Панель управления Traefik `http://<docker-host>:3001/`

## Развертывание в Kubernetes
Члены сообщества Moleculer [работают](https://github.com/moleculerjs/moleculer/issues/512) над интеграцией Kubernetes. Вы можете проверить [пошаговую инструкцию](https://dankuida.com/moleculer-deployment-thoughts-8e0fc8c0fb07) от [dkuida](https://github.com/dkuida), [примеры кода](https://github.com/lehno/moleculer-k8s-examples) от [lehno](https://github.com/lehno) и [инструкцию по развертыванию](https://gist.github.com/tobydeh/0aa33a5b672821f777165159b6a22cc5) от [tobydeh](https://github.com/tobydeh).
