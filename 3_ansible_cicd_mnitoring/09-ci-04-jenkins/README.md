## Домашнее задание к занятию "09.04 Jenkins"

### Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

### Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.  
[Jenkinsfile](https://github.com/andrey-tyumin/mnt-homeworks-ansible/blob/main/Jenkinsfile)  
Текст:  
```
pipeline {
    agent {
        node {
            label "linux"
        }
    }
    stages {
        stage('Checkout'){
            steps{
                    dir('mnt-homeworks-ansible') {
                    git branch: 'main', url: 'https://github.com/andrey-tyumin/mnt-homeworks-ansible.git'
                    }
                }
            }
        stage('Install requirements'){
            steps{
                dir('mnt-homeworks-ansible') {
                sh 'python3 -m pip install -r test-requirements.txt'
                }
            }
        }
        stage('Mkdir'){
            steps{
                dir('mnt-homeworks-ansible') {
                sh 'mkdir -p ./molecule/default/files'
                }
            }
        }
        stage('Run molecule'){
            steps{
                dir('mnt-homeworks-ansible') {
                sh 'molecule test'
                }
            }
            
        }
    }
}
```
4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.  

[ScriptedJenkinsfile](https://github.com/andrey-tyumin/mnt-homeworks-ansible/blob/main/ScriptedJenkinsfile)  
Текст:
```
node("linux"){
    stage("Git checkout"){
       git branch: 'main', url: 'https://github.com/andrey-tyumin/mnt-homeworks-ansible.git'
        }
    stage("Define prod_run"){
        prod_run=false
    }
    stage("Run playbook"){
        if (params.prod_run==true){
            sh 'ansible-playbook site.yml -i inventory/prod.yml'
        }
        else{
            sh 'ansible-playbook site.yml -i inventory/prod.yml --check --diff'
        }
        
    }
}
```
8. Отправить ссылку на репозиторий в ответе.  
https://github.com/andrey-tyumin/mnt-homeworks-ansible.git
