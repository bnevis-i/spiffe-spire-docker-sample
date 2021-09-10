#!/bin/sh -x

local_agent_svid=$1
reg_sock="/tmp/edgex/secrets/spiffe/run/registration.sock"
svid_service_base="spiffe://edgexfoundry.org/service"

/usr/local/bin/spire-server entry create -registrationUDSPath "${reg_sock}" -parentID "${local_agent_svid}" -dns spiffe-agent -spiffeID "${svid_service_base}/spiffe-agent" -selector "docker:label:com.docker.compose.service:spiffe-agent"
/usr/local/bin/spire-server entry create -registrationUDSPath "${reg_sock}" -parentID "${local_agent_svid}" -dns spiffe-service1 -spiffeID "${svid_service_base}/spiffe-service1" -selector "docker:label:com.docker.compose.service:spiffe-service1"
/usr/local/bin/spire-server entry create -registrationUDSPath "${reg_sock}" -parentID "${local_agent_svid}" -dns spiffe-service2 -spiffeID "${svid_service_base}/spiffe-service2" -selector "docker:label:com.docker.compose.service:spiffe-service2"
