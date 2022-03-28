#!/bin/bash
set +x 

# 1. Create empty postgres database
# 2. Connect with migrations container and run it
# 3. Dump results 
# 4. Clean resources
CONTAINER=postgres-server
NETWORK=generate-db
DATABASE_NAME=hangman_db

echo removing previous artifacts
rm -f ./hangman_database_init.sql


echo generating database from migrations

# create network
docker network create ${NETWORK}

# Run a generic postgres container from jaimesalas/hangman-db-migration image
docker run \
    -d \
    --name ${CONTAINER} \
    --network ${NETWORK} \
    -e "POSTGRES_USER=postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    jaimesalas/hangman-db-migration

# Ping postgres before initialize database
HEALTHCHECK=$(docker exec $CONTAINER pg_isready > /dev/null 2>&1; echo $?)
while [ $HEALTHCHECK -ne 0 ]; do
   echo "Waiting for postgres to start..."
   HEALTHCHECK=$(docker exec $CONTAINER pg_isready > /dev/null 2>&1; echo $?)
   sleep 1
done

docker run -d \
  --name migration_container \
  --network ${NETWORK} \
  -e "DATABASE_PORT=5432" \
  -e "DATABASE_HOST=${CONTAINER}" \
  -e "DATABASE_NAME=${DATABASE_NAME}" \
  -e "DATABASE_USER=postgres" \
  -e "DATABASE_PASSWORD=postgres" \
  -e "DATABASE_POOL_MIN=2" \
  -e "DATABASE_POOL_MAX=10" \
  jaimesalas/db-migrations

# wait until migrations finish
docker wait migration_container

docker rm migration_container

# dumping database 
docker exec -i $CONTAINER pg_dump --create -U postgres $DATABASE_NAME > ./hangman_database_init.sql 

echo database init script generated

echo cleaning resources

docker rm -fv ${CONTAINER}

docker stop ${CONTAINER} && docker rm ${CONTAINER}

docker network rm ${NETWORK}
