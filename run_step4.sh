docker build -t res/apache_php ./docker-images/apache-php-image/
docker build -t res/express_animals ./docker-images/express-image/
docker build -t res/apache_rp ./docker-images/apache-reverse-proxy/

docker run -d --name apache_static res/apache_php
docker run -d --name express_dynamaic res/express_animals
docker run -d -p 8080:80 --name apache_rp res/apache_rp
