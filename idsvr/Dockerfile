#
# A development custom docker image for getting started
#
# After building, files in the image can be viewed via the below commands:
# - eval $(minikube docker-env --profile curity)
# - docker run -it custom_idsvr:6.1.0 bash
#

# Get the base image
FROM curity.azurecr.io/curity/idsvr:6.1.0

# The MYSQL driver, extracted from the platform independent tar file: https://dev.mysql.com/downloads/connector/j
COPY idsvr/mysql-connector-java-8.0.22.jar /opt/idsvr/lib/plugins/data.access.jdbc

# Copy in a log file with a root logger of INFO level - or increase to DEBUG when required
COPY idsvr/log4j2.xml /opt/idsvr/etc/

# Copy the HAAPI web sample to the root web folder of runtime nodes
COPY haapi-web-example/* /opt/idsvr/usr/share/webroot/

# Extra tools - for development troubleshooting only
USER root
RUN apt-get update
RUN apt-get install curl -y
USER idsvr
