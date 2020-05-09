# Snort 
FROM ubuntu:18.04

MAINTAINER Ventsislav Varbanovski <penetrateoffensive@gmail.com>

RUN apt update && \
    apt install -y \
        gcc \
        net-tools \
        python-setuptools \
        python-pip \
        python-dev \
        wget \
        build-essential \
        bison \
        flex \
        libpcap-dev \
        libpcre3-dev \
        libdumbnet-dev \
        zlib1g-dev \
        iptables-dev \
        libnetfilter-queue1 \
        tcpdump \
        unzip \
        zlib1g-dev \
        libluajit-5.1-dev \  
        openssl \
        libssl-dev \
        libnghttp2-dev \
        bison \
        flex \
        libdnet \
        vim && pip install -U pip dpkt snortunsock

# Define working directory.
WORKDIR /opt

ENV DAQ_VERSION 2.0.6
RUN wget https://www.snort.org/downloads/archive/snort/daq-${DAQ_VERSION}.tar.gz \
    && tar xvfz daq-${DAQ_VERSION}.tar.gz \
    && cd daq-${DAQ_VERSION} \
    && ./configure; make; make install

ENV SNORT_VERSION 2.9.12
RUN wget https://www.snort.org/downloads/archive/snort/snort-${SNORT_VERSION}.tar.gz \
    && tar xvfz snort-${SNORT_VERSION}.tar.gz \
    && cd snort-${SNORT_VERSION} \
    && ./configure --enable-sourcefire; make; make install

RUN ldconfig

# snortunsock
RUN wget --no-check-certificate \
       https://github.com/nu11secur1ty/snort-2.9.12/snortunsock/archive/master.zip \
    && unzip master.zip

# ENV SNORT_RULES_SNAPSHOT 2972
ADD mysnortrules /opt
RUN mkdir -p /var/log/snort && \
    mkdir -p /usr/local/lib/snort_dynamicrules && \
    mkdir -p /etc/snort && \

    # mysnortrules rules
    cp -r /opt/rules /etc/snort/rules && \
    
    # Due to empty folder so mkdir
    mkdir -p /etc/snort/preproc_rules && \
    mkdir -p /etc/snort/so_rules && \
    cp -r /opt/etc /etc/snort/etc && \
    touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules

# Clean up APT when done.
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /opt/snort-${SNORT_VERSION}.tar.gz /opt/daq-${DAQ_VERSION}.tar.gz


ENV NETWORK_INTERFACE eth0

# Validate an installation
# snort -T -i eth0 -c /etc/snort/etc/snort.conf
CMD ["snort", "-T", "-i", "echo ${NETWORK_INTERFACE}", "-c", "/etc/snort/etc/snort.conf"]
