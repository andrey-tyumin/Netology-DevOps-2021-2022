
### Задача 1.  
Используя docker поднимите инстанс PostgreSQL (версию 13).  
Данные БД сохраните в volume.  
Подключитесь к БД PostgreSQL используя psql.  
Воспользуйтесь командой \? для вывода подсказки по имеющимся в psql управляющим командам.  
Найдите и приведите управляющие команды для:  

    вывода списка БД
    подключения к БД
    вывода списка таблиц
    вывода описания содержимого таблиц
    выхода из psql

Ответ:
```
docker run --name hw64_postgres -e POSTGRES_PASSWORD=secret -d postgres:13
вывода списка БД: \l
подключения к БД: \c
вывода списка таблиц \d
вывода описания содержимого таблиц \dt+
выхода из psql \q
```
---

### Задача 2  
Используя psql создайте БД test_database.  
Изучите бэкап БД.  
Восстановите бэкап БД в test_database.  
Перейдите в управляющую консоль psql внутри контейнера.  
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.  
Используя таблицу pg_stats, найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах.  
Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.  

Ответ:  
```
postgres=# create database test_database;
CREATE DATABASE
postgres=# exit
postgres@3d4f8a626c6c:~$ psql test_database < /home/test_dump.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
postgres@3d4f8a626c6c:~$ psql
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

postgres=# \l
                                   List of databases
     Name      |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
---------------+----------+----------+------------+------------+-----------------------
 postgres      | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 test_database | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)

postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_database=# select * from orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
(8 rows)

test_database=# analyze verbose orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE

test_database=# select attname, avg_width from pg_stats where tablename = 'orders' order by avg_width desc limit 1;
 attname | avg_width
---------+-----------
 title   |        16
(1 row)

test_database=#
```
Итоговая команда:  
```
select attname, avg_width from pg_stats where tablename = 'orders' order by avg_width desc limit 1;
```
---

### Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных  
размеров и поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии  
предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).  
Предложите SQL-транзакцию для проведения данной операции.  
Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders? 

Ответ:
```
create table orders_1 (check (price <= 499)) inherits (orders);
create table orders_2 (check (price > 499)) inherits (orders);
insert into orders_1 (select * from orders where price<=499);
insert into orders_2 (select * from orders where price>499);
create rule insert_1 AS ON INSERT TO orders WHERE (price <= 499) DO INSTEAD INSERT INTO orders_1 VALUES (new.*);
create rule insert_2 AS ON INSERT TO orders WHERE (price > 499) DO INSTEAD INSERT INTO orders_2 VALUES (new.*);
```
При создании таблицы можно указать PARTITION BY, указав метод разбиения,  
создать разделы\таблицы указав при создании PARTITION OF имя_таблицы.  

---

### Задача 4.

Используя утилиту pg_dump создайте бекап БД test_database.
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database?
```
pg_dump test_database > test_database.sql
```
или
```
pg_dump -h localhost -p 5432 -U postgres -C -F p -b -v -f test_database_1.sql test_database  
```
Строку 29 бэкапа можно изменить, например так(добавить UNIQUE):
```
title character varying(80) NOT NULL, UNIQUE
```
