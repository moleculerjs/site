title: Deploy
---

## Implementação do Docker
O exemplo abaixo mostra como usar [moleculer-runner](runner.html) e Docker para implantar serviços Moleculer em vários contêineres.

{% note info %}
Note que moleculer-runner é capaz de ler variáveis de ambiente, que são muito usadas nas implantações do Docker. [Mais informações sobre a lógica de carregamento da configuração do runner](runner.html#Configuration-loading-logic).
{% endnote %}

> Os arquivos Docker exibidos aqui são do projeto [moleculer-demo](usage.html#Create-a-Moleculer-project).

### Dockerfile
Dockerfile para executar os serviços do Moleculer

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
Arquivos Docker Compose para executar serviços Moleculer com NATS & Traefik (Balanceamento de carga na API Gateway)

Defina as variáveis de ambiente necessárias. **docker-compose.env**
```bash
NAMESPACE=
LOGGER=true
LOGLEVEL=info
SERVICEDIR=services           # Inform runner about the location of service files

TRANSPORTER=nats://nats:4222  # Set transporter in all containers
```

Configurar os contêineres. **docker-compose.yml**
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

**Iniciar contêineres**
```bash
$ docker-compose up -d
```

Acesse seu app em `http://<docker-host>:3000/`. Dashboard do Traefik em `http://<docker-host>:3001/`

## Implantação de Kubernetes
Membros da comunidade Moleculer estão [trabalhando na](https://github.com/moleculerjs/moleculer/issues/512) integração Kubernetes. Você pode verificar o [passo a passo](https://dankuida.com/moleculer-deployment-thoughts-8e0fc8c0fb07) do [dkuida](https://github.com/dkuida), os [códigos de exemplo](https://github.com/lehno/moleculer-k8s-examples) do [lehno](https://github.com/lehno) e o [guia de implantação](https://gist.github.com/tobydeh/0aa33a5b672821f777165159b6a22cc5) do [tobydeh](https://github.com/tobydeh).
