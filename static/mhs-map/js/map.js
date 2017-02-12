var SITELIST = null;
var LISTWIDGET = null;
var MAP = null;
function setMapAreaMode() {
    __setf_siteListStName(jQuery('#mhs-st-name-input').val(), SITELIST);
    __setf_siteListSndNoP(jQuery('#mhs-snd-no-p-input').val(), SITELIST);
    __setf_siteListSpdNoP(jQuery('#mhs-spd-no-p-input').val(), SITELIST);
    __setf_siteListSmdNoP(jQuery('#mhs-smd-no-p-input').val(), SITELIST);
    __setf_siteListKeyword1(jQuery('#mhs-keyword1-input').val(), SITELIST);
    __setf_siteListOp2(jQuery('#mhs-op2-input').val(), SITELIST);
    __setf_siteListKeyword2(jQuery('#mhs-keyword2-input').val(), SITELIST);
    __setf_siteListOp3(jQuery('#mhs-op3-input').val(), SITELIST);
    __setf_siteListKeyword3(jQuery('#mhs-keyword3-input').val(), SITELIST);
    __setf_siteListMode('map-area', SITELIST);
    __setf_mapWidgetCenter(DEFAULTCENTER, MAP);
    return __setf_mapWidgetZoom(DEFAULTZOOM, MAP);
};
function setGeolocationMode(distance) {
    __setf_siteListStName(jQuery('#mhs-st-name-input').val(), SITELIST);
    __setf_siteListSndNoP(jQuery('#mhs-snd-no-p-input').val(), SITELIST);
    __setf_siteListSpdNoP(jQuery('#mhs-spd-no-p-input').val(), SITELIST);
    __setf_siteListSmdNoP(jQuery('#mhs-smd-no-p-input').val(), SITELIST);
    __setf_siteListKeyword1(jQuery('#mhs-keyword1-input').val(), SITELIST);
    __setf_siteListOp2(jQuery('#mhs-op2-input').val(), SITELIST);
    __setf_siteListKeyword2(jQuery('#mhs-keyword2-input').val(), SITELIST);
    __setf_siteListOp3(jQuery('#mhs-op3-input').val(), SITELIST);
    __setf_siteListKeyword3(jQuery('#mhs-keyword3-input').val(), SITELIST);
    __setf_mapWidgetRecenterP(true, MAP);
    __setf_siteListMode('geolocation', SITELIST);
    __setf_siteListCenterDistance({ 'center' : new google.maps.LatLng(0, 0), 'distance' : distance }, SITELIST);
    return __setf_mapWidgetZoom(8, MAP);
};
function setMunicipalityMode(mName) {
    __setf_siteListStName(jQuery('#mhs-st-name-input').val(), SITELIST);
    __setf_siteListSndNoP(jQuery('#mhs-snd-no-p-input').val(), SITELIST);
    __setf_siteListSpdNoP(jQuery('#mhs-spd-no-p-input').val(), SITELIST);
    __setf_siteListSmdNoP(jQuery('#mhs-smd-no-p-input').val(), SITELIST);
    __setf_siteListKeyword1(jQuery('#mhs-keyword1-input').val(), SITELIST);
    __setf_siteListOp2(jQuery('#mhs-op2-input').val(), SITELIST);
    __setf_siteListKeyword2(jQuery('#mhs-keyword2-input').val(), SITELIST);
    __setf_siteListOp3(jQuery('#mhs-op3-input').val(), SITELIST);
    __setf_siteListKeyword3(jQuery('#mhs-keyword3-input').val(), SITELIST);
    __setf_mapWidgetRecenterP(true, MAP);
    __setf_siteListMode('municipality', SITELIST);
    __setf_siteListMName(mName, SITELIST);
    return __setf_mapWidgetZoom(8, MAP);
};
function initialize() {
    SITELIST = new SiteList(FEATURESURI);
    jQuery('#mhs-update-map-btn').click(function () {
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
        return __setf_siteListBounds(mapWidgetBounds(mapWidget), SITELIST);
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
