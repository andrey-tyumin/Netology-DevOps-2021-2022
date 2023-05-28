### Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

#### Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube  
```
andrey@WS01:~/142$ kubectl apply -f vault-pod.yml 
pod/14.2-netology-vault created

```
Получить значение внутреннего IP пода  
```
andrey@WS01:~/142$ kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"172.17.0.3"}]

```
Запустить второй модуль для использования в качестве клиента  
```
andrey@WS01:~/142$ kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.1# 

```
Установка доп. пакетов  
Вывод обрезал:  
```
sh-5.1# dnf -y install pip
Fedora 35 - x86_64                                1.4 MB/s |  79 MB     00:56    
Fedora 35 openh264 (From Cisco) - x86_64          1.4 kB/s | 2.5 kB     00:01    
Fedora Modular 35 - x86_64                        671 kB/s | 3.3 MB     00:05    
Fedora 35 - x86_64 - Updates                      292 kB/s |  29 MB     01:40    
Fedora Modular 35 - x86_64 - Updates               83 kB/s | 2.8 MB     00:34    
Dependencies resolved.

```
```
sh-5.1# pip install hvac
Collecting hvac
  Downloading hvac-0.11.2-py2.py3-none-any.whl (148 kB)
     |████████████████████████████████| 148 kB 905 kB/s 
Collecting six>=1.5.0

```
Запускаем интерпретатор Python и выполняем код(поменяв ip пода на свой):  
```
sh-5.1# /usr/bin/python3
Python 3.10.2 (main, Jan 17 2022, 00:00:00) [GCC 11.2.1 20211203 (Red Hat 11.2.1-7)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import hvac
>>> client = hvac.Client(
...     url='http://172.17.0.3:8200',
...     token='aiphohTaa0eeHei'
... )
>>> client.is_authenticated()
True
>>> 
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big secret!!!'),
... )
{'request_id': 'c8ca6406-3fda-8428-6972-6daf265cd66b', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-03-25T12:17:38.432806972Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 
>>> # Читаем секрет
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': '1aaa500d-6f9a-db7f-08c8-ff2ae1751b90', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!!'}, 'metadata': {'created_time': '2022-03-25T12:17:38.432806972Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 

```
Сделал проброс порта на хост, чтобы посмотреть через web интерфейс:  
```
andrey@WS01:~/142$ kubectl port-forward 14.2-netology-vault 8200:8200
```
![screen1](https://github.com/andrey-tyumin/clokub-homeworks/blob/main/14.2-vault/hw142-screen1.png)

#### Задача 2 (*): Работа с секретами внутри модуля  
    На основе образа fedora создать модуль;  
    Создать секрет, в котором будет указан токен;  
    Подключить секрет к модулю;  
    Запустить модуль и проверить доступность сервиса Vault.  

Сделал деплоймент:  
```
andrey@WS01:~/142$ kubectl create deployment hw142 --image=fedora -- sleep 7777777
deployment.apps/hw142 created

```
Сделал секрет:  
```
andrey@WS01:~/142$ kubectl create secret generic mytoken --from-literal=vault_token=aiphohTaa0eeHei
secret/mytoken created

```

Присоединил секрет к поду через переменную окружения:  
```
andrey@WS01:~/142$ kubectl set env --from=secret/mytoken deployment/hw142
deployment.apps/hw142 env updated

```
Добавил в переменные окружения адрес vault:  
```
andrey@WS01:~/142$ kubectl set env deployment/hw142 VAULT_ADDR=http://172.17.0.3:8200
deployment.apps/hw142 env updated
```

Зашел на под:  
```
andrey@WS01:~/142$ kubectl get po
NAME                     READY   STATUS      RESTARTS   AGE
14.2-netology-vault      1/1     Running     0          39m
fedora                   0/1     Completed   0          36m
hw142-54f6cbdc6c-j2zjg   1/1     Running     0          91s
andrey@WS01:~/142$ kubectl exec -ti hw142-54f6cbdc6c-j2zjg -c fedora -- /bin/sh
sh-5.1# 

```
Как в пред. задании устанавливаем зависимости:  
```
dnf -y install pip
pip install hvac
```
Выполнил немного измененный код из первого задания в python:  
```
sh-5.1# /usr/bin/python3
Python 3.10.2 (main, Jan 17 2022, 00:00:00) [GCC 11.2.1 20211203 (Red Hat 11.2.1-7)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import hvac
>>> import os
>>> client = hvac.Client(
...     url=os.environ.get('VAULT_ADDR'),
...     token=os.environ.get('VAULT_TOKEN')
... )
>>> client.is_authenticated()
True
>>> 
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac_new',
...     secret=dict(hw142='Very Big Super secret!!!'),
... )
{'request_id': '7e1e09cc-9b05-0b0e-12a9-70de241b54ed', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-03-25T12:42:54.496305564Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 
>>> # Читаем секрет
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac_new',
... )
{'request_id': '86d9738d-24c7-ddb4-37f0-cf99a5635bdf', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'hw142': 'Very Big Super secret!!!'}, 'metadata': {'created_time': '2022-03-25T12:42:54.496305564Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 

```
Проверил через web интерфейс:  
![screen2](https://github.com/andrey-tyumin/clokub-homeworks/blob/main/14.2-vault/hw142-screen2.png)
