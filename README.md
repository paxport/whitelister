# paxport whitelister
A simple docker container that runs HAProxy and a cron invoking a shell script that updates HAProxy config

## What's in the container?

* Base Ubunto
* HA Proxy which is kept up with systemd
* cron runs a script every minute that pulls down the latest haproxy.cfg from known URL
* If the config from the URL is different from current haproxy config then a soft reload occurs

## Pre-requisites

* Docker
* Google Cloud SDK with gcloud configured to use your default project

## Build container and deploy to registry

### Build
`$ docker build --rm -t paxport-whitelister . `

### Tag
`$ docker tag paxport-whitelister gcr.io/paxportcloud/paxport-whitelister `

### Push
`$ gcloud docker push gcr.io/paxportcloud/paxport-whitelister `

## Create Compute Instance

### Create Template
    gcloud alpha compute instance-templates create-from-container paxport-whitelister-template \
        --docker-image=gcr.io/paxportcloud/paxport-whitelister:latest \
        --port-mappings=8000:8000:TCP,8001:8001:TCP,8002:8002:TCP,8003:8003:TCP,8004:8004:TCP,8005:8005:TCP,8006:8006:TCP,8007:8007:TCP,8008:8008:TCP,8009:8009:TCP

### Create Managed Instance
    gcloud compute instance-groups managed create paxport-whitelister-group \
      --instance-template=paxport-whitelister-template \
      --size=1

## how to install and debug it locally
Copy the repository and build from the Dockerimage:

`$ sudo docker build --rm -t paxport-whitelister . `

Run the docker container in the background (docker returns the id of the container):

```
$ sudo docker run -t -i -d paxport-whitelister
9bc2f85be3101e1edc7c130b2edea264a58e5e8519696840eda40bb26adada32
```

To check if it is running properly, connect to the container using the id and view the logfile. (You may have to wait 2 minutes)

```
$ sudo docker exec -i -t 74872bfcd924530cad4242534babbf61d3809e2325301c07a48b415a08ea7206 /bin/bash
root@b149b5e7306d:/# cat /var/log/cron.log
Thu May 26 13:11:01 UTC 2016: executed script
Thu May 26 13:12:01 UTC 2016: executed script
```

The cron job is running. Now let's modify the interval and the actual job executed!


## how to modify
To change the interval the cron job is runned, just simply edit the *crontab* file. In default, the job is runned every minute.


`* * * * * root /script.sh`

To change the actual job performed just change the content of the *script.sh* file. In default, the script writes the date into a file located in */var/log/cron.log*.


`echo "$(date): executed script" >> /var/log/cron.log 2>&1`
