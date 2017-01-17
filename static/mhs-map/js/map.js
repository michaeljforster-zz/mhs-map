var SITELIST = null;
var LISTWIDGET = null;
var MAP = null;
function setMapAreaMode() {
    __setf_siteListMode('map-area', SITELIST);
    return __setf_siteListMunicipalityName('', SITELIST);
};
function setMunicipalityMode(municipalityName) {
    __setf_mapWidgetRecenterP(true, MAP);
    __setf_siteListMode('municipality', SITELIST);
    return __setf_siteListMunicipalityName(municipalityName, SITELIST);
};
function initialize() {
    jQuery('#mhs-show-map-btn').click(function (e) {
        jQuery('#mhs-map-widget').removeClass('hidden');
        return jQuery('#mhs-list-widget').addClass('hidden');
    });
    jQuery('#mhs-show-list-btn').click(function (e) {
        jQuery('#mhs-map-widget').addClass('hidden');
        return jQuery('#mhs-list-widget').removeClass('hidden');
    });
    SITELIST = new SiteList(FEATURESURI);
    LISTWIDGET = new ListWidget(SITELIST, jQuery('#mhs-list-widget'));
    siteListSubscribeToPopulated(SITELIST, function () {
        console.log('LIST-WIDGET notified ' + siteListSize(SITELIST));
        return updateWidget(LISTWIDGET);
    });
    MAP = new MapWidget(SITELIST, jQuery('#mhs-map-widget'), DEFAULTCENTER, DEFAULTZOOM, GEOLOCATIONOPTIONS);
    siteListSubscribeToPopulated(SITELIST, function () {
        console.log('MAP notified ' + siteListSize(SITELIST));
        return updateWidget(MAP);
    });
    return mapWidgetListenOnIdle(MAP, function (mapWidget) {
        return __setf_siteListBounds(mapWidgetBounds(mapWidget), SITELIST);
    });
};
