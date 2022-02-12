# Imports
FROM ubuntu:20.04

# Install dependencies
COPY dependencies.sh .
RUN chmod +x dependencies.sh \
&& ./dependencies.sh \
&& sudo su

# Copy the Python script to login into the seafile server and create a user folder
COPY login_seafile_page.py /home

# Start setup
COPY setup.sh .
RUN chmod +x setup.sh\
&& ./setup.sh

# Script to start needed programs
COPY onboot.sh /home
RUN chmod +x /home/onboot.sh
CMD ["./home/onboot.sh"]

# For conecting via Open SSL
EXPOSE 80
EXPOSE 8082
EXPOSE 8000
EXPOSE 22


