#
# A basic PostgreSQL docker image that also restores some SQL data
# - eval $(minikube docker-env --profile curity)
# - docker run -it custom_postgres:13.2 bash
#

FROM postgres:13.2
COPY postgres/idsvr-data-backup.sql /docker-entrypoint-initdb.d/
