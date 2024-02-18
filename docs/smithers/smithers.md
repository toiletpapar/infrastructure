## Setting up secrets
The following secrets are used in this project:
* production-psql - The connection string used by the smithers deployment to talk to the internal 

### GCP
Read `docs/gcloud/a01-gke.md` for details on managing secrets with gcp secret manager

### Baremetal
Create the following folders under the `secrets/baremetal` directory:
* `credentials` - This will house all your secrets in lieu of an external secret manager.
* `k8s` - This will be where your secret files will live

Create a file for every secret listed above and put your secret in there. Example:
production-psql -> `secrets/baremetal/credentials/production-psql`.

Run `secrets/baremetal/make-secrets.sh` to create secret files and apply them to your k8 cluster. The secrets are named the same as above (e.g. `production-psql`)

Verify secrets were successfully created by running `kubectl get secrets`

## Deploy single node PSQL server
`kubectl apply -f ./psql/psql-statefulset.yaml`
`kubectl apply -f ./psql/psql-service.yaml`

For HA-psql cluster see
https://cloud.google.com/kubernetes-engine/docs/tutorials/stateful-workloads/postgresql#deploy-postgresql

Check that you can access your psql server (for example, using port forwarding)
`kubectl port-forward service/postgresql-db-service 5432:5432`

### Cleanup
In this project, I set the PV reclaim policy to retain so that you can decide whether to keep the data or wipe it during cleanup.
Remove the statefulset
`kubectl delete -f psql/psql-statefulset.yaml`

Remove the claim
`kubectl get pvc`
`kubectl delete pvc <name of pvc for postgresql-db-disk>`

Reclaim the drive manually. If you're using GCP and their dynamic provisioner, this will delete all the data in the drive and remove the pv. If you're using baremetal with the local provisioner, this will not wipe the drive and a new pv will automatically become available.
`kubectl get pv`
`kubectl delete pv <name of pv for postgresql-db-disk>`

## Deploy server
Ensure that `./smithers-server/credentials` is populated with the appropriate credentials for gcloud. You must have the following APIs enabled for the following hardware environments:
Vision (GCP/baremetal)
Secret Manager (GCP)

`kubectl apply -f ./smithers-server/smithers-deployment.yaml`
`kubectl apply -f ./smithers-server/smithers-service.yaml`

## Deploy crawler
Ensure that `./smithers-server/credentials` is populated with the appropriate credentials for gcloud. You must have the following APIs enabled for the following hardware environments:
Secret Manager (GCP)

`kubectl apply -f ./smithers-crawler/smithers-cron.yaml`

## Deploy Ingress, Ingress Controller
### Controller
* Download yaml from https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml (ingress/controller.yaml)

`kubectl apply -f ./ingress/controller.yaml`

https://kubernetes.github.io/ingress-nginx/deploy/#environment-specific-instructions

If you're running on a cloud provider, follow the below steps to ensure your load balancer has a static ip for use with your DNS solution
* Retrieve the IP of your load balancer
* Promote the IP to a static IP
* Patch k8s with static IP
`kubectl patch svc ingress-nginx-controller --namespace ingress-nginx -p '{"spec": {"loadBalancerIP": "xxx.xxx.xxx.xx"}}'`

If you're running baremetal, then you'll likely have configured `metallb` and a DNS through this project for a private network. Therefore, your static ip can be found at `docs/baremetal/metallb/ip-address-pool.yaml` and your DNS will be configured to serve resolve that ip for `api.smithers.private`.

https://kubernetes.github.io/ingress-nginx/examples/static-ip/

### Ingress
`kubectl apply -f ./ingress/ingress.yaml`

https://kubernetes.github.io/ingress-nginx/examples/tls-termination/

If you're using `cert-manager` and `lets-encrypt` for certificate management, go to `Install cert-manager` section.
If you're using managing certificates manually, go to `Install certificate`

## Install cert-manager (gcp)
https://cert-manager.io/docs/installation/

* Retrieve the installation yaml from https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml (it should be `./ingress/cert-manager.yaml` in this repo)
* Update the yaml to change references to kube-system to cert-manager

We need to do this because cert-manager has issues with restrictions on gke-autopilot (what my k8s cluster is running on). You can skip this step if you're running on something else.
See https://cert-manager.io/docs/installation/compatibility/#gke-autopilot.

`kubectl apply -f ./ingress/cert-manager.yaml`

### Create Issuers (Let's Encrypt)
For Testing:
* Change your email in `./ingress/issuer-staging.yaml`
`kubectl apply -f ./ingress/issuer-staging.yaml`
* In ingress.yaml
`metadata.annotations.cert-manager.io/issuer: "letsencrypt-staging"`
`kubectl apply -f ./ingress/ingress.yaml`

For Production:
* Change your email in `./ingress/issuer-prod.yaml`
`kubectl apply -f ./ingress/issuer-prod.yaml`
* In ingress.yaml
`metadata.annotations.cert-manager.io/issuer: "letsencrypt-prod"`
`kubectl apply -f ./ingress/ingress.yaml`

### Create a certificate automatically with cert-manager
https://kubernetes.github.io/ingress-nginx/user-guide/tls/
https://cert-manager.io/docs/tutorials/acme/nginx-ingress/

* At this point, if you've updated your ingress with `metadata.annotations.cert-manager.io/issuer: "letsencrypt-prod"`, removing the secret will retrigger reissuing of the certificate by cert-manager
`kubectl delete secret tls-secret`

## Install certificate (baremetal)
TBD