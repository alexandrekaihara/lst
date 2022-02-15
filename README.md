# Coburg Intrusion Detection Data Sets  - CIDDS Experiment
## Description
Our goal is to provide an easy-use tool to emulate benign and malicious network flows. This project is a modification of a work developed by Markus Ring et. al. (available at: https://www.hs-coburg.de/cidds), which provided us with all the scripts to emulate a small business environment. This environment includes several clients and typical servers like Mail and Web server. 

Provisioning many virtual machines may consume a lot of memory space and CPU resources. Also, configuration scripts may have versioning problems. Thus, we created Docker images for each server and client to mitigate these issues. Also, we will provide Docker compose and Bash scripts to configure the entire network environment with all servers and clients configured.

The facility provided by this tool is due to the possibility of configuring the experiment from a single JSON file. You can define the number of machines, the Docker image, the behavior of clients, the IP, and the subnet. For future works, we expect to implement the configuration of the network topology through this centralized configuration file. 

Another facility is that the docker images encapsulate the dependencies and the configuration process. Thus, it reduces the number of dependencies needed to set up the experiment. And the creation of machines is simplified and faster because the configuration must be done only during the creation of the Docker image.

## System Requirements
Your machine must be using a Linux distribution. In our experiments, were used a Ubuntu Server version 20.04.3 LTS virtual machine installed on Virtualbox version 6.1.26 r145957 (Qt5.6.2). Is highly recommended to have at least 12 GB of free memory to be used by the docker. 

## Dependencies
All the dependencies consists of:
- Docker (version 20.10.7)
- Docker Compose (version 1.25.0)
- Pip3 (22.0.3)
- OpenvSwitch (2.13.3)

We provide a Bash script to install all the needed dependencies. To install all dependencies, execute:

> sudo git clone https://github.com/mdewinged/cidds

> cd cidds/experiment

> sudo chmod +x dependencies.sh && sudo ./dependencies.sh

## Execution
To execute the script to set up the network topology, execute these commands:

> sudo chmod +x setup.sh

> sudo ./setup.sh partial_experiment.json

If you want to finish the experiment e get back to your original network configuration, press CTRL + C once.

## Docker image build
If it is necessary to make any change on the docker images, check the "docker" folder located on the root directory of this repository. To build any docker image, access the folder containing its "Dockerfile" file and execute:

> docker build --network=host --tag mdewinged/cidds:NEW_CONTAINER_NAME .

To use the newly built image in the experiment, access the "cidds/experiment" folder and change the file named as "variables" and find the respective image and change its value for the "NEW_CONTAINER_NAME" you have attributed. For example, you have built another version of the webserver and named as webserver2. Thus, you need to change the value of WEB=webserver2 in the "variable" file. 

The only image that does not follow the command above is the seafileserver. Due to a particular characteristic of its configuration, the seafileserver must create a network interface to build the image, and its IP address in the experiment is static (default is 192.168.50.1). If you need to change the IP on which the server listens, a rebuild is necessary with the new IP. More detailed instructions are located inside the "cidds/docker/seafileserver" folder.

