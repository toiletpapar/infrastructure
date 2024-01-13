# For turning your pi into a private image registry
https://www.docker.com/blog/how-to-use-your-own-registry-2/

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

## Run the Registry
https://www.docker.com/blog/how-to-use-your-own-registry-2/

### Download and run the latest registry image
The default port for registry is 5000
```
sudo docker run -d -p 5000:5000 --name registry registry:latest
```

### Test
Tail the registry logs
```
docker logs -f registry
```

In another terminal:
Pull a test image from the public repo
```
docker pull hello-world
```

Tag the image with the registry location
```
docker tag hello-world localhost:5000/hello-world
```

Push the tagged image
```
docker push localhost:5000/hello-world
```

At this point you should see the tailed logs populate a request to save the hello-world image. Now let’s remove our localhost:5000/hello-world image and then pull the image from our local repository to make sure everything is working properly.

Verify that the local image list
```
docker images
```

Remove our local repo image
```
docker rmi localhost:5000/hello-world
```

Ensure it has been removed
```
docker images
```

Pull the image from the local registry
```
docker pull localhost:5000/hello-world
```

Verify the image exists
```
docker images
```

## Registry TLS
Now it's time to configure your pi to expose the registry on the private network.
https://distribution.github.io/distribution/about/deploying/#run-an-externally-accessible-registry

For an internally exposed registry, a self-signed cert secured registry should suffice. To begin this process, you must have set up a local DNS (see `baremetal/pi/b01-pi-dns.md`).

Make the self-signed certs
```
mkdir -p certs
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -addext "subjectAltName = DNS:myregistry.domain.local" \
  -x509 -days 365 -out certs/domain.crt
```

## Stopping the registry
If you need to clean up your node, you can stop the registry and remove all its data by running the following commands:
```
docker container stop registry
docker container rm -v registry
```

## Registry Documentation
If you need to read more on the registry and additional configuration options:
https://distribution.github.io/distribution/about/

At this point your registry should be running correctly.

## Enable the registry port
The registry default port is 5000.
`ufw allow 5000`