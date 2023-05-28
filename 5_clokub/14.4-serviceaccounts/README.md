### Домашнее задание к занятию "14.4 Сервис-аккаунты"  
#### Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube.  

##### Как создать сервис-аккаунт?
```
root@vps13419:~/144/kubespray# kubectl create serviceaccount netology
serviceaccount/netology created
```

##### Как просмотреть список сервис-акаунтов?  
```
root@vps13419:~/144/kubespray# kubectl get serviceaccounts
NAME       SECRETS   AGE
default    1         22m
netology   1         80s
```
```
root@vps13419:~/144/kubespray# kubectl get serviceaccount netology
NAME       SECRETS   AGE
netology   1         118s
```

##### Как получить информацию в формате YAML и/или JSON?  
```
root@vps13419:~/144/kubespray# kubectl get serviceaccount netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-04-02T18:22:36Z"
  name: netology
  namespace: default
  resourceVersion: "4053"
  uid: f3c2646e-4e91-426c-830f-6726fd6de3cd
secrets:
- name: netology-token-6l5ss
```
```
root@vps13419:~/144/kubespray# kubectl get serviceaccount default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-04-02T18:01:06Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "412",
        "uid": "3a32add3-4d50-4ec2-91b3-9a5daccc4821"
    },
    "secrets": [
        {
            "name": "default-token-b5zx5"
        }
    ]
}
```

##### Как выгрузить сервис-акаунты и сохранить его в файл?  
Вывод обрезал.  
```
root@vps13419:~/144/kubespray# kubectl get serviceaccount -o json > serviceaccount.json
root@vps13419:~/144/kubespray# cat serviceaccount.json
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2022-04-02T18:01:06Z",
                "name": "default",
                "namespace": "default",
                "resourceVersion": "412",
```
```
root@vps13419:~/144/kubespray# kubectl get serviceaccount netology -o yaml > netology.yml
root@vps13419:~/144/kubespray# cat netology.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-04-02T18:22:36Z"
  name: netology
  namespace: default
  resourceVersion: "4053"
  uid: f3c2646e-4e91-426c-830f-6726fd6de3cd
secrets:
- name: netology-token-6l5ss
```

##### Как удалить сервис-акаунт?  
```
root@vps13419:~/144/kubespray# kubectl delete serviceaccount netology
serviceaccount "netology" deleted
```

##### Как загрузить сервис-акаунт из файла?  
```
root@vps13419:~/144/kubespray# kubectl apply -f netology.yml
serviceaccount/netology created
```

#### Задача 2 (*): Работа с сервис-акаунтами внутри модуля.  

##### Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить доступность API Kubernetes.  
```
root@vps13419:~/144/kubespray# kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.1
```

##### Просмотреть переменные среды.  
```
sh-5.1# env | grep KUBE
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
KUBERNETES_SERVICE_HOST=10.233.0.1
KUBERNETES_PORT=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
sh-5.1#
```

##### Получить значения переменных.  
```
sh-5.1# export K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT SADIR=/var/run/secrets/kubernetes.io/serviceaccount TOKEN=$(cat $SADIR/token) CACERT=$SADIR/ca.crt NAMESPACE=$(cat $SADIR/namespace)
sh-5.1# env | grep -E 'K8S|SADIR|TOKEN|CACERT|NAMESPACE'
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=default
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IkZwQzRjWXl6N0VqV2tYZ2dzZUt1cUZaODhFRGJYam16N2E1YzJyQkowOFEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjgwNDYzMjYwLCJpYXQiOjE2NDg5MjcyNjAsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJmZWRvcmEiLCJ1aWQiOiJmNDM2MDk4OC1jY2Y4LTQxOTYtOTcxMC03ODBjMWQ2NmFlODgifSwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImRlZmF1bHQiLCJ1aWQiOiIzYTMyYWRkMy00ZDUwLTRlYzItOTFiMy05YTVkYWNjYzQ4MjEifSwid2FybmFmdGVyIjoxNjQ4OTMwODY3fSwibmJmIjoxNjQ4OTI3MjYwLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpkZWZhdWx0In0.MCwXIsI3L06G4RWduZV5kOPy1zvQ9gerBBIXqiCUItoy4-_ZukXX0gBax2ISf3As6tZAD7YMedKPCeOV_JvLFzKGNJPm0s1-2QrfLPFKivyUHp0EOxZ1hMCpxs4YJQS66o_aRMNyE0I9myR4UY5pL2S0WFQgh1YqMZrSxE7wU4JOhOa_A-R297VM9ktN6dHvwKAxfSrYjqb8e5qRjwusZcLtwfK2tSq-WpY_zSN-goRR6NwpJAAuSk6AQNd_U-Au26a2bCRMp9wDmjD4t75TWm2IHhjK72uzYd25HJiPg7-kf_JUaiE1GLKBkvuDOopg3xii-vONEjAamTF-Ig3uOg
K8S=https://10.233.0.1:443
```
##### Подключаемся к API  
Вывод обрезал.  
```
sh-5.1# curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
```
