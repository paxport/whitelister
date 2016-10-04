# paxport whitelister
A simple docker container that runs HAProxy and a shell script that updates HAProxy config periodically

## What's in the container?

* Base Ubunto
* HA Proxy which is kept up with systemd
* docker runs a script which loops and every minute pulls down the latest haproxy.cfg from known URL
* If the config from the URL is different from current haproxy config then a soft reload occurs

## Pre-requisites

* Docker
* Google Cloud SDK with gcloud configured to use your default project

# Build container and deploy to google container registry

### Build
`$ docker build --rm -t paxport-whitelister . `

### Tag
`$ docker tag paxport-whitelister gcr.io/paxportcloud/paxport-whitelister `

### Push
`$ gcloud docker push gcr.io/paxportcloud/paxport-whitelister `

    
## Create Compute Instance to run docker image


### Create a new Instance (rename node-a if creating new one)

    gcloud alpha compute instances create-from-container whitelister-node-a \
        --docker-image=gcr.io/paxportcloud/paxport-whitelister:latest \
        --port-mappings=8000:8000:TCP,8001:8001:TCP,8002:8002:TCP,8003:8003:TCP,8004:8004:TCP,8005:8005:TCP,8006:8006:TCP,8007:8007:TCP,8008:8008:TCP,8009:8009:TCP \
        --zone us-central1-c \
        --machine-type g1-small


## Debug by SSHing into compute instance

```
$ gcloud compute ssh whitelister-node-a --zone=us-central1-c
```

then

```
$ sudu su
```

## Find docker container id

```
$ docker ps | grep pax
```

### Tail Update Log

```
$ docker exec -i -t <container id> tail -f /var/log/cron.log
```

### View container logs

```
$ docker logs -f <container id>
```

### Login to container

```
$ docker exec -i -t <container id> /bin/bash
```    

## how to install and debug it locally
Copy the repository and build from the Dockerimage:

`$ docker build --rm -t paxport-whitelister . `

Run the docker container in the background (docker returns the id of the container):

```
$ docker run -t -i -d paxport-whitelister
```

To check if it is running properly:

```
$ docker ps
```

Connect to the container using the id and view the logfile. (You may have to wait 2 minutes)

    $ sudo docker exec -i -t 74872bfcd924530cad4242534babbf61d3809e2325301c07a48b415a08ea7206 /bin/bash 
    root@b149b5e7306d:/# cat /var/log/cron.log
    Thu May 26 13:11:01 UTC 2016: executed script
    Thu May 26 13:12:01 UTC 2016: executed script


If you only have one container running you can always log in with:

```
$ docker exec -i -t $(docker ps -q) /bin/bash
```    

You can stop and remove all containers with:

```
$ docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
```
