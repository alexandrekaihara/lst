# Imports
FROM ubuntu:20.04

# Install dependencies
COPY dependencies.sh .
RUN chmod +x dependencies.sh \
&& ./dependencies.sh \
&& sudo su

# Start setup
COPY setup.sh .
RUN chmod +x setup.sh\
&& ./setup.sh

# Start samba
COPY onboot.sh /home
RUN chmod +x /home/onboot.sh
CMD ["./home/onboot.sh"]

# For conecting via Open SSL
EXPOSE 22
EXPOSE 139
EXPOSE 445


