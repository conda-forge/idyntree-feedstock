#!/bin/sh

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

env

cmake ${CMAKE_ARGS} -GNinja .. \
    -DIDYNTREE_USES_PYTHON:BOOL=ON \
    -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DIDYNTREE_PYTHON_PIP_METADATA_INSTALLER=conda

ninja -v
cmake --build . --config Release --target install
