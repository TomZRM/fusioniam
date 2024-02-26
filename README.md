# FusionIAM

This is the main [FusionIAM](https://www.fusioniam.org) project.

FusionIAM is a software federation to offer a global open source IAM solution.

| Short name | Long name                    | Technical component            |
|------------|------------------------------|--------------------------------|
| FIDS       | FusionIAM Directory Server   | OpenLDAP LTB                   |
| FIDM       | FusionIAM Directory Manager  | Fusion Directory               |
| FIAM       | FusionIAM Access Manager     | LemonLDAP::NG                  |
| FIWP       | FusionIAM White Pages        | LTB White Pages                |
| FISD       | FusionIAM Service Desk       | LTB Service Desk               |
| FISC       | FusionIAM Sync Connector     | LDAP Synchronization Connector |

## Build

### Prerequisites

To build container images, you need `podman` or `docker`.

### Create images

Go in `build/` and choose the subdirectory.

For example:
```
cd build/rockylinux9
```

Then build all images:
```
make all
```

### Upload images

List  images:
```
podman images
```

FusionIAM developers can upload images to OW2 repository:
```
export FUSIONIAM_VERSION=v0.1
podman tag localhost/fusioniam-rockylinux9:$FUSIONIAM_VERSION gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-rockylinux9:$FUSIONIAM_VERSION
podman tag localhost/fusioniam-openldap-ltb:$FUSIONIAM_VERSION gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-openldap-ltb:$FUSIONIAM_VERSION
podman tag localhost/fusioniam-lemonldap-ng:$FUSIONIAM_VERSION gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-lemonldap-ng:$FUSIONIAM_VERSION
podman tag localhost/fusioniam-fusiondirectory:$FUSIONIAM_VERSION gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-fusiondirectory:$FUSIONIAM_VERSION
podman tag localhost/fusioniam-service-desk:$FUSIONIAM_VERSION gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-service-desk:$FUSIONIAM_VERSION
podman tag localhost/fusioniam-white-pages:$FUSIONIAM_VERSION gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-white-pages:$FUSIONIAM_VERSION
podman push gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-rockylinux9:$FUSIONIAM_VERSION
podman push gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-openldap-ltb:$FUSIONIAM_VERSION
podman push gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-lemonldap-ng:$FUSIONIAM_VERSION
podman push gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-fusiondirectory:$FUSIONIAM_VERSION
podman push gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-service-desk:$FUSIONIAM_VERSION
podman push gitlab.ow2.org:4567/fusioniam/fusioniam/fusioniam-white-pages:$FUSIONIAM_VERSION
```

## Run

### Configuration

Configuration parameters are set as environment variables.

| Variable name                     | Description                                   |
|-----------------------------------|-----------------------------------------------|
| ACCCONFIGROOTPW                   | Password of OpenLDAP cn=config admin          |
| ACCDATAROOTPW                     | Password of OpenLDAP main database admin      |
| ADMIN_LDAP_PASSWORD               | Password of admin account                     |
| CUSTOMERID                        | ID of the organization / customer             |
| FUSIONDIRECTORY_HOST              | Internal host for FD                          |
| FUSIONDIRECTORY_LDAP_PASSWORD     | Password of FD service account                |
| FUSIONDIRECTORY_LDAP_USERNAME     | Identifier of FD service account              |
| FUSIONDIRECTORY_NAME              | Virtual host name for FD                      |
| FUSIONDIRECTORY_PORT              | Internal port for FD                          |
| FUSIONDIRECTORY_WS_PASSWORD       | Password of webservice account                |
| FUSIONDIRECTORY_WS_USERNAME       | Identifier of webservice account              |
| LDAP_HOST                         | Hostname of LDAP server                       |
| LDAP_PORT                         | Port of LDAP server                           |
| LEMONLDAP2_LDAP_PASSWORD          | Password of LL::NG service account            |
| LEMONLDAP2_LDAP_USERNAME          | Identifier of LL::NG service account          |
| LEMONLDAP2_OIDCPRIV               | Path to OIDC private key                      |
| LEMONLDAP2_OIDCPUB                | Path to OIDC public key                       |
| LEMONLDAP2_SAMLPRIV               | Path to SAML private key                      |
| LEMONLDAP2_SAMLPUB                | Path to SAML public key or certificate        |
| LEMONLDAP2_UNPROTECT_PHOTO_URL    | Allow unauthenticated access to user photo    |
| LEMONLDAP2_UNPROTECT_PROFILE_URL  | Allow unauthenticated access to user profile  |
| LSC_LDAP_PASSWORD                 | Password of LSC service account               |
| LSC_LDAP_USERNAME                 | Identifier of LSC service account             |
| POSTGRES_DB                       | Name of dedicated lemonldap database          |
| POSTGRES_HOST                     | Host of database server                       |
| POSTGRES_PASSWORD                 | Password of database account                  |
| POSTGRES_PORT                     | Port of database server                       |
| POSTGRES_USER                     | Login of database account                     |
| SERVICEDESK_HOST                  | Internal host for SD                          |
| SERVICEDESK_LDAP_PASSWORD         | Password of SD service account                |
| SERVICEDESK_LDAP_USERNAME         | Identifier of SD service account              |
| SERVICEDESK_NAME                  | Virtual host name for SD                      |
| SERVICEDESK_PORT                  | Internal port for SD                          |
| SSO_DOMAIN                        | Main SSO domain                               |
| WHITEPAGES_HOST                   | Internal host for WP                          |
| WHITEPAGES_LDAP_PASSWORD          | Password of WP service account                |
| WHITEPAGES_LDAP_USERNAME          | Identifier of WP service account              |
| WHITEPAGES_NAME                   | Virtual host name for WP                      |
| WHITEPAGES_PORT                   | Internal port for WP                          |
| LEMONLDAP2_LOCAL_PORT             | port local de LemonLDAP                       |
| LDAP_TLS                          | Deploy TLS parameters at first run            |
| LDAP_CERTIFICATE_FILE             | Path to certificate file for LDAP server      |
| LDAP_CERTIFICATE_KEY              | Path to certificate key file for LDAP server  |
| LDAP_TLS_PROTOCOL_MIN             | Minimal TLS protocol for LDAP server          |
| LDAP_TLS_CIPHER_SUITE             | Cipher suite for LDAP server                  |

An example in this file is available in `run/ENVVAR.example`.

### Launch containers

We use the following options:
* `-env-file=/path/to/ENVVAR`: pass environment variables to container
* `-v`: mount volumes if needed
* `--rm=true`: Remove old container
* `--network=NAME`: name of bridge network for containers to communicate
* `--net-alias`: alias of the container on the network
* `--add-host`: add optional FQDN in `/etc/hosts`
* `-p HOST_IP:HOST_PORT:PORT`: bind container ports
* `--name=NAME`: friendly name
* `--entrypoint=/bin/bash`: override entrypoint if needed
* `--detach=true`: detach container
* `/run-ct.sh nginx`: additional arguments for the entrypoint (specific to each container)

| Service           | External port | Internal port |
|-------------------|---------------|---------------|
| OpenLDAP LTB      | 33389         | 33389         |
| PostgreSQL        | 33432         | 5432          |
| LemonLDAP::NG     | 8080          | 8080          |
| Fusion Directory  | 8081          | 8080          |
| Service Desk      | 8082          | 8080          |
| White Pages       | 8083          | 8080          |

#### Pre-requisites

The first time, it is required to create directories for all components:

```
# FIDS data (OpenLDAP)
mkdir -p run/volumes/ldap-data run/volumes/ldap-config run/volumes/ldap-tls

# FIWP socket (white-pages)
mkdir -p run/volumes/wp-run

# FISD socket (service-desk)
mkdir -p run/volumes/sd-run

# FIAM database, socket, cache and keys (Postgresql, LemonLDAP::NG)
mkdir -p run/volumes/sso-data
mkdir -p run/volumes/llng-run
mkdir -p run/volumes/llng-cache
mkdir -p run/volumes/llng-keys

# FIDM socket (Fusion Directory)
mkdir -p run/volumes/fd-run
```

If you have a previous installation of FusionIAM, or if you are migrating from/to docker or podman, you must take care about volumes.

Note that these volumes won't be overwritten at startup:

* ldap-data: user accounts, groups,... Should not be emptied, except if you want to drop all data.
* ldap-config: configuration of OpenLDAP, including admin passwords. You should remove the content of the directory for the container to import a new configuration.
* sso-data: postgresql database, including SSO configurations and sessions. You can remove this if you want to drop all configurations. You may have to adapt the owner/group to the one used by postgres container.

You also need to initialize keys for SAML and OpenID Connect services:

```
openssl req -new -newkey rsa:4096 -keyout run/volumes/llng-keys/saml.key -nodes -out run/volumes/llng-keys/saml.pem -x509 -days 3650
openssl genrsa -out run/volumes/llng-keys/oidc.key 4096
openssl rsa -pubout -in run/volumes/llng-keys/oidc.key -out run/volumes/llng-keys/oidc_pub.key
```

If you wish to enable TLS parameters with `LDAP_TLS=true`, you will also need a certificate. You can generate a self-signed one with:
```
openssl req -new -newkey rsa:4096 -keyout run/volumes/ldap-tls/key.pem -nodes -out run/volumes/ldap-tls/cert.pem -x509 -days 3650
```

#### Run with docker-compose

You need docker and docker-compose.

Run all containers:

```
docker-compose up -d
```

Stop all containers:

```
docker-compose stop
```

Remove containers:
```
docker-compose rm fusioniam-access-manager-cron fusioniam-access-manager-fastcgi-server fusioniam-access-manager-nginx fusioniam-database fusioniam-directory-server fusioniam-fusiondirectory-nginx fusioniam-fusiondirectory-php-fpm fusioniam-service-desk-nginx fusioniam-service-desk-php-fpm fusioniam-white-pages-nginx fusioniam-white-pages-php-fpm
```

#### Run with docker or podman

Check you have podman or docker installed. podman will have precedence over docker.

There is a Makefile to help you run some or all containers.
You can check the Makefile at the root of the project to verify if it fits with your needs.

For podman, make sure you have a recent network backend. Typically, in `/etc/containers/containers.conf`:

```
network_backend = "netavark"
```

else internal name resolution will fail.

For instance, you must have:

```
podman network inspect fusioniam-net

...

"dns_enabled": true,
```


Run all containers:

```
make runall
```

Run specific containers:

```
make runldap
make runwp
make runsd
make runfd
make runlemon
```

Stop all containers:

```
make stopall
```

Stop specific containers:

```
make stopldap
make stopwp
make stopsd
make stopfd
make stoplemon
```

### Start reverse proxy

On your host, start a reverse proxy that will connect to containers.

For example with Apache:
```
vi /etc/apache2/sites-available/demo-fusioniam.conf
```

```
<VirtualHost *:443>
  ServerName auth.demo.fusioniam.org
  ServerAlias manager.demo.fusioniam.org
  ServerAlias api-manager.demo.fusioniam.org
  ServerAlias wp.demo.fusioniam.org
  ServerAlias sd.demo.fusioniam.org
  ServerAlias fd.demo.fusioniam.org

  SSLEngine On
  SSLCertificateFile /etc/apache2/demo.fusioniam.org.pem
  SSLCertificateKeyFile /etc/apache2/demo.fusioniam.org.key

  ProxyPreserveHost on
  ProxyPass / http://localhost:8080/
  ProxyPassReverse / http://localhost:8080/
</VirtualHost>
```

```
a2ensite demo-fusioniam.conf
```

Configure DNS or add this to your `/etc/hosts`:
```
127.0.0.1       auth.demo.fusioniam.org manager.demo.fusioniam.org api-manager.demo.fusioniam.org wp.demo.fusioniam.org sd.demo.fusioniam.org fd.demo.fusioniam.org
```

Connect to https://auth.demo.fusioniam.org and authentication with `fusioniam-admin` account.


### Utilization

If you intend to adapt the plugin list of Fusion Directory, you must insert the corresponding schema in LDAP.
You can either:
- add them manually in `config.ldif` template
- enter manually the `fusioniam-fusiondirectory-php-fpm` container, and insert the corresponding schemas:

Example of one schema insertion:
```
# Insert schema audit-fd in OpenLDAP
php -d include_path=/usr/local/share/fusiondirectory/tools /usr/local/share/fusiondirectory/tools/fusiondirectory-schema-manager --simplebind --ldapuri "ldap://${LDAP_HOST}:${LDAP_PORT}" --binddn "cn=config" --bindpwd "${ACCCONFIGROOTPW}" --insert-schema /etc/ldap/schema/fusiondirectory/audit-fd.schema
```

Schema installed:
```
/etc/ldap/schema/fusiondirectory/audit-fd-conf.schema
/etc/ldap/schema/fusiondirectory/audit-fd.schema
/etc/ldap/schema/fusiondirectory/core-fd-conf.schema
/etc/ldap/schema/fusiondirectory/core-fd.schema
/etc/ldap/schema/fusiondirectory/dsa-fd-conf.schema
/etc/ldap/schema/fusiondirectory/internet2.schema
/etc/ldap/schema/fusiondirectory/ldapns.schema
/etc/ldap/schema/fusiondirectory/mail-fd-conf.schema
/etc/ldap/schema/fusiondirectory/mail-fd.schema
/etc/ldap/schema/fusiondirectory/newsletter-fd-conf.schema
/etc/ldap/schema/fusiondirectory/newsletter-fd.schema
/etc/ldap/schema/fusiondirectory/openssh-lpk.schema
/etc/ldap/schema/fusiondirectory/personal-fd-conf.schema
/etc/ldap/schema/fusiondirectory/personal-fd.schema
/etc/ldap/schema/fusiondirectory/ppolicy-fd-conf.schema
/etc/ldap/schema/fusiondirectory/public-forms-fd-conf.schema
/etc/ldap/schema/fusiondirectory/public-forms-fd.schema
/etc/ldap/schema/fusiondirectory/service-fd.schema
/etc/ldap/schema/fusiondirectory/supann-2019-11-22.schema
/etc/ldap/schema/fusiondirectory/supann-fd-conf.schema
/etc/ldap/schema/fusiondirectory/systems-fd-conf.schema
/etc/ldap/schema/fusiondirectory/systems-fd.schema
/etc/ldap/schema/fusiondirectory/template-fd.schema
/etc/ldap/schema/fusiondirectory/webservice-fd-conf.schema
```
