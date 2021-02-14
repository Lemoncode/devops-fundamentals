echo 'creating volume'
docker volume create registry-certs

echo 'creating CA'
docker run --rm -it -v registry-certs:/out squareup/certstrap init --common-name registry.ca 

echo 'request certificate'
docker run --rm -it -v registry-certs:/out squareup/certstrap request-cert --common-name registry.intranet

echo 'sign certificate'
docker run --rm -it -v  registry-certs:/out squareup/certstrap sign registry.intranet --CA registry.ca 

# expected output

# creating volume
# registry-certs
# creating CA
# Enter passphrase (empty for no passphrase): 
# Enter same passphrase again: 
# Created out/registry.ca.key
# Created out/registry.ca.crt
# Created out/registry.ca.crl
# request certificate
# Enter passphrase (empty for no passphrase): 
# Enter same passphrase again: 
# Created out/registry.intranet.key
# Created out/registry.intranet.csr
# sign certificate
# Created out/registry.intranet.crt from out/registry.intranet.csr signed by out/registry.ca.key

