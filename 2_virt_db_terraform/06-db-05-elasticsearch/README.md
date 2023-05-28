### Задача 1.
В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch. 

Ответ:   
Dockerfile:  
```
root@vps13419:~/65# cat Dockerfile
FROM centos:7
RUN yum update -y && yum install -y wget && yum install -y perl-Digest-SHA
WORKDIR /opt
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.14.0-linux-x86_64.tar.gz && \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.14.0-linux-x86_64.tar.gz.sha512 && \
shasum -a 512 -c elasticsearch-7.14.0-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-7.14.0-linux-x86_64.tar.gz
RUN echo "node.name: netology_test" >> /opt/elasticsearch-7.14.0/config/elasticsearch.yml && \
 echo "path.data: /var/lib" >> /opt/elasticsearch-7.14.0/config/elasticsearch.yml && \
 mkdir /opt/elasticsearch-7.14.0/snapshots && \
 echo "path.repo: /opt/elasticsearch-7.14.0/snapshots" >> /opt/elasticsearch-7.14.0/config/elasticsearch.yml && \
 adduser elastic && \
 chown elastic -R /opt/elasticsearch-7.14.0 && \
 chmod 775 /var/lib && \
 usermod -aG root elastic
USER elastic
CMD /opt/elasticsearch-7.14.0/bin/elasticsearch
```
Ссылка на образ:
https://hub.docker.com/repository/docker/imustgetout/elastic_hw

Ответ elasticsearch:
```
[elastic@54573ca2da4c opt]$ curl http://localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "MdnUfWWkQw6c_aYrp7aG3A",
  "version" : {
    "number" : "7.14.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "dd5a0a2acaa2045ff9624f3729fc8a6f40835aa1",
    "build_date" : "2021-07-29T20:49:32.864135063Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
---

### Задача 2.
В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

Ответ:  

Создаем индексы(через созданный скрипт create_index.sh):  
```
[elastic@54573ca2da4c ~]$ cat ./create_index.sh
curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1
    }
  }
}
'
curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 2
    }
  }
}
'
curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 4
    }
  }
}
'
[elastic@54573ca2da4c ~]$ ./create_index.sh
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```
Получаем список индексов и их статус:
```
[elastic@54573ca2da4c ~]$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases goCO6NGWSc2_vEysvugGww   1   0         41           33     40.1mb         40.1mb
yellow open   ind-1            qTCWokY1RGqraEPGK4wJ1A   1   1          0            0       208b           208b
yellow open   ind-3            33j5DSIZTuu2-OD3H7MqwA   4   1          0            0       832b           832b
yellow open   ind-2            VqWDWBleSRqFa3jt1N5lEw   2   1          0            0       416b           416b
```
Все в статусе yellow, т.к. в кластере только один узел.

Удаляем индексы:
```
[elastic@54573ca2da4c ~]$ curl -XDELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
[elastic@54573ca2da4c ~]$ curl -XDELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
[elastic@54573ca2da4c ~]$ curl -XDELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
[elastic@54573ca2da4c ~]$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases goCO6NGWSc2_vEysvugGww   1   0         41           33     40.1mb         40.1mb
```

Получаем состояние кластера:  
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl http://localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 3,
  "active_shards" : 3,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```
---

### Задача 3.

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

Ответ:  
В elasticsearch.yml добавил path.repo: /opt/elasticsearch-7.14.0/snapshots  
Перезапустил контейнер.  
Регистрируем директорию:  
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ cat ./create.snap.sh
curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/opt/elasticsearch-7.14.0/snapshots"
  }
}
'
[elastic@54573ca2da4c elasticsearch-7.14.0]$ ./create.snap.sh
{
  "acknowledged" : true
}
```
Проверяем:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl -X GET "localhost:9200/_snapshot?pretty"
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/opt/elasticsearch-7.14.0/snapshots"
    }
  }
}
```
Создаем индекс:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ cat ./create_1ind.sh
curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
    "number_of_shards": 1,
    "number_of_replicas": 0

    }
  }
}
'
[elastic@54573ca2da4c elasticsearch-7.14.0]$ ./create_1ind.sh
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases goCO6NGWSc2_vEysvugGww   1   0         41           33     40.1mb         40.1mb
green  open   test             MN_KtSYoTSeH31J3HS67VA   1   0          0            0       208b           208b
```
Создаем снапшот:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl -X PUT "localhost:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "N4lvHyjdR0OnIcEXC-uyPA",
    "repository" : "netology_backup",
    "version_id" : 7140099,
    "version" : "7.14.0",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2021-08-11T20:16:55.634Z",
    "start_time_in_millis" : 1628713015634,
    "end_time" : "2021-08-11T20:16:57.044Z",
    "end_time_in_millis" : 1628713017044,
    "duration_in_millis" : 1410,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```
Листинг файлов в директории snapshots:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ ls -al ./snapshots/
total 56
drwxrwxr-x 3 elastic elastic  4096 Aug 11 20:16 .
drwxr-xr-x 1 elastic root     4096 Aug 11 20:12 ..
-rw-r--r-- 1 elastic elastic   828 Aug 11 20:16 index-0
-rw-r--r-- 1 elastic elastic     8 Aug 11 20:16 index.latest
drwxr-xr-x 4 elastic elastic  4096 Aug 11 20:16 indices
-rw-r--r-- 1 elastic elastic 27667 Aug 11 20:16 meta-N4lvHyjdR0OnIcEXC-uyPA.dat
-rw-r--r-- 1 elastic elastic   437 Aug 11 20:16 snap-N4lvHyjdR0OnIcEXC-uyPA.dat
```
Удаляем индекс test:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl -XDELETE 'http://localhost:9200/test?pretty'
{
  "acknowledged" : true
}
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases goCO6NGWSc2_vEysvugGww   1   0         41           33     40.1mb         40.1mb
```
Создаем индекс test-2:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ cat ./create_1ind.sh
curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
    "number_of_shards": 1,
    "number_of_replicas": 0

    }
  }
}
'
[elastic@54573ca2da4c elasticsearch-7.14.0]$ ./create_1ind.sh
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases goCO6NGWSc2_vEysvugGww   1   0         41           33     40.1mb         40.1mb
green  open   test-2           olFuh0xmTu-njh-rywB_mw   1   0          0            0       208b           208b
```
Восстанавливаем из снапшота:
```
[elastic@54573ca2da4c elasticsearch-7.14.0]$ cat ./restore.sh
curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "test",
  "ignore_unavailable": true,
  "include_global_state": false
}
'
[elastic@54573ca2da4c elasticsearch-7.14.0]$ ./restore.sh
{
  "accepted" : true
}
[elastic@54573ca2da4c elasticsearch-7.14.0]$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases goCO6NGWSc2_vEysvugGww   1   0         41           33     40.1mb         40.1mb
green  open   test-2           olFuh0xmTu-njh-rywB_mw   1   0          0            0       208b           208b
green  open   test             f7B3dCKeTQuaq4VIf4e1kQ   1   0          0            0       208b           208b
```
