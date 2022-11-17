//= require jquery
//= require jquery_ujs
function change_stops() {
    var state = document.getElementById("travel_plan_state").value;
    var cities = cities_in_state_hash[state];
    console.log(cities)
    var stops = document.getElementById("travel_plan_cities");
    stops.innerHTML = "";
    if (typeof cities !== 'undefined') {
      for (var i = 0; i < cities.length; i++) {
        var opt = document.createElement("option");
        opt.value = cities[i];
        opt.innerHTML = cities[i];
        stops.appendChild(opt);
      }
    }
  }