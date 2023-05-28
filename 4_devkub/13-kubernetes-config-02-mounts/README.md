## Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.


helm поставил, репозиторий добавил, nfs сервер установил, получил пример pvc:
```
root@vps13419:~/132/kubespray# helm install nfs-server stable/nfs-server-provisioner
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Mon Feb 14 10:55:28 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
```


### Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

Немного поменял файлы для развертывания из предыдущего дз.
( Файл в каталоге [stage](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-02-mounts/stage)).  
Сделал деплой.  
Проверил чтение-запись из контейнеров:  
Пишем в файл на фронте  и проверяем:  
```
kubectl exec -ti fbdpl-979bcf477-4c225 -c front -- bash -c "echo hi > /static/meow.txt"
kubectl exec -ti fbdpl-979bcf477-4c225 -c front -- bash -c "cat /static/meow.txt"
```
Проверяем это на back и пишем ответ:
```
kubectl exec -ti fbdpl-979bcf477-4c225 -c back -- ls -al /static
kubectl exec -ti fbdpl-979bcf477-4c225 -c back -- bash -c "cat /static/meow.txt"
kubectl exec -ti fbdpl-979bcf477-4c225 -c back -- bash -c "echo "meow">> /static/meow.txt"
```
проверяем ответ на front:
```
kubectl exec -ti fbdpl-979bcf477-4c225 -c front -- bash -c "cat /static/meow.txt"
```
Скриншот:
![SCREEN132-1](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-02-mounts/screens/screen132-1.png)  
Работает.  

### Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

Также поменял файлы для деплоя в прод из предыдущего дз, также добавил файл для создания pvc.  
Файлы в каталоге: [prod](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-02-mounts/prod)  
Проверял примерно также как в предыдущем задании.  
Пишем в первом front-е, проверяем и пишем ответ в back. Проверяем ответ в другом front-е:
```
kubectl exec -ti front-dpl-685ddd6b9-gvrq6 -c front -- bash -c "echo hi > /static/1.txt"
kubectl exec -ti front-dpl-685ddd6b9-gvrq6 -c front -- bash -c "cat /static/1.txt"
kubectl exec -ti back-dpl-77f797fdc7-pkqfm -c back -- ls -al /static
kubectl exec -ti back-dpl-77f797fdc7-pkqfm -c back -- bash -c "cat /static/1.txt"
kubectl exec -ti back-dpl-77f797fdc7-pkqfm -c back -- bash -c "echo "hi2">> /static/1.txt"
kubectl exec -ti front-dpl-685ddd6b9-kf7zd -c front -- bash -c "cat /static/1.txt"
```
Скриншот:
![screen132-2](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-02-mounts/screens/screen132-2.png)  
Работает.  
