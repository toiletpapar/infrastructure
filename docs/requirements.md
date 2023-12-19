## Prerequesites
* Docker
* gcloud
* Setup Domain and Cloud DNS
* Setup GKE
* Setup GCM

## Setup to push to Artifact Registry
Configure docker to use gcloud authentication
`gcloud auth configure-docker us-east1-docker.pkg.dev`

## Setup your cluster
For baremetal clusters follow:
* `docs/baremetal/a00-flatcar.md` and `docs/baremetal/a01-kubeadm` and onwards for the control plane
* `docs/baremetal/b00-pi.md` and `docs/baremetal/b01-pi-kubenode` and onwards for nodes (on arm devices with raspberry pi OS)
(Note: Currently missing nodes on flatcarOS)
* `docs/baremetal/c00-metallb.md` for setting up an implementation of load balancers for services of type `LoadBalancer`

For gcloud follow:
* `docs/gcloud/a01-gke.md`

## Setup project resources
* `docs/smithers/smithers.md`