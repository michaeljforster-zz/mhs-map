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
function SiteList() {
    this.sites = [];
    this.subscribers = [];
    return this;
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
function siteListUnsubscribeAll(siteList) {
    siteList.subscribers = [];
    return siteList;
};
function siteListSubscribeToPopulated(siteList, fn) {
    siteList.subscribers.push(fn);
    return siteList;
};
function siteListAnnouncePopulated(siteList) {
    siteList.subscribers.forEach(function (element) {
        return element();
    });
    return siteList;
};
function siteListPopulate(siteList, features) {
    siteList.sites = [];
    for (var feature = null, _js_idx1 = 0; _js_idx1 < features.length; _js_idx1 += 1) {
        feature = features[_js_idx1];
        siteList.sites.push(featureToSite(feature));
    };
    siteListAnnouncePopulated(siteList);
    return siteList;
};
