FROM dtr.dev.cray.com/baseos/centos8:8

RUN dnf -y update \
    && dnf -y group install --with-optional "Development Tools" \
    && dnf -y install \
        dnf-utils \
        git \
        python3 \
        python3-devel \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN chmod 777 /etc/yum.repos.d
RUN alternatives --set python /usr/bin/python3

WORKDIR /usr/src/packaging-tools

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY bin/* /usr/local/bin/
COPY hack schemas ./

VOLUME /data
WORKDIR /data

CMD [ "/bin/bash" ]
