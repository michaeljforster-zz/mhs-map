var SITELIST = null;
var LISTWIDGET = null;
var MAP = null;
function setMapAreaMode() {
    __setf_siteListMode('map-area', SITELIST);
    __setf_mapWidgetCenter(DEFAULTCENTER, MAP);
    return __setf_mapWidgetZoom(DEFAULTZOOM, MAP);
};
function setGeolocationMode(distance) {
    __setf_mapWidgetRecenterP(true, MAP);
    __setf_siteListMode('geolocation', SITELIST);
    __setf_siteListCenterDistance({ 'center' : new google.maps.LatLng(0, 0), 'distance' : distance }, SITELIST);
    return __setf_mapWidgetZoom(8, MAP);
};
function setMunicipalityMode(municipalityName) {
    __setf_mapWidgetRecenterP(true, MAP);
    __setf_siteListMode('municipality', SITELIST);
    __setf_siteListMunicipalityName(municipalityName, SITELIST);
    return __setf_mapWidgetZoom(8, MAP);
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
    jQuery('#mhs-filter-within-input').on('changed.bs.select', function (e) {
        var within = jQuery('#mhs-filter-within-input').val();
        switch (within) {
        case 'map-area':
            return setMapAreaMode();
        case '100':
        case '1000':
        case '10000':
        case '100000':
        case '1000000':
            return setGeolocationMode(parseInt(within));
        default:
            return setMunicipalityMode(within);
        };
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
