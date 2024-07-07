@echo off

set pathToHostNamesFile="%~dp0host-names.txt"
set pathToResultsFile="%~dp0Chrome Install Results.log"
set registryKeyToCheck=HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set startDate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set startTime=%%a:%%b)

echo -------------------------------------------------------------- >> %pathToResultsFile%
echo Google Chrome installation log: >> %pathToResultsFile%
echo. >> %pathToResultsFile%

rem Loop through host names and check to see if Google Chrome is installed, if so write entry to results file
for /f "usebackq tokens=*" %%a in (%pathToHostNamesFile%) do call :processHost %%a

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set endDate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set endTime=%%a:%%b)
echo. >> %pathToResultsFile%
echo Started: %startDate% %startTime% >> %pathToResultsFile%
echo Completed: %endDate% %endTime% >> %pathToResultsFile%

goto :eof


:processHost

rem Clear the error level
(call )
cls

rem Check to see if computer is online
echo Attempting to ping %*
ping %* -n 1
if %errorlevel% neq 0 (goto :pingError)
cls

rem Change RemoteRegistry service to manual startup
echo Change RemoteRegistry service to manual startup for %*
sc \\%* config RemoteRegistry start=demand
timeout 5
cls

rem Start RemoteRegistry service
echo Start RemoteRegistry service for %*
sc \\%* start RemoteRegistry
timeout 5
cls

rem Clear the error level
(call )
cls

rem Check if Chrome is installed
echo Check if Chrome is installed for %*
reg query "\\%*\%registryKeyToCheck%"
echo.

rem Write to file if installed
if %errorlevel% equ 0 (
    echo %*: Installed
    echo %*: Installed >> %pathToResultsFile%
) else (
    echo %*: Not Installed
    echo %*: Not Installed >> %pathToResultsFile%
)
echo.
timeout 5
cls

rem Stop RemoteRegistry service
echo Stop RemoteRegistry service for %*
sc \\%* stop RemoteRegistry
timeout 5
cls

rem Change RemoteRegistry service to disabled
echo Change RemoteRegistry service to disabled for %*
sc \\%* config RemoteRegistry start=disabled
goto :eof


:pingError
echo %*: Offline >> %pathToResultsFile%
timeout 5
cls


:eof