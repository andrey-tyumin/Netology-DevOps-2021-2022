function()
[
     {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'nfs-pv-1',
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
  },
    {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'nfs-pv-2',
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
  },
    {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'nfs-pv-3',
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
  },
]