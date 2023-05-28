## Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

### Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

### Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

### Ответ:  
Разворачивал терраформом. Инвентори формируется терраформом(темплэйт прилагается).  
Containerd в Kubespray по умолчанию: https://github.com/kubernetes-sigs/kubespray/blob/master/docs/containerd.md  
Последовательность действий:  
Сначала терраформ:  
```
terraform init
terraform plan
terraform apply var="token= тут нужен токен"
```
Далее подготовка к запуску Kubespray:  
Клонируем репозиторий:  
```
git clone https://github.com/kubernetes-sigs/kubespray.git
```
Копируем sample в myclaster и копируем сформированный inventory.ini:  
```
cp -r kubespray/inventory/sample/ kubespray/inventory/myclaster
cp ./inventory.ini kubespray/inventory/myclaster/
cat kubespray/inventory/myclaster/inventory.ini
```
Добавим в сертификат внешний ip адрес control plane(я вставил свой):  
```
sed -i '/# supplementary_addresses_in_ssl_keys:*/a supplementary_addresses_in_ssl_keys: [84.201.131.24]' kubespray/inventory/myclaster/group_vars/k8s_cluster/k8s-cluster.yml
cat kubespray/inventory/myclaster/group_vars/k8s_cluster/k8s-cluster.yml |grep supple
```
Зависимости:  
```
cd kubespray
pip install -r requirements.txt
```
Запуск создания кластера:  
```
ansible-playbook -i inventory/myclaster/inventory.ini -u andrey cluster.yml -b -v
```
После того, как плейбук отработает нужно будет скопировать /etc/kubernetes/admin.conf с control plane на локальную машину,  
поменять адрес в поле server на адрес control plane.  
И для проверки сделать:  
```
kubectl get nodes
```

