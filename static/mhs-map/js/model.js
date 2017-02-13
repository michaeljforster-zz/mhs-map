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
var DEFAULTBOUNDS = new google.maps.LatLngBounds(0, 0, 0, 0);
function makeCenterDistance(lat, lng, distance) {
    return { 'center' : new google.maps.LatLng(lat, lng), 'distance' : distance };
};
var DEFAULTCENTERDISTANCE = makeCenterDistance(0, 0, 0);
function SiteList(url) {
    this.url = url;
    this.mode = 'map-area';
    this.bounds = DEFAULTBOUNDS;
    this.centerDistance = DEFAULTCENTERDISTANCE;
    this.mName = '';
    this.stName = '';
    this.sndNoP = false;
    this.spdNoP = false;
    this.smdNoP = false;
    this.keyword1 = '';
    this.op2 = 'and';
    this.keyword2 = '';
    this.op3 = 'and';
    this.keyword3 = '';
    this.centroid = null;
    this.sites = [];
    this.subscribers = [];
    return this;
};
function percenturl(siteList) {
    switch (siteList.mode) {
    case 'map-area':
        var prevMv433 = 'undefined' === typeof __PS_MV_REG ? (__PS_MV_REG = undefined) : __PS_MV_REG;
        try {
            var south = decodeBounds(siteList.bounds);
            var _db434 = decodeBounds === __PS_MV_REG['tag'] ? __PS_MV_REG['values'] : [];
            var west = _db434[0];
            var north = _db434[1];
            var east = _db434[2];
            return siteList.url + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east + '&st-name=' + siteList.stName + (siteList.sndNoP ? '&snd-no-p=t' : '') + (siteList.spdNoP ? '&spd-no-p=t' : '') + (siteList.smdNoP ? '&smd-no-p=t' : '') + '&keyword1=' + siteList.keyword1 + '&op2=' + siteList.op2 + '&keyword2=' + siteList.keyword2 + '&op3=' + siteList.op3 + '&keyword3=' + siteList.keyword3;
        } finally {
            __PS_MV_REG = prevMv433;
        };
    case 'geolocation':
        var lat435 = siteList.centerDistance.center.lat();
        var lng436 = siteList.centerDistance.center.lng();
        var distance437 = siteList.centerDistance.distance;
        return siteList.url + '?lat=' + lat435 + '&lng=' + lng436 + '&distance=' + distance437 + '&st-name=' + siteList.stName + (siteList.sndNoP ? '&snd-no-p=t' : '') + (siteList.spdNoP ? '&spd-no-p=t' : '') + (siteList.smdNoP ? '&smd-no-p=t' : '') + '&keyword1=' + siteList.keyword1 + '&op2=' + siteList.op2 + '&keyword2=' + siteList.keyword2 + '&op3=' + siteList.op3 + '&keyword3=' + siteList.keyword3;
    case 'municipality':
        return siteList.url + '?m-name=' + siteList.mName + '&st-name=' + siteList.stName + (siteList.sndNoP ? '&snd-no-p=t' : '') + (siteList.spdNoP ? '&spd-no-p=t' : '') + (siteList.smdNoP ? '&smd-no-p=t' : '') + '&keyword1=' + siteList.keyword1 + '&op2=' + siteList.op2 + '&keyword2=' + siteList.keyword2 + '&op3=' + siteList.op3 + '&keyword3=' + siteList.keyword3;
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
    var url = percenturl(SITELIST);
    return xhrGetJson(percenturl(siteList), function (results) {
        siteList.centroid = results.centroid == null ? null : geometryPointToLatLng(results.centroid.geometry);
        siteList.sites = results.sites.features.map(function (feature) {
            return featureToSite(feature);
        });
        return percentannouncePopulated(siteList);
    });
};
function setSiteListMapAreaMode(siteList) {
    siteList.mode = 'map-area';
    this.bounds = DEFAULTBOUNDS;
    this.centerDistance = DEFAULTCENTERDISTANCE;
    return siteList.mName = '';
};
function setSiteListGeolocationMode(siteList) {
    siteList.mode = 'geolocation';
    this.bounds = DEFAULTBOUNDS;
    this.centerDistance = DEFAULTCENTERDISTANCE;
    return siteList.mName = '';
};
function setSiteListMunicipalityMode(siteList) {
    siteList.mode = 'municipality';
    this.bounds = DEFAULTBOUNDS;
    this.centerDistance = DEFAULTCENTERDISTANCE;
    return siteList.mName = '';
};
function updateSiteListBounds(siteList, bounds) {
    siteList.bounds = bounds;
    return percentpopulate(siteList);
};
function updateSiteListCenterDistance(siteList, centerDistance) {
    siteList.centerDistance = centerDistance;
    return percentpopulate(siteList);
};
function updateSiteListMName(siteList, mName) {
    siteList.mName = mName;
    return percentpopulate(siteList);
};
function updateSiteListParameters(siteList, stName, sndNoP, spdNoP, smdNoP, keyword1, op2, keyword2, op3, keyword3) {
    siteList.stName = stName;
    siteList.sndNoP = sndNoP;
    siteList.spdNoP = spdNoP;
    siteList.smdNoP = smdNoP;
    siteList.keyword1 = keyword1;
    siteList.op2 = op2;
    siteList.keyword2 = keyword2;
    siteList.op3 = op3;
    return siteList.keyword3 = keyword3;
};
function siteListCentroid(siteList) {
    return siteList.centroid;
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
