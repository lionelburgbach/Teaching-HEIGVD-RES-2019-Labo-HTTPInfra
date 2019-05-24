$(function () {
    function loadAnimals() {
    $.getJSON( "/api/animals/", function( animals ){
        console.log(animals);
        var message = "No animal here";
        if( animals.length > 0){
            message = "Animal : "+ animals[0].type + " Country : " + animals[0].country;
        }
        $(".skills").text(message);
    })    
    };

    loadAnimals();
    setInterval( loadAnimals, 2000);
});