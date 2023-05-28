### Домашнее задание к занятию "08.03 Использование Yandex Cloud"
Машины в облаке разворачиваются terraform-ом, также им заполняется файл inventory/prod/hosts.yml, и на машины  
добавляется пользователь и ключ, для работы ansible.  
Файлы для развертывания прилагаются.  
Токен прописываем в строке запуска:  
```
terraform apply -var="token=....."  
```
### 5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.  
ansible-lint традиционно выдает мне ошибку(пока не разобрался как исправить), но онлайн линтеры говорят "Ok":  
```
root@vps13419:~/83# ansible-lint ./site.yml
Couldn't parse task at site.yml:17 (conflicting action statements: get_url, __line__

The error appears to be in '<unicode string>': line 17, column 7, but may
be elsewhere in the file depending on the exact syntax problem.

(could not open file to display line))
{ 'get_url': { '__file__': 'site.yml',
               '__line__': 19,
               'dest': '/tmp/elasticsearch-{{ elk_stack_version }}-x86_64.rpm',
               'url': 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ '
                      'elk_stack_version }}-x86_64.rpm'},
  'name': "Download Elasticsearch's rpm",
  'register': 'download_elastic',
  'skipped_rules': [],
  'until': 'download_elastic is succeeded'}
  ```
### 6. Попробуйте запустить playbook на этом окружении с флагом `--check`.  
ansible-playbook с флагом --check, вываливается на отсутствующем файле, т.к. он не скачан(playbook не работал еще):  
```
root@vps13419:~/83# ansible-playbook site.yml -i inventory/prod/ --check
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Elasticsearch] *************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Download Elasticsearch's rpm] ******************************************************************************************************************************************************************************************************changed: [elasticsearch]

TASK [Install Elasticsearch] *************************************************************************************************************************************************************************************************************fatal: [elasticsearch]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/elasticsearch-7.14.0-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/elasticsearch-7.14.0-x86_64.rpm' found on system"]}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************elasticsearch              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

### 7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
```
root@vps13419:~/83# ansible-playbook site.yml -i inventory/prod/ --diff 
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Elasticsearch] *************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Download Elasticsearch's rpm] ******************************************************************************************************************************************************************************************************changed: [elasticsearch]

TASK [Install Elasticsearch] *************************************************************************************************************************************************************************************************************changed: [elasticsearch]

TASK [Configure Elasticsearch] ***********************************************************************************************************************************************************************************************************--- before: /etc/elasticsearch/elasticsearch.yml
+++ after: /root/.ansible/tmp/ansible-local-146090k1ozssrg/tmpiy16fjbg/elasticsearch.yml.j2
@@ -1,82 +1,7 @@
-# ======================== Elasticsearch Configuration =========================
-#
-# NOTE: Elasticsearch comes with reasonable defaults for most settings.
-#       Before you set out to tweak and tune the configuration, make sure you
-#       understand what are you trying to accomplish and the consequences.
-#
-# The primary way of configuring a node is via this file. This template lists
-# the most important settings you may want to configure for a production cluster.
-#
-# Please consult the documentation for further information on configuration options:
-# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
-#
-# ---------------------------------- Cluster -----------------------------------
-#
-# Use a descriptive name for your cluster:
-#
-#cluster.name: my-application
-#
-# ------------------------------------ Node ------------------------------------
-#
-# Use a descriptive name for the node:
-#
-#node.name: node-1
-#
-# Add custom attributes to the node:
-#
-#node.attr.rack: r1
-#
-# ----------------------------------- Paths ------------------------------------
-#
-# Path to directory where to store the data (separate multiple locations by comma):
-#
 path.data: /var/lib/elasticsearch
-#
-# Path to log files:
-#
 path.logs: /var/log/elasticsearch
