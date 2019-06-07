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

### To try and run :

We have a Dockerfie, you have to be in the main repository.

To build the image : 

- docker build -t res/express_animals ./docker-images/express-image/

To run : 

- docker run -d -p 9090:3000 res/express_animals

If you want to run more than one server, you have to change 9090 with 9091 (i.e.)

To verify, you can use telnet or your browser. (**yourDockerHostIPaddress**:9090)

Postman is really useful to see what happens between the client and the server.