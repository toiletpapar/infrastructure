# Introduction
The baremetal folder describes and provides the instructions and configurations to setup a baremetal k8s cluster. It's comprised of the following components:
* flatcar - The OS used for setting up the k8s control plane and k8s nodes
* metallb - An implementation of the service type `LoadBalancer`
* pi - The hardware and OS specific to pis and their limitations. This folder describes methods to turn pis into a private registry for images, or as a node if the hardware is powerful enough. Other alternatives that are not listed include using it as a DNS Server.

Considerations
* volumes - Unless you have configured NAS, you'll likely be limited to `local` PVs which need to be manually provisioned and require `nodeAffinity` (https://kubernetes.io/docs/concepts/storage/volumes/#local).
* LAN - The baremetal configuration is meant for a private network