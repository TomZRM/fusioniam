#!/bin/sh

set -e

export CONTAINER_TYPE="${1}"

# For Openshift to be able to write its PV
# Openshift runs the container with a permanent userid (but unpredictable)
sed -e "s#^fusioniam.*#fusioniam:x:$(id -u):$(id -g)::/home/fusioniam:/bin/bash#" /etc/passwd > /tmp/passwd.tmp ; cat /tmp/passwd.tmp 2>/dev/null > /etc/passwd || true ; rm /tmp/passwd.tmp
sed -e "s#^fusioniam.*#fusioniam:x:$(id -G | cut -d' ' -f 2):#" /etc/group > /tmp/group.tmp; cat /tmp/group.tmp 2>/dev/null > /etc/group || true ; rm /tmp/group.tmp

/bin/bash /run-playbook.sh /deploy.yaml

case "${1}" in
  "nginx")
    ln -sf /dev/stdout /var/log/nginx/access.log
    ln -sf /dev/stdout /var/log/nginx/error.log
    ln -sf /dev/stdout /var/log/nginx/fd.access.log
    ln -sf /dev/stdout /var/log/nginx/fd.error.log
    /usr/sbin/nginx -g 'daemon off;'
    ;;
  "php-fpm")
    cp -rf /etc/fusiondirectory-orig/* /var/cache/fusiondirectory/
    ln -sf /proc/1/fd/1 /var/log/php-fpm/error.log
    ln -sf /proc/1/fd/1 /var/log/php-fpm/www-error.log
    /usr/sbin/php-fpm --nodaemonize
    ;;
  *)
    echo "Unknown argument : ${1}"
    ;;
esac

exit 0
