### hw3.5

1. Узнайте о sparse (разряженных) файлах.
Почитал.
2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  
Не могут, т.к. в inode хранятся также и права доступа, guid, uid владельца.  
3. -- 20. (большая часть вывода команд обрезал, т.к. слишком много, но могу выложить полный вывод всех клманд)
```
andrey@MSI:~/vagrant3.5$ vagrant ssh
vagrant@vagrant:~$ sudo su
root@vagrant:/home/vagrant# fdisk -l
root@vagrant:/home/vagrant# fdisk /dev/sdb
root@vagrant:/home/vagrant# sfdisk -d /dev/sdb | sfdisk /dev/sdc
root@vagrant:/home/vagrant# fdisk -l
Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md0 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
root@vagrant:/home/vagrant# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:/home/vagrant# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
root@vagrant:/home/vagrant# vgcreate vg1 /dev/md0 /dev/md1
  Volume group "vg1" successfully created
root@vagrant:/home/vagrant# pvs
  PV         VG        Fmt  Attr PSize    PFree   
  /dev/md0   vg1       lvm2 a--    <2.00g   <2.00g
  /dev/md1   vg1       lvm2 a--  1016.00m 1016.00m
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0 
root@vagrant:/home/vagrant# vgs vg1
  VG  #PV #LV #SN Attr   VSize  VFree 
  vg1   2   0   0 wz--n- <2.99g <2.99g
root@vagrant:/home/vagrant# vgdisplay -v vg1 
  --- Volume group ---
  VG Name               vg1
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0   
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               3hwmU7-64Ri-sJfH-RSTe-unJy-o3Nl-Nf0a3P
   
  --- Physical volumes ---
  PV Name               /dev/md0     
  PV UUID               s9yo4u-ylOr-1c6x-67St-VJne-PxQy-T5bv7A
  PV Status             allocatable
  Total PE / Free PE    511 / 511
   
  PV Name               /dev/md1     
  PV UUID               joUbrP-yUTr-Y841-VRae-A4yu-pT0y-44OIpf
  PV Status             allocatable
  Total PE / Free PE    254 / 254
root@vagrant:/home/vagrant# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
└─sdb2                 8:18   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
└─sdc2                 8:34   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
root@vagrant:/home/vagrant# lvcreate -L 100M -n lv1 vg1 /dev/md1
  Logical volume "lv1" created.
root@vagrant:/home/vagrant# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
└─sdb2                 8:18   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
    └─vg1-lv1        253:2    0  100M  0 lvm   
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
└─sdc2                 8:34   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
    └─vg1-lv1        253:2    0  100M  0 lvm   
root@vagrant:/home/vagrant# mkfs.ext4 /dev/vg1/lv1
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
root@vagrant:/home/vagrant# mkdir /tmp/new
root@vagrant:/home/vagrant# mount /dev/vg1/lv1 /tmp/new
root@vagrant:/home/vagrant# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2021-05-11 20:16:06--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 20704505 (20M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                        100%[=============================================================================>]  19.75M  4.91MB/s    in 4.2s    

2021-05-11 20:16:10 (4.75 MB/s) - ‘/tmp/new/test.gz’ saved [20704505/20704505]
root@vagrant:/home/vagrant# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
└─sdb2                 8:18   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
    └─vg1-lv1        253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
└─sdc2                 8:34   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
    └─vg1-lv1        253:2    0  100M  0 lvm   /tmp/new
root@vagrant:/home/vagrant# gzip -t /tmp/new/test.gz
root@vagrant:/home/vagrant# echo $?
0
root@vagrant:/home/vagrant# pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 100.00%
root@vagrant:/home/vagrant# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
│   └─vg1-lv1        253:2    0  100M  0 lvm   /tmp/new
└─sdb2                 8:18   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md0                9:0    0    2G  0 raid1 
│   └─vg1-lv1        253:2    0  100M  0 lvm   /tmp/new
└─sdc2                 8:34   0  511M  0 part  
  └─md1                9:1    0 1018M  0 raid0 
root@vagrant:/home/vagrant# mdadm --fail /dev/md0 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md0 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
root@vagrant:/home/vagrant# gzip -t /tmp/new/test.gz
root@vagrant:/home/vagrant# echo $?
0
```
