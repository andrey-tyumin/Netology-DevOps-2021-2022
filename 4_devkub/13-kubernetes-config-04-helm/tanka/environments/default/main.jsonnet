local val = import "val.json";
[
#psql
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'psql-cm',
    },
    data: {
      POSTGRES_DB: 'news',
      POSTGRES_USER: 'postgres',
      POSTGRES_PASSWORD: 'postgres',
      PGDATA: '/var/lib/postgresql/data/k8s',
    },
  },
  {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'nfs-pv',
    },
    spec: {
      capacity: {
        storage: '10Gi',
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
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'psql-db',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'db',
        },
      },
      serviceName: 'db',
      template: {
        metadata: {
          labels: {
            app: 'db',
          },
        },
        spec: {
          containers: [
            {
              name: 'db',
              image: val.psql.image,
              ports: [
                {
                  containerPort: 5432,
                },
              ],
              envFrom: [
                {
                  configMapRef: {
                    name: 'psql-cm',
                  },
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/var/lib/postgresql/data',
                  name: 'db-volume',
                },
              ],
            },
          ],
        },
      },
      volumeClaimTemplates: [
        {
          metadata: {
            name: 'db-volume',
          },
          spec: {
            accessModes: [
              'ReadWriteOnce',
            ],
            resources: {
              requests: {
                storage: '10Gi',
              },
            },
          },
        },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'db',
      labels: {
        app: 'db',
      },
    },
    spec: {
      selector: {
        app: 'db',
      },
      ports: [
        {
          port: 5432,
          protocol: 'TCP',
        },
      ],
    },
  },
  
  #back
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'back-dpl',
    },
    spec: {
      replicas: val.back.replicas,
      selector: {
        matchLabels: {
          app: 'back-pod',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'back-pod',
          },
        },
        spec: {
          containers: [
            {
              name: 'back',
              image: val.back.image,
              ports: [
                {
                  containerPort: 9000,
                },
              ],
              env: [
                {
                  name: 'DATABASE_URL',
                  value: 'postgres://postgres:postgres@db:5432/news',
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'back-svc',
    },
    spec: {
      selector: {
        app: 'back-pod',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 9000,
          targetPort: 9000,
        },
      ],
    },
  },

#front

  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'front-dpl',
    },
    spec: {
      replicas: val.front.replicas,
      selector: {
        matchLabels: {
          app: 'front-pod',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'front-pod',
          },
        },
        spec: {
          containers: [
            {
              name: 'front',
              image: val.front.image,
              ports: [
                {
                  containerPort: 80,
                },
              ],
              env: [
                {
                  name: 'BASE_URL',
                  value: 'http://hw131-back-svc:9000',
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'front-svc',
    },
    spec: {
      type: 'NodePort',
      selector: {
        app: 'front-pod',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 8000,
          targetPort: 80,
          nodePort: val.front.nodePort,
        },
      ],
    },
  },
]