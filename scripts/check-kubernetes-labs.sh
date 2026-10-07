#!/usr/bin/env bash
set -euo pipefail
lab=${1:?assignment number required}
set -x
client() { kubectl exec lab-client -- "$@"; }
kubectl run lab-client --image=busybox:1.36 --restart=Never -- sleep 7200
kubectl wait --for=condition=Ready pod/lab-client --timeout=120s
case "$lab" in
10)
  cd session10-k8s-core-objects
  kubectl apply -f pod.yml -f hello.yml
  kubectl wait --for=condition=Ready pod/nginx-pod --timeout=120s
  kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/hello-pod --timeout=90s
  kubectl logs hello-pod
  kubectl apply -f pod-lifecycle/
  kubectl get pods -o wide
  sleep 45
  kubectl wait --for=condition=Ready pod/lifecycle-startup --timeout=90s
  kubectl get pods -o wide
  for pod in $(kubectl get pods -o name | grep lifecycle); do
    kubectl describe "$pod"
    kubectl logs "$pod" --all-containers --tail=12 || true
  done
  kubectl delete pod lifecycle-termination --wait=false
  kubectl get pod lifecycle-termination
  kubectl logs lifecycle-termination -f --pod-running-timeout=20s || true
  kubectl delete -f pod-lifecycle/ --ignore-not-found --wait=true
  kubectl apply -f replicaset.yml
  kubectl wait --for=condition=Ready pod -l app=nginx --timeout=180s
  old=$(kubectl get pod -l app=nginx -o jsonpath='{.items[0].metadata.name}')
  kubectl delete pod "$old"
  kubectl wait --for=condition=Ready pod -l app=nginx --timeout=180s
  kubectl get rs,pods -l app=nginx
  kubectl apply -f daemonset/node-agent-ds.yaml
  kubectl rollout status daemonset/node-logging-agent --timeout=120s
  kubectl get ds,pods -o wide
  set +x
  kubectl create secret generic mysql-lab-secret --from-literal="password=$(openssl rand -hex 16)"
  set -x
  kubectl apply -f k8s-core-objects/mysql-service.yml -f k8s-core-objects/statefulset.yml
  kubectl rollout status statefulset/mysql --timeout=240s
  kubectl get sts,pods,pvc,svc
  client nslookup mysql.default.svc.cluster.local
  kubectl delete -f k8s-core-objects/statefulset.yml -f k8s-core-objects/mysql-service.yml
  kubectl delete pvc -l app=mysql --ignore-not-found
  kubectl apply -f 01-rolling-update/deployment-v1.yaml -f 01-rolling-update/service.yaml
  kubectl rollout status deployment/app-rolling --timeout=180s
  client wget -qO- http://app-rolling-service
  kubectl apply -f 01-rolling-update/deployment-v2.yaml
  kubectl get pods -l app=app-rolling --show-labels
  kubectl rollout status deployment/app-rolling --timeout=180s
  client wget -qO- http://app-rolling-service
  kubectl rollout history deployment/app-rolling
  kubectl rollout undo deployment/app-rolling
  kubectl rollout status deployment/app-rolling --timeout=180s
  kubectl delete -f 01-rolling-update/deployment-v1.yaml -f 01-rolling-update/service.yaml
  kubectl apply -f 02-blue-green/deployment-blue.yaml -f 02-blue-green/deployment-green.yaml -f 02-blue-green/service-blue.yaml
  kubectl rollout status deployment/app-blue --timeout=180s
  kubectl rollout status deployment/app-green --timeout=180s
  client wget -qO- http://myapp-service
  kubectl apply -f 02-blue-green/service-green.yaml
  sleep 3
  client wget -qO- http://myapp-service
  kubectl get endpointslice -l kubernetes.io/service-name=myapp-service
  kubectl delete -f 02-blue-green/deployment-blue.yaml -f 02-blue-green/deployment-green.yaml -f 02-blue-green/service-green.yaml
  kubectl apply -f 03-canary/
  kubectl rollout status deployment/app-stable --timeout=180s
  kubectl rollout status deployment/app-canary --timeout=180s
  kubectl get pods -l app=myapp-canary --show-labels
  client sh -c 'for i in $(seq 1 60); do wget -qO- http://myapp-canary-service; done' | grep -E 'STABLE v1|CANARY v2' | sort | uniq -c
  kubectl scale deployment/app-stable --replicas=5
  kubectl scale deployment/app-canary --replicas=5
  kubectl rollout status deployment/app-canary --timeout=180s
  kubectl get deployments
  kubectl delete -f 03-canary/
  kubectl apply -f 04-recreate/deployment-v1.yaml -f 04-recreate/service.yaml
  kubectl rollout status deployment/app-recreate --timeout=180s
  client wget -qO- http://app-recreate-service
  kubectl apply -f 04-recreate/deployment-v2.yaml
  kubectl get pods -l app=app-recreate --show-labels
  kubectl rollout status deployment/app-recreate --timeout=180s
  client wget -qO- http://app-recreate-service
  kubectl get events --sort-by=.metadata.creationTimestamp
  kubectl delete -f 04-recreate/deployment-v2.yaml -f 04-recreate/service.yaml
  ;;
