# paxport whitelister
A simple docker container that runs HAProxy and a cron invoking a shell script that updates HAProxy config

## how to install and use it
Copy the repository and build from the Dockerimage:


`$ sudo docker build --rm -t paxport-whitelister . `


Run the docker container in the background (docker returns the id of the container):


```
$ sudo docker run -t -i -d paxport-whitelister
9bc2f85be3101e1edc7c130b2edea264a58e5e8519696840eda40bb26adada32
```

To check if it is running properly, connect to the container using the id and view the logfile. (You may have to wait 2 minutes)

```
$ sudo docker exec -i -t 326378caee4e7407bd51230f4563992a7c8aeb97a911471844f4f5c9d327146c /bin/bash
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
