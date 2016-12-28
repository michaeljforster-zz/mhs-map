#!/bin/sh

if [ -z "$WORKSPACE" ]; then
  echo 1>&2 "WORKSPACE is unset"
  exit 1
fi

PROJECT_NAME=mhs-map

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "PRE-BUILDING, TESTING, AND GENERATING MANIFEST"
echo

sbcl --no-sysinit \
     --no-userinit \
     --non-interactive \
     --load ~/quicklisp/setup.lisp \
     --eval "(asdf:initialize-source-registry '(:source-registry (:tree \"${WORKSPACE}/src\") :inherit-configuration))" \
     --eval "(ql:quickload \"${PROJECT_NAME}\")" \
     --eval "(ql:write-asdf-manifest-file \"${WORKSPACE}/build/quicklisp-manifest.txt\")"

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "BUILDING FROM MANIFEST"
echo

buildapp --manifest-file "${WORKSPACE}/build/quicklisp-manifest.txt" \
         --asdf-tree "${WORKSPACE}/src" \
         --load-system "${PROJECT_NAME}" \
         --output "${WORKSPACE}/build/${PROJECT_NAME}" \
         --logfile "${WORKSPACE}/build/buildapp.log" \
         --entry "${PROJECT_NAME}:main"
