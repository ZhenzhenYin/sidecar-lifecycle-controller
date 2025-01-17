# Kubernetes Custom Controller - Sidecar Shutdown

Kubernetes (cron)jobs sidecar terminator.
Originally forked from https://github.com/nrmitchi/k8s-controller-sidecars .

## What is this?

This is a custom Kubernetes controller for the purpose of watching running pods, and sending a SIGTERM to sidecar containers when the "main" application container has exited (and the sidecars are the only non-terminated containers).

This is a response to https://github.com/kubernetes/kubernetes/issues/25908.

## Usage

1. Build image and push to a docker hub (skippable if no code change needed)

```sh
docker build -f Dockerfile -t $YOUR_REPO/sidecar-lifecycle-controller:$YOUR_TAG .
docker push $YOUR_REPO/sidecar-lifecycle-controller:$YOUR_TAG
```

2. Deploy the controller into your cluster

```sh
./devops/sidecar-lifecycle-controller-deploy.sh 0.0.1 kube-system your-image-repo
```

3. Add the `sidecar-lifecycle-controller/sidecars` annotation to your pods, with a comma-seperated list of sidecar container names.

Example:

```yaml
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: test-job
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          annotations:
            sidecar-lifecycle-controller/sidecars: logging
        spec:
          restartPolicy: Never
          containers:
            - name: test-job
              image: ubuntu:latest
              command: ["sleep", "5"]
            - name: logging
              image: fluentd
```
