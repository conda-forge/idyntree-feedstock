#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=ON \
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
      -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install
ctest --output-on-failure -C Release

# Fix Python package version
cd ..
sed -i.bak "s|use_scm_version=dict(local_scheme=\"dirty-tag\"),|version=\"$PKG_VERSION\",|g" setup.py
diff -u setup.py{.bak,} || true

# Delete wheel folder
rm -rf _dist_conda/

# Generate the wheel
$PYTHON \
    -m build \
    --wheel \
    --outdir _dist_conda \
    --no-isolation \
    --skip-dependency-check \
    "-C--global-option=build_ext" \
    "-C--global-option=--no-cmake-extension=all" \
    .

# Install Python package
pip install \
  --no-index --find-links=./_dist_conda/ \
  --no-build-isolation --no-deps \
  idyntree

# Delete wheel folder
rm -rf _dist_conda/

# Restore original files
mv setup.py{.bak,}
