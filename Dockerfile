FROM ubuntu:latest

# Install cron
RUN apt-get update
RUN apt-get install cron

# Install curl so we can grab files via http
RUN apt-get install curl -y

# Install HAProxy
RUN mkdir /var/log/haproxy
RUN touch /var/log/haproxy/ha.log
RUN apt-get install haproxy -y

# Install Links so we can check proxy is working
RUN apt-get install links -y

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/simple-cron

# Add shell script and grant execution rights
ADD script.sh /script.sh
RUN chmod +x /script.sh

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/simple-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Overwrite haproxy config with ours
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

# Run Cron
CMD cron && tail -f /var/log/cron.log
