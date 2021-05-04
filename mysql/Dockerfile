#
# A basic MySql docker image that also runs a SQL script
# - eval $(minikube docker-env --profile curity)
# - docker run -it custom_mysql:8.0.22 bash
#

FROM mysql:8.0.22
COPY mysql/idsvr-data-backup.sql /docker-entrypoint-initdb.d/
