
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    stage +: {
        replicasfront: 1,
        imagefront: "imustgetout/hw131frontend:v1.1",
        nodePortfront: 30081,
        replicasback: 1,
        imageback: "imustgetout/hw131backend:v1.1",
        replicaspsql: 1,
        imagepsql: "postgres",
    },
  }
}
