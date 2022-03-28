docker pull localhost:5000/custom-nginx

docker run -d -p 80:80 --name custom-nginx localhost:5000/custom-nginx

sleep 30

curl localhost:80