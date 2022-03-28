docker run -p 80:80 \
    -v `pwd`/www:/www \
    -v `pwd`/conf:/etc/nginx/conf.d \
    nginx