## Домашнее задание к занятию "14.1 Создание и использование секретов"

### Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

#### Как создать секрет?
Генерируем приватный ключ:

```
openssl genrsa -out cert.key 4096
```
Создаем самоподписной сертификат:
```
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
```
Создаем секрет tls с именем domain-cert с полученными сертификатом и ключём:
```
kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key
```

Процесс:
```
andrey@WS01:~/141$ openssl genrsa -out cert.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
.++++
....++++
e is 65537 (0x010001)
andrey@WS01:~/141$ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt -subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
andrey@WS01:~/141$ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key
secret/domain-cert created
andrey@WS01:~/141$ 

```

#### Как просмотреть список секретов?

```
andrey@WS01:~/141$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-wcdns   kubernetes.io/service-account-token   3      1h19m
domain-cert           kubernetes.io/tls                     2      42s
andrey@WS01:~/141$ kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      55s
andrey@WS01:~/141$ 

```

#### Как просмотреть секрет?

```
andrey@WS01:~/141$ kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      99s
```
```
andrey@WS01:~/141$ kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
andrey@WS01:~/141$ 

```

#### Как получить информацию в формате YAML и/или JSON?
(Вывод обрезал)

```
andrey@WS01:~/141$ kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBL
kind: Secret
metadata:
  creationTimestamp: "2022-03-21T08:49:46Z"
  name: domain-cert
  namespace: default
  resourceVersion: "9643"
  uid: 066067fb-dc42-4896-8d54-28165255b7b4
type: kubernetes.io/tls
```
```
andrey@WS01:~/141$ kubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZ
        "tls.key": "LS0tLS1CRUdJTiBSU0EgUFJ
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-03-21T08:49:46Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "9643",
        "uid": "066067fb-dc42-4896-8d54-28165255b7b4"
    },
    "type": "kubernetes.io/tls"
}

```

#### Как выгрузить секрет и сохранить его в файл?
Вывод обрезал.

```
andrey@WS01:~/141$ kubectl get secrets -o json > secrets.json
andrey@WS01:~/141$ cat secrets.json 
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": 
```
```
andrey@WS01:~/141$ kubectl get secret domain-cert -o yaml > domain-cert.yml
andrey@WS01:~/141$ cat domain-cert.yml 
apiVersion: v1
data:
  tls.crt: 
```

#### Как удалить секрет?

```
andrey@WS01:~/141$ kubectl delete secret domain-cert
secret "domain-cert" deleted
andrey@WS01:~/141$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-wcdns   kubernetes.io/service-account-token   3      1h29m

```

#### Как загрузить секрет из файла?

```
andrey@WS01:~/141$ kubectl apply -f domain-cert.yml
secret/domain-cert created
andrey@WS01:~/141$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-wcdns   kubernetes.io/service-account-token   3      1h30m
domain-cert           kubernetes.io/tls                     2      2s

```

### Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

Подключаю в виде тома:
```
andrey@WS01:~/141$ kubectl apply -f podSecretVolume.yaml 
pod/hw141volumesecret created
andrey@WS01:~/141$ kubectl get po
NAME                READY   STATUS    RESTARTS   AGE
hw141volumesecret   1/1     Running   0          110s
andrey@WS01:~/141$ kubectl exec -ti hw141volumesecret -c nginx -- ls -al /opt/secretvolume
total 4
drwxrwxrwt 3 root root  120 Mar 21 09:09 .
drwxr-xr-x 1 root root 4096 Mar 21 09:09 ..
drwxr-xr-x 2 root root   80 Mar 21 09:09 ..2022_03_21_09_09_00.1355600272
lrwxrwxrwx 1 root root   32 Mar 21 09:09 ..data -> ..2022_03_21_09_09_00.1355600272
lrwxrwxrwx 1 root root   14 Mar 21 09:09 tls.crt -> ..data/tls.crt
lrwxrwxrwx 1 root root   14 Mar 21 09:09 tls.key -> ..data/tls.key
andrey@WS01:~/141$ 

```
В виде переменной окружения:
```
andrey@WS01:~/141$ kubectl apply -f podSecretEnv.yaml 
pod/hw141envsecret created
andrey@WS01:~/141$ kubectl get po
NAME                READY   STATUS    RESTARTS   AGE
hw141envsecret      1/1     Running   0          8s
hw141volumesecret   1/1     Running   0          28m
andrey@WS01:~/141$ kubectl exec -ti hw141envsecret -c nginx -- env |grep cert
cert=-----BEGIN CERTIFICATE-----
andrey@WS01:~/141$ kubectl exec -ti hw141envsecret -c nginx -- env |grep key
key=-----BEGIN RSA PRIVATE KEY-----

```

полный вывод можно посмотреть по:
```
kubectl exec -ti hw141envsecret -c nginx -- env
```
