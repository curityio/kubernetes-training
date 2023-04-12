#
# A development custom docker image for getting started
#

# Get the base image
FROM curity.azurecr.io/curity/idsvr:latest

# Install developer tools
USER root
RUN apt-get update
RUN apt-get install curl -y

# Copy in custom resources
USER idsvr
COPY idsvr/license.json /opt/idsvr/etc/init/license/
COPY idsvr/log4j2.xml /opt/idsvr/etc/
COPY haapi-web-example/* /opt/idsvr/usr/share/webroot/
