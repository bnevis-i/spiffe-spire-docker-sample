#!/bin/sh -xe

umask 027

rm -f /tmp/edgex/secrets/spiffe/agent0/join-token
mkdir -p /tmp/edgex/secrets/spiffe/run

exec spire-server run -config /usr/local/etc/spire/server.conf
