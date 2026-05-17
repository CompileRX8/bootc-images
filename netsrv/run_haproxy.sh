#!/bin/bash

podman volume create haproxy_config

podman create --name=haproxy \
--cap-add=NET_ADMIN \
--cap-add=NET_RAW \
--cap-add=CAP_AUDIT_WRITE \
--cap-add=NET_BIND_SERVICE \
--net=host \
--hostname=netsrv.highley.net \
--add-host=netsrv.highley.net:10.0.0.250 \
-v /var/run:/var/run:Z \
-v haproxy_config:/usr/local/etc/haproxy:Z \
docker.io/library/haproxy:3.0

#podman start haproxy

