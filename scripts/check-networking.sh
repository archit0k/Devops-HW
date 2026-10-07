#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
scratch=$(mktemp -d)
cp -a 07-docker-networking-volumes/. "$scratch/"
export MYSQL_ROOT_PASSWORD="$(openssl rand -hex 16)"
compose() { docker compose -p homework8 -f "$scratch/docker-compose.yml" "$@"; }
cleanup() { compose down -v; sudo service apache2 stop; }
trap cleanup EXIT
set -x
compose up -d
for attempt in $(seq 1 60); do
  if docker exec homework-database sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqladmin ping -uroot --silent'; then break; fi
  [[ "$attempt" -lt 60 ]] || exit 1
  sleep 2
done
compose ps
docker network ls
docker inspect homework-backend --format '{{json .NetworkSettings.Networks}}'
docker exec homework-backend ping -c 2 homework-frontend
docker exec homework-backend ping -c 2 homework-database
docker exec homework-backend nc -z -w 5 homework-database 3306
if docker exec homework-frontend getent hosts homework-database; then
  echo 'Isolation failed: frontend unexpectedly resolved database'; exit 1
else
  echo 'Isolation verified: frontend has no database-network DNS entry'
fi
curl --retry 5 --retry-connrefused --retry-delay 2 -fsS http://localhost:8090
started=$(docker inspect homework-frontend --format '{{.State.StartedAt}}')
sed -i 's/Hello students/Hello students - Archit Kulkarni - 24BCS10194/' "$scratch/frontend/index.html"
# Mounting the directory also supports editors that save by replacing the file.
docker exec homework-frontend cat /usr/share/nginx/html/index.html
curl -fsS http://localhost:8090 | grep 'Archit Kulkarni'
test "$started" = "$(docker inspect homework-frontend --format '{{.State.StartedAt}}')"
echo 'Bind mount updated without a container restart'
sudo apt-get update -qq
sudo apt-get install -y apache2
sudo service apache2 start
curl -fsS http://localhost:80 | grep 'Apache2 Ubuntu Default Page'
docker run --rm --network host alpine:3.21 wget -qO- http://127.0.0.1:80 | grep 'Apache2 Ubuntu Default Page'
echo 'Host-network container reached Apache installed on the Linux host'
