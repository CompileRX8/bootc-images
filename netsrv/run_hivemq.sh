#!/bin/bash

podman volume create hivemq_data
podman volume create hivemq_log

podman create --name=hivemq-ce \
--net=host \
--hostname=netsrv.highley.net \
--add-host=netsrv.highley.net:10.0.0.250 \
-v hivemq_data:/opt/hivemq/data:Z \
-v hivemq_log:/opt/hivemq/log:Z \
hivemq/hivemq-ce:latest

