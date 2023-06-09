## Домашнее задание к занятию "12.3 Развертывание кластера на собственных серверах, лекция 1"
Поработав с персональным кластером, можно заняться проектами. Вам пришла задача подготовить кластер под новый проект.

### Задание 1: Описать требования к кластеру
Сначала проекту необходимо определить требуемые ресурсы. Известно, что проекту нужны база данных, система кеширования, а само приложение состоит из бекенда и фронтенда. Опишите, какие ресурсы нужны, если известно:

* база данных должна быть отказоустойчивой (не менее трех копий, master-slave) и потребляет около 4 ГБ ОЗУ в работе;
* кэш должен быть аналогично отказоустойчивый, более трех копий, потребление: 4 ГБ ОЗУ, 1 ядро;
* фронтенд обрабатывает внешние запросы быстро, отдавая статику: не более 50 МБ ОЗУ на каждый экземпляр;
* бекенду требуется больше: порядка 600 МБ ОЗУ и по 1 ядру на копию.

Требования: опишите, сколько нод в кластере и сколько ресурсов (ядра, ОЗУ, диск) нужно для запуска приложения. Расчет вести из необходимости запуска 5 копий фронтенда и 10 копий бекенда, база и кеш.

### Ответ:

Необходимые ресурсы для разворачивания приложения:  
БД 4 ГБ ОЗУ, ядра не указано, считаем что ядро=1(маловато наверное, но пусть так), умножаем на 3: 12 ГБ ОЗУ, 3 ядра.  
Кэш  4ГБ ОЗУ, 1 ядро, тоже 3 экземпляра, получаем 12 ГБ ОЗУ, 3 ядра.  
Фронтенд 50МБ ОЗУ, 0.1 ядро, умножаем на 5: 250МБ, 0.5 ядра.  
Бекенд 600МБ ОЗУ, 1 ядро, умножаем на 10: 6ГБ ОЗУ, 10 ядер.  
Итог: 30,25ГБ ОЗУ(Считаем за 31Гб) 16.5 ядер(считаем за 17).  

Для самой ноды нужно 1ГБ ОЗУ, 1 ядро.  

Старался считать по минимальному остатку "лишних" ресурсов, ноды можно и потом добавить по мере роста нагрузки.  

Пусть мастер нода стоит отдельно, её приплюсую в конце.  

Для БД или кэша минимум памяти на ноде 4Гб. Если взять это за основу , то на каждую ноду минимум  
5Гб(с учетом самой ноды), с небольщим запасом берем по 6, Для самого приложения на ноде остается 5 Гб,  
получаем 7 нод, для приложения остается 35Гб.  
Количество ядер получается 24(17+7). На ноду по 4 ядра(28 ядер). Для самого приложения остается 
21 ядро (по 3 ядра на каждой ноде).  
Этого недостаточно, максимум нагрузка на ноду будет 2,5 ядра + 4,85Гб ОЗУ(1БД+ 1бэкенд+фронтенды).  
Не хватит минимум 1 ядра, т.к. из-за недостатка ОЗУ на нодах, не сможем задействовать для приложения  
все ядра полностью.  
Если взять ОЗУ по 8Гб(или больше), то решение становится рабочим и отказоустойчивым. Но это все-таки минимум.  
Получается 7 рабочих нод по 4 ядра 8Гб ОЗУ + мастер нода.  

Вариант с 5 нодами.  
Всего нужно 36ГБ ОЗУ и 22 ядра(с учетом самих нод).  
Каждая нода по 8Гб ОЗУ(всего 40) и 6 ядер(30 всего). Для приложения остается 7х5=35Гб, 5х5=25 ядер. На каждой  
ноде для приложения остается 7ГБ ОЗУ и 5 ядер.  
Но не хватит ОЗУ для БД и кэша, учитывая что нод всего пять,а на каждой уместиться только по 1 экземпляру пода  
с БД или кэшем(по памяти), свободные же  ядра есть.  
Памяти нужно добавить минимум до 10Гб, тогда решение становится рабочим и отказоустойчивым(и минимальным опять же).  
Получается 5 рабочих нод по 6 ядер 10ГБ ОЗУ + мастер нода.  

Наверное, подходящие варианты можно подобрать для разного кол-ва нод, вопрос в стоимости(экономим\не экономим ;-).
Почитал статьи, большее количество нод(в разумных пределах) выгоднее в плане плавного масштабирования,  
обновления, снижения нагрузки на отдельную ноду(но увеличивает нагрузку на мастер ноду и сложнее в управлении).  
Можно также предложить 1 рабочую ноду 32Гб и 22 ядра, это подешевле, но страшненько.  :smile:  
В этой задаче думаю минимальное количество рабочих нод - 5, например - 3 для распределения БД и кэша,  
одна для бэкенда и фронтенда(не все обязательно на одной ноде), и еще одна для возможности перераспределения  
подов в случае отказа любой из нод.  
Мой вариант ответа 5 рабочих нод по 6 ядер 10ГБ ОЗУ + мастер нода.  
