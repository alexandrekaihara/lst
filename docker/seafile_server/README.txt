To build the seafile server image it is necessary to create a adapter on host with the IP which will be configured on the seafile server.

This IP is fixed in order to simplify the execution and setting up the experiment. 

If you wish to change the seafile IP, you must change it on the the first line of setup.sh file and change the ip address of the network adapter of build.sh file.

The following commands must be used to build this image.

sudo chmod +x build.sh
./build.sh
