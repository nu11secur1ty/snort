# Snort 2.9.16
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
        ## new version
        # gcc \
        # libpcre3-dev \ 
        zlib1g-dev \
        libluajit-5.1-dev \ 
        # libpcap-dev \ 
        openssl \
        libssl-dev \
        libnghttp2-dev \
        # libdumbnet-dev \ 
        bison \
        flex \
        libdnet \
        vim && pip install -U pip dpkt snortunsock

# Define working directory.
WORKDIR /opt

ENV DAQ_VERSION 2.0.7
RUN wget https://www.snort.org/downloads/archive/snort/daq-${DAQ_VERSION}.tar.gz \
    && tar xvfz daq-${DAQ_VERSION}.tar.gz \
    && cd daq-${DAQ_VERSION} \
    && ./configure; make; make install

# ENV SNORT_VERSION 2.9.12
# ENV SNORT_VERSION 2.9.15
ENV SNORT_VERSION 2.9.16
RUN wget https://www.snort.org/downloads/archive/snort/snort-${SNORT_VERSION}.tar.gz \
    && tar xvfz snort-${SNORT_VERSION}.tar.gz \
    && cd snort-${SNORT_VERSION} \
    && ./configure --enable-sourcefire; make; make install

RUN ldconfig

# pigrelay
# RUN wget --no-check-certificate \
#         https://github.com/John-Lin/pigrelay/archive/master.zip \
#     && unzip master.zip

# snortunsock
RUN wget --no-check-certificate \
        https://github.com/John-Lin/snortunsock/archive/master.zip \
    && unzip master.zip

# ENV SNORT_RULES_SNAPSHOT 2972
# ADD snortrules-snapshot-${SNORT_RULES_SNAPSHOT} /opt
ADD mysnortrules /opt
RUN mkdir -p /var/log/snort && \
    mkdir -p /usr/local/lib/snort_dynamicrules && \
    mkdir -p /etc/snort && \
    # mkdir -p /etc/snort/rules && \
    # mkdir -p /etc/snort/preproc_rules && \
    # mkdir -p /etc/snort/so_rules && \
    # mkdir -p /etc/snort/etc && \

    # mysnortrules rules
    cp -r /opt/rules /etc/snort/rules && \
    # Due to empty folder so mkdir
    mkdir -p /etc/snort/preproc_rules && \
    mkdir -p /etc/snort/so_rules && \
    # cp -r /opt/preproc_rules /etc/snort/preproc_rules && \
    # cp -r /opt/so_rules /etc/snort/so_rules && \
    cp -r /opt/etc /etc/snort/etc && \

    # snapshot2972 rules
    # cp -r /opt/rules /etc/snort/rules && \
    # cp -r /opt/preproc_rules /etc/snort/preproc_rules && \
    # cp -r /opt/so_rules /etc/snort/so_rules && \
    # cp -r /opt/etc /etc/snort/etc && \

    # touch /etc/snort/rules/local.rules && \
    touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules

# Clean up APT when done.
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /opt/snort-${SNORT_VERSION}.tar.gz /opt/daq-${DAQ_VERSION}.tar.gz


ENV NETWORK_INTERFACE eth0
# Validate an installation
# snort -T -i eth0 -c /etc/snort/etc/snort.conf
CMD ["snort", "-T", "-i", "echo ${NETWORK_INTERFACE}", "-c", "/etc/snort/etc/snort.conf"]
