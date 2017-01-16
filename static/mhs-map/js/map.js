var SITELIST = null;
var LISTWIDGET = null;
var MAP = null;
function setMapAreaMode() {
    mapWidgetListenOnIdle(MAP, function (mapWidget) {
        return __setf_siteListBounds(mapWidgetBounds(mapWidget), SITELIST);
    });
    MAP.googleMap.setZoom(DEFAULTZOOM);
    return MAP.googleMap.panTo(DEFAULTCENTER);
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
    SITELIST = new SiteList(FEATURESURI);
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
