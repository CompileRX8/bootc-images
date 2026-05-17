#!/bin/bash

step ca renew --force --offline https/cert.pem https/key.pem

podman secret create gitea-quadlet-cert --replace https/cert.pem
