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
function SiteList(url) {
    this.url = url;
    this.mode = 'map-area';
    this.bounds = new google.maps.LatLngBounds(0, 0, 0, 0);
    this.centerDistance = { 'center' : new google.maps.LatLng(0, 0), 'distance' : 0 };
    this.municipalityName = '';
    this.centroid = null;
    this.sites = [];
    this.subscribers = [];
    return this;
};
function siteListMode(siteList) {
    return siteList.mode;
};
function __setf_siteListMode(newMode, siteList) {
    return siteList.mode = newMode;
};
function siteListBounds(siteList) {
    return siteList.bounds;
};
function __setf_siteListBounds(newBounds, siteList) {
    siteList.bounds = newBounds;
    return percentpopulate(siteList);
};
function siteListCentroid(siteList) {
    return siteList.centroid;
};
function siteListCenterDistance(siteList) {
    return siteList.centerDistance;
};
function __setf_siteListCenterDistance(newCenterDistance, siteList) {
    siteList.centerDistance = newCenterDistance;
    return percentpopulate(siteList);
};
function siteListMunicipalityName(siteList) {
    return siteList.municipalityName;
};
function __setf_siteListMunicipalityName(newMunicipalityName, siteList) {
    siteList.municipalityName = newMunicipalityName;
    return percentpopulate(siteList);
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
function siteListSubscribeToPopulated(siteList, fn) {
    siteList.subscribers.push(fn);
    return siteList;
};
function siteListUnsubscribeAll(siteList) {
    siteList.subscribers = [];
    return siteList;
};
function percenturl(siteList) {
    switch (siteList.mode) {
    case 'map-area':
        var prevMv694 = 'undefined' === typeof __PS_MV_REG ? (__PS_MV_REG = undefined) : __PS_MV_REG;
        try {
            var south = decodeBounds(siteList.bounds);
            var _db695 = decodeBounds === __PS_MV_REG['tag'] ? __PS_MV_REG['values'] : [];
            var west = _db695[0];
            var north = _db695[1];
            var east = _db695[2];
            return siteList.url + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east;
        } finally {
            __PS_MV_REG = prevMv694;
        };
    case 'geolocation':
        var lat696 = siteList.centerDistance.center.lat();
        var lng697 = siteList.centerDistance.center.lng();
        var distance698 = siteList.centerDistance.distance;
        return siteList.url + '?lat=' + '&lng=' + '&distance=';
    case 'municipality':
        return siteList.url + '?municipality-name=' + siteList.municipalityName;
    default:
        throw siteList.mode + ' fell through CASE expression.';
    };
};
function percentannouncePopulated(siteList) {
    return siteList.subscribers.forEach(function (element) {
        return element();
    });
};
function percentpopulate(siteList) {
    return xhrGetJson(percenturl(siteList), function (results) {
        siteList.centroid = results.centroid == null ? null : geometryPointToLatLng(results.centroid.geometry);
        siteList.sites = results.sites.features.map(function (feature) {
            return featureToSite(feature);
        });
        return percentannouncePopulated(siteList);
    });
};
