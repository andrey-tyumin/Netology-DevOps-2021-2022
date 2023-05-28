## Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

### Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods  
 
### Ответ:  
```
kubectl create deploy app-deploy --image=k8s.gcr.io/echoserver:1.4 --replicas=2
```
Процесс:  
```
andrey@hw104:~/122$ kubectl create deploy app-deploy --image=k8s.gcr.io/echoserver:1.4 --replicas=2
deployment.apps/app-deploy created
andrey@hw104:~/122$ kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
app-deploy-9b975845-92tpk   1/1     Running   0          10s
app-deploy-9b975845-n88hs   1/1     Running   0          10s
```

### Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

### Ответ:  
По прочтенной документации сделал вывод, что лучше использовать RBAC авторизацию.  
Т.к. нужно ограничить пространство имен, то мне кажется оптимально будет сделать кластерную роль с привязкой RoleBinding(не кластерной),  
т.к. в этом случае можно указать к какому namespace -у эта привязка применяется.  
По этапам будет примерно так(используем токены, не сертификаты):  
    1. Проверим, использует ли кластер RBAC авторизацию:  
     ```
     andrey@hw104:~/122$ kubectl cluster-info dump | grep authorization-mode 
     ```  
    2. Создаем serviceaccount.  
    3. Создаем кластерную роль и прописываем права роли.  
    4. Создаем привязку роли(для созданного serviceaccont-а и роли)  
    5. Получаем токен  
    6. Устанавливаем контекст  
Создадим namespace:  
```
kubectl create ns app-namespace
```
Сделаем deploy:  
```
    kubectl create deploy app-deploy --image=k8s.gcr.io/echoserver:1.4 --namespace=app-namespace --replicas=2
```
создадим аккаунт:  
```
    kubectl create serviceaccount viewpodslog
```
Создадим роль:  
```
    kubectl create clusterrole viewpodslog --verb=get --verb=list --verb=watch --resource=pods --resource=pods/log
```
Создадим привязку роли:  
```
kubectl create rolebinding viewpodslog --serviceaccount=default:viewpodslog --clusterrole=viewpodslog -n app-namespace
```
Получим токен serviceaccount-а, и запишем его в .kube/config :  
```
kubectl config set-credentials andrey --token=$(kubectl describe secrets "$(kubectl describe serviceaccount viewpodslog | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
```
Настроим контекст:  
```
kubectl config set-context applogs --cluster=minikube --user=andrey
```
Используем контекст:  
```
kubectl config use-context applogs
```
Лог процесса:  
```
andrey@hw104:~/122$ minikube start
😄  minikube v1.24.0 on Ubuntu 20.04 (amd64)
✨  Automatically selected the docker driver. Other choices: none, ssh
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=4000MB) ...

🧯  Docker is nearly out of disk space, which may cause deployments to fail! (98% of capacity)
💡  Suggestion:

    Try one or more of the following to free up space on the device:

    1. Run "docker system prune" to remove unused Docker data (optionally with "-a")
    2. Increase the storage allocated to Docker for Desktop by clicking on:
    Docker icon > Preferences > Resources > Disk Image Size
    3. Run "minikube ssh -- docker system prune" if using the Docker container runtime
🍿  Related issue: https://github.com/kubernetes/minikube/issues/9024

🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.8 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
andrey@hw104:~/122$ kubectl create ns app-namespace
namespace/app-namespace created
andrey@hw104:~/122$ kubectl create deploy app-deploy --image=k8s.gcr.io/echoserver:1.4 --namespace=app-namespace --replicas=2
deployment.apps/app-deploy created
andrey@hw104:~/122$ kubectl create serviceaccount viewpodslog
serviceaccount/viewpodslog created
andrey@hw104:~/122$ kubectl create clusterrole viewpodslog --verb=get --verb=list --verb=watch --resource=pods --resource=pods/log
clusterrole.rbac.authorization.k8s.io/viewpodslog created
andrey@hw104:~/122$ kubectl create rolebinding viewpodslog --serviceaccount=default:viewpodslog --clusterrole=viewpodslog -n app-namespace
rolebinding.rbac.authorization.k8s.io/viewpodslog created
andrey@hw104:~/122$ kubectl config set-credentials andrey --token=$(kubectl describe secrets "$(kubectl describe serviceaccount viewpodslog | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
User "andrey" set.
andrey@hw104:~/122$ kubectl config set-context applogs --cluster=minikube --user=andrey
Context "applogs" created.
andrey@hw104:~/122$ kubectl config use-context applogs
Switched to context "applogs".
andrey@hw104:~/122$ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:viewpodslog" cannot list resource "pods" in API group "" in the namespace "default"
andrey@hw104:~/122$ kubectl get pods -n app-namespace
NAME                        READY   STATUS    RESTARTS   AGE
app-deploy-9b975845-f2wsg   1/1     Running   0          79s
app-deploy-9b975845-zvn25   1/1     Running   0          79s
andrey@hw104:~/122$ kubectl logs app-deploy-9b975845-f2wsg
Error from server (Forbidden): pods "app-deploy-9b975845-f2wsg" is forbidden: User "system:serviceaccount:default:viewpodslog" cannot get resource "pods" in API group "" in the namespace "default"
andrey@hw104:~/122$ kubectl logs app-deploy-9b975845-f2wsg -n app-namespace
andrey@hw104:~/122$ kubectl logs -f app-deploy-9b975845-f2wsg -n app-namespace
^C
andrey@hw104:~/122$
```

### Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)
 
 ### Ответ:  
 ```
 kubectl scale deploy app-deploy --replicas=5
 ```
 Процесс:  
 ```
 andrey@hw104:~/122$ kubectl scale deploy app-deploy --replicas=5
deployment.apps/app-deploy scaled
andrey@hw104:~/122$ kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
app-deploy-9b975845-92tpk   1/1     Running   0          2m39s
app-deploy-9b975845-9ckhz   1/1     Running   0          3s
app-deploy-9b975845-d66q2   1/1     Running   0          3s
app-deploy-9b975845-n88hs   1/1     Running   0          2m39s
app-deploy-9b975845-ppbc7   1/1     Running   0          3s
```
