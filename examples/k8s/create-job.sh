#!/bin/sh -e

# This assumes minikube is running locally.

minikube image load talend-job-builder
kubectl create namespace talend-jobs
kubectl --namespace talend-jobs create secret generic talend-job-secrets --from-literal=password='e3E6AA6Q3ry2515vh092GZhKYtQXcxpB'
eval "$(minikube -p minikube docker-env)"
docker image build --build-arg JOB_NAME=Print_Context --build-arg CONTEXT_NAME=NonProd -f ../talend/EXAMPLE/talend-job-builder/Dockerfile -t print-context ../talend/EXAMPLE
kubectl apply -f print-context-job.yaml
kubectl --namespace talend-jobs create job --from cronjob.batch/print-context pc-test
sleep 3
kubectl --namespace talend-jobs logs job.batch/pc-test