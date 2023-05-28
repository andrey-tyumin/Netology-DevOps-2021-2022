### hw4.2


**1. Есть скрипт:**
```
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```
**Какое значение будет присвоено переменной c?**  
Никакое. Ошибка сложение числа и строки

**Как получить для переменной c значение 12?**  
Определить a как строку: a = '1'

**Как получить для переменной c значение 3?**  
Определить b как число: b = 2

---

**2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer.  
Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории,  
относительно локальных изменений. Этим скриптом недовольно начальство, потому что  
в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории,  
где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования  
вашего руководителя?**  
```
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```
Ответ:
```
#!/usr/bin/env python3

import os

giton ="~/netology/sysadm-homeworks"
bash_command = ["cd "+giton, "git ls-files --modified"]
result_os = os.popen(' && '.join(bash_command)).read()

print("Modified files:")
for result in result_os.split('\n'):
    if result == "": continue
    print(giton+result)
```
---

**3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий  
в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём  
как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу  
этого скрипта в директориях, которые не являются локальными репозиториями.**  

Ответ:
```
#!/usr/bin/env python3

import os
import sys
indir = ''
if len(sys.argv) == 1:
    indir = os.getcwd()
else:
    indir = sys.argv[1]
if not os.path.exists(indir + '/.git'):
    print('No local repository! ')
    sys.exit(0)

bash_command = ["cd {}".format(indir), "git status -uall"]
result_os = indir + '\n' + os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```
---

**4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем,  
что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP  
сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой  
очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы  
сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера  
не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим  
написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный  
вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего  
IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в  
стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать,  
что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.**  
```
#!/usr/bin/env python3

import os
import socket

log_file = './log.txt'
remotes = ('drive.google.com', 'mail.google.com', 'google.com')

if not os.path.isfile(log_file):
    open(log_file, 'a')
    file = open(log_file, "w")
    for i in range(0, 3):
        file.write(socket.gethostbyname(remotes[i])+'\n')
    file.close()
    print('No old data, first run, logging to file')
else:
    with open(log_file) as f:
        old_data = f.readlines()
        old_data = [line.rstrip() for line in old_data]
    file = open(log_file, "w")
    for i in range(0, 3):
        new_data_str = socket.gethostbyname(remotes[i])
        file.write(new_data_str + '\n')
        if old_data[i] != new_data_str:
            print('[ERROR] '+remotes[i]+' IP mismatch: Old IP= '+old_data[i]+', New IP= '+new_data_str)
        else:
            print(remotes[i]+' '+new_data_str+' Ok')
    file.close()
```
