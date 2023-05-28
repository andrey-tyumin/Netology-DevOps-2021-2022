## Домашнее задание к занятию "13.5 поддержка нескольких окружений на примере Qbec"
Приложение обычно существует в нескольких окружениях. Для удобства работы следует использовать соответствующие инструменты, например, Qbec.

### Задание 1: подготовить приложение для работы через qbec
Приложение следует упаковать в qbec. Окружения должно быть 2: stage и production. 

Требования:
* stage окружение должно поднимать каждый компонент приложения в одном экземпляре;
* production окружение — каждый компонент в трёх экземплярах;
* для production окружения нужно добавить endpoint на внешний адрес.

### Ответ:  
Файлы для разворота в каталоге [qbec](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-05-qbec/qbec).  
Не очень удачно получилось, один компонент для каждого окружения. В каждом компоненте описаны все разворачиваемые объекты.  
Когда понял, что делаю не по феншую, уже лень было переделывать.  
Получилось так: для stage - компонент stage(каталог stage в components).  
Для production - компонент production(каталог production в components).  
В каталоге компонента, разворачиваемые объекты вызываются из index.jsonnet.  
Сами объекты описаны в jsonnet файлах в том же каталоге.  
Со Storageclass provisioner тоже не стал заморачиваться, вручную прописал разворот нужного кол-ва pv для каждого окружения.  
Можно было попробовать сделать это в цикле, но я поленился.  
Namespace надо сделать заранее с kubectl(опять поленился).  
Кластер разворачивал как в предыдущем дз(с внешним nfs сервером).  
После разворота кластера меняем адрес на свой в qbec.yaml.  
Делаем  
```
qbec apply production  
```
Кусок вывода:  
```
stats:
  created:
  - persistentvolumes nfs-pv-1 (source production)
  - persistentvolumes nfs-pv-2 (source production)
  - persistentvolumes nfs-pv-3 (source production)
  - configmaps psql-cm -n production (source production)
  - endpoints number -n production (source production)
  - deployments back-dpl -n production (source production)
  - deployments front-dpl -n production (source production)
  - statefulsets psql-db -n production (source production)
  - services back-svc -n production (source production)
  - services db -n production (source production)
  - services front-svc -n production (source production)

waiting for readiness of 3 objects
  - deployments back-dpl -n production
  - deployments front-dpl -n production
  - statefulsets psql-db -n production

  0s    : deployments back-dpl -n production :: 0 of 3 updated replicas are available
  0s    : deployments front-dpl -n production :: 0 of 3 updated replicas are available
  0s    : statefulsets psql-db -n production :: 1 of 3 updated
  11s   : deployments front-dpl -n production :: 1 of 3 updated replicas are available
  15s   : deployments front-dpl -n production :: 2 of 3 updated replicas are available
  24s   : statefulsets psql-db -n production :: 2 of 3 updated
✓ 45s   : statefulsets psql-db -n production :: 3 new pods updated (2 remaining)
  1m5s  : deployments back-dpl -n production :: 1 of 3 updated replicas are available
  1m9s  : deployments back-dpl -n production :: 2 of 3 updated replicas are available
✓ 1m18s : deployments front-dpl -n production :: successfully rolled out (1 remaining)
✓ 1m28s : deployments back-dpl -n production :: successfully rolled out (0 remaining)
```
Проверим:  
```
kubectl get po -n production
NAME                         READY   STATUS    RESTARTS   AGE
back-dpl-99975f947-mbwkw     1/1     Running   0          102s
back-dpl-99975f947-rvnft     1/1     Running   0          102s
back-dpl-99975f947-zp9ch     1/1     Running   0          102s
front-dpl-7ddc6bcd7f-97v89   1/1     Running   0          102s
front-dpl-7ddc6bcd7f-ccvcm   1/1     Running   0          102s
front-dpl-7ddc6bcd7f-p52n9   1/1     Running   0          102s
psql-db-0                    1/1     Running   0          101s
psql-db-1                    1/1     Running   0          76s
psql-db-2                    1/1     Running   0          55s
```

Потом для stage:
```
qbec apply stage
```
кусок вывода:  
```
stats:
  created:
  - persistentvolumes nfs-pv-0 (source stage)
  - configmaps psql-cm -n stage (source stage)
  - deployments back-dpl -n stage (source stage)
  - deployments front-dpl -n stage (source stage)
  - statefulsets psql-db -n stage (source stage)
  - services back-svc -n stage (source stage)
  - services db -n stage (source stage)
  - services front-svc -n stage (source stage)

waiting for readiness of 3 objects
  - deployments back-dpl -n stage
  - deployments front-dpl -n stage
  - statefulsets psql-db -n stage

✓ 0s    : statefulsets psql-db -n stage :: 1 new pods updated (2 remaining)
  0s    : deployments back-dpl -n stage :: 0 of 1 updated replicas are available
  0s    : deployments front-dpl -n stage :: 0 of 1 updated replicas are available
✓ 3s    : deployments back-dpl -n stage :: successfully rolled out (1 remaining)
✓ 16s   : deployments front-dpl -n stage :: successfully rolled out (0 remaining)

✓ 16s: rollout complete
command took 20.74s
```
Проверим:  
```
kubectl get po -n stage
NAME                         READY   STATUS    RESTARTS   AGE
back-dpl-99975f947-zs2p9     1/1     Running   0          65s
front-dpl-7ddc6bcd7f-mk5vz   1/1     Running   0          65s
psql-db-0                    1/1     Running   0          65s
```
