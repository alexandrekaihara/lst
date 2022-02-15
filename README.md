# Coburg Intrusion Detection Data Sets  - CIDDS-001
# 1. Description
This repository is an adaptation of a work developed by Markus Ring et. al., which contains all the scripts used to emulate a small business environment using OpenStack. This environment includes several clients and typical servers like an E-Mail server or a Web server. Python scripts are used to emulate normal user behavior on the clients.

The CIDDS-001 Dataset is available at: https://www.hs-coburg.de/cidds

# 2. Motivation
Our goal is to provide an easy tool to emulate benign and malicious network flows to develop a Real-Time Network Intrusion Detection System (NIDS). 

To mitigate problems with version control and the usage of virtual machines, which consume a lot of memory space and CPU resources, we are developing Docker images for each server and client. And also we will provide Docker compose and Bash scripts to set up an entire network environment with all servers and clients configured.

# 3. Usage
This section describes how to install all dependencies and execute all the scripts and configurations to set up the topology and virtual machines.

## 3.1 System Requirements
Your machine must be using a Linux distribution. In our experiments, were used a Ubuntu Server version 20.04.3 LTS virtual machine installed on Virtualbox version 6.1.26 r145957 (Qt5.6.2). Is highly recommended to have at least 12 GB of free memory to be used by the docker. 

## 3.2 Dependencies
All the dependencies consists of:
- Docker (version 20.10.7)
- Docker Compose (version 1.25.0)
- Pip3 (22.0.3)
- OpenvSwitch (2.13.3)

We provide a Bash script to install all the needed dependencies. To install all dependencies, execute:

> sudo git clone https://github.com/mdewinged/cidds

> cd cidds/experiment

> sudo chmod +x dependencies.sh && sudo ./dependencies.sh

## 3.3 Execution
To execute the script to set up the network topology, execute these commands:

> sudo chmod +x setup.sh

> sudo ./setup.sh partial_experiment.json

If you want to finish the experiment e get back to your original network configuration, press CTRL + C once.
 
