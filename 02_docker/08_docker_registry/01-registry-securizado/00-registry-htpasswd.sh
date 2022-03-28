docker volume create registry-auth

docker run --rm \
    -v registry-auth:/auth \
    registry:2.7.0 \
    sh -c "htpasswd -Bbn devops secretpassword >> /auth/htpasswd"

docker run --rm -v registry-auth:/auth registry:2.7.0 cat /auth/htpasswd