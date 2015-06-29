FROM debian:stable

MAINTAINER Mihnea Iancu <m.iancu@jacobs-university.de>

## Disable apt cache
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

## Basics
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y git subversion  && \
    apt-get clean

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
RUN cd /var/data/mws/ && make && make install && cd ../
## (3) Cloning MMT Library
RUN cd /var/data/ && git clone http://gl.mathhub.info/oeis/TestOEIS.git mmtarch
## (4) Setting up generated content 
# (4.1) Creating havests
RUN cd /var/data/ && mkdir harvest
RUN cd /var/data/ && find mmtarch/export/planetary/narration/ -name *.html | xargs -n 10 docs2harvest -c mmtarch/lib/tema-config.json -o harvest
# (4.2) Indexing 
RUN cd /var/data/ && mkdir index && mws/bin/mws-index -I harvest -o index/
# (4.3) Generating elasticsearch json index, will out to `havest/` a .json file for every .harvest file
RUN cd /var/data/ && harvests2json -H harvest/ -I index/
# (5) Adding start-up script, see adjacent `start-tema` file for details
ADD start-tema /usr/bin/

