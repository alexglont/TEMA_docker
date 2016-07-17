FROM debian:stable

MAINTAINER Mihnea Iancu <m.iancu@jacobs-university.de>

## Disable apt cache
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

## Basics
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y git subversion locales  && \
    apt-get clean
ADD locale.gen /etc/locale.gen
RUN locale-gen
RUN echo "export LC_CTYPE=en_US.UTF-8" >> ~/.bashrc
RUN echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc

## (1) Installing Dependencies
# (1.1) MWS & Misc Deps
RUN apt-get install -y g++ cmake make pkg-config && apt-get clean
RUN apt-get install -y libmicrohttpd-dev libxml2-dev libleveldb-dev libsnappy-dev libjson0-dev  && apt-get clean
RUN apt-get install -y libicu-dev libcurl4-gnutls-dev libhtmlcxx-dev && apt-get clean
# (1.2) TEMA Frontend Deps
RUN apt-get install -y curl php5 php5-curl elasticsearch && apt-get clean
# (1.3) TEMA Proxy deps
RUN apt-get install -y npm && apt-get clean

## (2) Cloning and installing MWS & friends
RUN mkdir /var/data/
RUN cd /var/data/ && git clone https://github.com/KWARC/mws.git
RUN cd /var/data/ && git clone https://github.com/KWARC/mws-frontend.git
RUN cd /var/data/ && git clone https://github.com/KWARC/tema-proxy.git
# (2.1) Configuration file for tema-proxy
ADD tema-proxy-config.js /var/data/tema-proxy/config.js
# (2.2) Configuration file for elasticsearch in mws
ADD mws-es-config.sh /var/data/mws/scripts/elastic-search/config.sh
# (2.3) Configuration file for mws
ADD mws-config.h.in /var/data/mws/config/config.h.in
# (2.4) Configuration file for elasticsearch
ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
# (2.5) Installing mws
RUN cd /var/data/mws/ && make && make install && cd ../

## (3) GAP-specific frontend
RUN cd /var/data/mws-frontend/ && git checkout gap-demo
#  (3.1) Configuration files for frontend
ADD tema_proxy.php /var/data/mws-frontend/php/tema_proxy.php
ADD mws_proxy.php /var/data/mws-frontend/php/mws_proxy.php

## (4) Setting up generated content
# (4.1) Creating havests
RUN cd /var/data/ && mkdir harvest
RUN cd /var/data/ && find mws-frontend/data -name *.html | xargs -n 10 docs2harvest -c mws-frontend/libs/tema-config.json -o harvest
# (4.2) Indexing
RUN cd /var/data/ && mkdir index && mws/bin/mws-index -I harvest -o index/
# (4.3) Generating elasticsearch json index, will out to `havest/` a .json file for every .harvest file
RUN cd /var/data/ && harvests2json -H harvest/ -I index/

# (5) Adding start-up script, see adjacent `start-tema` file for details
ADD start-tema /usr/bin/
