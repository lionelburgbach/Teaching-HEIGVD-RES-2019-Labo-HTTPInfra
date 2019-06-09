### Step 1: Static HTTP server with apache httpd

This step is on the branch **fb-apache-static**

The first part is an http server apache with php. You can find the image with Docker hub, we use php:5.6-apache. To copy the content, you have to put every file in the content/ folder and it will be copied into /var/www/html. Bootstrap is very useful to find a good design and responsive for your website template.

Configuration files are in /etc/apache2/

### To try and run :

We have a Dockerfie, you have to be in the main repository.

To build the image :

- docker build -t res/apache_php ./docker-images/apache-php-image/

To run :

- docker run -d -p 8080:80 res/apache_php

If you want to run more than one server, you have to change 8080 with 8081 (i.e.)

To verify, you can use  your browser. (192.168.99.100:8080)

### Step 2: Dynamic HTTP server with express.js

This step is on the branch **fb-express-dynamic**

In this part, the purpose is to write a little express server with nodejs and run it in docker.
We choose to send statistics about animals, the country, and how much people they kill per year.
The content has to be in src folder, this folder is copied when you build the docker image.
The node version is 4.4, you can change this in the Dockerfile.

This is the javascript code : 

```
var Chance = require('chance');
var chance = new Chance();

var express = require('express');
var app = express();

app.get('/', function(req, res) {
   res.send( generateAnimalStats());
});

app.listen(3000, function () {
   console.log('Accepting HTTP requests on port 3000.');
});

function generateAnimalStats() {

      var numberOfAnimals = chance.integer({
         min: 0,
         max: 10
      });
      console.log(numberOfAnimals);
      var animals = [];
      for (var i=0; i<numberOfAnimals; i++) {
         var type = chance.animal();
         var nb_kill_people = chance.integer({
            min:0,
            max: 10000
         });
         var country = chance.country({ full: true });
         animals.push({
            type,
            nb_kill_people,
            country
         });
      };
      console.log(animals);
      return animals;
}
```
### To try and run :

We have a Dockerfie, you have to be in the main repository.

To build the image : 

- docker build -t res/express_animals ./docker-images/express-image/

To run : 

- docker run -d -p 9090:3000 res/express_animals

If you want to run more than one server, you have to change 9090 with 9091 (i.e.)

To verify, you can use telnet or your browser. (**yourDockerHostIPaddress**:9090)

Postman is really useful to see what happens between the client and the server.

### Step 3: Reverse proxy with apache (static configuration)

This step is on the branch **fb-apache-reverse-proxy**

We will add a reverse proxy here, it's a good thing for security.

You have to change server configuration files to do this.  These files are in conf/sites-available/ , you have to edit 001-reverse-proxy.conf to change configuration. **BE CAREFUL**, it's hardcoded so you have to verify which IP is used by docker. (You can use : docker inspect **name** | grep -i ipaddress).

To resolve DNS problem, you have to change, on your computer, in /etc/hosts (for macOS) and add **yourDockerHostIPaddress** demo.res.ch

### To try and run : 

We have a Dockerfie, you have to be in the main repository.

To build the image : 

- docker build -t res/apache_php ./docker-images/apache-php-image/
- docker build -t res/express_animals ./docker-images/express-image/
- docker build -t res/apache_rp ./docker-images/apache-reverse-proxy/

To run : 

- docker run -d --name apache_static res/apache_php
- docker run -d --name express_dynamic res/express_animals
- docker inspect apache_static | grep -i ipaddress
- docker inspect express_dynamic | grep -i ipaddress

And change IP in the configuration file.

- docker run -d -p 8080:80 res/apache_rp

To verify, you can use your browser. (demo.res.ch:8080 (website) or demo.res.ch:8080/api/animals/ (animals array))

### Step 4: AJAX requests with JQuery

This step is on the branch **fb-ajax-jquery**

To update node:4.4 We used this : https://superuser.com/questions/1423486/issue-with-fetching-http-deb-debian-org-debian-dists-jessie-updates-inrelease

Here, we are focusing on dynamic content on the web page. To do that, we use JQuery. 
You have to update the index.html file to add the script at the end and write a function in JavaScript.

Our script is called animals.js

```
$(function () {
    function loadAnimals() {
    $.getJSON( "/api/animals/", function( animals ){
        console.log(animals);
        var message = "No animal here";
        if( animals.length > 0){
            message = "Animal : "+ animals[0].type + " - Country : " + animals[0].country;
        }
        $(".skills").text(message);
    })    
    };

    loadAnimals();
    setInterval( loadAnimals, 2000);
});
```

### To try and run 

When you build images, you have to use these names and you have to be in the main repository :

- docker build -t res/apache_php ./docker-images/apache-php-image/
- docker build -t res/express_animals ./docker-images/express-image/
- docker build -t res/apache_rp ./docker-images/apache-reverse-proxy/

And run images : 

- docker run -d --name apache_static res/apache_php
- docker run -d --name express_dynamaic res/express_animals
- docker run -d -p 8080:80 --name apache_rp res/apache_rp

You can just run the script run_setp4.sh and go to your browser and enjoy the result.

If the script doesn't work, verify IP address, change them if you need and run again.

### Step 5: Dynamic reverse proxy configuration

This step is on the branch **fb-dynamic-configuration**

In the last part, hardcode is changed by dynamic code that is really better.

A php script is used here, to catch the ip address when you run the revers proxy and write them into the file 001-reverse-proxy.conf. This script is in the repository templates and it's config-template.php.

For the apache2-foreground, we have to use this version, the one in the webcast doesn’t work : https://github.com/docker-library/php/blob/f016f5dc420e7d360f7381eb014ac6697e247e11/5.6/apache/apache2-foreground

It's still not good enough, if the revers proxy crash or one other server, everything is down, so we will try to change that.

### To try and run 

First you have to build images and have to be in the main repository :

- docker build -t res/apache_php ./docker-images/apache-php-image/
- docker build -t res/express_animals ./docker-images/express-image/
- docker build -t res/apache_rp ./docker-images/apache-reverse-proxy/

Now you have to run images (containers with no name are used to see if it's working) :

- docker run -d res/apache_php
- docker run -d res/apache_php       
- docker run -d --name apache_static res/apache_php
- docker run -d res/express_animals
- docker run -d res/express_animals
- docker run -d --name express_dynamic res/express_animals

Now you have to check ip form container and save it in a variable

- static_app=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static\`
- dynamic_app=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic\`

Now you can run the revers proxy : 

- docker run -d -p 8080:80 -e STATIC_APP=$static_app:80 -e DYNAMIC_APP=$dynamic_app:3000 --name apache_rp res/apache_rp

There is a script for that, run_step5.sh

### Extra step 1: Management UI

To use Management UI, you have to run these commands (only the first time for the first one): 

- docker volume create portainer_data
- docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

Go to your browser, it's beautiful! (**yourDockerHostIPaddress**:9000)
