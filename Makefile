FVERSION=build/VERSION

# Which container to choose: podman by default, else docker
CTN := $(shell which podman >/dev/null 2>&1 && echo podman || echo docker)
PWD := $(shell pwd)

# For podman: map current uid/gid for mounting volumes with correct permissions
ID := $(shell id -u)
# fusioniam default user id in container
UID := 1000
# fusioniam default group id in container
GID := 1000
# uidmap format: rootless user: container_uid:intermediate_uid:amount
#                rootful user: container_uid:host_uid:amount
# rootless user:
# map podman user uid (0) to fusioniam container uid (1000) + map lowest user uid in /etc/subuid (1) to root container uid (0)
# rootful user:
# map root (0) to fusioniam container uid (1000) + map user uid 100000 to root container uid (0)
UIDMAP := $(shell which podman >/dev/null 2>&1 && if [ $(ID) -eq 0 ]; then echo "--uidmap $(UID):0:1 --uidmap 0:100000:1"; else echo "--uidmap $(UID):0:1 --uidmap 0:1:1"; fi || echo "")
GIDMAP := $(shell which podman >/dev/null 2>&1 && if [ $(ID) -eq 0 ]; then echo "--gidmap $(GID):0:1 --gidmap 0:100000:1"; else echo "--gidmap $(GID):0:1 --gidmap 0:1:1"; fi || echo "")

IMAGENAME="fusioniam-rockylinux9"
VVERSION=`cat $(FVERSION)`
IDLDAP="fusioniam-directory-server"
IDWPB="fusioniam-white-pages-php-fpm"
IDWPF="fusioniam-white-pages-nginx"
IDSDB="fusioniam-service-desk-php-fpm"
IDSDF="fusioniam-service-desk-nginx"
IDLEMONB="fusioniam-access-manager-fastcgi-server"
IDLEMONF="fusioniam-access-manager-nginx"
IDLEMONC="fusioniam-access-manager-cron"
IDBASE="fusioniam-database"
IDFDB="fusioniam-fusiondirectory-php-fpm"
IDFDF="fusioniam-fusiondirectory-nginx"


################################################################################
# Run commands
################################################################################

# check / create bridge network
startnet:
	$(CTN) network inspect fusioniam-net >/dev/null 2>&1 && \
	echo "network fusioniam-net ok" || \
	$(CTN) network create -d bridge fusioniam-net

stopnet:
	$(CTN) network inspect fusioniam-net >/dev/null 2>&1 && \
	$(CTN) network rm fusioniam-net || \
	echo "network fusioniam-net already removed"

runldap: startnet
	mkdir -p run/volumes/ldap-data run/volumes/ldap-config
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/ldap-data:/usr/local/openldap/var/openldap-data \
		-v $(PWD)/run/volumes/ldap-config:/usr/local/openldap/etc/openldap/slapd.d \
		-v $(PWD)/run/volumes/ldap-tls:/usr/local/openldap/etc/openldap/tls \
		--rm=true \
		--network=fusioniam-net \
		--network-alias=fusioniam-directory-server \
		-p 127.0.0.1:33389:33389 \
		--name=fusioniam-directory-server \
		--detach=true \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-openldap-ltb:v0.1

runwp: startnet
	mkdir -p run/volumes/wp-run
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/wp-run:/run/php-fpm/ \
		--rm=true \
		--network=fusioniam-net \
		--name=fusioniam-white-pages-php-fpm \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-white-pages:v0.1 \
		/bin/bash /run-ct.sh php-fpm
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/wp-run:/var/run/php-fpm/ \
		--rm=true \
		-p 127.0.0.1:8083:8080 \
		--network=fusioniam-net \
		--network-alias=fusioniam-white-pages-nginx \
		--name=fusioniam-white-pages-nginx \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-white-pages:v0.1 \
		/bin/bash /run-ct.sh nginx

runsd: startnet
	mkdir -p run/volumes/sd-run
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/sd-run:/run/php-fpm/ \
		--rm=true \
		--network=fusioniam-net \
		--name=fusioniam-service-desk-php-fpm \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-service-desk:v0.1 \
		/bin/bash /run-ct.sh php-fpm
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/sd-run:/var/run/php-fpm/ \
		--rm=true \
		-p 127.0.0.1:8082:8080 \
		--network=fusioniam-net \
		--network-alias=fusioniam-service-desk-nginx \
		--name=fusioniam-service-desk-nginx \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-service-desk:v0.1 \
		/bin/bash /run-ct.sh nginx

