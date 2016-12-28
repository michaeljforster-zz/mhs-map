# mhs-map

mhs-map is the Fast, Portable, User-Configurable Map of Manitoba
Historic Sites published under the Manitoba Historical Society (MHS)
website, http://www.mhs.mb.ca/.

mhs-map is distributed under the MIT license.  See LICENSE.

mhs-map is being developed using SBCL on Linux and OS X.  See
mhs-map.asd for the list of dependencies.

## Installation

mhs-map is not available for download via
[quicklisp](https://www.quicklisp.org/). Clone the repository and tell
[ASDF](https://www.common-lisp.net/project/asdf/) where to find the
system definition.

## Running Interactively

Having started Common Lisp, the system can be loaded with quicklisp
and run interactively:

```lisp
(ql:quickload "mhs-map")
...
(mhs-map:start :debugp t
               :username "foo"
               :password ""
               :pg-database "mhs_map"
               :pg-user "postgres"
               :pg-password ""
               :pg-host "localhost"
               :http-port 4242
               :http-private-host "127.0.0.1"
               :http-private-port 4242
               :http-private-protocol :http
               :http-session-max-time 10800
               :static-uri-base #u"http://127.0.0.1:4242/mhs-map/static/"
               :mhs-base-uri #u"http://www.mhs.mb.ca/docs/sites/"
               :mhs-sites-uri #u"http://www.mhs.mb.ca/docs/sites/index.shtml")
```

Once running, mhs-map can be stopped interactively:

```lisp
(mhs-map:stop)
```

## Building an Executable to Run as a Service

mhs-map can be built as an SBCL executable
using [buildapp](http://www.xach.com/lisp/buildapp/) using the
provided build.sh script and a prepared workspace directory tree as
follows:

```shell
mkdir -p /tmp/workspace/src /tmp/workspace/build
export WORKSPACE=/tmp/workspace
./build.sh
```

Upon a successful build, the executable will be saved as
$WORKSPACE/build/mhs-map.
