#!/bin/bash

: "${SCHAIN_NAME?Set SCHAIN_NAME}"
: "${DATA_DIR?Set DATA_DIR}"
: "${PGUSER?Set PGUSER}"
: "${PGPASSWORD?Set PGPASSWORD}"

OLD_PG_DATA_PATH=${DATA_DIR}/${SCHAIN_NAME}_old/blockscout-db-data/
NEW_PG_DATA_PATH=${DATA_DIR}/${SCHAIN_NAME}_upgraded/blockscout-db-data/
[ -d ${DATA_DIR}/${SCHAIN_NAME}_upgraded/ ] && rm -r ${DATA_DIR}/${SCHAIN_NAME}_upgraded/

docker update --restart=no ${SCHAIN_NAME}_db
docker exec ${SCHAIN_NAME}_db pg_ctl stop -D /var/lib/postgresql/data -m fast
[ -d ${DATA_DIR}/${SCHAIN_NAME}/blockscout-db-data/ ] && mv ${DATA_DIR}/${SCHAIN_NAME}/ ${DATA_DIR}/${SCHAIN_NAME}_old/
docker build -t pg-upgrade -f docker/Dockerfile.pg-upgrade docker/

docker run --rm \
  -v ${OLD_PG_DATA_PATH}:/var/lib/postgresql/15/data \
  -v ${NEW_PG_DATA_PATH}:/var/lib/postgresql/17/data \
  -e PGUSER=${PGUSER} \
  -e PGPASSWORD=${PGPASSWORD} \
  pg-upgrade
