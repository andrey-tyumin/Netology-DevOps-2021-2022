### Задача 1

Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).

Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её 
нужно прервать. 

Вы как инженер поддержки решили произвести данную операцию:
- напишите список операций, которые вы будете производить для остановки запроса пользователя
- предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB

Ответ:  

_Найти запрос пользователя(его opid)_  
_db.currentOp({"secs_running": {$gte: 180}})_  
_"Убить" запрос:_  
_db.killOp(<opid of the query to kill>)_  

Вариант решения вопроса:  
_Профилирование, мониторинг, поиск долгих запросов._  

---

### Задача 2

Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).

Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. 
Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
увеличивается пропорционально количеству реплик сервиса. 

При масштабировании сервиса до N реплик вы увидели, что:
- сначала рост отношения записанных значений к истекшим
- Redis блокирует операции записи

Как вы думаете, в чем может быть проблема?  
Ответ:  
_Мне кажется, это похоже, на то, что не хватает RAM:_   
_Количество реплик сервиса возросло - возросло количество записей._  
_Старые записи удаляются, -только тогда добавляются новые._  
_Если записи не удалялись -запись блокируется._  

---

### Задача 3

Перед выполнением задания познакомьтесь с документацией по [Common Mysql errors](https://dev.mysql.com/doc/refman/8.0/en/common-errors.html).

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:
```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```

Как вы думаете, почему это начало происходить и как локализовать проблему?

Какие пути решения данной проблемы вы можете предложить?  
Ответ:  
_Возможно, клиент получает, пакет, большего размера, чем указано в_  
_настройках(т.к. кол-во записей возросло - возросло кол-во возвращаемых данных):_  
```
 When a MySQL client or the mysqld server receives a packet bigger than max_allowed_packet bytes, it issues an ER_NET_PACKET_TOO_LARGE error and closes the connection. With some clients, you may also get a Lost connection to MySQL server during query error if the communication packet is too large.
Both the client and the server have their own max_allowed_packet variable, so if you want to handle big packets, you must increase this variable both in the client and in the server.
If you are using the mysql client program, its default max_allowed_packet variable is 16MB. To set a larger value, start mysql like this:

shell> mysql --max_allowed_packet=32M

That sets the packet size to 32MB.

The server's default max_allowed_packet value is 64MB. You can increase this if the server needs to handle big queries (for example, if you are working with big BLOB columns). For example, to set the variable to 128MB, start the server like this:

shell> mysqld --max_allowed_packet=128M
```

Решение вопроса - увеличить параметр max_allowed_packet.

---

### Задача 4

Перед выполнением задания ознакомтесь со статьей [Common PostgreSQL errors](https://www.percona.com/blog/2020/06/05/10-common-postgresql-errors/) из блога Percona.

Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с 
большим объемом данных лучше, чем MySQL.

После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:

`postmaster invoked oom-killer`

Как вы думаете, что происходит?

Как бы вы решили данную проблему?  

Ответ:  
_Возможно, долгие клиентские запросы в postgresql приводят к нехватке RAM,_  
_Время выполнения запросов большое - возросло количество клиентских сессий в ед. времени._  
_и oom-killer "прибивает" вызывающие это клиентские процессы._  
_Вариант решения:_  
_Разбитие длинных запросов на части._  
_Оптимизайия БД,_  
_Оптимизация запросов._  
_Можно выставлять параметры ядра на сервере(vm.overcommit_memory=2, и т.д.), но это более опасно,_  
