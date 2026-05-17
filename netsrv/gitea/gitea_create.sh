#!/bin/bash

BASENAME=gitea-local
VOLNAME_DATA=$BASENAME-data
VOLNAME_CONFIG=$BASENAME-config
VOLNAME_POSTGRESQL=$BASENAME-postgresql

HOSTNAME=$(hostname -f)

if ( ! podman volume exists $VOLNAME_DATA ); then
    podman volume create --opt o=uid=1000,gid=1000 $VOLNAME_DATA
    tar cvf - . | podman volume import $VOLNAME_DATA -
fi
if ( ! podman volume exists $VOLNAME_CONFIG ); then
    podman volume create --opt o=uid=1000,gid=1000 $VOLNAME_CONFIG
fi
if ( ! podman volume exists $VOLNAME_POSTGRESQL ); then
    podman volume create $VOLNAME_POSTGRESQL
fi

if ( ! podman pod exists $BASENAME ); then
    podman pod create --name $BASENAME \
        --hostname $HOSTNAME \
        --network host \
        --volume $VOLNAME_DATA:/var/lib/gitea:Z \
        --volume $VOLNAME_CONFIG:/etc/gitea:Z \
        --volume /etc/localtime:/etc/localtime:ro \
        --volume /etc/pki:/etc/pki:ro
fi

if ( ! podman container exists $BASENAME-gitea ); then
    podman create --name $BASENAME-gitea \
        --pod $BASENAME \
        --publish 3000:3000 \
        --publish 22222:22222 \
        -e GITEA__server__DOMAIN=$HOSTNAME \
        -e GITEA__server__PROTOCOL=https \
        -e GITEA__server__CERT_FILE=https/cert.pem \
        -e GITEA__server__KEY_FILE=https/key.pem \
        -e GITEA__server__SSH_PORT=22222 \
        -e GITEA__server__SSH_LISTEN_PORT=22222 \
        -e GITEA__database__DB_TYPE=postgres \
        -e GITEA__database__HOST=localhost:5432 \
        -e GITEA__database__NAME=gitea \
        -e GITEA__database__USER=gitea \
        -e GITEA__database__PASSWD=gitea \
        gitea/gitea:1.24.6-rootless
fi

#        -e GITEA__server__ENABLE_ACME=false \
#        -e GITEA__server__ACME_ACCEPTTOS=true \
#        -e GITEA__server__ACME_URL=https://localhost:10443/acme/acme/directory \
#        -e GITEA__server__ACME_DIRECTORY=https \
#        -e GITEA__server__ACME_CA_ROOT=https/ca-chain.cert.pem \
#        -e GITEA__server__ACME_EMAIL=rhighley@redhat.com \

if ( ! podman container exists $BASENAME-postgresql ); then
    podman create --name $BASENAME-postgresql \
        --pod $BASENAME \
        -e POSTGRESQL_USER=gitea \
        -e POSTGRESQL_PASSWORD=gitea \
        -e POSTGRESQL_DATABASE=gitea \
        --volume $VOLNAME_POSTGRESQL:/var/lib/postgresql/data:Z \
        registry.redhat.io/rhel10/postgresql-16:latest
fi

# podman pod start $BASENAME

