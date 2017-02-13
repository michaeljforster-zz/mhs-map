function updateWidget(widget) {
    return widget.updateWidget();
};
function ListWidget(model, jqelement) {
    this.model = model;
    this.jqelement = jqelement;
    this.updateWidget = (function () {
        var alternateP = true;
        this.jqelement.empty();
        this.jqelement.addClass('panel panel-default');
        return this.jqelement.html(['<DIV CLASS="panel-heading"><H3 CLASS="panel-title">List</H3></DIV><DIV CLASS="list-group">', siteListMap(this.model, (function (site) {
            alternateP = !alternateP;
            return ['<A HREF="', site.url === '' ? '#' : MHSBASEURI + site.sUrl, '" TARGET="_blank" CLASS="', alternateP ? 'list-group-item mhs-alternate-list-group-item' : 'list-group-item', '"><H4 CLASS="list-group-item-heading">', site.sName, '</H4><P CLASS="list-group-item-text">', site.sAddress, '</P><P CLASS="list-group-item-text">', site.mName, '</P></A>'].join('');
        }).bind(this)).join(''), '</DIV>'].join(''));
    }).bind(this);
    return this;
};
function siteIconUri(site) {
    var stName438 = site.stName;
    if (stName438 === 'Featured site') {
        return 'icon_feature.png';
    } else if (stName438 === 'Museum/Archives') {
        return 'icon_museum.png';
    } else if (stName438 === 'Building') {
        return 'icon_building.png';
    } else if (stName438 === 'Monument') {
        return 'icon_monument.png';
    } else if (stName438 === 'Cemetery') {
        return 'icon_cemetery.png';
    } else if (stName438 === 'Location') {
        return 'icon_location.png';
    } else if (stName438 === 'Other') {
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
    var sAddress439 = site.sAddress;
    return site.sName + ', ' + site.mName + (sAddress439 === '' ? '' : ', ' + sAddress439);
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
    this.recenterP = false;
    this.idleListener = null;
    this.geolocationOptions = geolocationOptions;
    this.geolocationMarker = new google.maps.Marker({ 'map' : null });
    this.geolocationWatchId = null;
    this.markers = [];
    this.siteInfoWindow = new google.maps.InfoWindow({  });
    this.googleMap = new google.maps.Map(jqelement[0], { 'center' : center, 'zoom' : zoom });
    this.updateWidget = (function () {
        if (this.recenterP && siteListCentroid(this.model) != null) {
            this.recenterP = false;
            this.googleMap.panTo(siteListCentroid(this.model));
        };
        for (var marker = null, _js_arrvar441 = this.markers, _js_idx440 = 0; _js_idx440 < _js_arrvar441.length; _js_idx440 += 1) {
            marker = _js_arrvar441[_js_idx440];
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
function mapWidgetRecenterP(mapWidget) {
    return mapWidget.recenterP;
};
function __setf_mapWidgetRecenterP(newFlag, mapWidget) {
    return mapWidget.recenterP = newFlag;
};
function mapWidgetBounds(mapWidget) {
    return mapWidget.googleMap.getBounds();
};
function mapWidgetCenter(mapWidget) {
    return mapWidget.googleMap.getCenter();
};
function __setf_mapWidgetCenter(newCenter, mapWidget) {
    return mapWidget.googleMap.panTo(newCenter);
};
function mapWidgetZoom(mapWidget) {
    return mapWidget.googleMap.getZoom();
};
function __setf_mapWidgetZoom(newZoom, mapWidget) {
    return mapWidget.googleMap.setZoom(newZoom);
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
