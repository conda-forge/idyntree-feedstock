#!/bin/sh

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

env

Python3_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python3_NumPy_INCLUDE_DIR="$(python -c 'import numpy;print(numpy.get_include())')"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${Python3_INCLUDE_DIR}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_NumPy_INCLUDE_DIR=${Python3_NumPy_INCLUDE_DIR}"

cmake ${CMAKE_ARGS} -GNinja .. \
    -DIDYNTREE_USES_PYTHON:BOOL=ON \
    -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DIDYNTREE_PYTHON_PIP_METADATA_INSTALLER=conda

ninja -v
cmake --build . --config Release --target install
