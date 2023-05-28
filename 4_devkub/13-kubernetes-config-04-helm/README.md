## Задание 1: подготовить helm чарт для приложения  
Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:  
* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;  
* в переменных чарта измените образ приложения для изменения версии.  

[Файлы созданного чарта](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-04-helm/front)  
Использовал стенд из дз 13.1 с внешним nfs сервером.  
Дополнительно с помощью helm устанавливаем StorageClass провизионер для внешнего nfs сервера(нужен для postgresql чарта).  
Вот этот: [Kubernetes NFS Subdir External Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)  
Делал разворот с помощью субчартов: front зависит от back и postgresql(чисто для интереса).  
Postgresql чарт взял от bitnami: https://bitnami.com/stack/postgresql/helm  
Все параметры для postgresql забиты в values.yaml front-а.  
Т.к. зависимости от внешних чартов есть(postgresql), сначала сделал:  
```
helm dependency update
```
(Скачает в ./charts postgresql чарт от bitnami)  
Установил репо с чартом StorageClass provisioner для nfs сервера:
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
```
установил провизионер(адрес сервера внутренний указать):
```
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=10.130.0.21 \
    --set nfs.path=/
```
Получим StorageClass nfs-client(или меняем на свое, указав при установке --set storageClass.name=   ).

В values.yaml front-a добавил параметры для чарта postgresql:
```
  primary:
    persistence:
      storageClass: nfs-client
```
Потом устанавливаю приложение:
```
helm install test1 ./front
```
После установки проверяю:  
```
root@vps13419:~/13kubectl get po,svc,pv,pvc,sc
NAME                                                   READY   STATUS    RESTARTS   AGE
pod/db-0                                               1/1     Running   0          7m26s
pod/nfs-subdir-external-provisioner-7bd9b4b4cc-zb6n9   1/1     Running   0          101m
pod/test1-back-7cb9686595-hfxgw                        1/1     Running   0          5m18s
pod/test1-back-7cb9686595-nk7fz                        1/1     Running   0          5m18s
pod/test1-front-5d4cd5f8b5-p2spb                       1/1     Running   0          7m26s
pod/test1-front-5d4cd5f8b5-tqvps                       1/1     Running   0          7m26s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/db            ClusterIP   10.233.45.110   <none>        5432/TCP       7m27s
service/db-hl         ClusterIP   None            <none>        5432/TCP       7m27s
service/kubernetes    ClusterIP   10.233.0.1      <none>        443/TCP        2d6h
service/test1-back    ClusterIP   10.233.59.44    <none>        9000/TCP       7m27s
service/test1-front   NodePort    10.233.50.220   <none>        80:30080/TCP   7m27s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
persistentvolume/pvc-a3a380df-9ecb-4c76-be2f-c9ea3e6bde5d   8Gi        RWO            Delete           Bound    default/data-db-0   nfs-client              58m

NAME                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-db-0   Bound    pvc-a3a380df-9ecb-4c76-be2f-c9ea3e6bde5d   8Gi        RWO            nfs-client     58m

NAME                                     PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/nfs-client   cluster.local/nfs-subdir-external-provisioner   Delete          Immediate           true                   101m

