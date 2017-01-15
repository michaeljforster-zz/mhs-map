var SITELIST = null;
var LISTWIDGET = null;
var MAP = null;
function setMapAreaMode() {
    mapWidgetListenOnIdle(MAP, function (mapWidget) {
        var prevMv6 = 'undefined' === typeof __PS_MV_REG ? (__PS_MV_REG = undefined) : __PS_MV_REG;
        try {
            var south = decodeBounds(mapWidgetBounds(mapWidget));
            var _db7 = decodeBounds === __PS_MV_REG['tag'] ? __PS_MV_REG['values'] : [];
            var west = _db7[0];
            var north = _db7[1];
            var east = _db7[2];
            return xhrGetJson(FEATURESWITHINBOUNDSURI + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east, function (results) {
                return siteListPopulate(mapWidget.model, results.features);
            });
        } finally {
            __PS_MV_REG = prevMv6;
        };
    });
    MAP.googleMap.setZoom(DEFAULTZOOM);
    return MAP.googleMap.panTo(DEFAULTCENTER);
};
function setMunicipalityMode() {
    mapWidgetListenOnIdle(MAP, function (mapWidget) {
        var municipalityName = 'Winnipeg';
        var municipality = { 'mName' : municipalityName,
                             'mLat' : 49.89024330998252,
                             'mLng' : -97.1446768914188
                           };
        xhrGetJson(FEATURESBYMUNICIPALITYURI + '?municipality=' + municipality.mName, function (results) {
            return siteListPopulate(mapWidget.model, results.features);
        });
        return mapWidget.googleMap.panTo(new google.maps.LatLng({ 'lat' : municipality.mLat, 'lng' : municipality.mLng }));
    });
    var municipalityName = 'Winnipeg';
    var municipality = { 'mName' : municipalityName,
                         'mLat' : 49.89024330998252,
                         'mLng' : -97.1446768914188
                       };
    MAP.googleMap.setZoom(11);
    return MAP.googleMap.panTo(new google.maps.LatLng({ 'lat' : municipality.mLat, 'lng' : municipality.mLng }));
};
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
    SITELIST = new SiteList();
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
    return setMapAreaMode();
};
