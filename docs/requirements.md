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
* `docs/baremetal/b00-pi.md` to setup a pi
* `docs/baremetal/b01-dns.md` to modify your pi to be a DNS server using BIND9
* `docs/baremetal/b01-registry.md` to modify your pi to be a private registry using `distribution/distribution/registry`
* `docs/baremetal/a00-flatcar.md` to setup a flatcar node
* `docs/baremetal/a01-kubeadm` and modify your flatcar node to a k8s control plane
* `docs/baremetal/a02-kubectl` to further modify any k8s node
* `docs/baremetal/c00-metallb.md` for setting up an implementation of load balancers for services of type `LoadBalancer`

For gcloud follow:
* `docs/gcloud/a01-gke.md`

## Setup project resources
* `docs/smithers/smithers.md`