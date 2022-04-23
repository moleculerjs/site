title: Deploy
---

## Implementação do Docker
O exemplo abaixo mostra como usar [moleculer-runner](runner.html) e Docker para implantar serviços Moleculer em vários contêineres.

{% note info %}
Note que moleculer-runner é capaz de ler variáveis de ambiente, que são muito usadas nas implantações do Docker. [Mais informações sobre a lógica de carregamento da configuração do runner](runner.html#Configuration-loading-logic).
{% endnote %}

> Os arquivos Docker exibidos aqui são do projeto [moleculer-demo](usage.html#Create-a-Moleculer-project).

> Para informações detalhadas sobre o modo Docker e Kubernetes por favor, verifique o repositório [docker demo](https://github.com/moleculerjs/docker-demo).

### Dockerfile
Dockerfile para executar os serviços do Moleculer

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
Arquivos Docker Compose para executar serviços Moleculer com NATS & Traefik (Balanceamento de carga na API Gateway)

Defina as variáveis de ambiente necessárias. **docker-compose.env**
```bash
NAMESPACE=
LOGGER=true
LOGLEVEL=info
SERVICEDIR=services # Inform moleculer runner about the location of service files

TRANSPORTER=nats://nats:4222 # Set transporter in all containers
MONGO_URI=mongodb://mongo/project-demo # Set MongoDB URI

```

Configurar os contêineres. **docker-compose.yml**
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

**Iniciar contêineres**
```bash
$ docker-compose up -d
```

Acesse seu app em `http://<docker-host>:3000/`. Dashboard do Traefik em `http://<docker-host>:3001/`

## Implantação de Kubernetes
Membros da comunidade Moleculer estão [trabalhando na](https://github.com/moleculerjs/moleculer/issues/512) integração Kubernetes. Você pode verificar o [passo a passo](https://dankuida.com/moleculer-deployment-thoughts-8e0fc8c0fb07) do [dkuida](https://github.com/dkuida), os [códigos de exemplo](https://github.com/lehno/moleculer-k8s-examples) do [lehno](https://github.com/lehno) e o [guia de implantação](https://gist.github.com/tobydeh/0aa33a5b672821f777165159b6a22cc5) do [tobydeh](https://github.com/tobydeh).
