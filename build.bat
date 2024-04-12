@echo off
goto:$Main

:$Main
setlocal EnableDelayedExpansion
    set "_root=%~dp0"
    if "%_root:~-1%."=="\." set "_root=%_root:~0,-1%"

    set "_args=%*"
    if "%~1."=="." set "_args=vc17win64"

    if not "%~1."=="setup." goto:$MainSkipSetup
    call sudo winget install -e --id "Nvidia.CUDA"
    call sudo winget install -e --id "Nvidia.VideoEffectsSDK.20xx-Turing"
    call sudo winget install -e --id "Nvidia.RTXVoice"

    :$MainSkipSetup
    set "PHYSX_SOURCE_ROOT_DIR=%_root%"
    set "PHYSX_SOURCE_ROOT_DIR=%PHYSX_SOURCE_ROOT_DIR:\=/%"
    set "PHYSX_ROOT_DIR=%PHYSX_SOURCE_ROOT_DIR%/physx"
    set "PHYSX_ROOT_DIR=%PHYSX_ROOT_DIR:\=/%"
    set "PM_VSWHERE_PATH=%PHYSX_SOURCE_ROOT_DIR%/externals/VsWhere"
    set "PM_CMAKEMODULES_PATH=%PHYSX_SOURCE_ROOT_DIR%/source/compiler/cmake/modules"
    set "PM_PXSHARED_PATH=%PHYSX_SOURCE_ROOT_DIR%/pxshared"
    set "PM_TARGA_PATH=%PHYSX_SOURCE_ROOT_DIR%/externals/targa"
    set "PM_PATHS=%PM_CMAKEMODULES_PATH%;%PM_TARGA_PATH%"

    if exist "%PHYSX_SOURCE_ROOT_DIR%\build" rmdir /s /q "%PHYSX_SOURCE_ROOT_DIR%\build"

    call "!_root!\physx\generate_projects.bat" !_args!

    ::
    :: call "%_root%\physx\generate_projects.bat" %_args%
    ::

    cmake -S "%PHYSX_SOURCE_ROOT_DIR%/physx/compiler/public" -B "%PHYSX_SOURCE_ROOT_DIR%/build" -Ax64 -DTARGET_BUILD_PLATFORM=windows -DPX_OUTPUT_ARCH=x86 --no-warn-unused-cli -DCMAKEMODULES_PATH=%PHYSX_SOURCE_ROOT_DIR%/externals/CMakeModules -DPXSHARED_PATH=%PHYSX_SOURCE_ROOT_DIR%/pxshared -DCMAKE_PREFIX_PATH="%PHYSX_SOURCE_ROOT_DIR%/externals/CMakeModules;%PHYSX_SOURCE_ROOT_DIR%/externals/targa" -DPHYSX_ROOT_DIR="%PHYSX_SOURCE_ROOT_DIR%/physx" -DPX_OUTPUT_LIB_DIR="%PHYSX_SOURCE_ROOT_DIR%/physx" -DPX_OUTPUT_BIN_DIR="%PHYSX_SOURCE_ROOT_DIR%/physx" -DPX_BUILDSNIPPETS=FALSE -DPX_BUILDPUBLICSAMPLES=FALSE -DPX_GENERATE_STATIC_LIBRARIES=FALSE -DNV_USE_STATIC_WINCRT=TRUE -DNV_USE_DEBUG_WINCRT=TRUE -DPX_FLOAT_POINT_PRECISE_MATH=FALSE -DCMAKE_INSTALL_PREFIX="%PHYSX_SOURCE_ROOT_DIR%/physx/install/vc17win64/PhysX"

    cmake --build "%PHYSX_SOURCE_ROOT_DIR%\build"
endlocal & exit /b %errorlevel%
