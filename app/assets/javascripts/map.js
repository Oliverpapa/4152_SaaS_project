// Initialize and add the map

let markers = [];
let maps = [];
let travelPaths = [];

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
      markers.push([]);
    };
  };
}

// add a marker to the map and push to the array
function addMarkers(map_idx, loaction, name, lable, map) {
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

  markers[map_idx].push(marker);
}

function setMapOnAll(map_idx, map) {
  for (let i = 0; i < markers[map_idx].length; i++) {
    markers[map_idx][i].setMap(map);
  }
}

function deleteMarkers(map_idx) {
  setMapOnAll(map_idx, null);
  markers[map_idx] = [];
}

function updateMap(map_idx, location_info, path_info) {
  deleteMarkers(map_idx);
  console.log("UPDATE MAP");
  var bounds = new google.maps.LatLngBounds();
  var counter = 1;
  for (const attraction of path_info) {
    value = location_info[attraction]
    bounds.extend(value);
    addMarkers(map_idx, value, attraction, counter.toString(), maps[map_idx]);
    counter++;
  }
  maps[map_idx].fitBounds(bounds);


  pathLocations = path_info.map((attraction) => location_info[attraction]);
  travelPath = travelPaths[map_idx];
  if (travelPath) {
    travelPath.setMap(null);
  }
  travelPaths[map_idx] = new google.maps.Polyline({
    path: Object.values(pathLocations),
    geodesic: true,
    strokeColor: "#FF0000",
    strokeOpacity: 1.0,
    strokeWeight: 2,
  });

  travelPaths[map_idx].setMap(maps[map_idx]);
  
}
