mkdir build_cxx
cd build_cxx

if "%IDYNTREE_DEPS_VARIANT%"=="sdformat" (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DIDYNTREE_USES_SDFORMAT:BOOL=ON"
) else (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DIDYNTREE_USES_SDFORMAT:BOOL=OFF"
)


cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DIDYNTREE_USES_IPOPT:BOOL=ON ^
    -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON ^
    -DIDYNTREE_USES_IRRLICHT:BOOL=ON ^
    -DIDYNTREE_USES_ASSIMP:BOOL=ON ^
    -DIDYNTREE_USES_MATLAB:BOOL=OFF ^
    -DIDYNTREE_USES_PYTHON:BOOL=OFF ^
    -DIDYNTREE_USES_OCTAVE:BOOL=OFF ^
    -DIDYNTREE_USES_LUA:BOOL=OFF ^
    -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
:: Visualizer tests skipped as a workaround for https://github.com/robotology/idyntree/issues/808
ctest --output-on-failure -C Release -E "Visualizer"
if errorlevel 1 exit 1
