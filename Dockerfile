FROM alpine:3.22
MAINTAINER Michal Kouril<xmkouril@gmail.com>

# add python2
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main"  >> /etc/apk/repositories
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/community"  >> /etc/apk/repositories
RUN apk add python2 python2-dev make g++ && rm -rf /var/cache/apk/*
RUN python -m ensurepip --upgrade

COPY . /haproxy-src

RUN apk update && \
    apk --no-cache add tini haproxy build-base libffi-dev openssl-dev && \
    cp /haproxy-src/reload.sh /reload.sh && \
    cd /haproxy-src && \
    PIP_CONSTRAINT=constraint.txt pip2 install -r requirements.txt && \
    PIP_CONSTRAINT=constraint.txt pip2 install . && \
    apk del build-base python2-dev && \
    rm -rf "/tmp/*" "/root/.cache" `find / -regex '.*\.py[co]'`

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

USER haproxy
EXPOSE 80 443 1936
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["dockercloud-haproxy"]
