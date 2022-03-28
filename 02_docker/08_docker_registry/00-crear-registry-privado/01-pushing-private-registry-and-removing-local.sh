docker build -t custom-nginx - <<EOF
FROM nginx:latest
RUN sed -i 's/Welcome to nginx/Welcome to custom nginx/' /usr/share/nginx/html/index.html
EOF

docker tag custom-nginx localhost:5000/custom-nginx

docker push localhost:5000/custom-nginx

docker rmi nginx custom-nginx localhost:5000/custom-nginx