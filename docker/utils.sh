#!/bin/bash

SafeAptInstall (){
    count=${#1[@]}
    for i in `seq 1 $count`
    do
        until dpkg -s ${1[$i-1]} | grep -q Status;
        do
        apt-get install -y --no-install-recommends --force-yes ${1[$i-1]}${2[$i-1]}
        done
    done
}