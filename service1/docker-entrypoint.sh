#!/bin/sh

umask 027

while ! spire-agent api fetch x509 -socketPath /tmp/edgex/secrets/spiffe/run/agent.sock -write /tmp; do
  echo "Waiting for SVID"
  sleep 1
done

server

tail -f /dev/null
