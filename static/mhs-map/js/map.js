var SITELIST = null;
var LISTWIDGET = null;
var MAP = null;
function setMapAreaMode() {
    setSiteListMapAreaMode(SITELIST);
    var designations = jQuery('#mhs-designation-input').val();
    updateSiteListParameters(SITELIST, jQuery('#mhs-st-name-input').val(), designations.includes('National'), designations.includes('Provincial'), designations.includes('Municipal'), jQuery('#mhs-keyword1-input').val(), jQuery('#mhs-op2-input').val(), jQuery('#mhs-keyword2-input').val(), jQuery('#mhs-op3-input').val(), jQuery('#mhs-keyword3-input').val());
    __setf_mapWidgetCenter(DEFAULTCENTER, MAP);
    __setf_mapWidgetZoom(DEFAULTZOOM, MAP);
    return updateSiteListBounds(SITELIST, mapWidgetBounds(MAP));
};
function setGeolocationMode(distance) {
    setSiteListGeolocationMode(SITELIST);
    var designations = jQuery('#mhs-designation-input').val();
    updateSiteListParameters(SITELIST, jQuery('#mhs-st-name-input').val(), designations.includes('National'), designations.includes('Provincial'), designations.includes('Municipal'), jQuery('#mhs-keyword1-input').val(), jQuery('#mhs-op2-input').val(), jQuery('#mhs-keyword2-input').val(), jQuery('#mhs-op3-input').val(), jQuery('#mhs-keyword3-input').val());
    __setf_mapWidgetZoom(8, MAP);
    return updateSiteListCenterDistance(SITELIST, makeCenterDistance(0, 0, distance));
};
function setMunicipalityMode(mName) {
    setSiteListMunicipalityMode(SITELIST);
    var designations = jQuery('#mhs-designation-input').val();
    updateSiteListParameters(SITELIST, jQuery('#mhs-st-name-input').val(), designations.includes('National'), designations.includes('Provincial'), designations.includes('Municipal'), jQuery('#mhs-keyword1-input').val(), jQuery('#mhs-op2-input').val(), jQuery('#mhs-keyword2-input').val(), jQuery('#mhs-op3-input').val(), jQuery('#mhs-keyword3-input').val());
    __setf_mapWidgetRecenterP(true, MAP);
    __setf_mapWidgetZoom(8, MAP);
    return updateSiteListMName(SITELIST, mName);
};
function initialize() {
    SITELIST = new SiteList(FEATURESURI);
    jQuery('#mhs-update-map-btn').click(function (e) {
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
    mapWidgetListenOnIdle(MAP, function (mapWidget) {
        return updateSiteListBounds(SITELIST, mapWidgetBounds(mapWidget));
    });
    jQuery(window).resize(function () {
        jQuery('#mhs-search-tab').toggleClass('active', true);
        jQuery('#mhs-list-tab').toggleClass('active', false);
        jQuery('#mhs-map-tab').toggleClass('active', false);
        jQuery('#mhs-search-col').toggleClass('invisible', false);
        jQuery('#mhs-list-col').toggleClass('invisible', false);
        return jQuery('#mhs-map-col').toggleClass('invisible', false);
    });
    jQuery('#mhs-search-btn').click(function () {
        jQuery('#mhs-search-tab').toggleClass('active', true);
        jQuery('#mhs-list-tab').toggleClass('active', false);
        jQuery('#mhs-map-tab').toggleClass('active', false);
        jQuery('#mhs-search-col').toggleClass('invisible', false);
        jQuery('#mhs-list-col').toggleClass('invisible', true);
        return jQuery('#mhs-map-col').toggleClass('invisible', true);
    });
    jQuery('#mhs-list-btn').click(function () {
        jQuery('#mhs-search-tab').toggleClass('active', false);
        jQuery('#mhs-list-tab').toggleClass('active', true);
        jQuery('#mhs-map-tab').toggleClass('active', false);
        jQuery('#mhs-search-col').toggleClass('invisible', true);
        jQuery('#mhs-list-col').toggleClass('invisible', false);
        return jQuery('#mhs-map-col').toggleClass('invisible', true);
    });
    return jQuery('#mhs-map-btn').click(function () {
        jQuery('#mhs-search-tab').toggleClass('active', false);
        jQuery('#mhs-list-tab').toggleClass('active', false);
        jQuery('#mhs-map-tab').toggleClass('active', true);
        jQuery('#mhs-search-col').toggleClass('invisible', true);
        jQuery('#mhs-list-col').toggleClass('invisible', true);
        return jQuery('#mhs-map-col').toggleClass('invisible', false);
    });
};
