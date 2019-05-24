#docker build -t res/apache_php
#docker build -t res/express_animals
#docker build -t res/apache_rp

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)


docker run -d --name apache_static res/apache_php
docker run -d --name express_dynamaic res/express_animals
docker run -d -p 8080:80 --name apache_rp res/apache_rp
