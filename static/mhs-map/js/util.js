function xhrGetJson(url, successFunction) {
    return jQuery.getJSON(url, successFunction).fail(function (jqXHR, textStatus, errorThrown) {
        return alert('Error: ' + textStatus);
    });
};
function decodeBounds(bounds) {
    var southWest = bounds.getSouthWest();
    var northEast = bounds.getNorthEast();
    var south = southWest.lat();
    var west = southWest.lng();
    var north = northEast.lat();
    var east = northEast.lng();
    __PS_MV_REG = { 'tag' : arguments.callee, 'values' : [west, north, east] };
    return south;
};
function geometryPointX(geometry) {
    if (geometry.type !== 'Point') {
        throw 'Geometry is not a Point';
    } else {
        return geometry.coordinates[0];
    };
};
function geometryPointY(geometry) {
    if (geometry.type !== 'Point') {
        throw 'Geometry is not a Point';
    } else {
        return geometry.coordinates[1];
    };
};
function geometryPointToLatLng(geometry) {
    return new google.maps.LatLng({ 'lat' : geometryPointY(geometry), 'lng' : geometryPointX(geometry) });
};
function featureToSite(feature) {
    return new Site(feature.properties.sNo, feature.properties.sName, feature.properties.mName, feature.properties.sAddress, feature.properties.stName, feature.properties.sUrl, geometryPointToLatLng(feature.geometry));
};
