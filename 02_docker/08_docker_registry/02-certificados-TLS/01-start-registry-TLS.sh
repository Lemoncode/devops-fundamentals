echo 'cleaning dangling volumes'
docker rm -fv registry

echo 'starting registry'
# docker run -d -p 5000:443 \
#     --name registry \
#     -v registry-data:/var/lib/registry \
#     -v registry-certs:/certs/ro \
#     -v registry-auth:/auth/ro \
#     -e "REGISTRY_AUTH=htpasswd" \
#     -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
#     -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
#     -e "REGISTRY_HTTP_ADDR=0.0.0.0:443" \
#     -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.ca.crt" \
#     -e "REGISTRY_HTTP_TLS_KEY=/certs/registry.ca.key" \
#     registry:2
docker run \
  -d \
  -p 5000:443 \
  --name registry \
  -v registry-data:/var/lib/registry \
  -v registry-certs:/certs:ro \
  -v registry-auth:/auth:ro \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  -e "REGISTRY_HTTP_ADDR=0.0.0.0:443" \
  -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.ca.crt" \
  -e "REGISTRY_HTTP_TLS_KEY=/certs/registry.ca.key" \
  registry:2