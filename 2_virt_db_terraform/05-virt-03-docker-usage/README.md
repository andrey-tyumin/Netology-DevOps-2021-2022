Домашнее задание к занятию "5.3. Контейнеризация на примере Docker"

---

Задача 1

Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

---

Сценарий:

    Высоконагруженное монолитное java веб-приложение;
        Тут больше подходит физический сервер(т.к. нагрузка высока, приложение монолитное, докер контейнер  
        будет слишком тяжел, как мне кажется).  

    Go-микросервис для генерации отчетов;  
        Докер тут идеально вписывается. Физ. сервер - жирновато для микросервиса, да и виртуалка тоже.

    Nodejs веб-приложение;  
        Докер подходит. Запустить приложение в контейнере и прокинуть порт наружу. наверное так.  
        Виртуалка и физ сервер тут лишние.  

    Мобильное приложение c версиями для Android и iOS;  
        Никогда такое не делал, быстро вникнуть не получится. В принципе если приложение IOS  
        нативное(не веб), то нужен mac, т. е. физ. сервер.  

    База данных postgresql используемая, как кэш;  
        Докер подходит, только настройки по памяти нужно крутить. Физ. сервер может быть избыточным,  
        чтение кэша только.  

    Шина данных на базе Apache Kafka;  
        Много незнакомых слов(на данный момент :-). Почитав несколько статей по  этому продукту, думаю,  
        что тут лучше всего подходит докер.  

    Очередь для Logstash на базе Redis;  
        Тут все можно запустить в контейнерах.  

    Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch,  
    два logstash и две ноды kibana;  
        Докер. Не могу веско аргументировать, мне кажется, в проде будет важна  
        идемпотентность - это про докер.  

    Мониторинг-стек на базе prometheus и grafana;  
        Тут также все можно запустить в докере, физ. сервере и виртуалка избыточны.  

    Mongodb, как основное хранилище данных для java-приложения;  
        Docker. Раз это можно запустить в докере и нагрузка не велика, то docker подходит  
        лучше всего.  

    Jenkins-сервер.  
        Docker. для большей изоляции и переносимости.  

---

Задача 2  

Сценарий выполения задачи:  

    создайте свой репозиторий на докерхаб;   
    выберете любой образ, который содержит апачи веб-сервер;  
    создайте свой форк образа;  
    реализуйте функциональность: запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:  
```
<html>  
<head>  
Hey, Netology  
</head>  
<body>  
<h1>I’m kinda DevOps now</h1>  
</body>  
</html>  
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на докерхаб-репо.  
Ссылка:https://hub.docker.com/r/imustgetout/netology-httpd  
Вывод :
```
root@vps13419:~/netology-httpd# docker images
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
httpd        2.4       bd29370f84ea   5 days ago   138MB
httpd        latest    bd29370f84ea   5 days ago   138MB
root@vps13419:~/netology-httpd# cat Dockerfile
FROM httpd:2.4
COPY index.html /usr/local/apache2/htdocs/
EXPOSE 80
root@vps13419:~/netology-httpd# docker build -t imustgetout/netology-httpd:1st .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM httpd:2.4
 ---> bd29370f84ea
Step 2/3 : COPY index.html /usr/local/apache2/htdocs/
 ---> fa40197d2ed0
Step 3/3 : EXPOSE 80
 ---> Running in 5bce1a7911f3
Removing intermediate container 5bce1a7911f3
 ---> 172d0f7c4ccc
Successfully built 172d0f7c4ccc
Successfully tagged imustgetout/netology-httpd:1st
root@vps13419:~/netology-httpd# docker ps     
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@vps13419:~/netology-httpd# docker images
REPOSITORY                   TAG       IMAGE ID       CREATED          SIZE
imustgetout/netology-httpd   1st       172d0f7c4ccc   24 seconds ago   138MB
httpd                        2.4       bd29370f84ea   5 days ago       138MB
httpd                        latest    bd29370f84ea   5 days ago       138MB
root@vps13419:~/netology-httpd# docker run -d 172d0f7c4ccc   
e8688bcac46160f4c88c44ce58ea2c58acaac2fe940c5bbd139f25061e6b0d7d
root@vps13419:~/netology-httpd# docker ps
CONTAINER ID   IMAGE          COMMAND              CREATED         STATUS         PORTS     NAMES
e8688bcac461   172d0f7c4ccc   "httpd-foreground"   4 seconds ago   Up 3 seconds   80/tcp    condescending_austin
root@vps13419:~/netology-httpd# docker inspect e8688bcac461 |grep IP
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
                    "IPAMConfig": null,
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
root@vps13419:~/netology-httpd# curl 172.17.0.2:80
<html>
	<head>
		Hey, Netology
	</head>
	<body>
		<h1>I’m kinda DevOps now</h1>
	</body>
