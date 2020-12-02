FROM ubuntu:xenial
MAINTAINER John Garza <johnegarza@wustl.edu>

LABEL \
    description="Image containing Java, Picard, bwa, samblaster, samtools"

RUN apt-get update -y && apt-get install -y \
    apt-utils \
    build-essential \
    bzip2 \
    cmake \
    default-jre \
    g++ \
    git \
    libbz2-dev \
    liblzma-dev \
    libtbb2 \
    libtbb-dev \
    make \
    ncurses-dev \
    wget \
    xz-utils \
    zlib1g-dev

RUN mkdir /opt/picard-2.18.1/ \
    && cd /tmp/ \
    && wget --no-check-certificate https://github.com/broadinstitute/picard/releases/download/2.18.1/picard.jar \
    && mv picard.jar /opt/picard-2.18.1/ \
    && ln -s /opt/picard-2.18.1 /opt/picard \
    && ln -s /opt/picard-2.18.1 /usr/picard



ENV BWA_VERSION 2-2.1
RUN cd /opt/ \
    && wget -q https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.1/bwa-mem${BWA_VERSION}_x64-linux.tar.bz2 \
    && tar -xjvf bwa-mem${BWA_VERSION}_x64-linux.tar.bz2 \
    && cp /opt/bwa-mem${BWA_VERSION}_x64-linux/bwa-mem2* /usr/local/bin/ \
    && rm -rf bwa-mem${BWA_VERSION}_x64-linux.tar.bz2

RUN cd /tmp/ \
    && git clone https://github.com/GregoryFaust/samblaster.git \
    && cd /tmp/samblaster \
    && git checkout tags/v.0.1.24 \
    && make \
    && cp /tmp/samblaster/samblaster /usr/local/bin \
    && rm -rf /tmp/samblaster

ENV SAMTOOLS_INSTALL_DIR=/opt/samtools

WORKDIR /tmp
RUN wget https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 && \
  tar --bzip2 -xf samtools-1.7.tar.bz2

WORKDIR /tmp/samtools-1.7
RUN ./configure --enable-plugins --prefix=$SAMTOOLS_INSTALL_DIR && \
  make all all-htslib && \
  make install install-htslib

WORKDIR /
RUN ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/bin/samtools && \
  rm -rf /tmp/samtools-1.7

###############
# Flexbar 3.5 #
###############

RUN mkdir -p /opt/flexbar/tmp \
    && cd /opt/flexbar/tmp \
    && wget https://github.com/seqan/flexbar/archive/v3.5.0.tar.gz \
    && wget https://github.com/seqan/seqan/releases/download/seqan-v2.4.0/seqan-library-2.4.0.tar.xz \
    && tar xzf v3.5.0.tar.gz \
    && tar xJf seqan-library-2.4.0.tar.xz \
    && mv seqan-library-2.4.0/include flexbar-3.5.0 \
    && cd flexbar-3.5.0 \
    && cmake . \
    && make \
    && cp flexbar /opt/flexbar/ \
    && cd / \
    && rm -rf /opt/flexbar/tmp


COPY alignment_helper.sh /usr/bin/alignment_helper.sh
