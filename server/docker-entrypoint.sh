#!/bin/sh -xe

umask 027

rm -f /tmp/edgex/secrets/spiffe/agent0/join-token
mkdir -p /tmp/edgex/secrets/spiffe/run /tmp/edgex/secrets/spiffe/ca

if test ! -f "/srv/spiffe/ca/public/ca.crt"; then
    mkdir -p "/srv/spiffe/ca/public" "/srv/spiffe/ca/private"
    openssl ecparam -genkey -name secp521r1 -noout -out "/srv/spiffe/ca/private/ca.key"
    SAN="" openssl req -subj "/CN=SPIFFE Root CA" -config "/usr/local/etc/openssl.conf" -key "/srv/spiffe/ca/private/ca.key" -sha384 -new -out "/run/ca.req.$$"
    SAN="" openssl x509 -sha384 -signkey "/srv/spiffe/ca/private/ca.key" -clrext -extfile /usr/local/etc/openssl.conf -extensions ca_ext -CAkey "/srv/spiffe/ca/private/ca.key" -CAcreateserial -req -in "/run/ca.req.$$" -days 3650 -out "/srv/spiffe/ca/public/ca.crt"
    rm -f "/run/ca.req.$$"
fi

cp -fp /srv/spiffe/ca/public/ca.crt /tmp/edgex/secrets/spiffe/ca/ca.crt

exec spire-server run -config /usr/local/etc/spire/server.conf
