## Домашнее задание к занятию "15.1. Организация сети"

Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию. Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. 

Перед началом работ следует настроить доступ до облачных ресурсов из Terraform используя материалы прошлых лекций и [ДЗ](https://github.com/netology-code/virt-homeworks/tree/master/07-terraform-02-syntax ). А также заранее выбрать регион (в случае AWS) и зону.

---
### Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать VPC.
- Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 192.168.10.0/24.
- Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1
- Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 192.168.20.0/24.
- Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
- Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

Resource terraform для ЯО
- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet)
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table)
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance)
---
### Ответ:  
В каталоге с прилагаемыми файлами [main.tf](https://github.com/andrey-tyumin/clokub-homeworks/blob/main/15.1-network/main.tf), [outputs.tf](https://github.com/andrey-tyumin/clokub-homeworks/blob/main/15.1-network/outputs.tf),
[variables.tf](https://github.com/andrey-tyumin/clokub-homeworks/blob/main/15.1-network/variables.tf), [metadata.txt](https://github.com/andrey-tyumin/clokub-homeworks/blob/main/15.1-network/metadata.txt) делаем:
```
terraform init
terraform plan
terraform apply
```
В конце terraform выдаст public адрес vm1(хост в public подсети) и private адрес vm2(хост в private подсети):  
```
Outputs:

vm1_external_address = "51.250.66.188"
vm2_internal_address = "192.168.20.24"
root@vps13419:~/151#
```
Подключаюсь к vm2 через vm1:  
```
root@vps13419:~/151# ssh -J andrey@51.250.66.188 andrey@192.168.20.24
The authenticity of host '51.250.66.188 (51.250.66.188)' can't be established.
ECDSA key fingerprint is SHA256:p4QCJe89TBeeME3SOXeiNOP6YzSp8sUV8KtmgygpaVY.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '51.250.66.188' (ECDSA) to the list of known hosts.
The authenticity of host '192.168.20.24 (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:UfjTfv9eCXg6k5zJhNdZhaq9DmC79MFDkV9Txzr4/p0.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.20.24' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

andrey@fhm4ifuab13m6qlq85dj:~$
```
Проверяю адрес и маршруты:  
```
andrey@fhm4ifuab13m6qlq85dj:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:0d:49:3f:ca:58 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.24/24 brd 192.168.20.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d20d:49ff:fe3f:ca58/64 scope link
       valid_lft forever preferred_lft forever
andrey@fhm4ifuab13m6qlq85dj:~$ ip r
default via 192.168.20.1 dev eth0 proto dhcp src 192.168.20.24 metric 100
192.168.20.0/24 dev eth0 proto kernel scope link src 192.168.20.24
192.168.20.1 dev eth0 proto dhcp scope link src 192.168.20.24 metric 100
andrey@fhm4ifuab13m6qlq85dj:~$
```
Пингую сервисы в интернете:  
```
andrey@fhm4ifuab13m6qlq85dj:~$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=58 time=6.71 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=58 time=4.28 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=58 time=4.04 ms
^C
--- 1.1.1.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 4.038/5.010/6.708/1.204 ms
andrey@fhm4ifuab13m6qlq85dj:~$ ping ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=56 time=4.64 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=56 time=0.808 ms
^C
--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.808/2.723/4.638/1.915 ms
andrey@fhm4ifuab13m6qlq85dj:~$
```
Работает.  
