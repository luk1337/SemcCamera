#!/bin/bash

BASENAME=`basename "${DST}"`
OUT=`realpath "${DST}/../${BASENAME}-$(date +%Y%m%d).zip"`
TEMP=`mktemp -d`

rm "${OUT}" 2>/dev/null

pushd "${DST}/../addon-common"

zip -r "${OUT}" .

popd

pushd "${TEMP}"

mkdir system
cp -Rv "${DST}/proprietary/"* system

mkdir -p system/etc/default-permissions
cp -v "${DST}/semccamera-default-permissions.xml" system/etc/default-permissions

mkdir -p system/etc/permissions
cp -v "${DST}/privapp-permissions-semccamera.xml" system/etc/permissions

mkdir -p system/addon.d
echo "#!/sbin/sh
#
# ADDOND_VERSION=2
#
# /system/addon.d/60-semccamera.sh
# During a LineageOS upgrade, this script backs up SemcCamera,
# /system is formatted and reinstalled, then the files are restored.
#

. /tmp/backuptool.functions

list_files() {
cat <<EOF
`cat "${DST}/proprietary-files.txt" | sed "s/^-//g;s/\;PRESIGNED//g"`
etc/default-permissions/semccamera-default-permissions.xml
etc/permissions/privapp-permissions-semccamera.xml
EOF
}

case \"\$1\" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file \$S/\"\$FILE\"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=\"\"
      [ -n \"\$REPLACEMENT\" ] && R=\"\$S/\$REPLACEMENT\"
      [ -f \"\$C/\$S/\$FILE\" ] && restore_file \$S/\"\$FILE\" \"\$R\"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Stub
  ;;
esac" > system/addon.d/60-semccamera.sh

zip -r "${OUT}" .

popd

rm -rf "${TEMP}"

echo "Done: ${OUT}"
