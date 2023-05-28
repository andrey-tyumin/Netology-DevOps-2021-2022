## Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

### Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

Образы собрал, Dockerfile -s немного поменял для удобства:  
[frontend](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/dockerfiles/front/Dockerfile)  
[backend](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/dockerfiles/back/Dockerfile)  
и залил на hub.docker.com.  
Образы сделал с переменными по умолчанию BASE_URL=http://localhost:9000 (для frontend) и DATABASE_URL=postgres://postgres:postgres@db:5432/news (для backend)  
Переменные можно переопределить, передав свои.  

Подготовка виртуалок с помощью terraform. Создаются 4 рабочих ноды, 1 CP, nfs сервер, внешний(ЯОблако) loadbalanser(нацелен на рабочие ноды, на порт, выставленный с помощью NodePort).
Все файлы для разворачивания - в каталоге [terraform](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-01-objects/terraform).  

Кластер разворачивается с помощью kubespray, все так же как и в предыдущих дз, дополнительно добавлено в  
inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml:  
```
dns_etchosts: |
          10.130.0.7 nfs-server
```
(добавляем адрес nfs сервера в dns кластера, адрес меняем на свой).  
Процесс:  
Добавляем ConfigMap, pv, Statefullset, Service для Postgresql:  
kubectl apply -f psql.yaml  
Deploy и Service для frontend и backend:  
kubectl apply -f fb.yaml  
Скриншот вывода :  
![screen1](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/screen/hw131-screen1-1.png)
psql.yaml  и fb.yaml в каталоге [stage](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-01-objects/stage)  
Приложение не заработало, поразбирался, но не получилось :-).
Скриншот:  
![screen1-2](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/screen/hw131-screen1-2.png)  

---

### Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.   

Поделил деплоймент frontend и backend, переопределил переменные.  
Файлы front.yaml, back.yaml, psql.yaml в каталоге [production](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-01-objects/production)  
Скриншот:  
![screen2-1](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/screen/hw131-screen2-1.png)  

Еще немного поразбирался с приложением, посмотрел что есть в базе:
![screen2-2](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/screen/hw131-screen2-2.png)  
Какие-то данные есть, потыкал все сервисы палкой - реагируют, не стал дальше разбираться, т.к. может затянуться этот процесс.  

---

### Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).  

Не уверен, что такой ответ предполагался, сделал endpoint и service к нему для проверки.  

![screen3-1](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/screen/hw131-screen3-1.png)  
На запрос реагирует (на скриншоте).
Файл [endpoint.yaml](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-01-objects/endpoint.yaml).  

