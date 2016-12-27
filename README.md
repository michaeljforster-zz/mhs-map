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

## Loading and Running Interactively

Before loading the system, the following following Unix environment
variables must be set:

    USERNAME
    PASSWORD
    MHSBASEURI
    MHSSITESURI
    PGDATABASE
    PGUSER
    PGPASSWORD
    PGHOST
    HTTPPORT
    HTTPPRIVATEHOST
    HTTPSESSIONMAXTIME
    STATICURIBASE
    SWANKPORT

As a convenience, either the SETDEVENV or SETENV file can be read and
executed in the current Bourne Shell context to set those variables
for development or production, respectively:

```shell
. SETDEVENV
```

```shell
. SETENV
```

Having set the environment variables and started Common Lisp, the
system can be loaded with quicklisp and run interactively:

```lisp
(ql:quickload "mhs-map")
...
(mhs-map:start)
```

Once running, mhs-map can be stopped interactively:

```lisp
(mhs-map:stop)
```

## Building and Running as a Service

mhs-map can be built as an SBCL executable using
[buildapp](http://www.xach.com/lisp/buildapp/) using the provided
buildapp.sh script. The executable and build related files will be
placed in $BUILD_DIR as defined in buildapp.sh.

```shell
./buildapp.sh
```

A [daemontools](http://cr.yp.to/daemontools.html) supervision and
logging directory tree, _service_, is provided. The required Unix
environment variables are set according to the files in the _env_ and
_log/env_ subdirectories. The _run_ and _log/run_ scripts hard code
some paths, and there are symbolic links to the mhs-map executable and
logging directory, both of which can be changed as needed.