</html>
root@vps13419:~/netology-httpd# docker push imustgetout/netology-httpd:1st  
The push refers to repository [docker.io/imustgetout/netology-httpd]
70fc519af2d7: Pushed 
239871c4cac5: Mounted from library/httpd 
9262f7dd1498: Mounted from library/httpd 
61172cb5065c: Mounted from library/httpd 
9fbbeddcc4e4: Mounted from library/httpd 
764055ebc9a7: Mounted from library/httpd 
1st: digest: sha256:fd78be75334e5353237c21b71efae0a5cd0a642577e1f79a9dde41822b3f094a size: 1573
root@vps13419:~/netology-httpd# 
```

---

Задача 3  

    Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку info из  
    текущей рабочей директории на  хостовой машине в /share/info контейнера;  
    Запустите второй контейнер из образа debian:latest в фоновом режиме, подключив папку info из текущей  
    рабочей директории на  хостовой машине в /info контейнера;  
    Подключитесь к первому контейнеру с помощью exec и создайте текстовый файл любого содержания в /share/info;  
    Добавьте еще один файл в папку info на хостовой машине;  
    Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.  
```
root@vps13419:~/3z# docker images
REPOSITORY                   TAG       IMAGE ID       CREATED        SIZE
imustgetout/netology-httpd   1st       172d0f7c4ccc   7 hours ago    138MB
httpd                        2.4       bd29370f84ea   5 days ago     138MB
httpd                        latest    bd29370f84ea   5 days ago     138MB
debian                       latest    7a4951775d15   3 weeks ago    114MB
centos                       latest    300e315adb2f   7 months ago   209MB
root@vps13419:~/3z# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@vps13419:~/3z# docker run -d -t -v /root/3z/info:/share/info centos
9e22226e633b5d2c57fd07ec77f1ba41f01c445f6616c61891d0d22e76b05925
root@vps13419:~/3z# docker run -d -t -v /root/3z/info:/info debian
6cf5cad0e49e482e34724e2b14ed43aeaf55f5901e66f499036b5f79979ab471
root@vps13419:~/3z# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
6cf5cad0e49e   debian    "bash"        13 seconds ago   Up 12 seconds             intelligent_wilson
9e22226e633b   centos    "/bin/bash"   42 seconds ago   Up 41 seconds             determined_driscoll
root@vps13419:~/3z# docker exec -ti 9e22226e633b bash
[root@9e22226e633b /]# echo "centos test" >> /share/info/centos.test
[root@9e22226e633b /]# cat /share/info/centos.test
centos test
[root@9e22226e633b /]# exit
exit
root@vps13419:~/3z# docker exec -ti 6cf5cad0e49e bash
root@6cf5cad0e49e:/# ls -al /info
total 12
drwxr-xr-x 2 root root 4096 Jul 14 18:03 .
drwxr-xr-x 1 root root 4096 Jul 14 18:01 ..
-rw-r--r-- 1 root root   12 Jul 14 18:03 centos.test
root@6cf5cad0e49e:/# exit
exit
root@vps13419:~/3z# ls -al ./info
total 12
drwxr-xr-x 2 root root 4096 Jul 14 21:03 .
drwxr-xr-x 3 root root 4096 Jul 14 14:18 ..
-rw-r--r-- 1 root root   12 Jul 14 21:03 centos.test
root@vps13419:~/3z# echo "host test" >> ./info/host.test
root@vps13419:~/3z# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
6cf5cad0e49e   debian    "bash"        4 minutes ago   Up 4 minutes             intelligent_wilson
9e22226e633b   centos    "/bin/bash"   4 minutes ago   Up 4 minutes             determined_driscoll
root@vps13419:~/3z# docker exec -ti 6cf5cad0e49e bash
root@6cf5cad0e49e:/# ls -al /info
total 16
drwxr-xr-x 2 root root 4096 Jul 14 18:05 .
drwxr-xr-x 1 root root 4096 Jul 14 18:01 ..
-rw-r--r-- 1 root root   12 Jul 14 18:03 centos.test
-rw-r--r-- 1 root root   10 Jul 14 18:05 host.test
root@6cf5cad0e49e:/# cat /info/centos.test
centos test
root@6cf5cad0e49e:/# cat /info/host.test
host test
root@6cf5cad0e49e:/#
```