runfd: startnet
	mkdir -p run/volumes/fd-run
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/fd-run:/run/php-fpm/ \
		--rm=true \
		--network=fusioniam-net \
		--name=fusioniam-fusiondirectory-php-fpm \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-fusiondirectory:v0.1 \
		/bin/bash /run-ct.sh php-fpm
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/fd-run:/var/run/php-fpm/ \
		--rm=true \
		-p 127.0.0.1:8081:8080 \
		--network=fusioniam-net \
		--network-alias=fusioniam-fusiondirectory-nginx \
		--name=fusioniam-fusiondirectory-nginx \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-fusiondirectory:v0.1 \
		/bin/bash /run-ct.sh nginx

runlemon: startnet
	mkdir -p run/volumes/sso-data
	mkdir -p run/volumes/llng-run
	mkdir -p run/volumes/llng-cache
	mkdir -p run/volumes/llng-keys
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/sso-data:/var/lib/postgresql/data \
		--rm=true \
		-p 127.0.0.1:33432:5432 \
		--network=fusioniam-net \
		--network-alias=fusioniam-database \
		--name=fusioniam-database \
		--detach=true \
		docker.io/library/postgres
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/llng-run:/run/llng-fastcgi-server \
		-v $(PWD)/run/volumes/llng-cache:/var/cache/lemonldap-ng \
		-v $(PWD)/run/volumes/llng-keys:/etc/lemonldap-ng-keys \
		--rm=true \
		--network=fusioniam-net \
		--name=fusioniam-access-manager-fastcgi-server \
                --add-host=reload.demo.fusioniam.org:10.0.2.2 \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-lemonldap-ng:v0.1 \
		/bin/bash /run-ct.sh llng-fastcgi-server
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/llng-run:/run/llng-fastcgi-server \
		-v $(PWD)/run/volumes/llng-cache:/var/cache/lemonldap-ng \
		-v $(PWD)/run/volumes/llng-keys:/etc/lemonldap-ng-keys \
		--rm=true \
		-p 127.0.0.1:8080:8080 \
		--network=fusioniam-net \
		--name=fusioniam-access-manager-nginx \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-lemonldap-ng:v0.1 \
		/bin/bash /run-ct.sh nginx
	$(CTN) run \
		--env-file=./run/ENVVAR.example \
		-v $(PWD)/run/volumes/llng-run:/run/llng-fastcgi-server \
		-v $(PWD)/run/volumes/llng-cache:/var/cache/lemonldap-ng \
		-v $(PWD)/run/volumes/llng-keys:/etc/lemonldap-ng-keys \
		--rm=true \
		--network=fusioniam-net \
		--name=fusioniam-access-manager-cron \
		--detach=true \
		--entrypoint=/usr/bin/tini \
		$(UIDMAP) \
		$(GIDMAP) \
		fusioniam-lemonldap-ng:v0.1 \
		/bin/bash /run-ct.sh purge-sessions

runall: runldap runwp runsd runfd runlemon


################################################################################
# Stop commands
################################################################################

stopldap:
		for container in $(IDLDAP) ; do \
			$(CTN) stop $$container ; \
		done

stopwp:
		for container in $(IDWPF) $(IDWPB) ; do \
			$(CTN) stop $$container ; \
		done

stopsd:
		for container in $(IDSDF) $(IDSDB) ; do \
			$(CTN) stop $$container ; \
		done

stoplemon:
		for container in $(IDLEMONF) $(IDLEMONB) $(IDLEMONC) $(IDBASE) ; do \
			$(CTN) stop $$container ; \
		done

stopfd:
		for container in $(IDFDB) $(IDFDF) ; do \
			$(CTN) stop $$container ; \
		done

stopall: stopldap stopwp stopsd stoplemon stopfd stopnet


################################################################################
# Enter commands
################################################################################

enterldap:
		$(CTN) exec --user 0 -it $(IDLDAP) /bin/bash

enterwp:
		$(CTN) exec --user 0 -it $(IDWPB) /bin/bash

entersd:
		$(CTN) exec --user 0 -it $(IDSDB) /bin/bash

enterlemon:
		$(CTN) exec --user 0 -it $(IDLEMONB) /bin/bash

enterfd:
		$(CTN) exec --user 0 -it $(IDFDB) /bin/bash
