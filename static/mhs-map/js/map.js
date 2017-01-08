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
function featureToSite(feature) {
    var site = new Site();
    site.sNo = feature.properties.sNo;
    site.sName = feature.properties.sName;
    site.mName = feature.properties.mName;
    site.sAddress = feature.properties.sAddress;
    site.stName = feature.properties.stName;
    site.sUrl = feature.properties.sUrl;
    site.latLng = new google.maps.LatLng({ 'lat' : feature.geometry.coordinates[1], 'lng' : feature.geometry.coordinates[0] });
    return site;
};
function Sites(url) {
    this.url = url;
    this.sites = [];
    this.subscribers = [];
    this.forEach = function (fn) {
        return this.sites.forEach(fn);
    };
    this.map = function (fn) {
        return this.sites.map(fn);
    };
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
function sitesPopulate(sites) {
    return xhrGetJson(sites.url, function (results) {
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
function ListWidget(model, jqobject) {
    this.model = model;
    this.jqobject = jqobject;
    this.updateWidget = function () {
        this.jqobject.empty();
        return this.jqobject.html(['<UL>', this.model.map(function (site) {
            return ['<LI>', site.sNo + ' - ' + site.sName, '</LI>'].join('');
        }).join(''), '</UL>'].join(''));
    };
    return this;
};
function Map(model, element, center, zoom, geolocationOptions) {
    this.model = model;
    this.markers = [];
    this.siteInfoWindow = new google.maps.InfoWindow({  });
    this.map = new google.maps.Map(element, { 'center' : center, 'zoom' : zoom });
    return this;
};
function siteIconUri(site) {
    var stName298 = site.stName;
    if (stName298 === 'Featured site') {
        return 'icon_feature.png';
    } else if (stName298 === 'Museum/Archives') {
        return 'icon_museum.png';
    } else if (stName298 === 'Building') {
        return 'icon_building.png';
    } else if (stName298 === 'Monument') {
        return 'icon_monument.png';
    } else if (stName298 === 'Cemetery') {
        return 'icon_cemetery.png';
    } else if (stName298 === 'Location') {
        return 'icon_location.png';
    } else if (stName298 === 'Other') {
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
    var sAddress299 = site.sAddress;
    return site.sName + ', ' + site.mName + (sAddress299 === '' ? '' : ', ' + sAddress299);
};
function siteLinkUrl(site) {
    return MHSBASEURI + site.sUrl;
};
function mapAddMarker(map, site) {
    var marker = new google.maps.Marker({ 'position' : site.latLng,
                                          'icon' : siteMarkerIcon(site),
                                          'title' : site.sName,
                                          'map' : map.map
                                        });
    var content = ['<DIV CLASS="site-info-window-content-box"><DIV CLASS="site-info-window-site-name-box"><A CLASS="site-info-window-site-link" HREF="', siteLinkUrl(site), '" TARGET="_blank">', siteLinkTitle(site), '</A></DIV></DIV>'].join('');
    google.maps.event.addListener(marker, 'click', function (event) {
        map.siteInfoWindow.setContent(content);
        return map.siteInfoWindow.open(map.map, marker);
    });
    return map.markers.push(marker);
};
function mapDeleteMarkers(map) {
    for (var marker = null, _js_arrvar301 = map.markers, _js_idx300 = 0; _js_idx300 < _js_arrvar301.length; _js_idx300 += 1) {
        marker = _js_arrvar301[_js_idx300];
        marker.setMap(null);
    };
    return map.markers.length = 0;
};
function mapAddMarkers(map) {
    return map.model.forEach(function (site) {
        return mapAddMarker(map, site);
    });
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
    SITES = new Sites('http://127.0.0.1:4242/mhs-map/features.json?west=49.620877447334585&south=-100.59589233398435&east=50.09805541906053&north=-99.2802795410156');
    LISTWIDGET = new ListWidget(SITES, jQuery('#list-view'));
    sitesSubscribeToPopulated(SITES, function () {
        console.log('LIST-WIDGET notified ' + SITES.sites.length);
        return updateWidget(LISTWIDGET);
    });
    MAP = new Map(SITES, jQuery('#map-canvas')[0], CURRENTCENTER, CURRENTZOOM, GEOLOCATIONOPTIONS);
    sitesSubscribeToPopulated(SITES, function () {
        console.log('MAP notified ' + SITES.sites.length);
        mapDeleteMarkers(MAP);
        return mapAddMarkers(MAP);
    });
    return sitesPopulate(SITES);
};
