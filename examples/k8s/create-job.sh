#!/bin/sh -e

# This assumes minikube is running locally.

kubectl create namespace talend-jobs
kubectl --namespace talend-jobs create secret generic talend-job-secrets --from-literal=password='e3E6AA6Q3ry2515vh092GZhKYtQXcxpB'
eval "$(minikube -p minikube docker-env)"
cd ../talend/EXAMPLE
docker image build --build-arg JOB_NAME=Print_Context --build-arg CONTEXT_NAME=NonProd -f talend-job-builder/Dockerfile -t print-context .
cd ../../k8s
kubectl apply -f print-context-job.yaml
kubectl create job --from cronjob.batch/print-context pc-test
kubectl logs job.batch/pc-test