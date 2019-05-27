docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

#docker build -t res/apache_php ./docker-images/apache-php-image/
#docker build -t res/express_animals ./docker-images/express-image/
#docker build -t res/apache_rp ./docker-images/apache-reverse-proxy/

docker run -d --name apache_static res/apache_php
docker run -d --name express_dynamic res/express_animals

static_app=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static`
dynamic_app=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic`

docker run -d -p 8080:80 -e STATIC_APP=$static_app:80 -e DYNAMIC_APP=$dynamic_app:3000 --name apache_rp res/apache_rp
