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
    this.stName = '';
    this.sndNoP = false;
    this.spdNoP = false;
    this.smdNoP = false;
    this.keyword1 = '';
    this.op2 = 'and';
    this.keyword2 = '';
    this.op3 = 'and';
    this.keyword3 = '';
    this.mode = 'map-area';
    this.bounds = new google.maps.LatLngBounds(0, 0, 0, 0);
    this.centerDistance = { 'center' : new google.maps.LatLng(0, 0), 'distance' : 0 };
    this.mName = '';
    this.centroid = null;
    this.sites = [];
    this.subscribers = [];
    return this;
};
function siteListStName(siteList) {
    return siteList.stName;
};
function __setf_siteListStName(newStName, siteList) {
    return siteList.stName = newStName;
};
function siteListSndNoP(siteList) {
    return siteList.sndNoP;
};
function __setf_siteListSndNoP(newSndNoP, siteList) {
    return siteList.sndNoP = newSndNoP;
};
function siteListSpdNoP(siteList) {
    return siteList.spdNoP;
};
function __setf_siteListSpdNoP(newSpdNoP, siteList) {
    return siteList.spdNoP = newSpdNoP;
};
function siteListSmdNoP(siteList) {
    return siteList.smdNoP;
};
function __setf_siteListSmdNoP(newSmdNoP, siteList) {
    return siteList.smdNoP = newSmdNoP;
};
function siteListKeyword1(siteList) {
    return siteList.keyword1;
};
function __setf_siteListKeyword1(newKeyword1, siteList) {
    return siteList.keyword1 = newKeyword1;
};
function siteListOp2(siteList) {
    return siteList.op2;
};
function __setf_siteListOp2(newOp2, siteList) {
    return siteList.op2 = newOp2;
};
function siteListKeyword2(siteList) {
    return siteList.keyword2;
};
function __setf_siteListKeyword2(newKeyword2, siteList) {
    return siteList.keyword2 = newKeyword2;
};
function siteListOp3(siteList) {
    return siteList.op3;
};
function __setf_siteListOp3(newOp3, siteList) {
    return siteList.op3 = newOp3;
};
function siteListKeyword3(siteList) {
    return siteList.keyword3;
};
function __setf_siteListKeyword3(newKeyword3, siteList) {
    return siteList.keyword3 = newKeyword3;
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
function siteListMName(siteList) {
    return siteList.mName;
};
function __setf_siteListMName(newMName, siteList) {
    siteList.mName = newMName;
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
        var prevMv46 = 'undefined' === typeof __PS_MV_REG ? (__PS_MV_REG = undefined) : __PS_MV_REG;
        try {
            var south = decodeBounds(siteList.bounds);
            var _db47 = decodeBounds === __PS_MV_REG['tag'] ? __PS_MV_REG['values'] : [];
            var west = _db47[0];
            var north = _db47[1];
            var east = _db47[2];
            return siteList.url + '?south=' + south + '&west=' + west + '&north=' + north + '&east=' + east + '&st-name=' + siteList.stName + (siteList.sndNoP ? '&snd-no-p=t' : '') + (siteList.spdNoP ? '&spd-no-p=t' : '') + (siteList.smdNoP ? '&smd-no-p=t' : '') + '&keyword1=' + siteList.keyword1 + '&op2=' + siteList.op2 + '&keyword2=' + siteList.keyword2 + '&op3=' + siteList.op3 + '&keyword3=' + siteList.keyword3;
        } finally {
            __PS_MV_REG = prevMv46;
        };
    case 'geolocation':
        var lat48 = siteList.centerDistance.center.lat();
        var lng49 = siteList.centerDistance.center.lng();
        var distance50 = siteList.centerDistance.distance;
        return siteList.url + '?lat=' + lat48 + '&lng=' + lng49 + '&distance=' + distance50 + '&st-name=' + siteList.stName + (siteList.sndNoP ? '&snd-no-p=t' : '') + (siteList.spdNoP ? '&spd-no-p=t' : '') + (siteList.smdNoP ? '&smd-no-p=t' : '') + '&keyword1=' + siteList.keyword1 + '&op2=' + siteList.op2 + '&keyword2=' + siteList.keyword2 + '&op3=' + siteList.op3 + '&keyword3=' + siteList.keyword3;
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
    return xhrGetJson(percenturl(siteList), function (results) {
        siteList.centroid = results.centroid == null ? null : geometryPointToLatLng(results.centroid.geometry);
        siteList.sites = results.sites.features.map(function (feature) {
            return featureToSite(feature);
        });
        return percentannouncePopulated(siteList);
    });
};
