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

# Add simple-cron file in the cron directory
# ADD simple-cron /etc/cron.d/simple-cron

# Replace HAPROXY_CONFIG_URL in simple-cron with our URL
# RUN sed -i "s|HAPROXY_CONFIG_URL|$HAPROXY_CONFIG_URL|g" /etc/cron.d/simple-cron

# Give execution rights on the cron job
# RUN chmod 0644 /etc/cron.d/simple-cron

# Now install into crontab
# RUN crontab /etc/cron.d/simple-cron

# Add shell script and grant execution rights
ADD haproxy-update.sh /haproxy-update.sh
RUN chmod +x /haproxy-update.sh

ADD loop-forever.sh /loop-forever.sh
RUN chmod +x /loop-forever.sh

# Create the log file to be able to run tail
# RUN touch /var/log/cron.log

# Overwrite haproxy config with ours
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

# Run cron
# CMD cron -L15 && tail -f /var/log/cron.log

RUN touch /var/log/loop-forever.log

# Loop Forever calling the update script with our update URL
# Update script output should end up in /var/log/syslog
CMD /loop-forever.sh 60 ./haproxy-update.sh $HAPROXY_CONFIG_URL >> /var/log/loop-forever.log 2>&1
