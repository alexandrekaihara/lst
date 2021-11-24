#!/bin/bash

SafeAptInstall (){
    packages=$1
    versions=$2
    count=${#packages[@]}
    for i in `seq 1 $count`
    do
        until dpkg -s ${packages[$i-1]} | grep -q Status;
        do
            RUNLEVEL=1 apt-get install -y --no-install-recommends --force-yes ${packages[$i-1]}${versions[$i-1]}
        done
    done
}