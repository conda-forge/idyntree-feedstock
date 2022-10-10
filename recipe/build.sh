#!/bin/sh


if [[ ${target_platform} == "linux-aarch64" ]]; then
  echo "Using 1 thread to build"
  export NUM_PARALLEL=-j1
else
  echo "Use all available cores to build"
  export NUM_PARALLEL=
fi

if [[ ${target_platform} == "linux-ppc64le" ]]; then
  export BUILD_TESTING=OFF
else
  export BUILD_TESTING=ON
fi

mkdir build
cd build

echo "Value set to Python3_NumPy_INCLUDE_DIR: "$BUILD_PREFIX/venv/lib/`ls $BUILD_PREFIX/venv/lib/ | grep "python\|pypy"`/site-packages/numpy/core/include

ls $BUILD_PREFIX/venv/lib/ | grep "python\|pypy"`


env

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
      -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON \
      -DIDYNTREE_PYTHON_PIP_METADATA_INSTALLER=conda \
      -DPython3_INCLUDE_DIR:PATH=$BUILD_PREFIX/include/`ls $BUILD_PREFIX/include | grep "python\|pypy"` \
      -DPython3_NumPy_INCLUDE_DIR:PATH=$BUILD_PREFIX/venv/lib/`ls $BUILD_PREFIX/venv/lib/ | grep "python\|pypy"`/site-packages/numpy/core/include
      
cat CMakeCache.txt 

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi
