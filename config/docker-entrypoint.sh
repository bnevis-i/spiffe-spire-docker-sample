#!/bin/sh -xe

umask 027

while test ! -f /srv/spiffe/server/data/journal.pem; do
  echo Waiting for database to initialize
  sleep 1
done

mkdir -p /tmp/edgex/secrets/spiffe/trust /tmp/edgex/secrets/spiffe/agent0
spire-server bundle show -registrationUDSPath /tmp/edgex/secrets/spiffe/run/registration.sock > /tmp/edgex/secrets/spiffe/trust/bundle
if [ $? -eq 0 ]; then
    echo INFO: Exported trust bundle
fi

if test ! -s /tmp/edgex/secrets/spiffe/agent0/join-token; then
    spire-server token generate -registrationUDSPath /tmp/edgex/secrets/spiffe/run/registration.sock | head -q -n 1 | awk '{ print $2; }' > /tmp/edgex/secrets/spiffe/agent0/join-token
    if [ $? -eq 0 ]; then
        echo INFO: Exported join token
    fi
fi

/usr/local/etc/spiffe-scripts.d/seed_builtin_entries.sh "spiffe://edgexfoundry.org/spire/agent/join_token/`cat /tmp/edgex/secrets/spiffe/agent0/join-token`"