FROM java:8
MAINTAINER Ajay Yeluri <ayeluri@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y supervisor curl && \
    apt-get clean

# Elasticsearch
RUN \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.deb && \
    sudo dpkg -i elasticsearch-5.0.0.deb && \
    sudo update-rc.d elasticsearch defaults 95 10 && \
    sudo /etc/init.d/elasticsearch start    
    
#ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

# Logstash
RUN \
    wget https://artifacts.elastic.co/downloads/logstash/logstash-5.0.0.deb && \
    sudo dpkg -i logstash-5.0.0.deb && \
    sudo update-rc.d logstash defaults 95 10 && \
    sudo /etc/init.d/logstash start    

# Logstash plugins
RUN /opt/logstash/bin/plugin install logstash-filter-translate


# Kibana
RUN \
    curl -s https://artifacts.elastic.co/downloads/kibana/kibana-5.0.0-linux-x86_64.tar.gz | tar -C /opt -xz && \
    ln -s /opt/kibana-5.0.0-linux-x86_64 /opt/kibana && \
#    sed -i 's/port: 5601/port: 80/' /opt/kibana/config/kibana.yml
    

ADD etc/supervisor/conf.d/kibana.conf /etc/supervisor/conf.d/kibana.conf

EXPOSE 5601 

ENV PATH /opt/logstash/bin:$PATH

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]

