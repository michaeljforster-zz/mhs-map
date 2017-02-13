# PLAN for mhs-map


* Locally:
  (push #p"/Users/mjf/common-lisp-published/postmodernity/" asdf:*central-registry*)
  (asdf:load-system "mhs-map")
  (mhs-map:start :debugp t)
  (in-package "MHS-MAP")
  (compile-paren-files)

* Development Server:
  http://54.172.75.208:4242/mhs-map/map
  (mhs-map:start :debugp t :username "admin" :password "admin" :pg-user "pgsql" :http-private-host "54.172.75.208" :static-uri-base "http://54.172.75.208:4242/mhs-map/static/")


https://silviomoreto.github.io/bootstrap-select/examples/



## ACTIVITY

TODO [DEPLOYMENT] remove sli-parentools (not used)

TODO [DEPLOYMENT] upgrade to PostgreSQL 9.5/6 + PostGIS 2.3.x

TODO [DEPLOYMENT] Need to use HTTPS for geolocation to work on Chrome (and other browsers later on most likely)

TODO [DOC] document installation for service

TODO revise and test for use with iframe in MHS site  - interactive map:  http://www.mhs.mb.ca/docs/sites/index.shtml  - each detail page has its own individual map; top of page link back to interactive map    larger version: http://www.mhs.mb.ca/docs/sites/index_noborder.shtml

TODO google analytics for usages stats

TODO review necessity of an API key: https://developers.google.com/maps/documentation/javascript/get-api-key

TODO need better error logging and handling in XHR-GET-JSON  http://api.jquery.com/jQuery.ajax/

TODO revise database.lisp to use POSTMODERNITY:DEFPGSTRUCT

TODO document geojson.lisp with https://tools.ietf.org/html/rfc7946 reference

TODO extract a PS geojson API from map.paren

TODO refactor to better express *google -lat-lng-bounds -> json -> alist -> SQL* in SQL, CL, and PS

TODO refactor -LIST-WIDGET to extract site model rendering


TODO Copyright 2012-2014 Manitoba Historical Society. Copyright 2012-2014 Shared Logic Inc.

TODO how to geolocate+follow and fallback to the other two modes

    NOTE: if it's available and user says OK, can we detect the
    initial geolocation and zoom/pan into the user? Otherwise, hide
    the geolocation/follow toggle button, and stay zoomed/panned to
    defaults.

    W3C says error function must be called if user denies permission
    for geolocation.

    https://dev.w3.org/geo/api/spec-source.html#navi-geo
    PERMISSION_DENIED
    POSITION_UNAVAILABLE
    TIMEOUT
    UNKNOWN_ERROR

    However, Firefox's third option, `not now', does not lead to the
    error function--just no success either.

    So, must rely upon success function to turn on geolocation search
    mode and fall back to map-area.



    Because of the potential for geolocation to be denied without a
    definite call to the error function and, subsequently, the map
    widget left in a bad state, we need to:

    - NOT simply rely upon a mode state

    - separate the setting of the query used in a mode vs. the event
    - making the query vs. event re-centering the map

    So, start by really thinking about the 3 modes of behaviour we
    outlined--that's what we're trying to maintain!

    HINT: consider that we could use BOTH get-current-position first
    followed by watch-position to separate an initial state in which we
    can check for a results and set the watch on success.  Would this help???


- My present location
  - state centered on user geolocation
  - repopulate according to geolocation and user-defined distance (+ criteria)
  *TODO REVIEW AND CONSIDER A MAP BTN INSTEAD re-center to geolocation on geolocate/pan/zoom out of bounds*
  *TODO OR CENTER JUST INITIALLY???  WOULD NEED TO HAVE search-form submission trigger this; can't use the listener to distinquish initial vs ongoing events*
  
*TODO REVIEW...*
-> watch on geolocate (user moved)
    -> navigator geolocation position
    -> update map-widget geolocation-position to position
    -> map-widget geolocation-position
    -> map-widget google-map bounds
    -> when geolocation-position out of bounds, map-widget google-map pan-to (smoother than set-center) geolocation-position
    -> search-form distance
    -> search-form criteria
    -> repository site-list-populate-within-distance + criteria

*TODO REVIEW...*
-> listen on idle (post pan/zoom)
    -> map-widget geolocation-position
    -> map-widget google-map bounds
    -> when geolocation-position out of bounds, map-widget google-map pan-to (smoother than set-center) geolocation-position





*TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO*


TODO PostgreSQL/PostGIS upgrades; Ubuntu?
I will review server upgrade issues

TODO move to HTTPS; untrusted cert?  hosting?
- Gord will look into free cert. and let me know

TODO Google API key?
- Send Gord docs on that

TODO x-mobile testing

TODO performance improvements?


TODO (Gord) eliminate space beteen AND/OR/NOT selects and keyword fields

TODO resolution of markers for mobile?
- FIRST review Google API docs on marker requirement
- second, get Gord will send me original vector formats to test - EPS???
- use smaller simpler ones (just dots?) when zoomed out

TODO specify search default of "10 km of me" to avoid user hitting the "Jackson Pollack" view!  a performance boost too

TODO integrate the geolocation
- see GEOLOCATION in scratch.lisp
- issues include Firefox's 3rd "Not now" permission option; looking for a workaround
- let geolocation set center-distance
- fix bug in center-distance query (database.lisp)


*TODO release for review*

TODO *disable* form submission so it's just XHR (have removed action, but there's "prevent" we need in the JS

TODO how to parse designations from single select to XHR
TODO split form: within/mode sets *site-list* mode & necessary params; other params set by Update button; visually distinct!

------------------------------------------------------------------------------------------------------

DONE (Gord) search form background accent colour
DONE (Gord) same accent colour for alternating rows in list
DONE revise model to incoroporate keywords + ops, site types, and designations
DONE revise features handler to incoroporate keywords + ops, site types, and designations
DONE revise select-sites-within-bounds/within-distance/by-municipality to incoroporate keywords + ops, site types, and designations
DONE Rough out search widget
DONE Toggle panel headings with nav tabs
DONE Reorder columns/tabs: map, list, search
DONE Rough out markup and CSS to support large vs. mobile display switching
DONE Drive search modes from nav bar
DONE rough out initial navbar with search fields and replace tabs
DONE bootstrap grid to make room for search form + map/list alternation
DONE use bootstrap
DONE features handler by municipality
DONE query by _municipality_
DONE Define MUNICIPALITY structure and queries
DONE compute and store coordinates of center of municipality during import
DONE separate features handlers by bounds vs center and distance
DONE query by _center_ and _distance_
DONE default to geolocation & follow
DONE revise map to populate on idle event without search criteria
DONE (see alter.sql) store geography as well as geometry (and original lat, lng)
DONE use new build.sh scheme
DONE grap env vars in MAIN and pass to START args rather than in APP-CONFIG
DONE sli-hunchentools -> hunchentools + whofields
DONE eliminate swank code (see ag-redemption2)



## DECISIONS

- Gord has catpured GPS _geographic_ coordinates, angular measurements
  in degrees of latitude and longitude, presumably in the WGS84 datum
  for North America.

- We'll use the EPSG projection SRID 4326: http://spatialreference.org/ref/epsg/4326/

- We'll be isplaying dynamically queried set of points now, not bulk
  xml load; JSON might reduce network traffic and parsing time
  compared to KML also want more control over features by parsing JSON
  directory instead of relying upon Google KmlLayer

  https://developers.google.com/maps/documentation/javascript/training/data/importing_data

  So, query for GeoJSON and display using Javascript.

- We'll store Gord's coordinates with PostgresSQL/PostGIS as both
  _geographical_ points (lat/lng) with SRID 4326 and _geometric_
  points (y/x).

- Place Google Map markers using the geographical coordinates and
  Google Maps will project for the web mercator (EPSG:3857).

  http://gis.stackexchange.com/questions/56862/what-spatial-reference-system-do-i-store-google-maps-lat-lng-in
  https://developers.google.com/maps/documentation/javascript/reference#LatLng

- Use the geometric coordinates for fast geospatial calculations and
  query criteria.
  
        If your data is geographically compact (contained within a
        state, county or city), use the geometry type with a Cartesian
        projection that makes sense with your data.
        
  http://workshops.boundlessgeo.com/postgis-intro/geography.html

        It is best practice to choose one SRID for all the tables in
        your database. Only use the transformation function when you
        are reading or writing data to external applications.

  http://workshops.boundlessgeo.com/postgis-intro/projection.html

- We'll create custom markers

  https://developers.google.com/maps/documentation/javascript/training/customizing/

- Geolocation on desktop or mobile

  https://en.wikipedia.org/wiki/W3C_Geolocation_API
  https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/Using_geolocation?redirectlocale=en-US&redirectslug=Using_geolocation

- Layout issues

SEE https://developers.google.com/maps/documentation/javascript/basics
SEE https://developers.google.com/maps/documentation/javascript/examples/interaction-cooperative

- Use absolute position and top/bottom to Z-stack widgets
SEE http://stackoverflow.com/questions/1909648/stacking-divs-on-top-of-each-other
SEE http://alistapart.com/article/css-positioning-101

- Use visibility rather than display to set the visible widget
NOTE that BS tabs use display, not visibility!!!
NOTE that BS "Responsive Utilities" use display, not visibility!!!
SEE http://stackoverflow.com/questions/4358582/google-map-shows-only-partially/4364422#4364422
SEE http://www.devx.com/tips/Tip/13638
SEE http://stackoverflow.com/questions/133051/what-is-the-difference-between-visibilityhidden-and-displaynone
SEE https://developer.mozilla.org/en-US/docs/Web/CSS/visibility
SEE http://getbootstrap.com/css/#responsive-utilities

- device: nav tabs to drive visibility (NOT display) of absolute positioned Z-stacked widgets
- desktop: 3 column BS grid rather than switchable tabs
NOTE matchMedia() would be perfect, but not yet guaranteed available in all browsers or stable implementation
https://developer.mozilla.org/en-US/docs/Web/API/Window/matchMedia
https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Testing_media_queries

