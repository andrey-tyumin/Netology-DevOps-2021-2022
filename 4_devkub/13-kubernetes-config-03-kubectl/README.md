## Домашнее задание к занятию "13.3 работа с kubectl"
### Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

Скриншоты:  
1 вариант - с помощью созданного пода из оф. образа curl
![curlimage](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-03-kubectl/screens/screen133-1.png)  


2 вариант - с помощью созданного пода из образа nettools (kubectl exec ко всем сервисам из этого пода).  
![nettoolimage](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-03-kubectl/screens/screen133-2.png)  


3 вариант - с помощью port-forward  
![portforward](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-03-kubectl/screens/screen133-3.png)  


вывод последней команды из предыдущего скрина:  
![psqloutput](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-03-kubectl/screens/screen133-4.png)  




### Задание 2: ручное масштабирование
При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, 
попробуйте увеличить количество бекенда и фронта до 3. После уменьшите количество копий до 1. Проверьте, на каких 
нодах оказались копии после каждого действия (kubectl describe).  

Скриншот:  

![scale](https://github.com/andrey-tyumin/netology-devkub-homeworks/blob/main/13-kubernetes-config-03-kubectl/screens/screen133-21.png)  
