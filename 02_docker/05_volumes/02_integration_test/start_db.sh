POSTGRES_IMAGE=$1
POSTGRES_PORT=$2

if [[ $(which docker) ]] ; then
    docker run -d -p $POSTGRES_PORT:5432 $POSTGRES_IMAGE
fi

# ./start_db.sh jaimesalas/todos_db 5432