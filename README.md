# Teaching-HEIGVD-RES-2018-Labo-HTTPInfra


### Step 1:

The first part is a http server apache with php. You can find the image with Docker hub, we use php:5.6-apache.

To copy the content, you have to put every file in the content/ folder and it will be copy into /var/www/html.
Bootstrap is very usefull to find a good design and responsiv for your website template.

Configuration files are in /etc/apache2/

### To try and run :

You have to be in fb-apache-static branch.

We have a Dockerfie, you have to be in the repository : docker-images/apache-php-image/

To build the image : 

docker build -t res/apache_php .

To run : 

docker run -d -p 8080:80 res/apache_php

If you want to run more than one server, you have to change 8080 with 8081 (i.e)

 To verify, you can use  your browser. (192.168.99.100:8080)

### Step 2:

In this part, the purpose is to write a little express server with nodejs and run it in docker.
We choose to send statistics about animal, the country, and how much people they kill per year.

The content has to be in src folder, this folder is copied when you build the docker image.
The node version is 4.4, you can change this in the Dockerfile.

### To try and run : 

You have to be in fb-express-dynamic branch.

We have a Dockerfie, you have to be in the repository : docker-images/express-image/

To build the image : 

docker build -t res/express_animals .

To run : 

docker run -d -p 9090:3000 res/express_animals

If you want to run more than one server, you have to change 9090 with 9091 (i.e)

 To verify, you can use telnet or your browser. (192.168.99.100:9090)

Postaman is really usefull to see what happen between the client and the server.


### Step 3:

You have to be in fb-apache-reverse-proxy branch.

We will add a rervers proxy here, it's a good thing for security.

You have to change server configuration files to do this.  These files are in conf/sites-available/ ,
you have to edit 001-reverse-proxy.conf to change configuration. BE CARFEUL, it's hardcode so you have to verify which IP is used by docker. (You can use : docker inspect <name> | grep -i ipaddress).

To resolve DNS problem, you have to change, on your computer, in /etc/hosts (for mac os) and add 192.168.99.100 demo.res.ch

### To try and run : 

We have a Dockerfie, you have to be in the repository : docker-images/apache-reverse-proxy/

To build the image : 

docker build -t res/apache_rp .

To run : 

docker run -d -p 8080:80 res/apache_rp

 To verify, you can use  your browser. (demo.res.ch:8080 (website) or demo.res.ch:8080/api/animals/ (animals array))

 ### Step 4:

 I've changed node:4.4 to node:8 to solve a problem with docker and vim.

 Here, we are focus on dymnamic content on the web page. To do that, we use JQuery. 
 You have to update the index.html file to add the script at the end and write a function in javascript.
 Our scrpit is called animals.js

 ### To try and run 

 When you build images, you have to use these names :

 - docker build -t res/apache_php
 - docker build -t res/express_animals
 - docker build -t res/apache_rp

 juste run the script sr_setp4.sh and go to your browser and enjoy the result.

 If the script dosen't work, verify IP adresse, change them if you need and run again.

 ### Step 5:

 In the last part, hardcode is change by dynamic code that is really better.

 A php script is used here, to catch the ip adresse when you run the revers proxy and write them into the file 001-reverse-proxy.conf
 This script is in the repository templates and it's config-template.php.

 For the apache2-foreground, we have to use this version, the one in the webcat does not work : https://github.com/docker-library/php/blob/master/7.3/stretch/apache/apache2-foreground 

It's still not good enough, if the revers proxy crash or one other server, everything is down, so we will try to change that.

 ### To try and run 

First you have to build images :

- docker build -t res/apache_php
- docker build -t res/express_animals
- docker build -t res/apache_rp

Now you have to run images :

- docker run -d --name apache_static res/apache_php
- docker run -d --name express_dynamic res/express_animals

Now you have to check ip form container and save it in a variable

