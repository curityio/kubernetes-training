#
# A development custom docker image for getting started
#

# Get the base image
FROM curity.azurecr.io/curity/idsvr:latest

# Copy in base resources
COPY idsvr/license.json /opt/idsvr/etc/init/license/
COPY idsvr/log4j2.xml /opt/idsvr/etc/

# Copy the HAAPI web sample to the root web folder of runtime nodes
COPY haapi-web-example/* /opt/idsvr/usr/share/webroot/

# Extra tools, for development troubleshooting only
USER root
RUN apt-get update
RUN apt-get install curl -y
USER idsvr
