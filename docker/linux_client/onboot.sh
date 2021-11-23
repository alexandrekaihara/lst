#!/bin/bash
# Generate dummy files for seafile
mkdir -pv /home/debian/tmpseafiles
i=0
while [ $i -le 100 ]
do
  i=`expr $i + 1`;
  zufall=$RANDOM;
  zufall=$(($zufall % 9999))
  dd if=/dev/zero of=/home/debian/tmpseafiles/test-`expr $zufall`.dat bs=1K count=`expr $zufall`
done

# Start cups
cupsd

/bin/bash