echo off
setlocal enabledelayedexpansion
cls

call :loadcolors

for %%i in (.) do set foldername=%%~nxi

echo %esc%[92;1m[MAKING GCC]%esc%[0m: Initializing %esc%[1m%foldername%%esc%[0m project

set cppfiles=0
for /r %%i in (*.cpp) do (
    set /a cppfiles=cppfiles + 1
    call :getcpp %%i
)

set cfiles=0
for /r %%i in (*.c) do (
    set /a cfiles=cfiles + 1
    call :getcpp %%i
)

echo %esc%[92;1m[MAKING GCC]%esc%[0m: Found %esc%[1m%cppfiles%%esc%[0m C++ files and %esc%[1m%cfiles%%esc%[0m C files

set libfiles=0
for /r "lib" %%i in (*.a) do (
    set /a libfiles=libfiles + 1
    call :getlib %%i
)

echo %esc%[92;1m[MAKING GCC]%esc%[0m: Found %esc%[1m%libfiles%%esc%[0m library files

goto :run

:loadcolors
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set esc=%%b
    exit /b

:getcpp
    set abspath=%1
    set relpath=!abspath:%cd%\=!
    set cpp=%cpp% %relpath%
    exit /b

:getlib
    set libname=%1
    set relpath=!libname:%cd%\lib\lib=!
    set lib=%lib% -l%relpath:.a=%
    exit /b

:run
    echo %esc%[92;1m[COMPILING]%esc%[0m: Starting compilation

    if exist bin/main.exe (
        set createdorupdated=updated
    ) else (
        set createdorupdated=created
    )

    for /f "tokens=1-4 delims=:.," %%a in ("%time%") do set /a "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"

    g++ -g -std=c++20 -I include -L lib %cpp% -o bin/main.exe %lib% > run.log 2>&1

    for /f "tokens=1-4 delims=:.," %%a in ("%time%") do set /a "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    
    set /a elapsed=end-start
    
    set /a rest=elapsed%%(60*60*100), rest%%=60*100, seconds=elapsed/100, milliseconds=rest%%100
    if %seconds% lss 10 set seconds=0%seconds%
    if %milliseconds% lss 10 set milliseconds=0%milliseconds%

    if errorlevel 1 (
        echo %esc%[91;1m[COMPILING]%esc%[0m: An error occurred when trying to compile, more information in run.log
        exit
    )

    echo %esc%[92;1m[COMPILING]%esc%[0m: Project compiled in %esc%[1m%seconds%.%milliseconds%s%esc%[0m

    echo %esc%[92;1m[COMPILING]%esc%[0m: Executable %esc%[1mmain.exe%esc%[0m %createdorupdated% in %esc%[1mbin%esc%[0m folder
    echo %esc%[92;1m[RUNNING]%esc%[0m: Running project

    for /f %%i in ('echo n ^| start-project') do set lastline=%%i

    if %lastline% gtr 0 (
        echo %esc%[91;1m[FINISHED]%esc%[0m: Project failed with code %esc%[91;1m%lastline%%esc%[0m
        exit
    ) else if %lastline% lss 0 (
        echo %esc%[92;1m[FINISHED]%esc%[0m: Forced exit
        exit
    )

    echo %esc%[92;1m[FINISHED]%esc%[0m: Project finished with no errors