# Docker Multi-Stage Build

Name: **Archit Kulkarni**  
Enrollment number: **24BCS10194**

This application uses a multi-stage Dockerfile: the `dependencies` stage installs production packages and the small production stage receives only `node_modules`, `package.json`, and `server.js`.

## Build and run

```bash
docker build -t archit-multistage-app .
docker run -d --name archit-multistage -p 8080:8080 archit-multistage-app
docker ps --filter name=archit-multistage
curl http://localhost:8080
```

Expected application response:

```html
<h1>Hello World from Docker multi-stage build</h1>
```

Expected `docker ps` port mapping includes `0.0.0.0:8080->8080/tcp`.

## Three Docker application types

The repository also deploys the required three application types in [`../05-docker-hello-apps`](../05-docker-hello-apps): Node.js, Python, and Java. Each has a standalone Dockerfile and a documented build/run command.
