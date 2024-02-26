#!/bin/sh
# input: $1, $2,... = names of schema to deploy/redeploy (for eg. core-fd)
# required envvars:
# - $LDAP_HOST
# - $LDAP_PORT
# - $ACCCONFIGROOTPW

################################################################################
# Variables
################################################################################

FD_HOME_PATH="/usr/local/share/fusiondirectory"
FD_SCHEMA_PATH="/etc/ldap/schema/fusiondirectory"
LDAP_HOST="${LDAP_HOST}"
LDAP_PORT="${LDAP_PORT}"
ACCCONFIGROOTPW="${ACCCONFIGROOTPW}"


################################################################################
# Functions
################################################################################


get_installed_schemas()
{
    SCHEMAS=$( php -d include_path=${FD_HOME_PATH}/tools ${FD_HOME_PATH}/tools/fusiondirectory-schema-manager --simplebind --ldapuri "ldap://${LDAP_HOST}:${LDAP_PORT}" --binddn "cn=config" --bindpwd "${ACCCONFIGROOTPW}" --list-schemas | grep -v -E '^Schemas:' | sed -e 's/[ \t]*\([^:]\+\):.*/\1/' )
    FOUND="0"
    for S in ${SCHEMAS} ; do
        if [ "${S}" = "core-fd" ]; then
            FOUND="1"
        fi
    done
    if [ "${FOUND}" = "0" ]; then
        SCHEMAS=""
    fi
    printf "%s\n" "${SCHEMAS}"
}


find_schema()
{
    ISCHEMA="$1"
    ISCHEMAS="$2"

    for S in ${ISCHEMAS} ; do
        if [ "${S}" = "${ISCHEMA}" ]; then
            return 1
        fi
    done
    return 0
}



################################################################################
# Entry point
################################################################################

for SCHEMA in "$@"
do

    printf "%s\n" "Deploying schema: ${SCHEMA}"

    SCHEMAS=$( get_installed_schemas )
    if [ "${SCHEMAS}" = "" ]; then
        printf "%s\n" "Problem while getting installed schema, aborting"
        exit 1
    fi

    find_schema "${SCHEMA}" "${SCHEMAS}"
    if [ "$?" -eq "1" ]; then
      printf "%s\n" "Schema ${SCHEMA} found, doing a replacement"
      php -d include_path=${FD_HOME_PATH}/tools ${FD_HOME_PATH}/tools/fusiondirectory-schema-manager --simplebind --ldapuri "ldap://${LDAP_HOST}:${LDAP_PORT}" --binddn "cn=config" --bindpwd "${ACCCONFIGROOTPW}" --replace-schema ${FD_SCHEMA_PATH}/${SCHEMA}.schema
    else
      printf "%s\n" "Schema ${SCHEMA} not found, doing an insertion"
      php -d include_path=${FD_HOME_PATH}/tools ${FD_HOME_PATH}/tools/fusiondirectory-schema-manager --simplebind --ldapuri "ldap://${LDAP_HOST}:${LDAP_PORT}" --binddn "cn=config" --bindpwd "${ACCCONFIGROOTPW}" --insert-schema ${FD_SCHEMA_PATH}/${SCHEMA}.schema
    fi

done
