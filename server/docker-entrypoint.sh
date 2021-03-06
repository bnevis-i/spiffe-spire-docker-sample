#!/bin/sh -xe

umask 027

# Set default env vars if unassigned
: ${SPIFFE_SERVER_SOCKET:=/tmp/edgex/secrets/spiffe/private/api.sock}
: ${SPIFFE_ENDPOINT_SOCKET:=/tmp/edgex/secrets/spiffe/public/api.sock}
: ${SPIFFE_TRUSTBUNDLE_PATH:=/tmp/edgex/secrets/spiffe/trust/bundle}
: ${SPIFFE_TRUST_DOMAIN:=edgexfoundry.org}
: ${SPIFFE_SERVER_HOST:=spiffe-server}
: ${SPIFFE_SERVER_PORT:=8968}

for dir in `dirname "${SPIFFE_SERVER_SOCKET}"` \
           `dirname "${SPIFFE_ENDPOINT_SOCKET}"` \
           /srv/spiffe/ca/public \
           /srv/spiffe/ca/private ; do
    test -d "$dir" || mkdir -p "$dir"
done

# CA SPIFFE identifiers

if test ! -f "/srv/spiffe/ca/public/ca.crt"; then
    openssl ecparam -genkey -name secp521r1 -noout -out "/srv/spiffe/ca/private/ca.key"
    SAN="" openssl req -subj "/CN=SPIFFE Root CA" -config "/usr/local/etc/openssl.conf" -key "/srv/spiffe/ca/private/ca.key" -sha384 -new -out "/run/ca.req.$$"
    SAN="" openssl x509 -sha384 -signkey "/srv/spiffe/ca/private/ca.key" -clrext -extfile /usr/local/etc/openssl.conf -extensions ca_ext -CAkey "/srv/spiffe/ca/private/ca.key" -CAcreateserial -req -in "/run/ca.req.$$" -days 3650 -out "/srv/spiffe/ca/public/ca.crt"
    rm -f "/run/ca.req.$$"
fi

# CA for node (agent) attestation

if test ! -f "/srv/spiffe/ca/public/agent-ca.crt"; then
    openssl ecparam -genkey -name secp521r1 -noout -out "/srv/spiffe/ca/private/agent-ca.key"
    SAN="" openssl req -subj "/CN=SPIFFE Agent CA" -config "/usr/local/etc/openssl.conf" -key "/srv/spiffe/ca/private/agent-ca.key" -sha384 -new -out "/run/ca.req.$$"
    SAN="" openssl x509 -sha384 -signkey "/srv/spiffe/ca/private/agent-ca.key" -clrext -extfile /usr/local/etc/openssl.conf -extensions ca_ext -CAkey "/srv/spiffe/ca/private/agent-ca.key" -CAcreateserial -req -in "/run/ca.req.$$" -days 3650 -out "/srv/spiffe/ca/public/agent-ca.crt"
    rm -f "/run/ca.req.$$"
fi

# Process server configuration template

CONF_FILE="/srv/spiffe/server/server.conf"
cp -fp /usr/local/etc/spire/server.conf.tpl "${CONF_FILE}"

sed -i -e "s~SPIFFE_ENDPOINT_SOCKET~${SPIFFE_ENDPOINT_SOCKET}~" "${CONF_FILE}"
sed -i -e "s~SPIFFE_SERVER_SOCKET~${SPIFFE_SERVER_SOCKET}~" "${CONF_FILE}"
sed -i -e "s~SPIFFE_TRUSTBUNDLE_PATH~${SPIFFE_TRUSTBUNDLE_PATH}~" "${CONF_FILE}"
sed -i -e "s~SPIFFE_TRUST_DOMAIN~${SPIFFE_TRUST_DOMAIN}~" "${CONF_FILE}"
sed -i -e "s~SPIFFE_SERVER_HOST~${SPIFFE_SERVER_HOST}~" "${CONF_FILE}"
sed -i -e "s~SPIFFE_SERVER_PORT~${SPIFFE_SERVER_PORT}~" "${CONF_FILE}"

exec spire-server run -config "${CONF_FILE}"
