# K8s-Bootstrap

Kustomize + Helm manifests for the Cloudhaven clusters. Each top-level directory is a cluster.

| Cluster | Description |
|---|---|
| `nebulosa/` | Home RPi cluster — Langfuse, Qdrant, observability, Envoy Gateway |
| `humboldt/` | AWS EC2 + Talos — ArgoCD, specialist agents, heavy compute |

---

## Make

All commands run from this directory. `CLUSTER` defaults to `nebulosa`.

### Apply / Diff / Build

```bash
make apply   CLUSTER=nebulosa APP=langfuse
make diff    CLUSTER=nebulosa APP=langfuse
make build   CLUSTER=nebulosa APP=langfuse

make apply-all CLUSTER=nebulosa
```

### CoreDNS rewrites

Adds `rewrite name exact` rules to the cluster's CoreDNS ConfigMap. Discovers the Envoy Gateway service automatically.

```bash
make coredns-add    CLUSTER=nebulosa   # prompted for hostname
make coredns-remove CLUSTER=nebulosa   # prompted for hostname
make coredns-list   CLUSTER=nebulosa
```
