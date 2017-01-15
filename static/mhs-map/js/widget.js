function updateWidget(widget) {
    return widget.updateWidget();
};
function ListWidget(model, jqelement) {
    this.model = model;
    this.jqelement = jqelement;
    this.updateWidget = (function () {
        this.jqelement.empty();
        return this.jqelement.html(['<UL>', siteListMap(this.model, (function (site) {
            return ['<LI>', site.sNo + ' - ' + site.sName, '</LI>'].join('');
        }).bind(this)).join(''), '</UL>'].join(''));
    }).bind(this);
    return this;
};
function siteIconUri(site) {
    var stName2 = site.stName;
    if (stName2 === 'Featured site') {
        return 'icon_feature.png';
    } else if (stName2 === 'Museum/Archives') {
        return 'icon_museum.png';
    } else if (stName2 === 'Building') {
        return 'icon_building.png';
    } else if (stName2 === 'Monument') {
        return 'icon_monument.png';
    } else if (stName2 === 'Cemetery') {
        return 'icon_cemetery.png';
    } else if (stName2 === 'Location') {
        return 'icon_location.png';
    } else if (stName2 === 'Other') {
        return 'icon_other.png';
    };
};
function siteMarkerIcon(site) {
    return { 'url' : ICONSURI + siteIconUri(site),
             'size' : new google.maps.Size(32, 32),
             'origin' : new google.maps.Point(0, 0),
             'anchor' : new google.maps.Point(16, 16)
           };
};
function siteLinkTitle(site) {
    var sAddress3 = site.sAddress;
    return site.sName + ', ' + site.mName + (sAddress3 === '' ? '' : ', ' + sAddress3);
};
function siteLinkUrl(site) {
    return MHSBASEURI + site.sUrl;
};
function mapAddMarker(googleMap, siteInfoWindow, site) {
    var marker = new google.maps.Marker({ 'position' : site.latLng,
                                          'icon' : siteMarkerIcon(site),
                                          'title' : site.sName,
                                          'map' : googleMap
                                        });
    var content = ['<DIV CLASS="site-info-window-content-box"><DIV CLASS="site-info-window-site-name-box"><A CLASS="site-info-window-site-link" HREF="', siteLinkUrl(site), '" TARGET="_blank">', siteLinkTitle(site), '</A></DIV></DIV>'].join('');
    google.maps.event.addListener(marker, 'click', function (event) {
        siteInfoWindow.setContent(content);
        return siteInfoWindow.open(googleMap, marker);
    });
    return marker;
};
function MapWidget(model, jqelement, center, zoom, geolocationOptions) {
    this.model = model;
    this.idleListener = null;
    this.geolocationOptions = geolocationOptions;
    this.geolocationMarker = new google.maps.Marker({ 'map' : null });
    this.geolocationWatchId = null;
    this.markers = [];
    this.siteInfoWindow = new google.maps.InfoWindow({  });
    this.googleMap = new google.maps.Map(jqelement[0], { 'center' : center, 'zoom' : zoom });
    this.updateWidget = (function () {
        for (var marker = null, _js_arrvar5 = this.markers, _js_idx4 = 0; _js_idx4 < _js_arrvar5.length; _js_idx4 += 1) {
            marker = _js_arrvar5[_js_idx4];
            marker.setMap(null);
        };
        this.markers.length = 0;
        return siteListDo(this.model, (function (site) {
            var marker = mapAddMarker(this.googleMap, this.siteInfoWindow, site);
            return this.markers.push(marker);
        }).bind(this));
    }).bind(this);
    return this;
};
function mapWidgetBounds(mapWidget) {
    return mapWidget.googleMap.getBounds();
};
function mapWidgetListenOnIdle(mapWidget, fn) {
    if (mapWidget.idleListener != null) {
        google.maps.event.removeListener(mapWidget.idleListener);
    };
    return mapWidget.idleListener = mapWidget.googleMap.addListener('idle', function (event) {
        return fn(mapWidget);
    });
};
function geolocationPositionToGoogleLatLng(position) {
    var lat = position.coords.latitude;
    var lng = position.coords.longitude;
    return new google.maps.LatLng({ 'lat' : lat, 'lng' : lng });
};
function geolocationSuccess(mapWidget, position) {
    var googleLatLng = geolocationPositionToGoogleLatLng(position);
    mapWidget.googleMap.setCenter(googleLatLng);
    mapWidget.geolocationMarker.setPosition(googleLatLng);
    return console.log('GEOLOCATION SUCCESS: lat-lng=' + googleLatLng);
};
function geolocationError(positionError) {
    console.log('GEOLOCATION ERROR: ' + positionError.code + ': ' + positionError.message);
    return alert('Geolocation Error: ' + positionError.code + ': ' + positionError.message);
};
function mapWidgetStartGeolocation(mapWidget) {
    if (navigator.geolocation) {
        mapWidget.geolocationMarker.setMap(mapWidget.googleMap);
        return mapWidget.geolocationWatchId = navigator.geolocation.watchPosition(function (position) {
            return geolocationSuccess(mapWidget, position);
        }, geolocationError, mapWidget.geolocationOptions);
    } else {
        return alert('Geolocation is not available.');
    };
};
function mapWidgetStopGeolocation(mapWidget) {
    if (navigator.geolocation) {
        navigator.geolocation.clearWatch(mapWidget.geolocationWatchId);
        map.geolocationWatchId = null;
        return mapWidget.geolocationMarker.setMap(null);
    } else {
        return alert('Geolocation is not available.');
    };
};
