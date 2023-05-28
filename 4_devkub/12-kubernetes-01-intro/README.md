## Домашнее задание к занятию "12.1 Компоненты Kubernetes"

Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

### Задача 1: Установить Minikube

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.

### Как поставить на AWS:
- создать EC2 виртуальную машину (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type) с типом **t3.small**. Для работы потребуется настроить Security Group для доступа по ssh. Не забудьте указать keypair, он потребуется для подключения.
- подключитесь к серверу по ssh (ssh ubuntu@<ipv4_public_ip> -i <keypair>.pem)
- установите миникуб и докер следующими командами:
  - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  - chmod +x ./kubectl
  - sudo mv ./kubectl /usr/local/bin/kubectl
  - sudo apt-get update && sudo apt-get install docker.io conntrack -y
  - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
- проверить версию можно командой minikube version
- переключаемся на root и запускаем миникуб: minikube start --vm-driver=none
- после запуска стоит проверить статус: minikube status
- запущенные служебные компоненты можно увидеть командой: kubectl get pods --namespace=kube-system

### Для сброса кластера стоит удалить кластер и создать заново:
- minikube delete
- minikube start --vm-driver=none

Возможно, для повторного запуска потребуется выполнить команду: sudo sysctl fs.protected_regular=0

Инструкция по установке Minikube - [ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)

**Важно**: t3.small не входит во free tier, следите за бюджетом аккаунта и удаляйте виртуалку.

### Ответ:  
Разворачивал на локальной машине.  
Все скачал, разложил по папкам по инструкции.  
Проверяем версию minikube:
```
andrey@WS01:~/k8s$ minikube version
minikube version: v1.24.0
commit: 76b94fb3c4e8ac5062daf70d60cf03ddcc0a741b
```
Запускаем minikube:  
```
root@WS01:/home/andrey/k8s# minikube start --vm-driver=none
😄  minikube v1.24.0 on Ubuntu 20.04
✨  Using the none driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🤹  Running on localhost (CPUs=4, Memory=9662MB, Disk=233200MB) ...
ℹ️  OS release is Ubuntu 20.04.3 LTS
🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.7 ...
    ▪ kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
    > kubelet.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubectl.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubectl: 44.73 MiB / 44.73 MiB [---------------] 100.00% 1.35 MiB p/s 33s
    > kubeadm: 43.71 MiB / 43.71 MiB [---------------] 100.00% 1.11 MiB p/s 40s
    > kubelet: 115.57 MiB / 115.57 MiB [------------] 100.00% 1.88 MiB p/s 1m2s
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🤹  Configuring local host environment ...

❗  The 'none' driver is designed for experts who need to integrate with an existing VM
💡  Most users should use the newer 'docker' driver instead, which does not require root!
📘  For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/

❗  kubectl and minikube configuration will be stored in /root
❗  To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:

    ▪ sudo mv /root/.kube /root/.minikube $HOME
    ▪ sudo chown -R $USER $HOME/.kube $HOME/.minikube

💡  This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Проверяем статус:
```
root@WS01:/home/andrey/k8s# minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

Проверяем запущенные компоненты:
```
root@WS01:/home/andrey/k8s# kubectl get pods --namespace=kube-system
NAME                           READY   STATUS    RESTARTS   AGE
coredns-78fcd69978-mnp6l       1/1     Running   0          15m
etcd-ws01                      1/1     Running   0          15m
kube-apiserver-ws01            1/1     Running   0          15m
kube-controller-manager-ws01   1/1     Running   0          15m
kube-proxy-ncklf               1/1     Running   0          15m
kube-scheduler-ws01            1/1     Running   0          15m
storage-provisioner            1/1     Running   0          15m
root@WS01:/home/andrey/k8s# 
```

