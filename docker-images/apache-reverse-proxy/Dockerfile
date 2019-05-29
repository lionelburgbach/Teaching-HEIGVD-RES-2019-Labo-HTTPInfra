FROM php:5.6-apache

RUN apt-get update && \
    apt-get install -y vim

COPY apache2-foreground /usr/local/bin/
COPY templates /var/apache2/templates

COPY conf/ /etc/apache2/
COPY apache2.conf /etc/apache2/apache2.conf

RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests status
RUN a2ensite 000-* 001-*