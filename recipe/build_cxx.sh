#!/bin/sh

mkdir build_cxx
cd build_cxx

if [[ "${IDYNTREE_DEPS_VARIANT}" == "sdformat" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DIDYNTREE_USES_SDFORMAT:BOOL=ON"
else
  CMAKE_ARGS="${CMAKE_ARGS} -DIDYNTREE_USES_SDFORMAT:BOOL=OFF"
fi

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DIDYNTREE_USES_IPOPT:BOOL=ON \
      -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON \
      -DIDYNTREE_USES_IRRLICHT:BOOL=ON \
      -DIDYNTREE_USES_ASSIMP:BOOL=ON \
      -DIDYNTREE_USES_MATLAB:BOOL=OFF \
      -DIDYNTREE_USES_PYTHON:BOOL=OFF \
      -DIDYNTREE_USES_OCTAVE:BOOL=OFF \
      -DIDYNTREE_USES_LUA:BOOL=OFF \
      -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}
# Visualizer tests skipped as a workaround for https://github.com/robotology/idyntree/issues/808
# IntegrationTestiCubTorqueEstimation skipped for https://github.com/robotology/idyntree/issues/1192
# UnitTestInverseKinematics|Ipopt skipped as it is really slow (~10/30 seconds)
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release -E "Visualizer|IntegrationTestiCubTorqueEstimation|UnitTestInverseKinematics|Ipopt"
fi
