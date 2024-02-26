#!/bin/bash

# For Openshift to be able to write its PV
# Openshift runs the container with a permanent userid (but unpredictable)
sed -e "s#^fusioniam.*#fusioniam:x:$(id -u):$(id -g)::/home/fusioniam:/bin/bash#" /etc/passwd > /tmp/passwd.tmp ; cat /tmp/passwd.tmp 2>/dev/null > /etc/passwd || true ; rm /tmp/passwd.tmp
sed -e "s#^fusioniam.*#fusioniam:x:$(id -G | cut -d' ' -f 2):#" /etc/group > /tmp/group.tmp; cat /tmp/group.tmp 2>/dev/null > /etc/group || true ; rm /tmp/group.tmp

export FUSIONIAM_UID=$(id -u)
export FUSIONIAM_GID=$(id -G | cut -d' ' -f 2)

/bin/bash /run-playbook.sh /deploy.yaml

LDAPS_INTERFACE="$( [ ! -z ${LDAP_TLS} ] && echo ldaps://*:33636 )"

/usr/local/openldap/libexec/slapd -h "ldap://*:33389 ${LDAPS_INTERFACE} ldapi://%2Fvar%2Frun%2Fslapd%2Fldapi" -F /usr/local/openldap/etc/openldap/slapd.d -d 256
