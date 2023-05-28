### hw4.3
1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
{ "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip : 71.78.22.43
        }
    ]
}
```
Нужно найти и исправить все ошибки, которые допускает наш сервис

Ответ: 
```
{ "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```
---

В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP.  
К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих  
наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по  
одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он  
должен так же поменяться в yml и json файле.

```
#!/usr/bin/env python3

import os
import socket
import yaml
import json

log_file = './log.txt'
remotes = ('drive.google.com', 'mail.google.com', 'google.com')
d = []
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
        d.append({remotes[i]: new_data_str})
        file.write(new_data_str + '\n')
        if old_data[i] != new_data_str:
            print('[ERROR] '+remotes[i]+' IP mismatch: Old IP= '+old_data[i]+', New IP= '+new_data_str)
        else:
            print(remotes[i]+' '+new_data_str+' Ok')
    file.close()
with open('out.yaml', 'w') as file:
    yaml.dump(d, file, sort_keys=False, default_flow_style=False, explicit_start=True)
with open('out.json', 'w') as file:
    json.dump(d, file)
```