11)
  cd session11-kubernetes-services
  kubectl apply -f 01-clusterip/
  kubectl rollout status deployment/web-app-clusterip --timeout=180s
  client wget -qO- http://web-service-clusterip:8080
  client nslookup web-service-clusterip.default.svc.cluster.local
  kubectl apply -f 02-nodeport/
  kubectl rollout status deployment/web-app-nodeport --timeout=180s
  node_ip=$(kubectl get node assignment-control-plane -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
  curl --retry 5 --retry-connrefused --retry-delay 2 -fsS "http://$node_ip:30080"
  kubectl apply -f 03-loadbalancer/
  kubectl rollout status deployment/web-app-loadbalancer --timeout=180s
  kubectl get svc web-service-loadbalancer
  client wget -qO- http://web-service-loadbalancer
  # The LoadBalancer's external implementation is checked separately on Minikube with tunnel.
  kubectl apply -f 04-externalname/
  client nslookup external-database-service.default.svc.cluster.local
  kubectl apply -f 05-headless/
  kubectl rollout status statefulset/web-stateful --timeout=180s
  client nslookup web-service-headless.default.svc.cluster.local
  client nslookup web-stateful-0.web-service-headless.default.svc.cluster.local
  kubectl get pods,svc,endpointslice -o wide
  kubectl -n kube-system get deployment coredns
  kubectl -n kube-system get configmap coredns -o yaml
  kubectl get events --sort-by=.metadata.creationTimestamp
  ;;
12)
  cd session12-ingress-configmaps-secrets
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.2/deploy/static/provider/kind/deploy.yaml
  kubectl label node assignment-control-plane ingress-ready=true --overwrite
  kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=240s
  kubectl apply -f 04-full-demo/configmap.yaml
  bash 02-secret/create-secret.sh
  kubectl apply -f 04-full-demo/backend.yaml -f 04-full-demo/frontend.yaml
  kubectl rollout status deployment/yatri-backend --timeout=180s
  kubectl rollout status deployment/yatri-frontend --timeout=180s
  kubectl apply -f 04-full-demo/ingress.yaml
  kubectl get configmap,secret,ingress,deploy,svc,pods
  kubectl exec deployment/yatri-backend -- sh -c 'test -n "$POSTGRES_PASSWORD" && echo "Secret injected; value not printed"'
  controller=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
  for attempt in $(seq 1 30); do
    if client wget -qO- --header='Host: yatri.local' "http://$controller/"; then break; fi
    [[ "$attempt" -lt 30 ]] || exit 1
    sleep 2
  done
  client wget -qO- --header='Host: yatri.local' "http://$controller/api/"
  kubectl patch svc yatri-backend-service -p '{"spec":{"selector":{"app":"wrong-app"}}}'
  sleep 3
  kubectl get endpointslice -l kubernetes.io/service-name=yatri-backend-service
  client wget -S -O- --header='Host: yatri.local' "http://$controller/api/" || true
  kubectl patch svc yatri-backend-service -p '{"spec":{"selector":{"app":"yatri-backend"}}}'
  sleep 3
  client wget -qO- --header='Host: yatri.local' "http://$controller/api/"
  kubectl patch configmap yatri-app-config -p '{"data":{"LOG_LEVEL":"DEBUG"}}'
  kubectl rollout restart deployment/yatri-backend
  kubectl rollout status deployment/yatri-backend --timeout=120s
  kubectl exec deployment/yatri-backend -- printenv LOG_LEVEL
  kubectl delete -f 04-full-demo/ingress.yaml -f 04-full-demo/backend.yaml -f 04-full-demo/frontend.yaml -f 04-full-demo/configmap.yaml
  kubectl delete secret yatri-db-secret
  ;;
