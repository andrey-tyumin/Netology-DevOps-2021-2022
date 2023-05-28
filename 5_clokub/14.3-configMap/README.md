### Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube. 

Как создать карту конфигураций?  
```
root@vps13419:~/143/14.3# kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created
root@vps13419:~/143/14.3# kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
```

Как просмотреть список карт конфигураций?  
```
root@vps13419:~/143/14.3# kubectl get configmaps
NAME               DATA   AGE
domain             1      15s
kube-root-ca.crt   1      90m
nginx-config       1      101s
```

Как просмотреть карту конфигурации?  
```
root@vps13419:~/143/14.3# kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      2m35s
root@vps13419:~/143/14.3# kubectl describe configmap domain       
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
```

Как получить информацию в формате YAML и/или JSON?  
Часть вывода обрезал  
```
root@vps13419:~/143/14.3# kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;

root@vps13419:~/143/14.3# kubectl get configmap domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-04-01T19:01:51Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "12669",
        "uid": "2aa82763-1a12-49d4-8632-bb51edfe9445"
    }
}
```

Как выгрузить карту конфигурации и сохранить его в файл?  
Часть вывода обрезал  
```
root@vps13419:~/143/14.3# kubectl get configmaps -o json > configmaps.json
root@vps13419:~/143/14.3# cat configmaps.json 
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "name": "netology.ru"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2022-04-01T19:01:51Z",
                "name": "domain",
                "namespace": "default",
                "resourceVersion": "12669",
                "uid": "2aa82763-1a12-49d4-8632-bb51edfe9445"
            }
        },

root@vps13419:~/143/14.3# kubectl get configmap nginx-config -o yaml > nginx-config.yml
```

Как удалить карту конфигурации?  
```
root@vps13419:~/143/14.3# kubectl delete configmap nginx-config
configmap "nginx-config" deleted
```

Как загрузить карту конфигурации из файла?  
```
root@vps13419:~/143/14.3# kubectl apply -f nginx-config.yml
configmap/nginx-config created
```

### Задача 2 (*): Работа с картами конфигураций внутри модуля  

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить их  доступность как в виде переменных окружения, так и в виде примонтированного тома  

Сделал yml для развертывания с образом федоры:  
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap1
data:
  task1: before task2
  task2: after task1
  task3: again

---
apiVersion: v1
kind: Pod
metadata:
  name: hw143pod
spec:
  containers:
    - name: fedora
      image: fedora
      command: [ "/bin/sh", "-c", "sleep 3600" ]
      env:
        - name: TASK_1
          valueFrom:
            configMapKeyRef:
              name: configmap1
              key: task1
        - name: TASK_2
          valueFrom:
            configMapKeyRef:
              name: configmap1
              key: task2
      volumeMounts:
      - name: configmap1-volume
        mountPath: /etc/config/
  volumes:
  - name: configmap1-volume
    configMap:
      name: configmap1
  restartPolicy: Never
```

Процесс:  
```
root@vps13419:~/143/14.3# kubectl get po
No resources found in default namespace.
root@vps13419:~/143/14.3# kubectl apply -f pods.yml
configmap/configmap1 created
pod/hw143pod created
root@vps13419:~/143/14.3# kubectl get po
NAME       READY   STATUS    RESTARTS   AGE
hw143pod   1/1     Running   0          7s
```

Проверяем переменные:  
```
root@vps13419:~/143/14.3# kubectl exec -ti hw143pod -c fedora -- env | grep TASK_1
TASK_1=before task2
root@vps13419:~/143/14.3# kubectl exec -ti hw143pod -c fedora -- env | grep TASK_2
TASK_2=after task1
```

Проверяем примонтированный диск:  
```
root@vps13419:~/143/14.3# kubectl exec -ti hw143pod -c fedora -- ls -al /etc/config
total 0
drwxrwxrwx. 3 root root 99 Apr  1 19:13 .
drwxr-xr-x. 1 root root 20 Apr  1 19:13 ..
drwxr-xr-x. 2 root root 45 Apr  1 19:13 ..2022_04_01_19_13_43.3727146560
lrwxrwxrwx. 1 root root 32 Apr  1 19:13 ..data -> ..2022_04_01_19_13_43.3727146560
lrwxrwxrwx. 1 root root 12 Apr  1 19:13 task1 -> ..data/task1
lrwxrwxrwx. 1 root root 12 Apr  1 19:13 task2 -> ..data/task2
lrwxrwxrwx. 1 root root 12 Apr  1 19:13 task3 -> ..data/task3
root@vps13419:~/143/14.3# kubectl exec -ti hw143pod -c fedora -- cat /etc/config/task1
before task2
root@vps13419:~/143/14.3# kubectl exec -ti hw143pod -c fedora -- cat /etc/config/task2
after task1
```
