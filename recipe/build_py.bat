cd bindings
rmdir /s /q build
mkdir build
cd build

cmake %CMAKE_ARGS% -G "Ninja" ^
    -DIDYNTREE_USES_PYTHON:BOOL=ON ^
    -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    -DIDYNTREE_PYTHON_PIP_METADATA_INSTALLER=conda ^
    ..
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1