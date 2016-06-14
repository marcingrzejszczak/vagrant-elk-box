# ZIPKIN PRESENTATION README

This readme presents steps to run ELK with the apps from the presentation and Zipkin.

# SETUP

- Run the `getReadyForConference.sh` script

# INSIDE VAGRANT

To manually run logstash and pass the configuration file just type

```
/opt/logstash/bin/logstash agent -f /vagrant/confs/logstash/logstash.conf
```

