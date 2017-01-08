function xhrGetJson(url, successFunction) {
    return goog.net.XhrIo.send(url, function (event) {
        var xhr = event.target;
        return xhr.isSuccess() ? successFunction(xhr.getResponseJson()) : alert('Error: ' + xhr.getStatusText());
    });
};
var MAPOPTIONS = { 'center' : CURRENTCENTER, 'zoom' : CURRENTZOOM };
var MAP = null;
var SITEINFOWINDOW = new google.maps.InfoWindow({  });
function linkControl(controlDiv) {
    controlDiv.className = 'link-control-box';
    var controlUi = document.createElement('div');
    controlUi.className = 'link-control-outline-box';
    controlUi.title = 'Click to return to search page';
    controlDiv.appendChild(controlUi);
    var controlText = document.createElement('div');
    controlText.className = 'link-control-content-box';
    controlText.innerHTML = '<SPAN CLASS="link-control-content-text">Search for sites</SPAN>';
    return controlUi.appendChild(controlText);
};
function siteTypeIconUri(stName) {
    if (stName === 'Featured site') {
        return 'icon_feature.png';
    } else if (stName === 'Museum/Archives') {
        return 'icon_museum.png';
    } else if (stName === 'Building') {
        return 'icon_building.png';
    } else if (stName === 'Monument') {
        return 'icon_monument.png';
    } else if (stName === 'Cemetery') {
        return 'icon_cemetery.png';
    } else if (stName === 'Location') {
        return 'icon_location.png';
    } else if (stName === 'Other') {
        return 'icon_other.png';
    };
};
var MYMARKER = null;
function setMyMarker(map, position) {
    if (MYMARKER == null) {
        MYMARKER = new google.maps.Marker({ 'map' : map });
    };
    return MYMARKER.setPosition(position);
};
var MARKERS = [];
function deleteMarkers() {
    for (var marker = null, _js_idx1 = 0; _js_idx1 < MARKERS.length; _js_idx1 += 1) {
        marker = MARKERS[_js_idx1];
        marker.setMap(null);
    };
    return MARKERS = [];
};
function addMarker(map, feature) {
    var coordinates2 = feature.geometry.coordinates;
    var properties3 = feature.properties;
    var latLng = new google.maps.LatLng(coordinates2[1], coordinates2[0]);
    var sNo4 = properties3.sNo;
    var sName5 = properties3.sName;
    var mName6 = properties3.mName;
    var sAddress7 = properties3.sAddress;
    var stName8 = properties3.stName;
    var sUrl9 = properties3.sUrl;
    var icon = { 'url' : ICONSURI + siteTypeIconUri(stName8),
                 'size' : new google.maps.Size(32, 32),
                 'origin' : new google.maps.Point(0, 0),
                 'anchor' : new google.maps.Point(16, 16)
               };
    var s = sName5 + ', ' + mName6 + (sAddress7 === '' ? '' : ', ' + sAddress7);
    var marker = new google.maps.Marker({ 'position' : latLng,
                                          'icon' : icon,
                                          'title' : sName5,
                                          'map' : map
                                        });
    var content = ['<DIV CLASS="site-info-window-content-box"><DIV CLASS="site-info-window-site-name-box"><A CLASS="site-info-window-site-link" HREF="', MHSBASEURI + sUrl9, '" TARGET="_blank">', s, '</A></DIV></DIV>'].join('');
    google.maps.event.addListener(marker, 'click', function (event) {
        SITEINFOWINDOW.setContent(content);
        return SITEINFOWINDOW.open(map, marker);
    });
    return MARKERS.push(marker);
};
function formatResultsInfoWindowContent(center, zoom, bounds, count) {
    return 'Center: ' + center + '<br>' + 'Zoom: ' + zoom + '<br>' + 'Bounds: ' + bounds + '<br>' + 'Sites within bounds:  ' + count;
};
function geolocationSuccess(position) {
    var lat = position.coords.latitude;
    var lng = position.coords.longitude;
    var altitude10 = position.coords.altitude;
    var accuracy11 = position.coords.accuracy;
    setMyMarker(MAP, new google.maps.LatLng({ 'lat' : lat, 'lng' : lng }));
    return console.log('GEOLOCATION SUCCESS: lat=' + lat + ' lng=' + lng);
};
function geolocationError(error) {
    return console.log('GEOLOCATION ERROR: ' + error.code + ': ' + error.message);
};
var GEOLOCATIONOPTIONS = {  };
var WATCHID = null;
function initialize() {
    if (navigator.geolocation) {
        WATCHID = navigator.geolocation.watchPosition(geolocationSuccess, geolocationError, GEOLOCATIONOPTIONS);
    } else {
        console.log('no geolocation');
    };
    MAP = new google.maps.Map(document.getElementById('map-canvas'), MAPOPTIONS);
    var controlDiv = document.createElement('div');
    var control = new linkControl(controlDiv);
    var position = google.maps.ControlPosition['TOP_CENTER'];
    controlDiv.index = 1;
    var foo = MAP.controls[position];
    foo.push(controlDiv);
    return MAP.addListener('idle', function () {
        CURRENTCENTER = MAP.getCenter();
        CURRENTZOOM = MAP.getZoom();
        var bounds = MAP.getBounds();
        var southWest = bounds.getSouthWest();
        var northEast = bounds.getNorthEast();
        var south = southWest.lng();
        var west = southWest.lat();
        var north = northEast.lng();
        var east = northEast.lat();
        return xhrGetJson(FEATURESJSONURI + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east, function (results) {
            console.log('Deleting markers');
            deleteMarkers();
            var sitesCount = results.features.length;
            return console.log('Populating markers: ' + sitesCount + ' center=' + CURRENTCENTER + ' zoom=' + CURRENTZOOM + ' bounds=' + bounds);
        });
    });
};
