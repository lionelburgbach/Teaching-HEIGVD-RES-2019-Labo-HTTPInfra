### Step 1: Static HTTP server with apache httpd

This step is on the branch **fb-apache-static**

The first part is an http server apache with php. You can find the image with Docker hub, we use php:5.6-apache. To copy the content, you have to put every file in the content/ folder and it will be copied into /var/www/html. Bootstrap is very useful to find a good design and responsive for your website template.

Configuration files are in /etc/apache2/

### To try and run :

We have a Dockerfie, you have to be in the main repository.

To build the image :

- docker  build -t res/apache_php ./docker-images/apache-php-image/

To run :

- docker run -d -p 8080:80 res/apache_php

If you want to run more than one server, you have to change 8080 with 8081 (i.e.)

To verify, you can use  your browser. (192.168.99.100:8080)