Сброс кластера:
```
root@WS01:/home/andrey/k8s# minikube delete
🔄  Uninstalling Kubernetes v1.22.3 using kubeadm ...
🔥  Deleting "minikube" in none ...
🔥  Trying to delete invalid profile minikube
root@WS01:/home/andrey/k8s# minikube start --vm-driver=none
😄  minikube v1.24.0 on Ubuntu 20.04
✨  Using the none driver based on user configuration
👍  Starting control plane node minikube in cluster minikube

❌  Exiting due to HOST_JUJU_LOCK_PERMISSION: Failed to save config: failed to acquire lock for /root/.minikube/profiles/minikube/config.json: {Name:mk270d1b5db5965f2dc9e9e25770a63417031943 Clock:{} Delay:500ms Timeout:1m0s Cancel:<nil>}: unable to open /tmp/juju-mk270d1b5db5965f2dc9e9e25770a63417031943: permission denied
💡  Suggestion: Run 'sudo sysctl fs.protected_regular=0', or try a driver which does not require root, such as '--driver=docker'
🍿  Related issue: https://github.com/kubernetes/minikube/issues/6391

root@WS01:/home/andrey/k8s# sysctl fs.protected_regular=0
fs.protected_regular = 0
root@WS01:/home/andrey/k8s# minikube start --vm-driver=none
😄  minikube v1.24.0 on Ubuntu 20.04
✨  Using the none driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🤹  Running on localhost (CPUs=4, Memory=9662MB, Disk=233200MB) ...
ℹ️  OS release is Ubuntu 20.04.3 LTS
🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.7 ...
    ▪ kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🤹  Configuring local host environment ...

❗  The 'none' driver is designed for experts who need to integrate with an existing VM
💡  Most users should use the newer 'docker' driver instead, which does not require root!
📘  For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/

❗  kubectl and minikube configuration will be stored in /root
❗  To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:

    ▪ sudo mv /root/.kube /root/.minikube $HOME
    ▪ sudo chown -R $USER $HOME/.kube $HOME/.minikube

💡  This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
---


### Задача 2: Запуск Hello World
После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.

- развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
- установить аддоны ingress и dashboard

### Ответ:  
Устанавливаем аддоны:
```
root@WS01:/home/andrey/k8s# minikube dashboard
🔌  Enabling dashboard ...
    ▪ Using image kubernetesui/dashboard:v2.3.1
    ▪ Using image kubernetesui/metrics-scraper:v1.0.7
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
http://127.0.0.1:42401/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
root@WS01:/home/andrey/k8s# minikube addons list
|-----------------------------|----------|--------------|-----------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |      MAINTAINER       |
|-----------------------------|----------|--------------|-----------------------|
| ambassador                  | minikube | disabled     | unknown (third-party) |
| auto-pause                  | minikube | disabled     | google                |
| csi-hostpath-driver         | minikube | disabled     | kubernetes            |
| dashboard                   | minikube | enabled ✅   | kubernetes            |
| default-storageclass        | minikube | enabled ✅   | kubernetes            |
| efk                         | minikube | disabled     | unknown (third-party) |
| freshpod                    | minikube | disabled     | google                |
| gcp-auth                    | minikube | disabled     | google                |
| gvisor                      | minikube | disabled     | google                |
| helm-tiller                 | minikube | disabled     | unknown (third-party) |
| ingress                     | minikube | disabled     | unknown (third-party) |
| ingress-dns                 | minikube | disabled     | unknown (third-party) |
| istio                       | minikube | disabled     | unknown (third-party) |
| istio-provisioner           | minikube | disabled     | unknown (third-party) |
| kubevirt                    | minikube | disabled     | unknown (third-party) |
| logviewer                   | minikube | disabled     | google                |
| metallb                     | minikube | disabled     | unknown (third-party) |
| metrics-server              | minikube | disabled     | kubernetes            |
| nvidia-driver-installer     | minikube | disabled     | google                |
| nvidia-gpu-device-plugin    | minikube | disabled     | unknown (third-party) |
| olm                         | minikube | disabled     | unknown (third-party) |
| pod-security-policy         | minikube | disabled     | unknown (third-party) |
| portainer                   | minikube | disabled     | portainer.io          |
| registry                    | minikube | disabled     | google                |
| registry-aliases            | minikube | disabled     | unknown (third-party) |
| registry-creds              | minikube | disabled     | unknown (third-party) |
| storage-provisioner         | minikube | enabled ✅   | kubernetes            |
| storage-provisioner-gluster | minikube | disabled     | unknown (third-party) |
| volumesnapshots             | minikube | disabled     | kubernetes            |
|-----------------------------|----------|--------------|-----------------------|
root@WS01:/home/andrey/k8s# minikube addons enable ingress
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
    ▪ Using image k8s.gcr.io/ingress-nginx/controller:v1.0.4
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled
```
Проверяем:  
```
root@WS01:/home/andrey/k8s# minikube addons list
|-----------------------------|----------|--------------|-----------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |      MAINTAINER       |
|-----------------------------|----------|--------------|-----------------------|
| ambassador                  | minikube | disabled     | unknown (third-party) |
| auto-pause                  | minikube | disabled     | google                |
| csi-hostpath-driver         | minikube | disabled     | kubernetes            |
| dashboard                   | minikube | enabled ✅   | kubernetes            |
| default-storageclass        | minikube | enabled ✅   | kubernetes            |
| efk                         | minikube | disabled     | unknown (third-party) |
| freshpod                    | minikube | disabled     | google                |
| gcp-auth                    | minikube | disabled     | google                |
| gvisor                      | minikube | disabled     | google                |
| helm-tiller                 | minikube | disabled     | unknown (third-party) |
| ingress                     | minikube | enabled ✅   | unknown (third-party) |
| ingress-dns                 | minikube | disabled     | unknown (third-party) |
| istio                       | minikube | disabled     | unknown (third-party) |
| istio-provisioner           | minikube | disabled     | unknown (third-party) |
| kubevirt                    | minikube | disabled     | unknown (third-party) |
| logviewer                   | minikube | disabled     | google                |
| metallb                     | minikube | disabled     | unknown (third-party) |
| metrics-server              | minikube | disabled     | kubernetes            |
| nvidia-driver-installer     | minikube | disabled     | google                |
| nvidia-gpu-device-plugin    | minikube | disabled     | unknown (third-party) |
| olm                         | minikube | disabled     | unknown (third-party) |
| pod-security-policy         | minikube | disabled     | unknown (third-party) |
| portainer                   | minikube | disabled     | portainer.io          |
| registry                    | minikube | disabled     | google                |
| registry-aliases            | minikube | disabled     | unknown (third-party) |
| registry-creds              | minikube | disabled     | unknown (third-party) |
| storage-provisioner         | minikube | enabled ✅   | kubernetes            |
| storage-provisioner-gluster | minikube | disabled     | unknown (third-party) |
| volumesnapshots             | minikube | disabled     | kubernetes            |
|-----------------------------|----------|--------------|-----------------------|
```

Устанавливаем приложение:
```
root@WS01:/home/andrey/k8s# kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello-node created
root@WS01:/home/andrey/k8s# kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           32s
root@WS01:/home/andrey/k8s# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-gcgbc   1/1     Running   0          46s
root@WS01:/home/andrey/k8s# kubectl get events
LAST SEEN   TYPE     REASON                    OBJECT                             MESSAGE
59s         Normal   Scheduled                 pod/hello-node-7567d9fdc9-gcgbc    Successfully assigned default/hello-node-7567d9fdc9-gcgbc to ws01
57s         Normal   Pulling                   pod/hello-node-7567d9fdc9-gcgbc    Pulling image "k8s.gcr.io/echoserver:1.4"
35s         Normal   Pulled                    pod/hello-node-7567d9fdc9-gcgbc    Successfully pulled image "k8s.gcr.io/echoserver:1.4" in 22.778094897s
28s         Normal   Created                   pod/hello-node-7567d9fdc9-gcgbc    Created container echoserver
28s         Normal   Started                   pod/hello-node-7567d9fdc9-gcgbc    Started container echoserver
59s         Normal   SuccessfulCreate          replicaset/hello-node-7567d9fdc9   Created pod: hello-node-7567d9fdc9-gcgbc
59s         Normal   ScalingReplicaSet         deployment/hello-node              Scaled up replica set hello-node-7567d9fdc9 to 1
13m         Normal   NodeHasSufficientMemory   node/ws01                          Node ws01 status is now: NodeHasSufficientMemory
13m         Normal   NodeHasNoDiskPressure     node/ws01                          Node ws01 status is now: NodeHasNoDiskPressure
13m         Normal   NodeHasSufficientPID      node/ws01                          Node ws01 status is now: NodeHasSufficientPID
13m         Normal   Starting                  node/ws01                          Starting kubelet.
13m         Normal   NodeHasSufficientMemory   node/ws01                          Node ws01 status is now: NodeHasSufficientMemory
13m         Normal   NodeHasNoDiskPressure     node/ws01                          Node ws01 status is now: NodeHasNoDiskPressure
13m         Normal   NodeHasSufficientPID      node/ws01                          Node ws01 status is now: NodeHasSufficientPID
13m         Normal   NodeAllocatableEnforced   node/ws01                          Updated Node Allocatable limit across pods
13m         Normal   NodeReady                 node/ws01                          Node ws01 status is now: NodeReady
12m         Normal   RegisteredNode            node/ws01                          Node ws01 event: Registered Node ws01 in Controller
12m         Normal   Starting                  node/ws01                          
```
---

### Задача 3: Установить kubectl

Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
- подключиться к minikube 
- проверить работу приложения из задания 2, запустив port-forward до кластера

### Ответ:  
```
root@WS01:/home/andrey/k8s# kubectl expose deployment hello-node --type=LoadBalancer --port=8080
service/hello-node exposed
root@WS01:/home/andrey/k8s# kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.102.60.197   <pending>     8080:30252/TCP   77s
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          17m
root@WS01:/home/andrey/k8s# minikube service hello-node
|-----------|------------|-------------|------------------------------|
| NAMESPACE |    NAME    | TARGET PORT |             URL              |
|-----------|------------|-------------|------------------------------|
| default   | hello-node |        8080 | http://192.168.253.103:30252 |
|-----------|------------|-------------|------------------------------|
🎉  Opening service default/hello-node in default browser...
Running Firefox as root in a regular user's session is not supported.  ($XAUTHORITY is /run/user/1000/gdm/Xauthority which is owned by andrey.)
paths: Creating directory '/root/.dillo/'
paths: Cannot open file '/root/.dillo/dillorc': No such file or directory
paths: Using /etc/dillo/dillorc
paths: Cannot open file '/root/.dillo/keysrc': No such file or directory
paths: Using /etc/dillo/keysrc
paths: Cannot open file '/root/.dillo/domainrc': No such file or directory
paths: Using /etc/dillo/domainrc
Domain: Default accept.
dillo_dns_init: Here we go! (threaded)
Cookies: Created file: /root/.dillo/cookiesrc
Disabling cookies.
** WARNING **: preferred cursive font "URW Chancery L" not found.
Nav_open_url: new url='http://192.168.253.103:30252'
Dns_server [0]: 192.168.253.103 is 192.168.253.103
Connecting to 192.168.253.103
a_Dicache_cleanup: length = 0
```
---

### Задача 4 (*): собрать через ansible (необязательное)

Профессионалы не делают одну и ту же задачу два раза. Давайте закрепим полученные навыки, автоматизировав выполнение заданий  ansible-скриптами. При выполнении задания обратите внимание на доступные модули для k8s под ansible.
 - собрать роль для установки minikube на aws сервисе (с установкой ingress)
 - собрать роль для запуска в кластере hello world

### Ответ:  
Сделал два плейбука: 1-й устанавливает minikube, 2-й настраивает кластер на нём.
Плейбуки работают на localhost(можно поменять в плейбуках в hosts:).  
[deploy_minikube.yaml](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/12-kubernetes-01-intro/deploy_minikube.yaml)  
[hellonode.yaml](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/12-kubernetes-01-intro/hellonode.yaml)  
Процесс:
```
ansible-playbook ./deploy_minikube.yaml
ansible-playbook ./hellonode.yaml
```

Перед запуском 2-го плейбука:
```
root@WS01:/home/andrey/k8s# kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   22h
root@WS01:/home/andrey/k8s# kubectl get ns
NAME                   STATUS   AGE
default                Active   23h
ingress-nginx          Active   22h
kube-node-lease        Active   23h
kube-public            Active   23h
kube-system            Active   23h
kubernetes-dashboard   Active   23h
root@WS01:/home/andrey/k8s# kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   23h
root@WS01:/home/andrey/k8s# kubectl get deploy
No resources found in default namespace.
root@WS01:/home/andrey/k8s# kubectl get pods
No resources found in default namespace.
```
Запускаем плейбук:
```
root@WS01:/home/andrey/k8s# ansible-playbook ./hellonode.yaml 
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [hw121] ************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************************************
ok: [127.0.0.1]

