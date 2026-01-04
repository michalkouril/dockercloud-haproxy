FROM ubuntu:24.04
MAINTAINER Michal Kouril<xmkouril@gmail.com>

RUN apt update
RUN apt install -y git vim tini haproxy python3 python3-gevent python3-future python3-websocket python3-docker python3-compose python3-mock python3-nose python3-pip
RUN python3 -m pip install git+https://github.com/michalkouril/python-dockercloud.git --break-system-packages

COPY . /haproxy-src

RUN cp /haproxy-src/reload.sh /reload.sh
RUN cd /haproxy-src && \
    python3 -m pip install . --break-system-packages

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
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["dockercloud-haproxy"]
