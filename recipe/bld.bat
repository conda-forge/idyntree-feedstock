mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DIDYNTREE_USES_IPOPT:BOOL=ON ^
    -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON ^
    -DIDYNTREE_USES_IRRLICHT:BOOL=ON ^
    -DIDYNTREE_USES_MATLAB:BOOL=OFF ^
    -DIDYNTREE_USES_PYTHON:BOOL=ON ^
    -DIDYNTREE_USES_OCTAVE:BOOL=OFF ^
    -DIDYNTREE_USES_LUA:BOOL=OFF ^
    -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF ^
    -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1

:: Fix Python package version
cd ..
sed -i.bak "s|use_scm_version=dict(local_scheme=""dirty-tag""),|version=""%PKG_VERSION%"",|g" setup.py
if errorlevel 1 exit 1

:: Inspect diff
diff -u setup.py.bak setup.py

:: Delete wheel folder
rmdir /s /q _dist_conda

:: Generate the wheel
%PYTHON% ^
    -m build ^
    --wheel ^
    --outdir _dist_conda ^
    --no-isolation ^
    --skip-dependency-check ^
    "-C--global-option=build_ext" ^
    "-C--global-option=--no-cmake-extension=all" ^
    .
if errorlevel 1 exit 1

:: Install Python package
%PYTHON% -m pip install ^
    --no-index --find-links=./_dist_conda/ ^
    --no-build-isolation --no-deps ^
    idyntree
if errorlevel 1 exit 1

:: Delete wheel folder
rmdir /s /q _dist_conda
if errorlevel 1 exit 1

:: Restore original files
move /y setup.py.bak setup.py
if errorlevel 1 exit 1
