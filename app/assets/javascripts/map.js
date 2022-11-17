// Initialize and add the map

let markers = [];
let maps = [];
let travelPaths = [0];

function initMap() {
  for (let i = 0; i < 10; i++) {
    let map_div = document.getElementById(`map_${i}`);
    if (map_div) {
      let map = new google.maps.Map(map_div, {
        zoom: 4,
        center: {lat: 0, lng: 0}
      });
      maps.push(map);
      travelPaths.push(0);
    };
  };
}

// add a marker to the map and push to the array
function addMarkers(loaction, name, lable, map) {
  const marker = new google.maps.Marker({
    position: loaction,
    map: map,
    label: lable,
  });

  const infowindow = new google.maps.InfoWindow({
    content: name
  });

  marker.addListener("mouseover", () => {
    infowindow.open({
      anchor: marker,
      map,
    });
  });

  marker.addListener("mouseout", () => {
    infowindow.close({
      anchor: marker,
      map,
    });
  });

  markers.push(marker);
}

function setMapOnAll(map) {
  for (let i = 0; i < markers.length; i++) {
    markers[i].setMap(map);
  }
}

function deleteMarkers() {
  setMapOnAll(null);
  markers = [];
}

function updateMap(map_idx, location_info, path_info) {
  deleteMarkers();
  console.log("UPDATE MAP");
  var bounds = new google.maps.LatLngBounds();
  var counter = 1;
  for (const attraction of path_info) {
    value = location_info[attraction]
    bounds.extend(value);
    addMarkers(value, attraction, counter.toString(), maps[map_idx]);
    counter++;
  }
  maps[map_idx].fitBounds(bounds);


  pathLocations = path_info.map((attraction) => location_info[attraction]);
  travelPath = travelPaths[map_idx];
  if (travelPath) {
    travelPath.setMap(null);
  }
  travelPath = new google.maps.Polyline({
    path: Object.values(pathLocations),
    geodesic: true,
    strokeColor: "#FF0000",
    strokeOpacity: 1.0,
    strokeWeight: 2,
  });

  travelPath.setMap(maps[map_idx]);
  
}
