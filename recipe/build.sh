#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=${BUILD_TESTING} \
      -DIDYNTREE_USES_IPOPT:BOOL=ON \
      -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON \
      -DIDYNTREE_USES_IRRLICHT:BOOL=ON \
      -DIDYNTREE_USES_ASSIMP:BOOL=ON \
      -DIDYNTREE_USES_MATLAB:BOOL=OFF \
      -DIDYNTREE_USES_PYTHON:BOOL=ON \
      -DIDYNTREE_USES_OCTAVE:BOOL=OFF \
      -DIDYNTREE_USES_LUA:BOOL=OFF \
      -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF \
      -DPython3_EXECUTABLE:PATH=$PYTHON \
      -DPython3_INCLUDE_DIR:PATH=$PREFIX/include/`ls $PREFIX/include | grep "python\|pypy"` \
      -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON \
      -DIDYNTREE_PYTHON_PIP_METADATA_INSTALLER=conda \
      --debug-find

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}
# Visualizer tests skipped as a workaround for https://github.com/robotology/idyntree/issues/808
# IntegrationTestiCubTorqueEstimation skipped for https://github.com/robotology/idyntree/issues/1192
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release -E "Visualizer|IntegrationTestiCubTorqueEstimation"
fi
