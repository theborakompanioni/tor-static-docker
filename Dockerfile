# global arguments
ARG MAINTAINER='tbk https://github.com/theborakompanioni'

FROM debian:bullseye-slim
ARG MAINTAINER

LABEL maintainer="$MAINTAINER"

RUN apt-get update \
    && apt-get install -qq --no-install-recommends --no-install-suggests -y gnupg curl apt-transport-https ca-certificates \
    # add nginx debian repo
    && curl --silent https://nginx.org/keys/nginx_signing.key | \
    gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg > /dev/null \
    && sh -c "echo 'deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/mainline/debian/ bullseye nginx' > /etc/apt/sources.list.d/nginx.list" \
    # add tor debian repo
    && curl --silent https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | \
    gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg > /dev/null \
    && sh -c "echo 'deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main' > /etc/apt/sources.list.d/tor.list"

RUN apt-get update \
    && apt-get install -qq --no-install-recommends --no-install-suggests -y \
    # image dependencies
    tini supervisor iproute2 procps vim \
    # tor
    tor \
    deb.torproject.org-keyring \
    # ui dependencies
    nginx \
    # cleanup
    && apt-get clean \
    && apt-get remove --purge --auto-remove -y gnupg apt-transport-https \
    && rm --recursive --force /var/lib/apt/lists/* \
    && rm --force /var/log/dpkg.log

COPY torrc /etc/tor/torrc
COPY index.html /app/
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY supervisor-conf/*.conf /etc/supervisor/conf.d/

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT  [ "tini", "-g", "--", "/docker-entrypoint.sh" ]
