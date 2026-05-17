#!/bin/bash

podman volume create httpd_html

podman create --name=httpd \
--net=host \
--hostname=netsrv.highley.net \
--add-host=netsrv.highley.net:10.0.0.250 \
-v httpd_html:/var/www:Z \
quay.io/fedora/httpd-24:latest

#podman start haproxy

