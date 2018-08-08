FROM ubuntu:xenial
MAINTAINER John Garza <johnegarza@wustl.edu>

LABEL \
    description="Image containing Java, Picard, bwa, samblaster, samtools"

RUN apt-get update -y && apt-get install -y \
    apt-utils \
    bzip2 \
    default-jre \
    g++ \
    git \
    libbz2-dev \
    liblzma-dev \
    make \
    ncurses-dev \
    wget \
    zlib1g-dev

RUN mkdir /opt/picard-2.18.1/ \
    && cd /tmp/ \
    && wget --no-check-certificate https://github.com/broadinstitute/picard/releases/download/2.18.1/picard.jar \
    && mv picard.jar /opt/picard-2.18.1/ \
    && ln -s /opt/picard-2.18.1 /opt/picard \
    && ln -s /opt/picard-2.18.1 /usr/picard

ENV BWA_VERSION 0.7.15

RUN cd /tmp/ \
    && wget -q http://downloads.sourceforge.net/project/bio-bwa/bwa-${BWA_VERSION}.tar.bz2 && tar xvf bwa-${BWA_VERSION}.tar.bz2 \
    && cd /tmp/bwa-${BWA_VERSION} \
    && sed -i 's/CFLAGS=\\t\\t-g -Wall -Wno-unused-function -O2/CFLAGS=-g -Wall -Wno-unused-function -O2 -static/' Makefile \
    && make \
    && cp /tmp/bwa-${BWA_VERSION}/bwa /usr/local/bin \
    && rm -rf /tmp/bwa-${BWA_VERSION}

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

COPY alignment_helper.sh /usr/bin/alignment_helper.sh
