#!/bin/sh -xe

umask 027

export SPIFFE_SERVER_SOCKET
export SPIFFE_EDGEX_SVID_BASE
export SPIFFE_TRUST_DOMAIN

: ${SPIFFE_SERVER_SOCKET:=/tmp/edgex/secrets/spiffe/private/api.sock}
: ${SPIFFE_EDGEX_SVID_BASE:=spiffe://edgexfoundry.org/service}
: ${SPIFFE_TRUST_DOMAIN:=edgexfoundry.org}

: ${SPIFFE_AGENT0_CN:=agent0}
: ${SPIFFE_PARENTID:=spiffe://${SPIFFE_TRUST_DOMAIN}/spire/agent/x509pop/cn/${SPIFFE_AGENT0_CN}}

/usr/local/etc/spiffe-scripts.d/seed_builtin_entries.sh "${SPIFFE_PARENTID}"

exec tail -f /dev/null