Лог процесса(большая часть вывода вырезана - слишком много, вывод терраформа не стал приводить):
```
root@vps13419:~/124hw# git clone https://github.com/kubernetes-sigs/kubespray.git
Cloning into 'kubespray'...
remote: Enumerating objects: 58941, done.
remote: Counting objects: 100% (692/692), done.
remote: Compressing objects: 100% (397/397), done.
remote: Total 58941 (delta 262), reused 597 (delta 221), pack-reused 58249
Receiving objects: 100% (58941/58941), 17.35 MiB | 5.59 MiB/s, done.
Resolving deltas: 100% (33140/33140), done.
root@vps13419:~/124hw# cp -r kubespray/inventory/sample/ kubespray/inventory/myclaster
root@vps13419:~/124hw# cp ./inventory.ini kubespray/inventory/myclaster/
root@vps13419:~/124hw# cat kubespray/inventory/myclaster/inventory.ini
# ## Configure 'ip' variable to bind kubernetes services on a
# ## different ip than the default iface
# ## We should set etcd_member_name for etcd cluster. The node that is not a etcd member do not need to set the value, or can set the empty string value.
[all]
cp ansible_host=84.201.131.24  ip=10.130.0.10 etcd_member_name=etcd1
node1 ansible_host=84.201.130.235   ip=10.130.0.32
node2 ansible_host=84.201.135.161   ip=10.130.0.7
node3 ansible_host=84.201.132.67   ip=10.130.0.9
node4 ansible_host=62.84.124.108   ip=10.130.0.19

# ## configure a bastion host if your nodes are not directly reachable
# [bastion]
# bastion ansible_host=x.x.x.x ansible_user=some_user

[kube_control_plane]
cp

[etcd]
cp

[kube_node]
node1
node2
node3
node4

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
root@vps13419:~/124hw# sed -i '/# supplementary_addresses_in_ssl_keys:*/a supplementary_addresses_in_ssl_keys: [84.201.131.24]' kubespray/inventory/myclaster/group_vars/k8s_cluster/k8s-cluster.yml
root@vps13419:~/124hw# cat kubespray/inventory/myclaster/group_vars/k8s_cluster/k8s-cluster.yml |grep supple
# supplementary_addresses_in_ssl_keys: [10.0.0.1, 10.0.0.2, 10.0.0.3]
supplementary_addresses_in_ssl_keys: [84.201.131.24]
root@vps13419:~/124hw# cd kubespray          
root@vps13419:~/124hw/kubespray# pip install -r requirements.txt
Collecting ansible==3.4.0
  Using cached ansible-3.4.0.tar.gz (31.9 MB)
Collecting ansible-base==2.10.15
  Using cached ansible-base-2.10.15.tar.gz (6.1 MB)

root@vps13419:~/124hw/kubespray# ansible-playbook -i inventory/myclaster/inventory.ini -u andrey cluster.yml -b -v


PLAY RECAP *********************************************************************************************************************************************************************************************
cp                         : ok=682  changed=146  unreachable=0    failed=0    skipped=1139 rescued=0    ignored=2   
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=474  changed=95   unreachable=0    failed=0    skipped=650  rescued=0    ignored=0   
node2                      : ok=474  changed=95   unreachable=0    failed=0    skipped=649  rescued=0    ignored=0   
node3                      : ok=474  changed=95   unreachable=0    failed=0    skipped=649  rescued=0    ignored=0   
node4                      : ok=474  changed=95   unreachable=0    failed=0    skipped=649  rescued=0    ignored=0   

Tuesday 18 January 2022  11:49:32 +0300 (0:00:00.208)       0:20:51.095 ******* 
=============================================================================== 
kubernetes/preinstall : Install packages requirements ----------------------------------------------------------------------------------------------------------------------------------------- 103.73s
kubernetes/kubeadm : Join to cluster ----------------------------------------------------------------------------------------------------------------------------------------------------------- 26.66s
kubernetes/control-plane : kubeadm | Initialize first master ----------------------------------------------------------------------------------------------------------------------------------- 26.06s
network_plugin/calico : Wait for calico kubeconfig to be created ------------------------------------------------------------------------------------------------------------------------------- 21.84s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 20.10s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 19.04s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 16.92s
container-engine/crictl : download_file | Download item ---------------------------------------------------------------------------------------------------------------------------------------- 16.06s
container-engine/runc : download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------ 16.03s
container-engine/containerd : download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------ 15.92s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 15.89s
container-engine/nerdctl : download_file | Download item --------------------------------------------------------------------------------------------------------------------------------------- 15.71s
download : download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------- 15.22s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 14.99s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ------------------------------------------------------------------------------------------------------------------------------------ 14.02s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 11.67s
download : download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------- 11.34s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ------------------------------------------------------------------------------------------------------------------------- 11.25s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running ---------------------------------------------------------------------------------------------------------------------- 11.07s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------- 10.74s
root@vps13419:~/124hw/kubespray# ssh andrey@84.201.131.24
The authenticity of host '84.201.131.24 (84.201.131.24)' can't be established.
ECDSA key fingerprint is SHA256:/1Xa3rZXEAFNmVcc1ek/4+w25HBRvUXmqua+iHK/5ZY.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '84.201.131.24' (ECDSA) to the list of known hosts.
[andrey@cp ~]$ whoami
andrey
[andrey@cp ~]$ sudo chown -R andrey:andrey /etc/kubernetes/admin.conf
[andrey@cp ~]$ exit
logout
Connection to 84.201.131.24 closed.
root@vps13419:~/124hw/kubespray# scp andrey@84.201.131.24:/etc/kubernetes/admin.conf kubespray-do.conf
admin.conf                                                                                                                                                            100% 5645   910.0KB/s   00:00    
root@vps13419:~/124hw/kubespray# vi kubespray-do.conf 
root@vps13419:~/124hw/kubespray# cat kubespray-do.conf |grep server:
    server: https://84.201.131.24:6443
root@vps13419:~/124hw/kubespray# export KUBECONFIG=$PWD/kubespray-do.conf
root@vps13419:~/124hw/kubespray# kubectl get nodes
NAME    STATUS   ROLES                  AGE   VERSION
cp      Ready    control-plane,master   12m   v1.23.1
node1   Ready    <none>                 11m   v1.23.1
node2   Ready    <none>                 11m   v1.23.1
node3   Ready    <none>                 11m   v1.23.1
node4   Ready    <none>                 11m   v1.23.1
root@vps13419:~/124hw/kubespray# 
```
