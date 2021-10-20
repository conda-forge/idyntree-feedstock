#!/bin/sh

# Workaround for low-memory Travis images
if [ ${target_platform} == "linux-ppc64le" ]; then
  NUM_PARALLEL=-j1
else
  NUM_PARALLEL=
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=ON \
      -DIDYNTREE_USES_IPOPT:BOOL=ON \
      -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON \
      -DIDYNTREE_USES_IRRLICHT:BOOL=ON \
      -DIDYNTREE_USES_MATLAB:BOOL=OFF \
      -DIDYNTREE_USES_PYTHON:BOOL=ON \
      -DIDYNTREE_USES_OCTAVE:BOOL=OFF \
      -DIDYNTREE_USES_LUA:BOOL=OFF \
      -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF \
      -DPython3_EXECUTABLE:PATH=$PYTHON \
      -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install
ctest --output-on-failure -C Release

# Fix Python package version
cd ..
sed -i.bak "s|use_scm_version=dict(local_scheme=\"dirty-tag\"),|version=\"$PKG_VERSION\",|g" setup.py
diff -u setup.py setup.py.bak

# Python package
$PYTHON \
    -m build \
    --wheel \
    --outdir dist \
    --no-isolation \
    --skip-dependency-check \
    "-C--global-option=build_ext" \
    "-C--global-option=--no-cmake-extension=all" \
    .
pip install --no-deps dist/*.whl
