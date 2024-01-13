# For turning your pi into a DNS server for private hostnames
https://www.ionos.ca/digitalguide/server/configuration/how-to-make-your-raspberry-pi-into-a-dns-server/
https://arstechnica.com/gadgets/2020/08/understanding-dns-anatomy-of-a-bind-zone-file/
https://bind9.readthedocs.io/en/latest/#

## Install tools
```
sudo apt-get install bind9 bind9utils dnsutils
```

## Setup zones
```
# The authoritative name server and resolver
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/named.conf

# The domain
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/smithers.private

# Reverse IP lookup for deployed domain
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/0.168.192.in-addr.arpa.conf

# Root files from https://www.iana.org/domains/root/files
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/named.root
```

## Restart BIND9
```
sudo service bind9 restart
```

## Start BIND9 on boot
```
system autostart
```

## Modify Router to use your DNS server
This is normally done through your router's settings (GUI)
