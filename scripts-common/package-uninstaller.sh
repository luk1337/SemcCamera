#!/bin/bash

BASENAME=`basename "${DST}"`
OUT=`realpath "${DST}/../${BASENAME}-$(date +%Y%m%d)-uninstaller.zip"`
TEMP=`mktemp -d`

rm "${OUT}" 2>/dev/null

pushd "${DST}/../addon-common"

zip -r "${OUT}" .

popd

pushd "${TEMP}"

mkdir -p META-INF/com/google/android

FILES_TO_DELETE=$(cat <<EOF
`cat "${DST}/proprietary-files.txt" | sed "s/^-//g;s/\;PRESIGNED//g"`
addon.d/60-semccamera.sh
etc/default-permissions/semccamera-default-permissions.xml
etc/permissions/privapp-permissions-semccamera.xml
EOF
)

cat <<EOF>> META-INF/com/google/android/updater-script
ifelse(is_mounted("/system"), unmount("/system"));
ifelse(is_mounted("/system_root"), unmount("/system_root"));
package_extract_file("force-permissions-update.sh", "/tmp/force-permissions-update.sh");
package_extract_file("mount-system.sh", "/tmp/mount-system.sh");
package_extract_file("unmount-system.sh", "/tmp/unmount-system.sh");
set_metadata("/tmp/force-permissions-update.sh", "uid", 0, "gid", 0, "mode", 0755);
set_metadata("/tmp/mount-system.sh", "uid", 0, "gid", 0, "mode", 0755);
set_metadata("/tmp/unmount-system.sh", "uid", 0, "gid", 0, "mode", 0755);
run_program("/tmp/mount-system.sh") == 0 || abort("Could not mount /system");

if getprop("ro.build.system_root_image") != "true" then
`echo "${FILES_TO_DELETE}" | sed "s/^/  delete\(\\"\/system\//g;s/$/\\"\)\;/g"`
else
`echo "${FILES_TO_DELETE}" | sed "s/^/  delete\(\\"\/system_root\/system\//g;s/$/\\"\)\;/g"`
endif;

run_program("/tmp/unmount-system.sh") == 0 || ui_print("Could not unmount /system");
ui_print("Done");
EOF

zip -r "${OUT}" .

popd


rm -rf "${TEMP}"

echo "Done: ${OUT}"
