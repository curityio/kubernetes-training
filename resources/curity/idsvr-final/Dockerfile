FROM curity.azurecr.io/curity/idsvr:latest

RUN rm -rf      /opt/idsvr/etc/init/*.xml
COPY config     /opt/idsvr/etc/init
COPY log4j2.xml /opt/idsvr/etc/
