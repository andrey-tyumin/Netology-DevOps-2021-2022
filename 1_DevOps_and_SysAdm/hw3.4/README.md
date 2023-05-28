# hw3.4
hw3.4

1. На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter:

    поместите его в автозагрузку,  
    предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на systemctl cat cron),  
    удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.


Ответ:  
Скачиваем   
```
vagrant@vagrant: wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
```
Распакуем  
```
vagrant@vagrant: tar zxvf node_exporter-1.1.2.linux-amd64.tar.gz
vagrant@vagrant:~$ cd node_exporter-1.1.2.linux-amd64
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ ls -al
total 18756
drwxr-xr-x 2 vagrant vagrant     4096 Mar  5 09:41 .
drwxr-xr-x 5 vagrant vagrant     4096 May  8 17:51 ..
-rw-r--r-- 1 vagrant vagrant    11357 Mar  5 09:41 LICENSE
-rwxr-xr-x 1 vagrant vagrant 19178528 Mar  5 09:29 node_exporter
-rw-r--r-- 1 vagrant vagrant      463 Mar  5 09:41 NOTICE
```
Скопируем  
```
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ sudo cp ./node_exporter /usr/bin/
````
Создадим unit файл(/etc/systemd/system/node_exporter.service):  
```
[Unit]
Description=node_exporter

[Service]
ExecStart=/usr/bin/node_exporter $EXTRA_OPTS
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Перегрузим демон systemd:  
```
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ sudo systemctl daemon-reload
```
Стартуем и стопим новый сервис:  
```
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ sudo systemctl start node_exporter 
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ sudo systemctl status node_exporter 
● node_exporter.service - node_exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: enabled)
     Active: active (running) since Sat 2021-05-08 18:21:42 UTC; 9s ago
   Main PID: 1153 (node_exporter)
      Tasks: 3 (limit: 1074)
     Memory: 2.0M
     CGroup: /system.slice/node_exporter.service
             └─1153 /usr/bin/node_exporter

May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.909Z caller=node_exporter.go:113 collector=thermal_zone
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.909Z caller=node_exporter.go:113 collector=time
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.909Z caller=node_exporter.go:113 collector=timex
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.911Z caller=node_exporter.go:113 collector=udp_queues
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.911Z caller=node_exporter.go:113 collector=uname
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.911Z caller=node_exporter.go:113 collector=vmstat
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.911Z caller=node_exporter.go:113 collector=xfs
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.911Z caller=node_exporter.go:113 collector=zfs
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.911Z caller=node_exporter.go:195 msg="Listening on" address=:9100
May 08 18:21:42 vagrant node_exporter[1153]: level=info ts=2021-05-08T18:21:42.917Z caller=tls_config.go:191 msg="TLS is disabled." http2=false
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ sudo systemctl stop node_exporter 
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ 
```

Включим автозапуск сервиса:  
```
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ sudo systemctl enable node_exporter 
Created symlink /etc/systemd/system/multi-user.target.wants/node_exporter.service → /etc/systemd/system/node_exporter.service.
vagrant@vagrant:~/node_exporter-1.1.2.linux-amd64$ 
```

Перегружаемся, смотрим статус сервиса:  
```
vagrant@vagrant:~$ systemctl status node_exporter
● node_exporter.service - node_exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2021-05-08 18:29:58 UTC; 1min 0s ago
   Main PID: 584 (node_exporter)
      Tasks: 3 (limit: 1074)
     Memory: 13.0M
     CGroup: /system.slice/node_exporter.service
             └─584 /usr/bin/node_exporter

May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=thermal_zone
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=time
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=timex
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=udp_queues
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=uname
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=vmstat
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=xfs
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.092Z caller=node_exporter.go:113 collector=zfs
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.093Z caller=node_exporter.go:195 msg="Listening on" address=:9100
May 08 18:29:59 vagrant node_exporter[584]: level=info ts=2021-05-08T18:29:59.111Z caller=tls_config.go:191 msg="TLS is disabled." http2=false
vagrant@vagrant:~$ 
```
Работает.  

---

2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.  
Ответ:  
--collector.cpu  
--collector.diskstats  
--collector.filesystem  
--collector.meminfo  
--collector.netstat  

---

3. Установите в свою виртуальную машину Netdata. Воспользуйтесь готовыми пакетами для установки (sudo apt install -y netdata). После успешной установки:

в конфигурационном файле /etc/netdata/netdata.conf в секции [web] замените значение с localhost на bind to = 0.0.0.0,  
добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте vagrant reload:  

config.vm.network "forwarded_port", guest: 19999, host: 19999

После успешной перезагрузки в браузере на своем ПК (не в виртуальной машине) вы должны суметь зайти на localhost:19999. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

Скриншот прилагаю.  
![alt text](https://github.com/andrey-tyumin/hw3.4/blob/main/2021-05-08%2021-58-39.png)

---

4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  
Ответ:  
Да.  
systemd[1]: Detected virtualization oracle.  

---

5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?  
Ответ:  
```
vagrant@vagrant:~$ sysctl fs.nr_open  
fs.nr_open = 1048576  
```
параметр указывает лимит на количество открытых файловых дескрипторов, можно также посмотреть в файле /proc/sys/fs/nr_open.
Другой лимит- hard limit open files:
```
vagrant@vagrant:~$ ulimit -Hn
1048576
```  

---

6. Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter. Для простоты работайте в данном задании под root (sudo -i). Под обычным пользователем требуются дополнительные опции (--map-root-user) и т.д.  
  
Ответ:  
```
vagrant@vagrant:~$ sudo su
root@vagrant:/home/vagrant# unshare -f --pid --mount-proc sleep 1h
```  
В другой сессии:  
```
root        1785  0.0  0.0   8080   596 pts/1    S+   20:21   0:00 unshare -f --pid --mount-proc sleep 1h
root        1786  0.0  0.0   8076   592 pts/1    S+   20:21   0:00 sleep 1h
root        1787  0.0  0.3  11492  3512 pts/2    R+   20:21   0:00 ps aux
root@vagrant:/home/vagrant# nsenter --target 1786 --pid --mount
root@vagrant:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   8076   592 pts/1    S+   20:21   0:00 sleep 1h
root           2  0.0  0.4   9836  4088 pts/2    S    20:21   0:00 -bash
root          11  0.0  0.3  11492  3440 pts/2    R+   20:22   0:00 ps aux
root@vagrant:/# 
```

---

7. Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов dmesg расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  
Ответ:  
для понятности заменим : именем f и отформатируем код.
```
f() {
  f | f &
}
f
```
таким образом это функция, которая параллельно пускает два своих экземпляра. Каждый пускает ещё по два и т.д. 
При отсутствии лимита на число процессов машина быстро исчерпывает физическую память и уходит в своп.
Ограничение на количество процессов для пользователя:  
```
vagrant@vagrant:~$ ulimit -u
3580
```
Для рута:  
```
vagrant@vagrant:~$ cat /proc/sys/kernel/pid_max 
4194304
```

Вывод dmesg(последняя строка):  
```
  252.078781] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope  
```
cgroups pids — используется для ограничения количества процессов в рамках контрольной группы.  

---
