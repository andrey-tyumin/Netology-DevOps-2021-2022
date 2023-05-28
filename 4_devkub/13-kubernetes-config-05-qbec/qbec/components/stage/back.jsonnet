#back
local p = import '../../params.libsonnet';
local params = p.components.stage;
function()
[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'back-dpl',
    },
    spec: {
      replicas: params.replicasback,
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
              image: params.imageback,
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

]
