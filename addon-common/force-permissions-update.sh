#!/sbin/sh

OLD_PROP=`grep "^ro.build.date=" /system_root/system/build.prop`
VALUE="${OLD_PROP:14}"
T=`echo ${VALUE} | grep -Eo "[0-9]{2}:[0-9]{2}:[0-9]{2}"`
S="${T:6}"

# Increment build date time
if [[ "${S}" -eq "59" ]]; then
    S="00"
else
    S=`printf "%02d" $((10#${S} + 1))`
fi

NEW_PROP=`echo "${OLD_PROP}" | sed "s/${T}/${T::5}:${S}/g"`
sed -i "s/${OLD_PROP}/${NEW_PROP}/" /system_root/system/build.prop

exit 0
