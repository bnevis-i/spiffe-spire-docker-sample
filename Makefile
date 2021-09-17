all: server agent

run: build
	docker-compose up -d

build: binaries
	docker-compose build

down:
	docker-compose down

clean: down
	docker volume prune -f
	rm -f */spire-server */spire-agent
	sudo rm -fr /tmp/edgex/secrets/spiffe

binaries: server config agent

unzip:

server: unzip server/spire-server

config: unzip config/spire-server

agent service1 service2: unzip agent/spire-agent service1/spire-agent service2/spire-agent

server/spire-server:
	cp spire-1.0.2/bin/spire-server $@

config/spire-server:
	cp spire-1.0.2/bin/spire-server $@

agent/spire-agent service1/spire-agent service2/spire-agent:
	cp spire-1.0.2/bin/spire-agent $@
