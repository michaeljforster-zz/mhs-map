#!/bin/sh

# http://stackoverflow.com/questions/18917067/how-to-use-buildapp-in-combination-with-quicklisp

BUILD_DIR=./build # set in .gitignore as well

mkdir $BUILD_DIR

sbcl --no-userinit --no-sysinit --non-interactive \
     --load ~/quicklisp/setup.lisp \
     --eval '(ql:quickload "mhs-map")' \
     --eval "(ql:write-asdf-manifest-file \"${BUILD_DIR}/quicklisp-manifest.txt\")"

buildapp --manifest-file ${BUILD_DIR}/quicklisp-manifest.txt \
         --load-system mhs-map \
         --output ${BUILD_DIR}/mhs-map \
         --logfile ${BUILD_DIR}/buildapp.log \
         --entry mhs-map:main
