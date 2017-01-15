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
function SiteList(url) {
    this.url = url;
    this.sites = [];
    this.subscribers = [];
    return this;
};
function siteListSize(siteList) {
    return siteList.sites.length;
};
function siteListMap(siteList, fn) {
    return siteList.sites.map(fn);
};
function siteListDo(siteList, fn) {
    return siteList.sites.forEach(fn);
};
function siteListUnsubscribeAll(siteList) {
    siteList.subscribers = [];
    return siteList;
};
function siteListSubscribeToPopulated(siteList, fn) {
    siteList.subscribers.push(fn);
    return siteList;
};
function siteListAnnouncePopulated(siteList) {
    siteList.subscribers.forEach(function (element) {
        return element();
    });
    return siteList;
};
function siteListPopulate(siteList, features) {
    siteList.sites = [];
    for (var feature = null, _js_idx205 = 0; _js_idx205 < features.length; _js_idx205 += 1) {
        feature = features[_js_idx205];
        siteList.sites.push(featureToSite(feature));
    };
    siteListAnnouncePopulated(siteList);
    return siteList;
};
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
    var stName206 = site.stName;
    if (stName206 === 'Featured site') {
        return 'icon_feature.png';
    } else if (stName206 === 'Museum/Archives') {
        return 'icon_museum.png';
    } else if (stName206 === 'Building') {
        return 'icon_building.png';
    } else if (stName206 === 'Monument') {
        return 'icon_monument.png';
    } else if (stName206 === 'Cemetery') {
        return 'icon_cemetery.png';
    } else if (stName206 === 'Location') {
        return 'icon_location.png';
    } else if (stName206 === 'Other') {
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
    var sAddress207 = site.sAddress;
    return site.sName + ', ' + site.mName + (sAddress207 === '' ? '' : ', ' + sAddress207);
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
    this.updateWidget = (function () {
        for (var marker = null, _js_arrvar209 = this.markers, _js_idx208 = 0; _js_idx208 < _js_arrvar209.length; _js_idx208 += 1) {
            marker = _js_arrvar209[_js_idx208];
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
    return mapWidget.googleMap.addListener('idle', function (event) {
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
var SITELIST = null;
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
    SITELIST = new SiteList(FEATURESWITHINBOUNDSURI);
    LISTWIDGET = new ListWidget(SITELIST, jQuery('#list-view'));
    siteListSubscribeToPopulated(SITELIST, function () {
        console.log('LIST-WIDGET notified ' + siteListSize(SITELIST));
        return updateWidget(LISTWIDGET);
    });
    MAP = new MapWidget(SITELIST, jQuery('#map-canvas'), DEFAULTCENTER, DEFAULTZOOM, GEOLOCATIONOPTIONS);
    siteListSubscribeToPopulated(SITELIST, function () {
        console.log('MAP notified ' + siteListSize(SITELIST));
        return updateWidget(MAP);
    });
    return mapWidgetListenOnIdle(MAP, function (mapWidget) {
        var prevMv210 = 'undefined' === typeof __PS_MV_REG ? (__PS_MV_REG = undefined) : __PS_MV_REG;
        try {
            var south = decodeBounds(mapWidgetBounds(mapWidget));
            var _db211 = decodeBounds === __PS_MV_REG['tag'] ? __PS_MV_REG['values'] : [];
            var west = _db211[0];
            var north = _db211[1];
            var east = _db211[2];
            return xhrGetJson(mapWidget.model.url + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east, function (results) {
                return siteListPopulate(mapWidget.model, results.features);
            });
        } finally {
            __PS_MV_REG = prevMv210;
        };
    });
};
