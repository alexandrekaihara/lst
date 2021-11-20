# Coburg Intrusion Detection Data Sets  - CIDDS-001
## 1. Description
This repository is a clone of a work developed by Markus Ring et. al., which contains all the scripts used to  emulate a small business environment using OpenStack. This environment includes several clients and typical servers like an E-Mail server or a Web server. Python scripts are used emulate normal user behaviour on the clients.

The CIDDS-001 data set is available at: https://www.hs-coburg.de/cidds

## 2. Motivation
Our goal is to use these scripts to emulate benign and malicious network flows in order develop and assess a Real-Time Network Intrusion Detection System (NIDS). 

Many corrections on the scripts were made to make corrections due to the bugs that were introduced by the usage of new versions of many dependencies, because there is some libraries and system versions that were used and today are not available anymore. Also, the all the Python scripts were built on Python 2 version, and now the Python 3 version had some improvements and changes, which means that these scripts needed some fixes too.

To avoid any further problems with version control, dependencies and also the usage of virtual machines - which consumes lot of memory space and CPU resources - we are developing a Docker image for each server and client. And also we will provide a Docker compose to build a entire network environment to emulate the topology with all servers and clients configured.

## 3. Usage
The docker images and docker compose scripts are still progress. Soon, will be available all steps to use and create the emulated network.

 
