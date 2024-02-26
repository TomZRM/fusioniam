#/bin/bash 

FILENAME="$1"

! test -f ${FILENAME} && exit 1
ansible-playbook --connection=local ${FILENAME}
