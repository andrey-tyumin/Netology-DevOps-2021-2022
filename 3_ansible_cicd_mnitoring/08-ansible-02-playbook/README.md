#### 5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
ansible-lint выдает ошибку. В чем проблема не понял(точнее как исправить).  
Ошибка 
```
conflicting action statements: set_fact, __line__
```
насколько я понял говорит о неправильном объявлении переменной
Все онлайн линтеры говорят "Ок".  
Пробовал много вариантов написать по другому- появляются другие ошибки. :neutral_face:
```
root@vps13419:~# ansible-lint 82/playbook/site.yml
Couldn't parse task at 82/playbook/site.yml:5 (conflicting action statements: set_fact, __line__

The error appears to be in '<unicode string>': line 5, column 7, but may
be elsewhere in the file depending on the exact syntax problem.

(could not open file to display line))
{ 'name': 'Set facts for Java 11 vars',
  'set_fact': { '__file__': '82/playbook/site.yml',
                '__line__': 7,
                'java_home': '/opt/jdk/{{ java_jdk_version }}'},
  'skipped_rules': [],
  'tags': 'java'}
```
---

#### 6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
ansible-playbook с флагом --check сваливается, по причине отсутствия дирестории, т.к. она не создана(playbook еще не работал):
```
root@vps13419:~/82/playbook# ansible-playbook site.yml -i inventory/prod.yml --check
[WARNING]: Found both group and host with same name: kibana
[WARNING]: Found both group and host with same name: elasticsearch
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Java] **********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [kibana]
ok: [elasticsearch]

TASK [Set facts for Java 11 vars] ********************************************************************************************************************************************************************************************************ok: [elasticsearch]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ************************************************************************************************************************************************************************changed: [elasticsearch]
changed: [kibana]

TASK [Ensure installation dir exists] ****************************************************************************************************************************************************************************************************changed: [kibana]
changed: [elasticsearch]

TASK [Extract java in the installation directory] ****************************************************************************************************************************************************************************************An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [kibana]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.12' must be an existing dir"}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [elasticsearch]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.12' must be an existing dir"}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************elasticsearch              : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
kibana                     : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```
---

#### 7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
```
root@vps13419:~/82/playbook# ansible-playbook site.yml -i inventory/prod.yml --diff 
[WARNING]: Found both group and host with same name: kibana
[WARNING]: Found both group and host with same name: elasticsearch
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Java] **********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [kibana]
ok: [elasticsearch]

TASK [Set facts for Java 11 vars] ********************************************************************************************************************************************************************************************************ok: [elasticsearch]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ************************************************************************************************************************************************************************diff skipped: source file size is greater than 104448
changed: [kibana]
diff skipped: source file size is greater than 104448
changed: [elasticsearch]

TASK [Ensure installation dir exists] ****************************************************************************************************************************************************************************************************--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.12",
-    "state": "absent"
+    "state": "directory"
 }

changed: [kibana]
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.12",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elasticsearch]

TASK [Extract java in the installation directory] ****************************************************************************************************************************************************************************************changed: [elasticsearch]
changed: [kibana]

TASK [Export environment variables] ******************************************************************************************************************************************************************************************************--- before
+++ after: /root/.ansible/tmp/ansible-local-11378jcefrnya/tmp1v2hwcik/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.12
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [elasticsearch]
--- before
+++ after: /root/.ansible/tmp/ansible-local-11378jcefrnya/tmp7ja76rzy/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.12
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [kibana]

PLAY [Install Elasticsearch] *************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ***************************************************************************************************************************************************************************************changed: [elasticsearch]

TASK [Create directrory for Elasticsearch] ***********************************************************************************************************************************************************************************************--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/elastic/7.10.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] *******************************************************************************************************************************************************************************changed: [elasticsearch]

TASK [Set environment Elastic] ***********************************************************************************************************************************************************************************************************--- before
+++ after: /root/.ansible/tmp/ansible-local-11378jcefrnya/tmp07s9wb8w/elk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/elastic/7.10.1
+export PATH=$PATH:$ES_HOME/bin
\ No newline at end of file

changed: [elasticsearch]

PLAY [Install Kibana] ********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Upload kibana] *********************************************************************************************************************************************************************************************************************changed: [kibana]

TASK [Create kibana directory] ***********************************************************************************************************************************************************************************************************--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/kibana/7.14.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [kibana]

TASK [Extract kibana in home directory] **************************************************************************************************************************************************************************************************changed: [kibana]

TASK [Set kibana environment] ************************************************************************************************************************************************************************************************************--- before
+++ after: /root/.ansible/tmp/ansible-local-11378jcefrnya/tmp2oduswlx/ki.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KIBANA_HOME=/opt/kibana/7.14.1
+export PATH=$PATH:$KIBANA_HOME/bin

changed: [kibana]

PLAY RECAP *******************************************************************************************************************************************************************************************************************************elasticsearch              : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
kibana                     : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
---

#### 8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
```
root@vps13419:~/82/playbook# ansible-playbook site.yml -i inventory/prod.yml --diff
[WARNING]: Found both group and host with same name: elasticsearch
[WARNING]: Found both group and host with same name: kibana
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Java] **********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [elasticsearch]
ok: [kibana]

