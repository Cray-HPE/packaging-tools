FROM python:3

WORKDIR /usr/src/packaging-tools

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY bin/* /usr/local/bin/
COPY hack schemas ./

VOLUME /data
WORKDIR /data

CMD [ "/bin/bash" ]
