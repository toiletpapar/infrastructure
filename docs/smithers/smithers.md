## Deploy single node PSQL server
`kubectl apply -f ./psql/psql-statefulset.yaml`
`kubectl apply -f ./psql/psql-service.yaml`

Currently configured with low-resources, increase as required.

For HA-psql cluster see
https://cloud.google.com/kubernetes-engine/docs/tutorials/stateful-workloads/postgresql#deploy-postgresql

## Deploy server
Ensure that `./smithers-server/credentials` is populated with the appropriate credentials for gcloud
`kubectl apply -f ./smithers-server/smithers-deployment.yaml`
`kubectl apply -f ./smithers-server/smithers-service.yaml`

## Deploy crawler
Ensure that `./smithers-crawler/credentials` is populated with the appropriate credentials for gcloud
`kubectl apply -f ./smithers-crawler/smithers-cron.yaml`

## Deploy Ingress, Ingress Controller
### Controller
* Download yaml from https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml (ingress/controller.yaml)

`kubectl apply -f ./ingress/controller.yaml`

https://kubernetes.github.io/ingress-nginx/deploy/#environment-specific-instructions

* Retrieve the IP of your load balancer
* Promote the IP to a static IP
* Patch k8s with static IP
`kubectl patch svc ingress-nginx-controller --namespace ingress-nginx -p '{"spec": {"loadBalancerIP": "xxx.xxx.xxx.xx"}}'`

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

## Create a certificate automatically with cert-manager
https://kubernetes.github.io/ingress-nginx/user-guide/tls/
https://cert-manager.io/docs/tutorials/acme/nginx-ingress/

* At this point, if you've updated your ingress with `metadata.annotations.cert-manager.io/issuer: "letsencrypt-prod"`, removing the secret will retrigger reissuing of the certificate by cert-manager
`kubectl delete secret tls-secret`