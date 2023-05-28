#front
function()
local p = import '../../params.libsonnet';
local params = p.components.production;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'front-dpl',
    },
    spec: {
      replicas: params.replicasfront,
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
              image: params.imagefront,
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
          nodePort: params.nodePortfront,
        },
      ],
    },
  },
]
