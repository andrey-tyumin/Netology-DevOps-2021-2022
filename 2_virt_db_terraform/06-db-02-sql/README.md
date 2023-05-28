Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.
Приведите получившуюся команду или docker-compose манифест.  
Ответ:  
```
root@vps13419:~/62# cat docker-compose.yml 
version: "3"

services:
  sqlserver:
    image: postgres
    environment:
      POSTGRES_PASSWORD: 123
    volumes: 
      - db-data:/var/lib/postgresql/data
      - db-backup:/backup
volumes:
  db-data:
  db-backup:
```

---

Задача 2

В БД из задачи 1:

    создайте пользователя test-admin-user и БД test_db
    в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
    предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
    создайте пользователя test-simple-user
    предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:

    id (serial primary key)
    наименование (string)
    цена (integer)

Таблица clients:

    id (serial primary key)
    фамилия (string)
    страна проживания (string, index)
    заказ (foreign key orders)

Приведите:

    итоговый список БД после выполнения пунктов выше,
    описание таблиц (describe)
    SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
    список пользователей с правами над таблицами test_db
Ответ:  
```
test_db=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges        
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)

test_db=# \dt+
                              List of relations
 Schema |  Name   | Type  |  Owner   | Persistence |    Size    | Description 
--------+---------+-------+----------+-------------+------------+-------------
 public | clients | table | postgres | permanent   | 8192 bytes | 
 public | orders  | table | postgres | permanent   | 0 bytes    | 
(2 rows)

test_db=# \d orders
                                    Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default               
--------+------------------------+-----------+----------+------------------------------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass)
 name   | character varying(255) |           |          | 
 price  | integer                |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

test_db=# \d clients
                                     Table "public.clients"
  Column   |          Type          | Collation | Nullable |               Default               
-----------+------------------------+-----------+----------+-------------------------------------
 id        | integer                |           | not null | nextval('clients_id_seq'::regclass)
 last_name | character varying(255) |           |          | 
 country   | character varying(255) |           |          | 
 order_id  | integer                |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_last_name_key" UNIQUE CONSTRAINT, btree (last_name)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

test_db=# SELECT DISTINCT grantee, table_catalog, table_schema, table_name, privilege_type FROM information_schema.table_privileges;
test_db=# SELECT DISTINCT grantee FROM information_schema.table_privileges;

```

---

Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders  
Наименование 	цена  
Шоколад 	10  
Принтер 	3000  
Книга 	500  
Монитор 	7000  
Гитара 	4000  

Таблица clients  
ФИО 	Страна проживания  
Иванов Иван Иванович 	USA  
Петров Петр Петрович 	Canada  
Иоганн Себастьян Бах 	Japan  
Ронни Джеймс Дио 	Russia  
Ritchie Blackmore 	Russia  

Используя SQL синтаксис:  

    вычислите количество записей для каждой таблицы
    приведите в ответе:
        запросы
        результаты их выполнения.
Ответ:  
```
test_db=# INSERT INTO orders (name, price) VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000), ('Гитара', 4000);
INSERT 0 5
test_db=# INSERT INTO clients (last_name, country) VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada');
INSERT 0 2
test_db=# INSERT INTO clients (last_name, country) VALUES ('Иоганн Себастьян Бах', 'Japan'), ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');
INSERT 0 3
test_db=# select count(*) from clients;
 count 
-------
     5
(1 row)

test_db=# select count(*) from orders;
 count 
-------
     5
(1 row)

```

---

Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.  

Используя foreign keys свяжите записи из таблиц, согласно таблице:  
ФИО 	Заказ  
Иванов Иван Иванович 	Книга  
Петров Петр Петрович 	Монитор  
Иоганн Себастьян Бах 	Гитара  
 
Приведите SQL-запросы для выполнения данных операций.  

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.  

Подсказк - используйте директиву UPDATE.  
```
test_db=# update clients set order_id = (select id from orders where name = 'Книга') where last_name = 'Иванов Иван Иванович';
UPDATE 1
test_db=# update clients set order_id = (select id from orders where name = 'Монитор') where last_name = 'Петров Петр Петрович';
UPDATE 1
test_db=# update clients set order_id = (select id from orders where name = 'Гитара') where last_name = 'Иоганн Себастьян Бах';
UPDATE 1
test_db=# select last_name from clients where order_id is not NULL;
               last_name                
----------------------------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)

test_db=# 

```

---

Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4  
(используя директиву EXPLAIN).  
Приведите получившийся результат и объясните что значат полученные значения.  

```
EXPLAIN select last_name from clients where order_id is not NULL;
test_db=# EXPLAIN select last_name from clients where order_id is not NULL;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..10.70 rows=70 width=516)
   Filter: (order_id IS NOT NULL)
(2 rows)
---
Все описание взято с https://postgrespro.ru/docs/postgresql/10/using-explain
Не скажу, что все понял, но пытался :-).
---
cost - Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных, 
например для сортирующего узла это время сортировки.
2-е число: Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, 
то есть возвращает все доступные строки. На практике родительский узел может досрочно прекратить чтение строк 
дочернего.
rows - Ожидаемое число строк, которое должен вывести этот узел плана. При этом так же предполагается, что 
узел выполняется до конца.
width - Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).
Filter -  то, что было после where, т.е. фильтр вывода.

```

---

Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).  
Остановите контейнер с PostgreSQL (но не удаляйте volumes).  
Поднимите новый пустой контейнер с PostgreSQL.  
Восстановите БД test_db в новом контейнере.  
Приведите список операций, который вы применяли для бэкапа данных и восстановления.  

```
root@89859367a087:/# chmod o+w /backup
root@89859367a087:/# su -l postgres
postgres@89859367a087:~$ pg_dump test_db > /backup/test_db_backup.sql;
```
Удалил контейнер.  
Очистил /var/lib/docker/volumes/62_db-data/_data/   

Запустил новый контейнер.  
Создаем пользователей, базу данных и восстанавливаем базу:  

```
postgres@6cb5c13ce8b4:~$ psql
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

postgres=# CREATE USER "test-admin-user";
CREATE ROLE
postgres=# CREATE database test_db;
CREATE DATABASE
postgres=# CREATE USER "test-simple-user";
CREATE ROLE
postgres=# exit
postgres@6cb5c13ce8b4:~$ ls -al /backup
total 16
drwxr-xrwx 2 root     root     4096 Jul 27 08:31 .
drwxr-xr-x 1 root     root     4096 Jul 27 08:46 ..
-rw-r--r-- 1 postgres postgres 4400 Jul 27 08:31 test_db_backup.sql
postgres@6cb5c13ce8b4:~$ psql test_db < /backup/test_db_backup.sql
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
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval 
--------
      5
(1 row)

 setval 
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
GRANT
GRANT
GRANT
GRANT
postgres@6cb5c13ce8b4:~$ psql
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

test_db=# select * from orders;
 id |      name      | price 
----+----------------+-------
  1 | Шоколад |    10
  2 | Принтер |  3000
  3 | Книга     |   500
  4 | Монитор |  7000
  5 | Гитара   |  4000
(5 rows)

test_db=# 
```
