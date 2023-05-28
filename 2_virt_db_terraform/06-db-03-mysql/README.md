# Домашнее задание к занятию "6.3. MySQL"

## Введение

[дополнительные материалы](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.
Перейдите в управляющую консоль `mysql` внутри контейнера.
Используя команду `\h` получите список управляющих команд.
Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
Подключитесь к восстановленной БД и получите список таблиц из этой БД.
**Приведите в ответе** количество записей с `price` > 300.
В следующих заданиях мы будем продолжать работу с данным контейнером.

Ответ:  
Поднимаем MySQL:
```
root@vps13419:~/63# docker run --name mysql-hw -e MYSQL_ROOT_PASSWORD=secret -d -v /root/63/data-db:/var/lib/mysql/ mysql:latest
root@vps13419:~/63# docker exec -ti mysql-hw /bin/bash
```
СОздаем базу и восстанавливаем из бэкапа:
```
mysql> CREATE DATABASE test_db
mysql> use test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> source /var/lib/mysql/test_dump.sql
```
Статус БД:
```
mysql> \s
--------------
mysql  Ver 8.0.26 for Linux on x86_64 (MySQL Community Server - GPL)
```
Список таблиц и количество записей с price>300:
```
mysql> show tables from test_db;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> SELECT * from test_db.orders where price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)

mysql> SELECT count(*) from test_db.orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```
---

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

Ответ:  
```
CREATE USER 'jamespretty'@'localhost' IDENTIFIED WITH mysql_native_password BY 'secret' PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3 ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
ALTER USER 'jamespretty'@'localhost' WITH MAX_QUERIES_PER_HOUR 100;
GRANT SELECT ON test_db.* TO 'jamespretty'@'localhost';


mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'jamespretty' AND HOST = 'localhost';
+-------------+-----------+---------------------------------------+
| USER        | HOST      | ATTRIBUTE                             |
+-------------+-----------+---------------------------------------+
| jamespretty | localhost | {"fname": "James", "lname": "Pretty"} |
+-------------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```
---
## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

Ответ:
```
mysql> set profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> show profiles;
Empty set, 1 warning (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.01 sec)

mysql> show profiles;
+----------+------------+----------------+
| Query_ID | Duration   | Query          |
+----------+------------+----------------+
|        1 | 0.01065700 | show databases |
+----------+------------+----------------+
1 row in set, 1 warning (0.00 sec)

mysql> show profile;
+----------------------------+----------+
| Status                     | Duration |
+----------------------------+----------+
| starting                   | 0.000734 |
| checking permissions       | 0.000174 |
| Opening tables             | 0.002807 |
| init                       | 0.000104 |
| System lock                | 0.000140 |
| optimizing                 | 0.000207 |
| statistics                 | 0.000599 |
| preparing                  | 0.000387 |
| Creating tmp table         | 0.001373 |
| executing                  | 0.002176 |
| end                        | 0.000017 |
| query end                  | 0.000018 |
| waiting for handler commit | 0.000113 |
| closing tables             | 0.000058 |
| freeing items              | 0.001365 |
| cleaning up                | 0.000388 |
```
Смотрим engine в БД test_db:
```
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)
```
Меняем engine и смотрим скорость:
```
mysql> ALTER TABLE test_db.orders ENGINE=MyISAM;
Query OK, 5 rows affected (0.07 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM test_db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

mysql> show profiles;
+----------+------------+------------------------------------------+
| Query_ID | Duration   | Query                                    |
+----------+------------+------------------------------------------+
|        1 | 0.00387150 | SELECT * FROM test_db.orders             |
|        2 | 0.07016750 | ALTER TABLE test_db.orders ENGINE=MyISAM |
|        3 | 0.00132225 | SELECT * FROM test_db.orders             |
+----------+------------+------------------------------------------+
3 rows in set, 1 warning (0.00 sec)

mysql> ALTER TABLE test_db.orders ENGINE=InnoDB;
Query OK, 5 rows affected (0.09 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM test_db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)
```
Итоговый рез-тат:
```
mysql> show profiles;
+----------+------------+------------------------------------------+
| Query_ID | Duration   | Query                                    |
+----------+------------+------------------------------------------+
|        1 | 0.00387150 | SELECT * FROM test_db.orders             |
|        2 | 0.07016750 | ALTER TABLE test_db.orders ENGINE=MyISAM |
|        3 | 0.00132225 | SELECT * FROM test_db.orders             |
|        4 | 0.08610775 | ALTER TABLE test_db.orders ENGINE=InnoDB |
|        5 | 0.00113025 | SELECT * FROM test_db.orders             |
+----------+------------+------------------------------------------+
5 rows in set, 1 warning (0.00 sec)
```
---

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

Ответ:  
```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 128M
innodb_log_file_size = 100M
```