13)
  cd session13-kubernetes-storage-and-scaling
  kubectl apply -f 01-volumes/
  kubectl wait --for=condition=Ready pod/emptydir-demo pod/hostpath-demo --timeout=180s
  kubectl exec emptydir-demo -- sh -c 'echo Archit-24BCS10194 > /data/student.txt; cat /data/student.txt'
  kubectl exec hostpath-demo -- sh -c 'echo Archit-24BCS10194 > /data/student.txt; cat /data/student.txt'
  kubectl delete pod hostpath-demo
  kubectl apply -f 01-volumes/hostpath-pod.yaml
  kubectl wait --for=condition=Ready pod/hostpath-demo --timeout=120s
  kubectl exec hostpath-demo -- cat /data/student.txt
  kubectl delete pod emptydir-demo
  kubectl apply -f 01-volumes/emptydir-pod.yaml
  kubectl wait --for=condition=Ready pod/emptydir-demo --timeout=120s
  kubectl exec emptydir-demo -- sh -c 'test ! -e /data/student.txt && echo "emptyDir reset after Pod replacement"'
  kubectl apply -f 02-persistent-storage/pv.yaml -f 02-persistent-storage/pvc.yaml -f 02-persistent-storage/pod.yaml
  kubectl wait --for=condition=Ready pod/storage-demo --timeout=180s
  kubectl get pv,pvc
  kubectl exec storage-demo -- sh -c 'echo Archit-24BCS10194 > /data/student.txt'
  kubectl delete pod storage-demo
  kubectl apply -f 02-persistent-storage/pod.yaml
  kubectl wait --for=condition=Ready pod/storage-demo --timeout=120s
  kubectl exec storage-demo -- cat /data/student.txt
  kubectl apply -f 03-storageclass/pvc.yaml
  kubectl run dynamic-client --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"dynamic-client","image":"nginx:1.27","volumeMounts":[{"name":"data","mountPath":"/data"}]}],"volumes":[{"name":"data","persistentVolumeClaim":{"claimName":"dynamic-pvc"}}]}}'
  kubectl wait --for=condition=Ready pod/dynamic-client --timeout=180s
  kubectl get storageclass,pv,pvc
  kubectl apply -f 05-probes/
  kubectl get pods
  kubectl apply -f mini-project/namespace.yaml
  kubectl apply -f mini-project/pvc.yaml -f mini-project/deployment.yaml -f mini-project/service.yaml -f mini-project/hpa.yaml
  kubectl -n production-webapp rollout status deployment/web-app --timeout=180s
  kubectl -n production-webapp exec deployment/web-app -- sh -c 'echo "Student: Archit Kulkarni - 24BCS10194" > /data/student.txt'
  old=$(kubectl -n production-webapp get pod -l app=web-app -o jsonpath='{.items[0].metadata.name}')
  kubectl -n production-webapp delete pod "$old"
  kubectl -n production-webapp rollout status deployment/web-app --timeout=120s
  kubectl -n production-webapp exec deployment/web-app -- cat /data/student.txt
  kubectl -n production-webapp get pods,pvc,hpa
  kubectl -n production-webapp describe deployment web-app
  echo 'CPU load and HPA metrics are checked separately on Minikube with metrics-server.'
  ;;
*) echo "Unknown lab: $lab"; exit 2;;
esac
