docker volume create registry-data

docker run -d -p 5000:5000 -v registry-data:/var/lib/registry --name registry registry:2