# Session 9 - Kubernetes Fundamentals

Name: Archit Kulkarni  
Roll number: 24BCS10194

## 1. CLI and Minikube setup

This lab uses `kubectl` to talk to the cluster and Minikube to create the local control-plane node.

```powershell
minikube version
kubectl version --client --output=yaml
minikube start --driver=virtualbox
minikube status
kubectl get nodes -o wide
minikube stop
```

`minikube start` creates the cluster, `status` confirms host/kubelet/API-server health, and `stop` releases the VM resources without deleting cluster configuration.

## 2. Cluster architecture

```text
kubectl / controllers
        |
  kube-apiserver <--> etcd
        |
 scheduler + controller-manager
        |
     worker node
  kubelet -> container runtime -> Pods
  kube-proxy -> Service networking
```

The control plane stores desired state in **etcd**. The **API server** is the only public control-plane entry point; the **scheduler** chooses a node for unscheduled pods, and controller managers continually reconcile actual state with desired state. On each worker, **kubelet** starts the assigned Pod through a CRI-compatible runtime, while **kube-proxy** programs Service traffic rules.

## 3. Checks recorded for this lab

The version, start, status, node, and stop commands above are the required checks. The later sessions reuse the same cluster; a clean stop is run after the Kubernetes labs are finished.
