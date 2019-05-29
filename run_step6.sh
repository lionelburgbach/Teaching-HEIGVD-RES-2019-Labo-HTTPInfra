docker build -t res/apache_php ./docker-images/apache-php-image/
docker build -t res/express_animals ./docker-images/express-image/
docker build -t res/apache_rp ./docker-images/apache-reverse-proxy/

docker run -d --name apache_static1 res/apache_php
docker run -d --name apache_static2 res/apache_php

docker run -d --name express_dynamic1 res/express_animals
docker run -d --name express_dynamic2 res/express_animals

static_app1=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static1`
static_app2=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static2`
dynamic_app1=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic1`
dynamic_app2=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic2`

docker run -d -p 8080:80 -e STATIC_APP1=$static_app1:80 -e STATIC_APP2=$static_app2:80 -e DYNAMIC_APP1=$dynamic_app1:3000 -e DYNAMIC_APP2=$dynamic_app2:3000 --name apache_rp res/apache_rp
