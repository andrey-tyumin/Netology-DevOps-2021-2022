### Файлы для развертывания стенда по дз "9.5 TeamCity"  
###### Памятка для себя.  
Сделал файлы для разворачивания стенда по дз 9.5 с помощью Terraform.    
Все, что относится к ансиблу(разворот Nexus) - взято из репозитория с дз.  
Разворачиваются 3 машинки в ЯОблаке: TeamCity-Server, TeamCity-agent и Nexus.  
TeamCity-server и TeamCity-agent разворачиваются на COI образах, на них заливается докер образы и запускаются  
соотв. контейнеры(после отработки терраформа нужно немного ~2 мин. подождать).  
В TeamCity-agent в контейнер прокидывается переменная SERVER_URL с адресом и портом TeamCity-server.  
Процесс:
```
terraform plan
terraform apply var="token=тут ваш токен"
```
Inventory файл для ansible формируется в infrastructure/inventory/cicd/hosts.yml.  
После того, как отработал Terraform, можно разворачивать Nexus с помощью ansible (из директории infrastructure):
```
ansible-playbook site.yml -i infrastructure/inventory/cicd/hosts.yml
```
Репозиторий со сделанным дз: https://github.com/andrey-tyumin/example-teamcity  
