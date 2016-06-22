FROM debian:stable

MAINTAINER Alexandru Mihai Glontaru <a.glontaru@jacobs-university.de>

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
# (1.4) MMT deps
#!!! RUN apt-get install -y java-common subversion
## (2) Cloning and installing MWS & friends
RUN mkdir /var/data/
RUN cd /var/data/ && git clone https://github.com/KWARC/mws.git
RUN cd /var/data/ && git clone https://github.com/KWARC/mws-frontend.git
RUN cd /var/data/ && git clone https://github.com/KWARC/tema-proxy.git
ADD tema-proxy-config.js /var/data/tema-proxy/config.js
RUN cd /var/data/mws/ && make && make install && cd ../
ADD mws-es-config.sh /var/data/mws/scripts/elastic-search/config.sh

## (3) Installing LaTeX
RUN apt-get install -y install texlive-full

## (4) Setting up generated content
ADD harvest-data /usr/bin/
# (5) Adding start-up script, see adjacent `start-tema` file for details
ADD start-tema /usr/bin/
