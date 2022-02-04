#!/bin/sh -x

local_agent_svid=$1

echo "local_agent_svid=${local_agent_svid}"
echo "SPIFFE_SERVER_SOCKET=${SPIFFE_SERVER_SOCKET}"
echo "SPIFFE_EDGEX_SVID_BASE=${SPIFFE_EDGEX_SVID_BASE}"

#spire-server entry create -socketPath "${SPIFFE_SERVER_SOCKET}" -parentID "${local_agent_svid}" -dns spiffe-agent -spiffeID "${SPIFFE_EDGEX_SVID_BASE}/spiffe-agent" -selector "docker:label:com.docker.compose.service:spiffe-agent"
spire-server entry create -socketPath "${SPIFFE_SERVER_SOCKET}" -parentID "${local_agent_svid}" -dns spiffe-service1 -spiffeID "${SPIFFE_EDGEX_SVID_BASE}/spiffe-service1" -selector "docker:label:com.docker.compose.service:spiffe-service1"
spire-server entry create -socketPath "${SPIFFE_SERVER_SOCKET}" -parentID "${local_agent_svid}" -dns spiffe-service2 -spiffeID "${SPIFFE_EDGEX_SVID_BASE}/spiffe-service2" -selector "docker:label:com.docker.compose.service:spiffe-service2"