- static_app=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static\`
- dynamic_app=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic\`

Now you can run the revers proxy : 

- docker run -d -p 8080:80 -e STATIC_APP=$static_app:80 -e DYNAMIC_APP=$dynamic_app:3000 --name apache_rp res/apache_rp

There is a script for that, run_step5.sh

### Step 6: Load Balancing

If one server is down, it should be possible to have another one to take the relay.

First you have to choose an load balancer scheduler algorithm, we have chosen lbmethod_byrequests (Request Counting).

In the script php, we have to change the older configuration and add a new one : 

exemple from the source : 

    <Proxy "balancer://mycluster">
        BalancerMember "http://192.168.1.50:80"
        BalancerMember "http://192.168.1.51:80"
    </Proxy>
    ProxyPass        "/test" "balancer://mycluster"
    ProxyPassReverse "/test" "balancer://mycluster"

The Dockerfile has to be update : 

We have to add these mods : proxy_balancer lbmethod_byrequests

Source : https://httpd.apache.org/docs/2.4/fr/mod/mod_proxy_balancer.html

### To try and run

First you have to build images :

- docker build -t res/apache_php
- docker build -t res/express_animals
- docker build -t res/apache_rp

Now you have to run images :

- docker run -d --name apache_static1 res/apache_php
- docker run -d --name apache_static2 res/apache_php
- docker run -d --name express_dynamic1 res/express_animals
- docker run -d --name express_dynamic2 res/express_animals

Now you have to check ip form container and save it in a variable

- static_app1=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static1\`
- static_app2=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache_static2\`
- dynamic_app1=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic1\`
- dynamic_app2=\`docker inspect --format '{{ .NetworkSettings.IPAddress }}' express_dynamic2\`

Now you can run the revers proxy : 

- docker run -d -p 8080:80 -e STATIC_APP1=$static_app1:80 -e STATIC_APP2=$static_app2:80 -e DYNAMIC_APP1=$dynamic_app1:3000 -e DYNAMIC_APP2=$dynamic_app2:3000 --name apache_rp res/apache_rp

There is a script for that, run_step6.sh

Kill one, see if it'is still working, and kill the second.

### Management UI

To use Management UI, you have to run these commands : 

- docker volume create portainer_data
- docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

Go to your browser, it's beautiful!

## Objectives

The first objective of this lab is to get familiar with software tools that will allow us to build a **complete web infrastructure**. By that, we mean that we will build an environment that will allow us to serve **static and dynamic content** to web browsers. To do that, we will see that the **apache httpd server** can act both as a **HTTP server** and as a **reverse proxy**. We will also see that **express.js** is a JavaScript framework that makes it very easy to write dynamic web apps.

The second objective is to implement a simple, yet complete, **dynamic web application**. We will create **HTML**, **CSS** and **JavaScript** assets that will be served to the browsers and presented to the users. The JavaScript code executed in the browser will issue asynchronous HTTP requests to our web infrastructure (**AJAX requests**) and fetch content generated dynamically.

The third objective is to practice our usage of **Docker**. All the components of the web infrastructure will be packaged in custom Docker images (we will create at least 3 different images).

## General instructions

* This is a **BIG** lab and you will need a lot of time to complete it. This is the last lab of the semester (but it will keep us busy for a few weeks!).
* We have prepared webcasts for a big portion of the lab (**what can get you the "base" grade of 4.5**).
* To get **additional points**, you will need to do research in the documentation by yourself (we are here to help, but we will not give you step-by-step instructions!). To get the extra points, you will also need to be creative (do not expect complete guidelines).
* The lab can be done in **groups of 2 students**. You will learn very important skills and tools, which you will need to next year's courses. You cannot afford to skip this content if you want to survive next year.
* Read carefully all the **acceptance criteria**.
* We will request demos as needed. When you do your **demo**, be prepared to that you can go through the procedure quickly (there are a lot of solutions to evaluate!)
* **You have to write a report. Please do that directly in the repo, in one or more markdown files. Start in the README.md file at the root of your directory.**
* The report must contain the procedure that you have followed to prove that your configuration is correct (what you would do if you were doing a demo)


## Step 1: Static HTTP server with apache httpd

### Webcasts

* [Labo HTTP (1): Serveur apache httpd "dockerisé" servant du contenu statique](https://www.youtube.com/watch?v=XFO4OmcfI3U)

### Acceptance criteria

* You have a GitHub repo with everything needed to build the Docker image.
* You can do a demo, where you build the image, run a container and access content from a browser.
* You have used a nice looking web template, different from the one shown in the webcast.
* You are able to explain what you do in the Dockerfile.
* You are able to show where the apache config files are located (in a running container).
* You have **documented** your configuration in your report.

## Step 2: Dynamic HTTP server with express.js

### Webcasts

* [Labo HTTP (2a): Application node "dockerisée"](https://www.youtube.com/watch?v=fSIrZ0Mmpis)
* [Labo HTTP (2b): Application express "dockerisée"](https://www.youtube.com/watch?v=o4qHbf_vMu0)

### Acceptance criteria

* You have a GitHub repo with everything needed to build the Docker image.
* You can do a demo, where you build the image, run a container and access content from a browser.
* You generate dynamic, random content and return a JSON payload to the client.
* You cannot return the same content as the webcast (you cannot return a list of people).
* You don't have to use express.js; if you want, you can use another JavaScript web framework or event another language.
* You have **documented** your configuration in your report.


## Step 3: Reverse proxy with apache (static configuration)

### Webcasts

* [Labo HTTP (3a): reverse proxy apache httpd dans Docker](https://www.youtube.com/watch?v=WHFlWdcvZtk)
* [Labo HTTP (3b): reverse proxy apache httpd dans Docker](https://www.youtube.com/watch?v=fkPwHyQUiVs)
* [Labo HTTP (3c): reverse proxy apache httpd dans Docker](https://www.youtube.com/watch?v=UmiYS_ObJxY)


### Acceptance criteria

* You have a GitHub repo with everything needed to build the Docker image for the container.
* You can do a demo, where you start from an "empty" Docker environment (no container running) and where you start 3 containers: static server, dynamic server and reverse proxy; in the demo, you prove that the routing is done correctly by the reverse proxy.
* You can explain and prove that the static and dynamic servers cannot be reached directly (reverse proxy is a single entry point in the infra). 
* You are able to explain why the static configuration is fragile and needs to be improved.
* You have **documented** your configuration in your report.


## Step 4: AJAX requests with JQuery

### Webcasts

* [Labo HTTP (4): AJAX avec JQuery](https://www.youtube.com/watch?v=fgpNEbgdm5k)

### Acceptance criteria

* You have a GitHub repo with everything needed to build the various images.
* You can do a complete, end-to-end demonstration: the web page is dynamically updated every few seconds (with the data coming from the dynamic backend).
* You are able to prove that AJAX requests are sent by the browser and you can show the content of th responses.
* You are able to explain why your demo would not work without a reverse proxy (because of a security restriction).
* You have **documented** your configuration in your report.

## Step 5: Dynamic reverse proxy configuration

### Webcasts

* [Labo HTTP (5a): configuration dynamique du reverse proxy](https://www.youtube.com/watch?v=iGl3Y27AewU)
* [Labo HTTP (5b): configuration dynamique du reverse proxy](https://www.youtube.com/watch?v=lVWLdB3y-4I)
* [Labo HTTP (5c): configuration dynamique du reverse proxy](https://www.youtube.com/watch?v=MQj-FzD-0mE)
* [Labo HTTP (5d): configuration dynamique du reverse proxy](https://www.youtube.com/watch?v=B_JpYtxoO_E)
* [Labo HTTP (5e): configuration dynamique du reverse proxy](https://www.youtube.com/watch?v=dz6GLoGou9k)

### Acceptance criteria

* You have a GitHub repo with everything needed to build the various images.
* You have found a way to replace the static configuration of the reverse proxy (hard-coded IP adresses) with a dynamic configuration.
* You may use the approach presented in the webcast (environment variables and PHP script executed when the reverse proxy container is started), or you may use another approach. The requirement is that you should not have to rebuild the reverse proxy Docker image when the IP addresses of the servers change.
* You are able to do an end-to-end demo with a well-prepared scenario. Make sure that you can demonstrate that everything works fine when the IP addresses change!
* You are able to explain how you have implemented the solution and walk us through the configuration and the code.
* You have **documented** your configuration in your report.

## Additional steps to get extra points on top of the "base" grade

### Load balancing: multiple server nodes (0.5pt)

* You extend the reverse proxy configuration to support **load balancing**. 
* You show that you can have **multiple static server nodes** and **multiple dynamic server nodes**. 
* You prove that the **load balancer** can distribute HTTP requests between these nodes.
* You have **documented** your configuration and your validation procedure in your report.

### Load balancing: round-robin vs sticky sessions (0.5 pt)

* You do a setup to demonstrate the notion of sticky session.
* You prove that your load balancer can distribute HTTP requests in a round-robin fashion to the dynamic server nodes (because there is no state).
* You prove that your load balancer can handle sticky sessions when forwarding HTTP requests to the static server nodes.
* You have documented your configuration and your validation procedure in your report.

### Dynamic cluster management (0.5 pt)

* You develop a solution, where the server nodes (static and dynamic) can appear or disappear at any time.
* You show that the load balancer is dynamically updated to reflect the state of the cluster.
* You describe your approach (are you implementing a discovery protocol based on UDP multicast? are you using a tool such as serf?)
* You have documented your configuration and your validation procedure in your report.

### Management UI (0.5 pt)

* You develop a web app (e.g. with express.js) that administrators can use to monitor and update your web infrastructure.
* You find a way to control your Docker environment (list containers, start/stop containers, etc.) from the web app. For instance, you use the Dockerode npm module (or another Docker client library, in any of the supported languages).
* You have documented your configuration and your validation procedure in your report.