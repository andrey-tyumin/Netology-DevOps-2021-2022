function()
[
  {
    apiVersion: 'v1',
    kind: 'Endpoints',
    metadata: {
      name: 'number',
    },
    subsets: [
      {
        addresses: [
          {
            ip: '159.65.220.83',
          },
        ],
        ports: [
          {
            port: 80,
          },
        ],
      },
    ],
  },
]