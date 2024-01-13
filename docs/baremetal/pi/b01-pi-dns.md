# For turning your pi into a DNS server for private hostnames
This is so that you can refer to domain names rather than private ips in your code and manage name resolution here.
https://www.ionos.ca/digitalguide/server/configuration/how-to-make-your-raspberry-pi-into-a-dns-server/
https://arstechnica.com/gadgets/2020/08/understanding-dns-anatomy-of-a-bind-zone-file/
https://bind9.readthedocs.io/en/latest/#

## Install tools
```
sudo apt-get install bind9 bind9utils dnsutils
```

## Validate
Ensure the following files were provided (necessary for the configurations in this project to function)
```
/etc/bind/db.local
/etc/bind/db.127
```

## Setup zones
These files may need to be modified for your specific private ip addresses serving your registry, k8s, or the smithers api.

```
# The authoritative name server and resolver
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/named.conf
# Keep a copy of the provided `named.conf`
mv /etc/bind/named.conf /etc/bind/named.conf.copy
mv named.conf /etc/bind/named.conf

# The domain
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/smithers.private
mv smithers.private /etc/bind/smithers.private

# Reverse IP lookup for deployed domain
wget https://raw.githubusercontent.com/toiletpapar/smithers-infrastructure/main/docs/baremetal/pi/0.168.192.in-addr.arpa
mv 0.168.192.in-addr.arpa /etc/bind/0.168.192.in-addr.arpa
```

### named.conf
* Add ACL for the project's private network
* Allow only our project's private network to query this DNS server
* Allow recursive queries for normal domain resolution outside of what's handled by this DNS server
* `forward-only` forwards all queries that are not handled by this DNS server
* Add addresses of public Google DNS resolvers to forward queries for which this DNS server is not authoritative
* `empty-zones-enable yes` to ensure that reverse mapped private IPs (e.g. 192.168.0.10) that are not resolve aren't forwarded to the public network
* Add `max-cache-size` for this particular project because a registry service is ran on the same host
* Add all `category default` logs to the `default_log` channel. This channel rotates from 3 files of size 250k at `/home/core/bind/log/named/default.log`. It only contains `warning` logs and up.
* Define the zones for which this DNS server is authoritative (forwarding everything else): `localhost`, `0.0.127.in-addr.arpa`, `smithers.private`, `0.168.192.in-addr.arpa`

#### Logging
Ensure the path exists:
`/home/core/bind/log/named/default.log`

#### Zones
Describes the areas for which this DNS server is authoritative
* localhost - Specifies how `localhost` should resolve (e.g. to `127.0.0.1`)
* 0.0.127.in-addr.arpa - Reverse map zone that specifies how `127.0.0.1` should map to `localhost`
* smithers.private - Specifies how to resolve `smithers.private`
* 0.168.192.in-addr.arpa - Reverse map zone that specifies how to resolve private ips for `smithers.private`

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
