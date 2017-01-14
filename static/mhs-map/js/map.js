function xhrGetJson(url, successFunction) {
    return jQuery.getJSON(url, successFunction).fail(function (jqXHR, textStatus, errorThrown) {
        return alert('Error: ' + textStatus);
    });
};
function decodeBounds(bounds) {
    var southWest = bounds.getSouthWest();
    var northEast = bounds.getNorthEast();
    var south = southWest.lat();
    var west = southWest.lng();
    var north = northEast.lat();
    var east = northEast.lng();
    console.log('BOUNDS: ' + bounds + ' SOUTH-EAST: ' + southWest + ' SOUTH: ' + south + ' WEST: ' + west + ' NORTH-EAST: ' + northEast + ' NORTH: ' + north + ' EAST: ' + east);
    __PS_MV_REG = { 'tag' : arguments.callee, 'values' : [west, north, east] };
    return south;
};
function Site(sNo, sName, mName, sAddress, stName, sUrl, latLng) {
    this.sNo = sNo;
    this.sName = sName;
    this.mName = mName;
    this.sAddress = sAddress;
    this.stName = stName;
    this.sUrl = sUrl;
    this.latLng = latLng;
    return this;
};
function geometryPointX(geometry) {
    if (geometry.type !== 'Point') {
        throw 'Geometry is not a Point';
    } else {
        return geometry.coordinates[0];
    };
};
function geometryPointY(geometry) {
    if (geometry.type !== 'Point') {
        throw 'Geometry is not a Point';
    } else {
        return geometry.coordinates[1];
    };
};
function geometryPointToLatLng(geometry) {
    return new google.maps.LatLng({ 'lat' : geometryPointY(geometry), 'lng' : geometryPointX(geometry) });
};
function featureToSite(feature) {
    return new Site(feature.properties.sNo, feature.properties.sName, feature.properties.mName, feature.properties.sAddress, feature.properties.stName, feature.properties.sUrl, geometryPointToLatLng(feature.geometry));
};
function Sites(url) {
    this.url = url;
    this.sites = [];
    this.subscribers = [];
    return this;
};
function sitesUnsubscribeAll(sites) {
    this.subscribers = [];
    return sites;
};
function sitesSubscribeToPopulated(sites, fn) {
    sites.subscribers.push(fn);
    return sites;
};
function sitesAnnouncePopulated(sites) {
    sites.subscribers.forEach(function (element) {
        return element();
    });
    return sites;
};
function sitesPopulateWithinBounds(sites, south, west, north, east) {
    return xhrGetJson(sites.url + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east, function (results) {
        sites.sites = [];
        results.features.forEach(function (feature) {
            return sites.sites.push(featureToSite(feature));
        });
        sitesAnnouncePopulated(sites);
        return sites;
    });
};
function updateWidget(widget) {
    return widget.updateWidget();
};
function ListWidget(model, jqelement) {
    this.model = model;
    this.jqelement = jqelement;
    this.updateWidget = function () {
        this.jqelement.empty();
        return this.jqelement.html(['<UL>', this.model.sites.map(function (site) {
            return ['<LI>', site.sNo + ' - ' + site.sName, '</LI>'].join('');
        }).join(''), '</UL>'].join(''));
    };
    return this;
};
function siteIconUri(site) {
    var stName9 = site.stName;
    if (stName9 === 'Featured site') {
        return 'icon_feature.png';
    } else if (stName9 === 'Museum/Archives') {
        return 'icon_museum.png';
    } else if (stName9 === 'Building') {
        return 'icon_building.png';
    } else if (stName9 === 'Monument') {
        return 'icon_monument.png';
    } else if (stName9 === 'Cemetery') {
        return 'icon_cemetery.png';
    } else if (stName9 === 'Location') {
        return 'icon_location.png';
    } else if (stName9 === 'Other') {
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
    var sAddress10 = site.sAddress;
    return site.sName + ', ' + site.mName + (sAddress10 === '' ? '' : ', ' + sAddress10);
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
    this.geolocationOptions = geolocationOptions;
    this.geolocationMarker = new google.maps.Marker({ 'map' : null });
    this.geolocationWatchId = null;
    this.markers = [];
    this.siteInfoWindow = new google.maps.InfoWindow({  });
    this.googleMap = new google.maps.Map(jqelement[0], { 'center' : center, 'zoom' : zoom });
    this.updateWidget = function () {
        for (var marker = null, _js_arrvar14 = this.markers, _js_idx13 = 0; _js_idx13 < _js_arrvar14.length; _js_idx13 += 1) {
            marker = _js_arrvar14[_js_idx13];
            marker.setMap(null);
        };
        this.markers.length = 0;
        for (var site = null, _js_arrvar12 = this.model.sites, _js_idx11 = 0; _js_idx11 < _js_arrvar12.length; _js_idx11 += 1) {
            site = _js_arrvar12[_js_idx11];
            var marker = mapAddMarker(this.googleMap, this.siteInfoWindow, site);
            this.markers.push(marker);
        };
    };
    return this;
};
function mapWidgetStartUpdatingMarkers(mapWidget) {
    return mapWidget.googleMap.addListener('idle', function () {
        var prevMv15 = 'undefined' === typeof __PS_MV_REG ? (__PS_MV_REG = undefined) : __PS_MV_REG;
        try {
            var south = decodeBounds(MAP.googleMap.getBounds());
            var _db16 = decodeBounds === __PS_MV_REG['tag'] ? __PS_MV_REG['values'] : [];
            var west = _db16[0];
            var north = _db16[1];
            var east = _db16[2];
            return sitesPopulateWithinBounds(SITES, south, west, north, east);
        } finally {
            __PS_MV_REG = prevMv15;
        };
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
    console.log('GEOLOCATION ERROR: ' + error.code + ': ' + error.message);
    return alert('Geolocation Error: ' + error.code + ': ' + error.message);
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
var SITES = null;
var LISTWIDGET = null;
var MAP = null;
function initialize() {
    jQuery('#list-view').hide();
    jQuery('#map-canvas').show();
    jQuery('#list-button').click(function () {
        jQuery('#list-view').show();
        return jQuery('#map-canvas').hide();
    });
    jQuery('#map-button').click(function () {
        jQuery('#list-view').hide();
        return jQuery('#map-canvas').show();
    });
    SITES = new Sites(FEATURESWITHINBOUNDSURI);
    LISTWIDGET = new ListWidget(SITES, jQuery('#list-view'));
    sitesSubscribeToPopulated(SITES, function () {
        console.log('LIST-WIDGET notified ' + SITES.sites.length);
        return updateWidget(LISTWIDGET);
    });
    MAP = new MapWidget(SITES, jQuery('#map-canvas'), DEFAULTCENTER, DEFAULTZOOM, GEOLOCATIONOPTIONS);
    sitesSubscribeToPopulated(SITES, function () {
        console.log('MAP notified ' + SITES.sites.length);
        return updateWidget(MAP);
    });
    mapWidgetStartUpdatingMarkers(MAP);
    return mapWidgetStartGeolocation(MAP);
};