-#
-# ----------------------------------- Memory -----------------------------------
-#
-# Lock the memory on startup:
-#
-#bootstrap.memory_lock: true
-#
-# Make sure that the heap size is set to about half the memory available
-# on the system and that the owner of the process is allowed to use this
-# limit.
-#
-# Elasticsearch performs poorly when the system is swapping the memory.
-#
-# ---------------------------------- Network -----------------------------------
-#
-# By default Elasticsearch is only accessible on localhost. Set a different
-# address here to expose this node on the network:
-#
-#network.host: 192.168.0.1
-#
-# By default Elasticsearch listens for HTTP traffic on the first free port it
-# finds starting at 9200. Set a specific HTTP port here:
-#
-#http.port: 9200
-#
-# For more information, consult the network module documentation.
-#
-# --------------------------------- Discovery ----------------------------------
-#
-# Pass an initial list of hosts to perform discovery when this node is started:
-# The default list of hosts is ["127.0.0.1", "[::1]"]
-#
-#discovery.seed_hosts: ["host1", "host2"]
-#
-# Bootstrap the cluster using an initial set of master-eligible nodes:
-#
-#cluster.initial_master_nodes: ["node-1", "node-2"]
-#
-# For more information, consult the discovery and cluster formation module documentation.
-#
-# ---------------------------------- Various -----------------------------------
-#
-# Require explicit names when deleting indices:
-#
-#action.destructive_requires_name: true
+network.host: 0.0.0.0
+discovery.seed_hosts: ["10.130.0.3"]
+node.name: node-a
+cluster.initial_master_nodes: 
+   - node-a

changed: [elasticsearch]

RUNNING HANDLER [restart Elasticsearch] **************************************************************************************************************************************************************************************************changed: [elasticsearch]

PLAY [Install Kibana] ********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Download Kibana] *******************************************************************************************************************************************************************************************************************changed: [kibana]

TASK [Install Kibana] ********************************************************************************************************************************************************************************************************************changed: [kibana]

TASK [Configure Kibana] ******************************************************************************************************************************************************************************************************************--- before: /etc/kibana/kibana.yml
+++ after: /root/.ansible/tmp/ansible-local-146090k1ozssrg/tmpu88yqlrm/kibana.yml.j2
@@ -1,111 +1,3 @@
-# Kibana is served by a back end server. This setting specifies the port to use.
-#server.port: 5601
-
-# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
-# The default is 'localhost', which usually means remote machines will not be able to connect.
-# To allow connections from remote users, set this parameter to a non-loopback address.
-#server.host: "localhost"
-
-# Enables you to specify a path to mount Kibana at if you are running behind a proxy.
-# Use the `server.rewriteBasePath` setting to tell Kibana if it should remove the basePath
-# from requests it receives, and to prevent a deprecation warning at startup.
-# This setting cannot end in a slash.
-#server.basePath: ""
-
-# Specifies whether Kibana should rewrite requests that are prefixed with
-# `server.basePath` or require that they are rewritten by your reverse proxy.
-# This setting was effectively always `false` before Kibana 6.3 and will
-# default to `true` starting in Kibana 7.0.
-#server.rewriteBasePath: false
-
-# Specifies the public URL at which Kibana is available for end users. If
-# `server.basePath` is configured this URL should end with the same basePath.
-#server.publicBaseUrl: ""
-
-# The maximum payload size in bytes for incoming server requests.
-#server.maxPayload: 1048576
-
-# The Kibana server's name.  This is used for display purposes.
-#server.name: "your-hostname"
-
-# The URLs of the Elasticsearch instances to use for all your queries.
-#elasticsearch.hosts: ["http://localhost:9200"]
-
-# Kibana uses an index in Elasticsearch to store saved searches, visualizations and
-# dashboards. Kibana creates a new index if the index doesn't already exist.
-#kibana.index: ".kibana"
-
-# The default application to load.
-#kibana.defaultAppId: "home"
-
-# If your Elasticsearch is protected with basic authentication, these settings provide
-# the username and password that the Kibana server uses to perform maintenance on the Kibana
-# index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
-# is proxied through the Kibana server.
-#elasticsearch.username: "kibana_system"
-#elasticsearch.password: "pass"
-
-# Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
-# These settings enable SSL for outgoing requests from the Kibana server to the browser.
-#server.ssl.enabled: false
-#server.ssl.certificate: /path/to/your/server.crt
-#server.ssl.key: /path/to/your/server.key
-
-# Optional settings that provide the paths to the PEM-format SSL certificate and key files.
-# These files are used to verify the identity of Kibana to Elasticsearch and are required when
-# xpack.security.http.ssl.client_authentication in Elasticsearch is set to required.
-#elasticsearch.ssl.certificate: /path/to/your/client.crt
-#elasticsearch.ssl.key: /path/to/your/client.key
-
-# Optional setting that enables you to specify a path to the PEM file for the certificate
-# authority for your Elasticsearch instance.
-#elasticsearch.ssl.certificateAuthorities: [ "/path/to/your/CA.pem" ]
-
-# To disregard the validity of SSL certificates, change this setting's value to 'none'.
-#elasticsearch.ssl.verificationMode: full
-
-# Time in milliseconds to wait for Elasticsearch to respond to pings. Defaults to the value of
-# the elasticsearch.requestTimeout setting.
-#elasticsearch.pingTimeout: 1500
-
-# Time in milliseconds to wait for responses from the back end or Elasticsearch. This value
-# must be a positive integer.
-#elasticsearch.requestTimeout: 30000
-
-# List of Kibana client-side headers to send to Elasticsearch. To send *no* client-side
-# headers, set this value to [] (an empty list).
-#elasticsearch.requestHeadersWhitelist: [ authorization ]
-
-# Header names and values that are sent to Elasticsearch. Any custom headers cannot be overwritten
-# by client-side headers, regardless of the elasticsearch.requestHeadersWhitelist configuration.
-#elasticsearch.customHeaders: {}
-
-# Time in milliseconds for Elasticsearch to wait for responses from shards. Set to 0 to disable.
-#elasticsearch.shardTimeout: 30000
-
-# Logs queries sent to Elasticsearch. Requires logging.verbose set to true.
-#elasticsearch.logQueries: false
-
-# Specifies the path where Kibana creates the process ID file.
-#pid.file: /run/kibana/kibana.pid
-
-# Enables you to specify a file where Kibana stores log output.
-#logging.dest: stdout
-
-# Set the value of this setting to true to suppress all logging output.
-#logging.silent: false
-
-# Set the value of this setting to true to suppress all logging output other than error messages.
-#logging.quiet: false
-
-# Set the value of this setting to true to log all events, including system usage information
-# and all requests.
-#logging.verbose: false
-
-# Set the interval in milliseconds to sample system and process performance
-# metrics. Minimum is 100ms. Defaults to 5000.
-#ops.interval: 5000
-
-# Specifies locale to be used for all localizable strings, dates and number formats.
-# Supported languages are the following: English - en , by default , Chinese - zh-CN .
-#i18n.locale: "en"
+server.host: "10.130.0.32"
+elasticsearch.hosts: "http://10.130.0.3:9200"
+kibana.index: ".kibana"

