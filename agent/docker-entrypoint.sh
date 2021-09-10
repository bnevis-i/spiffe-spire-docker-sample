#!/bin/sh

umask 027

while test ! -s /tmp/edgex/secrets/spiffe/agent0/join-token; do
  echo Waiting for /tmp/edgex/secrets/spiffe/agent0/join-token
  sleep 1
done

exec /usr/local/bin/spire-agent run  -config /usr/local/etc/spire/agent.conf -joinToken `cat /tmp/edgex/secrets/spiffe/agent0/join-token`
