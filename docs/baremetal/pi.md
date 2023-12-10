# For setting up Raspberry Pi
## Hardware
* 1 GB RAM
* 64 GB SD

## OS
### Raspberry Pi OS
* Download Raspberry Pi Imager
* Format SD with Raspberry Pi OS w/o desktop, 64-bit
* Plug in keyboard, monitor, SD, and power and wait for setup

### Flatcar OS (Container OS)
* Download Flatcar ISO from drive
* Burn the image into a drive (possibly using Raspberry Pi Imager)
* Boot the image via BIOS compatibility mode (not UEFI)
  - https://www.asus.com/us/support/FAQ/1013017/#A1 for ASUS Laptop

...TBD

## Network
### Connect to a network
Find current connections
```
nmcli con show
```

Disconnect any prior connections
```
nmcli con down <<SSID>>
```

Connect to your network
```
nmcli device wifi connect <<SSID>> password <<PASSWORD>>
```

At this point you should be connected to your router

### Resolving hostnames
You can find your DNS servers here
```
cat /etc/resolv.conf
```

You can test that your device can connect to the Internet
```
ping "google.com"
```

If you don't see the DNS servers provided by your router `nameserver xx.xx.xxx.xxx` or you can't reach the Internet, try modifying your connection to use Google DNS Servers

You can add the Public Google DNS Server
```
nmcli con mod "Wired connection 1" ipv4.dns "8.8.8.8 8.8.4.4"
```

Then you'll need to restart the network manager
```
service NetworkManager restart
```

## SSH
Find your raspberry pi's ip address
```
nmcli device show
```
Depending on how you are connected to your router, your ip address (IP4.ADDRESS[1]) is in "ethernet" or "wifi" blocks

### Enable SSH on Raspberry Pi
```
sudo raspi-config
```
Select Interfacing Options
Navigate to and select SSH
Choose Yes
Select Okss
Choose Finish

### SSH into your device
```
ssh <<username>>@<<raspberry pi's ip address>>
```

At this point you should be able to execute commands remotely

## Installing Docker
### For Pi using Raspberry Pi OS
https://docs.docker.com/engine/install/debian/#prerequisites

### For removing sudo with docker (and other post-installation instructions)
https://docs.docker.com/engine/install/linux-postinstall/

#### Automatically start on boot with systemd
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

At this point you should have docker ready to go. Test this by:
```
sudo docker run hello-world
```

