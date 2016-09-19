FROM ubuntu:latest

# By default this is where we will grab the latest haproxy config file from
ENV HAPROXY_CONFIG_URL https://raw.githubusercontent.com/paxport/whitelister/master/haproxy.cfg

# Install cron
RUN apt-get update
RUN apt-get install cron

# Install curl so we can grab files via http
RUN apt-get install curl -y

# Install HAProxy
RUN apt-get install haproxy -y

# Install rsyslog so we can view haproxy logs
RUN apt-get install rsyslog -y

# Install Links so we can check proxy is working
RUN apt-get install links -y

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/simple-cron

# Replace HAPROXY_CONFIG_URL in crontab with our URL
RUN sed -i "s|HAPROXY_CONFIG_URL|$HAPROXY_CONFIG_URL|g" /etc/cron.d/simple-cron

# Add shell script and grant execution rights
ADD haproxy-update.sh /haproxy-update.sh
RUN chmod +x /haproxy-update.sh

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/simple-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Overwrite haproxy config with ours
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

# Update rsyslog config to write haproxy log files
#ADD rsyslog.conf /etc/rsyslog.conf

# Restart rsyslog with new config
#RUN sudo service rsyslog restart

# Run Our Script
CMD ./haproxy-update.sh $HAPROXY_CONFIG_URL >> /var/log/cron.log

# Run cron
CMD cron && tail -f /var/log/cron.log
