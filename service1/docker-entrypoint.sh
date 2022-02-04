#!/bin/sh

umask 027

: ${SPIFFE_ENDPOINT_SOCKET:=/tmp/edgex/secrets/spiffe/public/api.sock}

while ! spire-agent api fetch x509 -socketPath "${SPIFFE_ENDPOINT_SOCKET}" -write /tmp; do
  echo "Waiting for SVID"
  sleep 1
done

server

tail -f /dev/null