TASK [Create a k8s namespace] *******************************************************************************************************************************************************************************
changed: [127.0.0.1]

TASK [Deployment] *******************************************************************************************************************************************************************************************
changed: [127.0.0.1]

TASK [Create service] ***************************************************************************************************************************************************************************************
changed: [127.0.0.1]

PLAY RECAP **************************************************************************************************************************************************************************************************
127.0.0.1                  : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
Проверяем:
```
root@WS01:/home/andrey/k8s# kubectl get ns
NAME                   STATUS   AGE
default                Active   23h
hello-namespace        Active   18s
ingress-nginx          Active   22h
kube-node-lease        Active   23h
kube-public            Active   23h
kube-system            Active   23h
kubernetes-dashboard   Active   23h
root@WS01:/home/andrey/k8s# kubectl get deploy --namespace=hello-namespace
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
helloworld   2/2     2            2           44s
root@WS01:/home/andrey/k8s# kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   23h
root@WS01:/home/andrey/k8s# kubectl get services --namespace=hello-namespace
NAME         TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
helloworld   NodePort   10.104.13.7   <none>        8080:30080/TCP   2m38s
```
Проверяем порт 30080:
```
root@WS01:/home/andrey/k8s# curl http://localhost:30080
CLIENT VALUES:
client_address=172.17.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://localhost:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=localhost:30080
user-agent=curl/7.68.0
BODY:
-no body in request-
```
Смотрим на поды:  
```
root@WS01:/home/andrey/k8s# kubectl get pods --namespace=hello-namespace
NAME                          READY   STATUS    RESTARTS   AGE
helloworld-774cfcb6dc-4xsmv   1/1     Running   0          4m31s
helloworld-774cfcb6dc-5hh4r   1/1     Running   0          4m31s
```
Пробуем удалить один под:
```
root@WS01:/home/andrey/k8s# kubectl delete pod helloworld-774cfcb6dc-4xsmv --namespace=hello-namespace
pod "helloworld-774cfcb6dc-4xsmv" deleted
```
Смотрим на поды снова:  
```
root@WS01:/home/andrey/k8s# kubectl get pods --namespace=hello-namespace
NAME                          READY   STATUS    RESTARTS   AGE
helloworld-774cfcb6dc-5hh4r   1/1     Running   0          5m12s
helloworld-774cfcb6dc-pcfv6   1/1     Running   0          6s
```
На замену удаленного пода поднялся новый.

