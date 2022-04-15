#!/usr/bin/env bash
# example: ./sidecar-lifecycle-controller-deploy.sh 0.0.1 kube-system your-image-repo

OPTS="--dry-run --debug"

image_tag=$1
image_repository=$3
env=$2

helm upgrade $OPTS --install --set image.tag=$image_tag --set image.repository=$image_repository"/sidecar-lifecycle-controller" -f ./sidecar-lifecycle-controller/values.yaml sidecar-lifecycle-controller ./sidecar-lifecycle-controller -n $2

#helm template --debug --set image.tag=$image_tag --set image.repository=$image_repository"/sidecar-lifecycle-controller" -f ./sidecar-lifecycle-controller/values.yaml sidecar-lifecycle-controller ./sidecar-lifecycle-controller -n $2