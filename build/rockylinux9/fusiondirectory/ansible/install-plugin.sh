#!/bin/sh
# input: $1 = name of the plugin to install

################################################################################
# Variables
################################################################################

FD_HOME_PATH="/usr/local/share/fusiondirectory"
FD_ETC_PATH="/etc/fusiondirectory"
FD_VAR_PATH="/var/cache/fusiondirectory"
PLUGINS_PATH="/usr/src/fd-plugins"
PLUGIN="${1}"
CLASSCACHE_FILENAME="class.cache"


################################################################################
# Functions
################################################################################

copy_dir()
{
    SRC="${1}"
    DST="${2}"
    if [ -d "${SRC}" ]; then
        mkdir -p "${DST}"
        cp -r ${SRC}/* ${DST}/
        chown root:root -R ${DST}
        find ${DST} -type d -exec chmod 755 {} \;
        find ${DST} -type f -exec chmod 644 {} \;
    fi
}

write_classcache()
{

    # Get all classes (all .inc that does not contain smarty)
    CLASSES_FILES=$( find ${FD_HOME_PATH} -name '*.inc' | grep -v smarty )

    RES=""
    for FILE in ${CLASSES_FILES} ; do
        # get lines matching "interface *" or "class *"
        MATCH=$( grep -E '^(interface\s*(\w+)|(abstract )?class\s*(\w+)).*' "$FILE" \
                 | sed -e 's/^interface\s*\(\w\+\).*$/\1/' \
                       -e 's/^.*class\s*\(\w\+\).*$/\1/' )
        # get truncated filename
        TFILE=$( printf "%s" "$FILE" | sed -e "s#${FD_HOME_PATH}##" )
        for M in ${MATCH}; do
            # format result : "key" => "value"
            RES="\t\t\"${M}\" => \"${TFILE}\",
$RES"
        done
    done

    # remove empty lines
    RES=$( printf "${RES}" | sed -e '/^$/d' )

    # sort
    RES=$( printf "${RES}" | sort )

    printf "<?php\n" > ${FD_VAR_PATH}/${CLASSCACHE_FILENAME}
    printf "\t\$class_mapping= array(\n" >> ${FD_VAR_PATH}/${CLASSCACHE_FILENAME}
    printf "${RES}\n"  >> ${FD_VAR_PATH}/${CLASSCACHE_FILENAME}
    printf "\t);\n" >> ${FD_VAR_PATH}/${CLASSCACHE_FILENAME}
    printf "?>\n" >> ${FD_VAR_PATH}/${CLASSCACHE_FILENAME}

}

write_i18n()
{

    ALL_PO_FILES=$( find ${FD_HOME_PATH} -name 'fusiondirectory.po' -type f )
    LANG_LIST=$( printf "${ALL_PO_FILES}" | sed -e 's/^.*\/\([^\/]\+\)\/fusiondirectory\.po$/\1/' | sort -u )

    for L in ${LANG_LIST} ; do
        PO_FILES=$( printf "${ALL_PO_FILES}" | grep -F "${L}/fusiondirectory.po" | tr '\r\n' ' ')
        mkdir -p "${FD_VAR_PATH}/locale/${L}/LC_MESSAGES"
        msgcat --use-first ${PO_FILES} > ${FD_VAR_PATH}/locale/${L}/LC_MESSAGES/fusiondirectory.po
        msgfmt -o ${FD_VAR_PATH}/locale/${L}/LC_MESSAGES/fusiondirectory.mo ${FD_VAR_PATH}/locale/${L}/LC_MESSAGES/fusiondirectory.po
        rm -f ${FD_VAR_PATH}/locale/${L}/LC_MESSAGES/fusiondirectory.po
    done

}



################################################################################
# Entry point
################################################################################

printf "%s\n" "Installing plugin: ${PLUGIN}"

copy_dir "${PLUGINS_PATH}/${PLUGIN}/addons" "${FD_HOME_PATH}/plugins/addons"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/admin" "${FD_HOME_PATH}/plugins/admin"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/config" "${FD_HOME_PATH}/plugins/config"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/personal" "${FD_HOME_PATH}/plugins/personal"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/reports" "${FD_HOME_PATH}/plugins/reports"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/generic" "${FD_HOME_PATH}/plugins/generic"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/html" "${FD_HOME_PATH}/html"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/ihtml" "${FD_HOME_PATH}/ihtml"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/include" "${FD_HOME_PATH}/include"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/contrib/openldap" "${FD_HOME_PATH}/contrib/openldap"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/contrib/etc" "${FD_ETC_PATH}/${PLUGIN}"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/contrib/doc" "${FD_HOME_PATH}/contrib/doc"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/contrib/yaml" "${FD_ETC_PATH}/yaml/${PLUGIN}"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/locale" "${FD_HOME_PATH}/locale/plugins/${PLUGIN}/locale"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/configuration" "${FD_HOME_PATH}/plugins/configuration"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/dashboard" "${FD_HOME_PATH}/plugins/dashboard"
copy_dir "${PLUGINS_PATH}/${PLUGIN}/export" "${FD_HOME_PATH}/plugins/export"

cp ${PLUGINS_PATH}/${PLUGIN}/contrib/openldap/*.schema /etc/ldap/schema/fusiondirectory/ 2>/dev/null || :

#write_classcache
#write_i18n

