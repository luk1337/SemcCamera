#!/bin/bash

for f in `cat proprietary-files.txt | sed "s/^-//g"`; do
    mkdir -p `dirname "proprietary/${f}"`
    # adb pull "/system/${f}" "proprietary/${f}"
    cp -v "/home/luk/lineage-17.1/out/target/product/pioneer/system/${f}" "${DST}/proprietary/${f}"
done
