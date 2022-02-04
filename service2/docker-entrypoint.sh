#!/bin/sh

umask 027

: ${SPIFFE_ENDPOINT_SOCKET:=/tmp/edgex/secrets/spiffe/public/api.sock}

while ! spire-agent api fetch x509 -socketPath "${SPIFFE_ENDPOINT_SOCKET}" -write /tmp; do
  echo "Waiting for SVID"
  sleep 1
done

while ! spire-agent api fetch jwt -socketPath "${SPIFFE_ENDPOINT_SOCKET}" -audience myinstall > /tmp/getjwt.txt; do
  echo "Waiting for SVID"
  sleep 1
done
sed -n -e 's/^\s\(ey.*\)/\1/p' /tmp/getjwt.txt > /tmp/svid.0.jwt

sleep 5

tlsclient

tail -f /dev/null
