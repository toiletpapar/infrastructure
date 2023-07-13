# Infrastructure
Infrastructure backing the Smithers application

Please see https://github.com/toiletpapar/infrastructure/blob/main/requirements.md for details on how you can set this up yourself

Done:
* Manually start autopilot gke (autopilot-cluster-smithers)
* Deploy postgres
* Change secret to service name
* Automate Let's Encrypt
* Deploy smither's servers

Next:
* Modify psql image for seeding
* Use Workload Identity for cluster authentication to secret manager

Limitations:
* Single node psql server, no replication
* Manually provisioned