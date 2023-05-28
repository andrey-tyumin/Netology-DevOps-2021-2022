
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    production +: {
        replicasfront: 3,
        imagefront: "imustgetout/hw131frontend:v1.1",
        nodePortfront: 30080,
        replicasback: 3,
        imageback: "imustgetout/hw131backend:v1.1",
        replicaspsql: 3,
        imagepsql: "postgres",
    },
  }
}
