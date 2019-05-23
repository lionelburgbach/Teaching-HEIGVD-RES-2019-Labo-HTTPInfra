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

//console.log("Be careful, " + chance.animal() + " can kill you easily!");
