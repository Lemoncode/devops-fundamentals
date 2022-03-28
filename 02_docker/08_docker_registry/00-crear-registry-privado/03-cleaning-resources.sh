echo stopping removing, containers and related volumes

docker stop custom-nginx && docker rm custom-nginx
docker stop registry && docker rm -v registry