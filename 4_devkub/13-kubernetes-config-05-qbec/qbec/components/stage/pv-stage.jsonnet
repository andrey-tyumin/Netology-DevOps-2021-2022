function() 
     {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'nfs-pv-0',
    },
    spec: {
      capacity: {
        storage: '5Gi',
      },
      accessModes: [
        'ReadWriteOnce',
      ],
      nfs: {
        server: 'nfs-server',
        path: '/',
      },
      mountOptions: [
        'nfsvers=4.2',
      ],
    },
  }