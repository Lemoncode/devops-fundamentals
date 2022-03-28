# CLEANUP

For last we're going to clean up all the resources that we have created.

```bash
helm uninstall prometheus
```

```bash
helm uninstall grafana
```

From console with `istioctl` variable execute

```bash
$ istioctl manifest generate --set profile=demo | kubectl delete -f -
```

```bash
$ kubectl delete -f kube/app-deployment.yaml
```

```bash
$ eksctl delete cluster lc-cluster
```