root@vps13419:~/134/kube# helm list
NAME                            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                                   APP VERSION
nfs-subdir-external-provisioner default         1               2022-02-24 14:15:21.363379943 +0300 MSK deployed        nfs-subdir-external-provisioner-4.0.16  4.0.2      
test1                           default         1               2022-02-24 15:49:05.49009168 +0300 MSK  deployed        front-0.1.0                             1.0.0      
root@vps13419:~/134/kube# 
```
---

## Задание 2: запустить 2 версии в разных неймспейсах  
Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:  
* одну версию в namespace=app1;  
* вторую версию в том же неймспейсе;  
* третью версию в namespace=app2.  

Запускаю первую версию приложения в namespace app1:  
```
root@vps13419:~/134/kube# helm install testapp1 ./front --namespace app1 --create-namespace
```
Проверяю:  
```
root@vps13419:~/134/kube# kubectl get po -n app1
NAME                             READY   STATUS    RESTARTS   AGE
db-0                             0/1     Running   0          16s
testapp1-back-744ff65594-hcb5f   1/1     Running   0          16s
testapp1-back-744ff65594-snlmw   1/1     Running   0          16s
testapp1-front-fd6469c9c-hk7x5   1/1     Running   0          16s
testapp1-front-fd6469c9c-hmn9r   1/1     Running   0          16s
root@vps13419:~/134/kube# 
```
Пробую создать второй экземпляр приложения в namespace app1:  
```
root@vps13419:~/134/kube# helm install testapp11 ./front --namespace app1 --create-namespace
Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists. Unable to continue with install: Secret "db" in namespace "app1" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "testapp11": current value is "testapp1"
```
Не получилось создать, т.к. чарт postgresql создает secret с fullname чарта, а оно у меня прибито в values.yaml "fullnameOverride: db". Сделал это для передачи имени сервиса postgresql бэкенду. Пробовал через темплейты postgresql чарта получить имя сервиса, но там пошли ссылки из helper темплэйта в named темплейт, который не может быть обработан, т.к. субчарт имеет своё имя(я как-то так это понял). Не стал дальше разбираться, решил указать свой fullname.
Попробовал сменить fullnameOverride и заодно nodePort:  
```
root@vps13419:~/134/kube# helm install testapp11 ./front --namespace app1 --set postgresql.fullnameOverride=db1 --set service.nodePort=30082
NAME: testapp11
LAST DEPLOYED: Thu Feb 24 16:46:10 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
NOTES:
There should be a note here, Noah don't know what to write. Come up with something.
root@vps13419:~/134/kube# 
```
Проверил:  
```
root@vps13419:~/134/kube# helm list -n app1
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
testapp1        app1            1               2022-02-24 16:12:55.114902634 +0300 MSK deployed        front-0.1.0     1.0.0      
testapp11       app1            1               2022-02-24 16:46:10.493061254 +0300 MSK deployed        front-0.1.0     1.0.0      
root@vps13419:~/134/kube# 
```
Заработало.  

Пробую запустить третью версию в другом namespace:  
```
root@vps13419:~/134/kube# helm install testapp2 ./front --namespace app2 --create-namespace
Error: INSTALLATION FAILED: Service "testapp2-front" is invalid: spec.ports[0].nodePort: Invalid value: 30080: provided port is already allocated
root@vps13419:~/134/kube# 
```
На нодах прописан nodePort и он уже занят(первым приложением).  
Пробую поменять nodePort:  
```
root@vps13419:~/134/kube# helm install testapp2 ./front --namespace app2 --create-namespace --set service.nodePort=30081
NAME: testapp2
LAST DEPLOYED: Thu Feb 24 16:42:24 2022
NAMESPACE: app2
STATUS: deployed
REVISION: 1
NOTES:
There should be a note here, Noah don't know what to write. Come up with something.
root@vps13419:~/134/kube# helm list -n app2
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
testapp2        app2            1               2022-02-24 16:42:24.395946166 +0300 MSK deployed        front-0.1.0     1.0.0      
root@vps13419:~/134/kube# kubectl get po -n app2
NAME                              READY   STATUS    RESTARTS   AGE
db-0                              1/1     Running   0          45s
testapp2-back-779c5f94f9-jn8nb    1/1     Running   0          45s
testapp2-back-779c5f94f9-zhfsg    1/1     Running   0          45s
testapp2-front-748c799697-rp9dj   1/1     Running   0          45s
testapp2-front-748c799697-sstjg   1/1     Running   0          45s
root@vps13419:~/134/kube# 
```
Запустилось.  

Посмотрел список всех развернутых мною подов(обрезал системные поды):  
```
root@vps13419:~/134/kube# kubectl get po -A
NAMESPACE     NAME                                               READY   STATUS    RESTARTS      AGE
app1          db-0                                               1/1     Running   0             45m
app1          db1-0                                              1/1     Running   0             12m
app1          testapp1-back-744ff65594-hcb5f                     1/1     Running   0             45m
app1          testapp1-back-744ff65594-snlmw                     1/1     Running   0             45m
app1          testapp1-front-fd6469c9c-hk7x5                     1/1     Running   0             45m
app1          testapp1-front-fd6469c9c-hmn9r                     1/1     Running   0             45m
app1          testapp11-back-58c8dbb4fc-md9lz                    1/1     Running   0             12m
app1          testapp11-back-58c8dbb4fc-nd6ds                    1/1     Running   0             12m
app1          testapp11-front-684998655c-78ll5                   1/1     Running   0             12m
app1          testapp11-front-684998655c-bgs2q                   1/1     Running   0             12m
app2          db-0                                               1/1     Running   0             16m
app2          testapp2-back-779c5f94f9-jn8nb                     1/1     Running   0             16m
app2          testapp2-back-779c5f94f9-zhfsg                     1/1     Running   0             16m
app2          testapp2-front-748c799697-rp9dj                    1/1     Running   0             16m
app2          testapp2-front-748c799697-sstjg                    1/1     Running   0             16m
```

---

## Задание 3 (*): повторить упаковку на jsonnet  
Для изучения другого инструмента стоит попробовать повторить опыт упаковки из задания 1, только теперь с помощью инструмента jsonnet.  

Для работы с Jsonnet решил попробовать tanka от раработчиков grafana.  
С документацией у них не очень, на мой взгляд.  
Но штука интересная, хотя по возможностям helm-у сильно уступает(imho).  
https://github.com/grafana/tanka  
https://tanka.dev  
[Файлы для разворота приложения с tanka](https://github.com/andrey-tyumin/netology-devkub-homeworks/tree/main/13-kubernetes-config-04-helm/tanka)  
Установка:  
```
sudo curl -Lo /usr/local/bin/tk https://github.com/grafana/tanka/releases/latest/download/tk-linux-amd64
```
и еще Jsonnet Bundler:  
```
sudo curl -Lo /usr/local/bin/jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-linux-amd64
```
права:
```
chmod a+x /usr/local/bin/tk
```
Создаем каталог, переходим в него, инициализируем структуру директорий tanka.
```
mkdir tanka
cd tanka
tk init
```
В environments/default/spec.json добавляем адрес API server (берем из kube.conf от своего кластера)

Структуру создал, переменные записал в val.json.  
проверил:  
```
root@vps13419:~/134/tanka# tk diff environments/default
```
Вывод не привожу -там много.
Применил:
```
root@vps13419:~/134/tanka# tk apply environments/default
```
Кусок вывода:  
```
+    manager: kubectl-client-side-apply
+    operation: Update
+    time: "2022-02-25T12:19:50Z"
+  name: front-svc
+  namespace: default
+  uid: 088e4cb6-2881-4048-bf35-8999294ee696
+spec:
+  clusterIP: 10.233.0.0
+  clusterIPs:
+  - 10.233.0.0
+  externalTrafficPolicy: Cluster
+  internalTrafficPolicy: Cluster
+  ipFamilies:
+  - IPv4
+  ipFamilyPolicy: SingleStack
+  ports:
+  - nodePort: 30080
+    port: 8000
+    protocol: TCP
+    targetPort: 80
+  selector:
+    app: front-pod
+  sessionAffinity: None
+  type: NodePort
+status:
+  loadBalancer: {}

