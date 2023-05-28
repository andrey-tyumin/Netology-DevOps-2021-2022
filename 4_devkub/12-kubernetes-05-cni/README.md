## Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
### Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)  

### Ответ.  
Разворачивал через kuberspray из предыдущего дз(ничего не менял). Вывод не прилагаю, все также.  
Проверим, что ничего нет:  
```
[andrey@cp ~]$ kubectl get deploy,svc,po
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.233.0.1   <none>        443/TCP   4h5m
```
Создадим deployment и service:
```
[andrey@cp ~]$ kubectl create deployment hello --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello created
[andrey@cp ~]$ kubectl expose deployment hello --port=80 --target-port=8080
service/hello exposed
```
Проверим, что все создалось:
```
[andrey@cp ~]$ kubectl get deploy,svc,po
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello   1/1     1            1           34s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/hello        ClusterIP   10.233.58.99   <none>        80/TCP    6s
service/kubernetes   ClusterIP   10.233.0.1     <none>        443/TCP   4h6m

NAME                         READY   STATUS    RESTARTS   AGE
pod/hello-75897c77f8-d7lss   1/1     Running   0          34s
```
Создадим под(с контейнером busybox) и проверим из него доступ:
```
[andrey@cp ~]$ kubectl run busybox --rm -ti --image=busybox -- /bin/sh
If you don't see a command prompt, try pressing enter.
/ # wget --spider --timeout=1 hello
Connecting to hello (10.233.58.99:80)
remote file exists
/ # exit
Session ended, resume using 'kubectl attach busybox -c busybox -i -t' command when the pod is running
pod "busybox" deleted
```

Доступ есть.

Создадим файл с политикой:  
```
[andrey@cp ~]$ vi netpol.yaml 
[andrey@cp ~]$ cat netpol.yaml 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: access
spec:
  podSelector:
    matchLabels:
      app: hello
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: "true"
```
Применим политику:
```
[andrey@cp ~]$ kubectl apply -f netpol.yaml 
networkpolicy.networking.k8s.io/access created
```
Проверим:
```
[andrey@cp ~]$ kubectl get networkpolicies 
NAME     POD-SELECTOR   AGE
access   app=hello      21m
[andrey@cp ~]$ kubectl describe networkpolicies access
Name:         access
Namespace:    default
Created on:   2022-01-31 12:02:21 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=hello
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: access=true
  Not affecting egress traffic
  Policy Types: Ingress
[andrey@cp ~]$ 

```
проверим доступ:
```
[andrey@cp ~]$ kubectl run busybox --rm -ti --image=busybox -- /bin/sh
If you don't see a command prompt, try pressing enter.
/ # wget --spider --timeout=1 hello
Connecting to hello (10.233.58.99:80)
wget: download timed out
/ # exit
Session ended, resume using 'kubectl attach busybox -c busybox -i -t' command when the pod is running
pod "busybox" deleted
```
Доступа нет.  
Запустим под с "нужной" меткой и проверим доступ.
```
[andrey@cp ~]$ kubectl run busybox1 --rm -ti --labels="access=true" --image=busybox -- /bin/sh
If you don't see a command prompt, try pressing enter.
/ # wget --spider --timeout=1 hello
Connecting to hello (10.233.58.99:80)
remote file exists
/ # 
```
Доступ есть.

### Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.   

### Ответ:  
```
[andrey@cp ~]$ calicoctl get node
NAME    
cp      
node1   
node2   
node3   
node4   

[andrey@cp ~]$ calicoctl get ipPool
NAME           CIDR             SELECTOR   
default-pool   10.233.64.0/18   all()    

[andrey@cp ~]$ calicoctl get profile
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-kube-controllers              
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       
```
