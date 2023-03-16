title: 部署（Deploying）
---

## Docker 部署
下面的示例展示了如何使用[moleculer-runner](runner.html)和Docker在多个容器中部署Moleculer服务。

{% note info %}
请注意，moleculer-runner能够读取环境变量，这些变量在Docker部署中被大量使用。 [有关Runner配置加载逻辑的更多信息。](runner.html#Configuration-loading-logic)
{% endnote %}

> 这里显示的Docker文件来自[moleculer-demo](usage.html#Create-a-Moleculer-project)项目。

> 有关Docker和Kubernetes的更详细信息，请查看[docker demo](https://github.com/moleculerjs/docker-demo)仓库。

### Dockerfile
使用Dockerfile运行Moleculer服务

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
使用NATS和Traefik（负载平衡API网关）运行Moleculer服务的Docker compose文件

设置必要的环境变量 **docker-compose.env**
```bash
NAMESPACE=
LOGGER=true
LOGLEVEL=info
SERVICEDIR=services # 通知moleculer runner服务文件的位置

TRANSPORTER=nats://nats:4222 # 在所有容器中设置transporter 
MONGO_URI=mongodb://mongo/project-demo # 设置MongoDB URI

```

配置容器。 **docker-compose.yml**
```yaml
version: "3.3"

services:

  api:
    build:
      context: .
    image: project-demo
    env_file: docker-compose.env
    environment:
      SERVICES: api # Moleculer Runner在此容器中只会启动’api’服务
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
      SERVICES: greeter # Moleculer Runner在此容器中只会启动’greeter’服务
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
      SERVICES: products # Moleculer Runner在此容器中只会启动’products’服务
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
      - "--api.insecure=true" # 请勿在生产环境中设置
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

**Start containers**
```bash
$ docker-compose up -d
```

使用`http://<docker-host>:3000/`访问你的应用。 打开Traefik仪表盘页面`http://<docker-host>:3001/`

## Kubernetes 部署
Moleculer社区成员[正在开展](https://github.com/moleculerjs/moleculer/issues/512)Kubernetes集成的工作。 您可以查看[dkuida](https://github.com/dkuida)的[分步教程](https://dankuida.com/moleculer-deployment-thoughts-8e0fc8c0fb07)，[lehno](https://github.com/lehno)的[代码示例](https://github.com/lehno/moleculer-k8s-examples)和[tobydeh](https://github.com/tobydeh)的[部署指南](https://gist.github.com/tobydeh/0aa33a5b672821f777165159b6a22cc5)。
