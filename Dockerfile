FROM ubuntu:latest

# By default this is where we will grab the latest haproxy config file from
ENV HAPROXY_CONFIG_URL https://raw.githubusercontent.com/paxport/whitelister/master/haproxy.cfg

# Install curl so we can grab files via http
RUN apt-get update && apt-get install curl -y

# Install HAProxy
RUN apt-get update && apt-get install haproxy -y

# Install and run rsyslog so we can view haproxy logs
RUN apt-get update && apt-get install rsyslog -y

RUN apt-get update && apt-get install logrotate -y

RUN apt-get update && apt-get install vim -y

# Install Links so we can check proxy is working
RUN apt-get update && apt-get install links -y

#
# Note that cron does not seem to execute correctly under docker
# containers running on google compute :(
#

# update rsyslog config to enable udp etc
# ADD rsyslog.conf /etc/rsyslog.conf
# RUN /etc/init.d/rsyslog restart

# Add shell script and grant execution rights
ADD haproxy-update.sh /haproxy-update.sh
RUN chmod +x /haproxy-update.sh

ADD loop-forever.sh /loop-forever.sh
RUN chmod +x /loop-forever.sh

# Overwrite haproxy config with ours
ADD haproxy.cfg /etc/haproxy/haproxy.cfg
RUN /etc/init.d/haproxy restart

RUN touch /var/log/haproxy-update.log

# Loop Forever calling the update script with our update URL
CMD /loop-forever.sh 60 ./haproxy-update.sh $HAPROXY_CONFIG_URL >> /var/log/haproxy-update.log 2>&1
