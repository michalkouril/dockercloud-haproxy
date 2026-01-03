FROM alpine:3.22
MAINTAINER Michal Kouril<xmkouril@gmail.com>

# add python2
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main"  >> /etc/apk/repositories
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/community"  >> /etc/apk/repositories
# RUN apk add python2 python2-dev make g++ && rm -rf /var/cache/apk/*
RUN apk add python3 python3-dev py3-pip make g++ git && rm -rf /var/cache/apk/*
# RUN python3 -m ensurepip --upgrade --break-system-packages

COPY . /haproxy-src

RUN apk update
# RUN pip3 install future --break-system-packages
RUN apk --no-cache add tini haproxy build-base libffi-dev openssl-dev py3-cached-property py3-docker-py py3-docopt py3-jsonschema py3-texttable py3-requests py3-six py3-websocket-client py3-gevent py3-dockerpty py3-future
# py3-pyaml
# py3-future
# RUN pip3 install "PyYAML>6.0" --break-system-packages
# RUN pip3 install "cython>=3.0.0" --break-system-packages
# RUN pip3 install "PyYAML<5.4.0" --break-system-packages
# RUN pip3 install "cython<3.0.0" --break-system-packages
# RUN pip3 install docker-compose --break-system-packages
# RUN pip3 install python-dockercloud --break-system-packages
RUN cp /haproxy-src/reload.sh /reload.sh
#PIP_CONSTRAINT=constraint.txt pip3 install -r requirements.txt
# RUN cd /haproxy-src && \
#     PIP_CONSTRAINT=constraint.txt pip3 install . --break-system-packages && \
#     apk del build-base python3-dev && \
#     rm -rf "/tmp/*" "/root/.cache" `find / -regex '.*\.py[co]'`
RUN pip3 install  git+https://github.com/michalkouril/python-dockercloud.git --break-system-packages
RUN cd /haproxy-src && \
    pip3 install . --break-system-packages

ENV RSYSLOG_DESTINATION=127.0.0.1 \
    MODE=http \
    BALANCE=roundrobin \
    MAXCONN=4096 \
    OPTION="redispatch, httplog, dontlognull, forwardfor" \
    TIMEOUT="connect 5000, client 50000, server 50000" \
    STATS_PORT=1936 \
    STATS_AUTH="stats:stats" \
    SSL_BIND_OPTIONS="ssl-min-ver TLSv1.2" \
    SSL_BIND_CIPHERS="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384" \
    SSL_BIND_CIPHERSUITES="TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256" \
    HEALTH_CHECK="check inter 2000 rise 2 fall 3" \
    NBPROC=1

# can't run as non-root user since we generate config to /haproxy.cfg
# USER haproxy
EXPOSE 80 443 1936
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["dockercloud-haproxy"]
