docker rm -fv registry-data

docker run \
    -d \
    -p 5000:5000 \
    --name registry \
    -v registry-data:/var/lib/registry \
    -v registry-auth:/auth:ro \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
    registry:2