Applying to namespace 'default' of cluster 'cluster.local' at 'https://130.193.50.69:6443' using context 'kubernetes-admin@cluster.local'.
Please type 'yes' to confirm: yes
configmap/psql-cm unchanged
persistentvolume/nfs-pv created
service/back-svc created
service/db created
service/front-svc created
deployment.apps/back-dpl created
deployment.apps/front-dpl created
statefulset.apps/psql-db created
root@vps13419:~/134/tanka# 
```
Проверил:  
```
root@vps13419:~/134/tanka# kubectl get po,pv,pvc,svc,deploy,statefulsets
NAME                             READY   STATUS    RESTARTS   AGE
pod/back-dpl-99975f947-xrbkv     1/1     Running   0          2m44s
pod/back-dpl-99975f947-zn2vh     1/1     Running   0          2m44s
pod/front-dpl-7ddc6bcd7f-92nk6   1/1     Running   0          2m44s
pod/front-dpl-7ddc6bcd7f-rpq64   1/1     Running   0          2m44s
pod/psql-db-0                    1/1     Running   0          2m44s

NAME                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS   REASON   AGE
persistentvolume/nfs-pv   10Gi       RWO            Retain           Bound    default/db-volume-psql-db-0                           2m45s

NAME                                        STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/db-volume-psql-db-0   Bound    nfs-pv   10Gi       RWO                           2m45s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/back-svc     ClusterIP   10.233.21.229   <none>        9000/TCP         2m45s
service/db           ClusterIP   10.233.1.17     <none>        5432/TCP         2m45s
service/front-svc    NodePort    10.233.36.37    <none>        8000:30080/TCP   2m45s
service/kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP          5h22m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/back-dpl    2/2     2            2           2m45s
deployment.apps/front-dpl   2/2     2            2           2m45s

NAME                       READY   AGE
statefulset.apps/psql-db   1/1     2m45s
root@vps13419:~/134/tanka# 
```
Запустилось.  

Удалил:
```
root@vps13419:~/134/tanka# tk delete environments/default
```
кусок вывода:
```
-kind: StatefulSet
-metadata:
-  name: psql-db
-  namespace: default
-spec:
-  selector:
-    matchLabels:
-      app: db
-  serviceName: db
-  template:
-    metadata:
-      labels:
-        app: db
-    spec:
-      containers:
-      - envFrom:
-        - configMapRef:
-            name: psql-cm
-        image: postgres
-        name: db
-        ports:
-        - containerPort: 5432
-        volumeMounts:
-        - mountPath: /var/lib/postgresql/data
-          name: db-volume
-  volumeClaimTemplates:
-  - metadata:
-      name: db-volume
-    spec:
-      accessModes:
-      - ReadWriteOnce
-      resources:
-        requests:
-          storage: 10Gi

Deleting from namespace 'default' of cluster 'cluster.local' at 'https://130.193.50.69:6443' using context 'kubernetes-admin@cluster.local'.
Please type 'yes' to confirm: yes
```
У меня на удалении не  отдавала консоль, но удалялось все корректно.  
