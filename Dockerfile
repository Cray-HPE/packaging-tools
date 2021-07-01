FROM python:3-alpine

WORKDIR /usr/src/packaging-tools

COPY requirements.txt ./

RUN set -ex \
    && apk -U upgrade --no-cache \
    && apk add --no-cache libxml2 libxslt \
    && apk add --no-cache --virtual .build-deps  \
        bluez-dev \
        build-base \
        bzip2-dev \
        cargo \
        coreutils \
        dpkg-dev dpkg \
        expat-dev \
        findutils \
        gcc \
        gdbm-dev \
        g++ \
        libc-dev \
        libffi-dev \
        libnsl-dev \
        libstdc++ \
        libtirpc-dev \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        make \
        musl-dev\
        ncurses-dev \
        openssl-dev \
        pax-utils \
        readline-dev \
        rust \
        sqlite-dev \
        tcl-dev \
        tk \
        tk-dev \
        util-linux-dev \
        xz-dev \
        zlib-dev \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && apk del --no-network .build-deps

COPY bin/* /usr/local/bin/
COPY schemas ./

VOLUME /data
WORKDIR /data

CMD [ "/bin/bash" ]
