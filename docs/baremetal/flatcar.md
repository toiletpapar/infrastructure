# For setting up a general computer

## Flatcar OS (Container OS)
### Boot from the Flatcar ISO on host machine
* Download Flatcar ISO from drive
* Burn the image into a drive (possibly using Raspberry Pi Imager)
* Boot the image via BIOS compatibility mode (not UEFI)
  - https://www.asus.com/us/support/FAQ/1013017/#A1 for ASUS Laptop

At this point, you should be in Flatcar Linux and should be able to run commands

### Create the config
You need to create a Butane config that will
* configure the networks used by systemd-networkd (including wpa_supplicant) - https://www.flatcar.org/docs/latest/setup/customization/network-config-with-networkd/
* allow you to SSH into the machine - https://www.flatcar.org/docs/latest/setup/security/customizing-sshd/
* run k8s (control plane, nodes) - https://www.flatcar.org/docs/latest/container-runtimes/getting-started-with-kubernetes/
* allow power saving when idle - https://www.flatcar.org/docs/latest/setup/customization/power-management/

#### Configure a wired network
Find your network interface
```
ls /sys/class/net
```

Note you'll likely want a static ip for the control plane
You can use your router's DHCP reservation for this ip
```
variant: flatcar
version: 1.0.0
storage:
  files:
    - path: /etc/systemd/network/00-<<your network interface>>.network
      contents:
        inline: |
          [Match]
          Name=<<your network interface>>

          [Network]
          DNS=8.8.8.8
          Address=<<reserved ip>>/24
          Gateway=<<router gateway ip>>
```

If DHCP is acceptable
```
variant: flatcar
version: 1.0.0
storage:
  files:
    - path: /etc/systemd/network/00-<<your network interface>>.network
      contents:
        inline: |
          [Match]
          Name=<<your network interface>>

          [Network]
          DHCP=yes
```

Make the appropriate changes to `cl-control.yaml` and `cl-node.yaml` for your particular network interface

#### SSH Daemon
https://www.flatcar.org/docs/latest/setup/security/customizing-sshd/
Flatcar Container Linux defaults to running an OpenSSH daemon using systemd socket activation – when a client connects to the port configured for SSH, sshd is started on the fly for that client using a systemd unit derived automatically from a template.

This project only allows the `core` user to login and disables password based authentication.
For the public/private keypair (for rsa) use
```
ssh-keygen
```

```
variant: flatcar
version: 1.0.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ssh-rsa <<public key>>
storage:
  files:
    - path: /etc/ssh/sshd_config
      overwrite: true
      mode: 0600
      contents:
        inline: |
          # Supported HostKey algorithms by order of preference.
          HostKey /etc/ssh/ssh_host_rsa_key
          HostKey /etc/ssh/ssh_host_ed25519_key
          HostKey /etc/ssh/ssh_host_ecdsa_key
          
          # Use most defaults for sshd configuration.
          UsePrivilegeSeparation sandbox
          Subsystem sftp internal-sftp
          UseDNS no

          PermitRootLogin no
          AllowUsers core
          AuthenticationMethods publickey
```

Make the appropriate changes to `cl-control.yaml` and `cl-node.yaml` for your particular private/public keypairs

#### Getting the host linked with the K8s cluster
https://www.flatcar.org/docs/latest/container-runtimes/getting-started-with-kubernetes/

This project uses kubeadm to manage the k8s cluster.
This project uses systemd-sysext to retrieve binaries and update them
This project reboots nodes whenever there are updates to flatcar or k8s (via Kured)

#### Power management
https://www.flatcar.org/docs/latest/setup/customization/power-management/
This project uses the conservative governor (Dynamically scale frequency at 95% cpu load) given that this project does not have continuous large loads.

```
variant: flatcar
version: 1.0.0
systemd:
  units:
    - name: cpu-governor.service
      enabled: true
      contents: |
        [Unit]
        Description=Enable CPU power saving

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/sbin/modprobe cpufreq_conservative
        ExecStart=/usr/bin/sh -c '/usr/bin/echo "conservative" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'

        [Install]
        WantedBy=multi-user.target   
```

### Install flatcar on the host machine's drive
Find the Butane config used for the control plane at `docs/baremetal/cl-control.yaml`
Find the Butane config used for nodes at `docs/baremetal/cl-node.yaml`

You can grab these configs by:
```
wget "https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/cl-control.yaml"
wget "https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/cl-node.yaml"
```

Translate the Butane config to an Ignition config
```
# Control Plane
cat cl-control.yaml | docker run --rm -i quay.io/coreos/butane:latest > ignition.json

# Nodes
cat cl-node.yaml | docker run --rm -i quay.io/coreos/butane:latest > ignition.json
```

Find the drive you want to install it to, likely `/dev/sda`
```
lsblk
```

Run the installation script
```
flatcar-install -d /dev/sda -i ignition.json -C stable
```

At this point flatcar should be bootable from the host's disk. It is now safe to reboot the host and remove the boot drive.

### Deploy CNI on the control plane
At this point you should be able to:

* SSH into the machine
`ssh core@<<node ip address>>`

* Deploy a CNI
This project uses Calico (v3.24.1)
`kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml`

* Allow for node reboots on Kubernetes or Flatcar update (via Kured)
```
latest=$(curl -s https://api.github.com/repos/kubereboot/kured/releases | jq -r '.[0].tag_name')
kubectl apply -f "https://github.com/kubereboot/kured/releases/download/$latest/kured-$latest-dockerhub.yaml"
```

At this point, the k8s control plane should be in the "Ready" state. You can verify this by running `kubectl get nodes`

### (TODO) Modify the control plane to allow for authorized access to Artifact Repository
https://www.flatcar.org/docs/latest/container-runtimes/registry-authentication/

At this point, k8s should be able to pull images from Artifact Repository