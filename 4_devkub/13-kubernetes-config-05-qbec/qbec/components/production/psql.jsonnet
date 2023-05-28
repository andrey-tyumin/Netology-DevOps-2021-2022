#psql
function()
local p = import '../../params.libsonnet';
local params = p.components.production;

[
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
      replicas: params.replicaspsql,
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
              image: params.imagepsql,
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
                storage: '5Gi',
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
]