TASK [Set facts for Java 11 vars] ********************************************************************************************************************************************************************************************************ok: [elasticsearch]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ************************************************************************************************************************************************************************ok: [kibana]
ok: [elasticsearch]

TASK [Ensure installation dir exists] ****************************************************************************************************************************************************************************************************ok: [kibana]
ok: [elasticsearch]

TASK [Extract java in the installation directory] ****************************************************************************************************************************************************************************************skipping: [elasticsearch]
skipping: [kibana]

TASK [Export environment variables] ******************************************************************************************************************************************************************************************************ok: [elasticsearch]
ok: [kibana]

PLAY [Install Elasticsearch] *************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ***************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Create directrory for Elasticsearch] ***********************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] *******************************************************************************************************************************************************************************skipping: [elasticsearch]

TASK [Set environment Elastic] ***********************************************************************************************************************************************************************************************************ok: [elasticsearch]

PLAY [Install Kibana] ********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Upload kibana] *********************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Create kibana directory] ***********************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Extract kibana in home directory] **************************************************************************************************************************************************************************************************skipping: [kibana]

TASK [Set kibana environment] ************************************************************************************************************************************************************************************************************ok: [kibana]

PLAY RECAP *******************************************************************************************************************************************************************************************************************************elasticsearch              : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
kibana                     : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```
---

### 9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.  
Плейбук разворачивает Elasticsearch и Kibana на docker контейнерах.  
Теги плейбука:
```
# ansible-playbook site.yml --list-tags
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
[WARNING]: Could not match supplied host pattern, ignoring: elasticsearch
[WARNING]: Could not match supplied host pattern, ignoring: kibana

playbook: site.yml

  play #1 (all): Install Java   TAGS: []
      TASK TAGS: [java]

  play #2 (elasticsearch): Install Elasticsearch        TAGS: []
      TASK TAGS: [elastic]

  play #3 (kibana): Install Kibana      TAGS: []
      TASK TAGS: [kibana]
  ```
  Тег all - таски для всех хостов.  
  Тег elasticsearch - таски для установки elasticsearch.  
  Тег kibana - таски для установки kibana.  
  Переменные плейбука:  
  java_jdk_version - версия java. (11.0.12).   
  java_oracle_jdk_package - файл для установки(имя). ("jdk-{{ java_jdk_version }}_linux-x64_bin.tar.gz")  
  java_home - директория, куда устанавливаем java. ("/opt/jdk/{{ java_jdk_version }}")  
  elastic_version - версия ES для установки. (7.10.1)  
  elastic_home - директория для установки ES. ("/opt/elastic/{{ elastic_version }}")  
  kibana_version - версия kibana для установки. (7.14.1)  
  kibana_home - директория для установки kibana. ("/opt/kibana/{{ kibana_version }}")  
  
