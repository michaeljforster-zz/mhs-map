function xhrGetJson(url, successFunction) {
    return jQuery.getJSON(url, successFunction).fail(function (jqXHR, textStatus, errorThrown) {
        return alert('Error: ' + textStatus);
    });
};
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
function featureToSite(feature) {
    var site = new Site();
    site.sNo = feature.properties.sNo;
    site.sName = feature.properties.sName;
    site.mName = feature.properties.mName;
    site.sAddress = feature.properties.sAddress;
    site.stName = feature.properties.stName;
    site.sUrl = feature.properties.sUrl;
    site.latLng = new google.maps.LatLng({ 'lat' : feature.geometry.coordinates[1], 'lng' : feature.geometry.coordinates[0] });
    return site;
};
function Sites(url) {
    this.url = url;
    this.sites = [];
    this.subscribers = [];
    this.forEach = function (fn) {
        return this.sites.forEach(fn);
    };
    this.map = function (fn) {
        return this.sites.map(fn);
    };
    return this;
};
function unsubscribeAll(sites) {
    this.subscribers = [];
    return sites;
};
function subscribeToPopulated(sites, fn) {
    sites.subscribers.push(fn);
    return sites;
};
function announcePopulated(sites) {
    sites.subscribers.forEach(function (element) {
        return element(sites);
    });
    return sites;
};
function populate(sites) {
    return xhrGetJson(sites.url, function (results) {
        sites.sites = [];
        results.features.forEach(function (feature) {
            return sites.sites.push(featureToSite(feature));
        });
        announcePopulated(sites);
        return sites;
    });
};
function render(widget, jqobject) {
    return widget.render(jqobject);
};
function ListWidget(model) {
    this.model = model;
    this.render = function (jqobject) {
        jqobject.empty();
        return jqobject.html(['<UL>', this.model.map(function (site) {
            return ['<LI>', site.sNo + ' - ' + site.sName, '</LI>'].join('');
        }).join(''), '</UL>'].join(''));
    };
    return this;
};
function initialize() {
    jQuery('#list-view').show();
    jQuery('#map-canvas').hide();
    jQuery('#list-button').click(function () {
        jQuery('#list-view').show();
        return jQuery('#map-canvas').hide();
    });
    jQuery('#map-button').click(function () {
        jQuery('#list-view').hide();
        return jQuery('#map-canvas').show();
    });
    var SITES = new Sites('http://127.0.0.1:4242/mhs-map/features.json?west=49.620877447334585&south=-100.59589233398435&east=50.09805541906053&north=-99.2802795410156');
    var LISTWIDGET = new ListWidget(SITES);
    subscribeToPopulated(SITES, function (sites) {
        return render(LISTWIDGET, jQuery('#list-view'));
    });
    return populate(SITES);
};
