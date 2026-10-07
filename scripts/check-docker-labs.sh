#!/usr/bin/env bash
set -euo pipefail
set -x
names=()
cleanup() { for name in "${names[@]}"; do docker rm -f "$name" || true; done; }
trap cleanup EXIT
for spec in 'nodejs-app:3000:3001' 'python-app:5000:5001' 'java-app:8080:8081' 'Apache-app:80:8082' 'React-app:80:8083' 'nginx-app:80:8084'; do
  IFS=: read -r app inside outside <<< "$spec"
  tag="homework-${app,,}"
  docker build -t "$tag" "05-docker-hello-apps/$app"
  docker run -d --name "$tag" -p "127.0.0.1:$outside:$inside" "$tag"
  names+=("$tag")
  for attempt in {1..30}; do curl -fsS "http://localhost:$outside" && break || sleep 2; done
  curl -fsS "http://localhost:$outside" | tee "/tmp/$tag.html"
  if [[ "$app" == React-app ]]; then
    asset=$(sed -n 's/.*src="\([^"]*\.js\)".*/\1/p' "/tmp/$tag.html")
    curl -fsS "http://localhost:$outside$asset" | grep -o 'Hello World' | head -n 1
  else
    grep -qi 'Hello World' "/tmp/$tag.html"
  fi
done
docker build -t homework-multistage 06-docker-multistage
docker run -d --name homework-multistage -p 127.0.0.1:8080:8080 homework-multistage
names+=(homework-multistage)
sleep 3
curl -fsS http://localhost:8080
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
docker image ls 'homework-*'
docker history homework-multistage
