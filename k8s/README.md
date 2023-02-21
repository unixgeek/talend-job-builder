THIS k8s EXAMPLE DOES NOT WORK CURRENTLY!

kubectl create namespace talend-jobs

kubectl --namespace talend-jobs create secret generic talend-job-secrets --from-literal=password='e3E6AA6Q3ry2515vh092GZhKYtQXcxpB'

kubectl apply -f print-context-job.yaml
