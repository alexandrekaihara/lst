#!/bin/bash

# brief:
function SafeAptInstall (){
    packages=$1
    versions=$2
    until dpkg -s $packages | grep -q Status;
    do
        apt-get install -y $packages$versions
    done
}