changed: [kibana]

TASK [Enable kibana service] *************************************************************************************************************************************************************************************************************changed: [kibana]

TASK [Open kibana port] ******************************************************************************************************************************************************************************************************************changed: [kibana]

PLAY [Install filebeat] ******************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [filebeat]

TASK [Download filebeat] *****************************************************************************************************************************************************************************************************************changed: [filebeat]

TASK [Install filebeat] ******************************************************************************************************************************************************************************************************************changed: [filebeat]

TASK [Enable filebeat service] ***********************************************************************************************************************************************************************************************************changed: [filebeat]

PLAY RECAP *******************************************************************************************************************************************************************************************************************************elasticsearch              : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
filebeat                   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
kibana                     : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
### 8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
```
root@vps13419:~/83# ansible-playbook site.yml -i inventory/prod/ --diff
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Elasticsearch] *************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Download Elasticsearch's rpm] ******************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Install Elasticsearch] *************************************************************************************************************************************************************************************************************ok: [elasticsearch]

TASK [Configure Elasticsearch] ***********************************************************************************************************************************************************************************************************ok: [elasticsearch]

PLAY [Install Kibana] ********************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Download Kibana] *******************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Install Kibana] ********************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Configure Kibana] ******************************************************************************************************************************************************************************************************************ok: [kibana]

TASK [Enable kibana service] *************************************************************************************************************************************************************************************************************changed: [kibana]

TASK [Open kibana port] ******************************************************************************************************************************************************************************************************************ok: [kibana]

PLAY [Install filebeat] ******************************************************************************************************************************************************************************************************************
TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************ok: [filebeat]

TASK [Download filebeat] *****************************************************************************************************************************************************************************************************************ok: [filebeat]

TASK [Install filebeat] ******************************************************************************************************************************************************************************************************************ok: [filebeat]

TASK [Enable filebeat service] ***********************************************************************************************************************************************************************************************************changed: [filebeat]

PLAY RECAP *******************************************************************************************************************************************************************************************************************************elasticsearch              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
filebeat                   : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
kibana                     : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
changed=1 из-за рестартов сервисов через модуль systemd
