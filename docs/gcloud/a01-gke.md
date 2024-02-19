# Set up GKE
Use this document to configure a gke cluster suitable for this project

## Setup k8s cluster
## Retrieve k8s cluster information (GKE)
`gcloud components install gke-gcloud-auth-plugin`
`gcloud container clusters get-credentials cluster-1 --region=us-east1-d`

https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl

## Managing secrets in k8s with Secret Manager
* Create a service account in gcloud and gke with appropriate permissions
* Bind both service accounts together

k8s resources in `secrets/gcp`
`kubectl apply -f secrets/gcp/secrets-serviceaccount.yaml`

Test
`kubectl apply -f secrets/gcp/test-secrets-pod.yaml`
`kubectl exec -it readonly-test --namespace=readonly-ns -- /bin/bash`
`gcloud secrets versions access 1 --secret=local-psql`
`exit`
`kubectl delete pods readonly-test`

https://cloud.google.com/kubernetes-engine/docs/tutorials/workload-identity-secrets

Now you can adjust the docker exec script to set the right ENV variables before starting their workload.

## Add HDD storage class for gcloud
`kubectl apply -f ./gcloud/pd-standard-class.yaml`