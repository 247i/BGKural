@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Start from the directory containing this batch file. This preserves the original path behavior.
pushd "%~dp0" || (
    echo ERROR: Unable to access the batch file directory.
    exit /b 1
)

rem ------------------------------------------------
rem Get the current Gregorian day, month, and year using PowerShell.
rem ------------------------------------------------
for /f "tokens=1-3 delims= " %%A in ('
    powershell -NoProfile -Command "(Get-Date).Day; (Get-Date).Month; (Get-Date).Year"
') do (
    if not defined Day (
        set "Day=%%A"
    ) else if not defined Month (
        set "Month=%%A"
    ) else if not defined Year (
        set "Year=%%A"
    )
)

if not defined Day goto :DateError
if not defined Month goto :DateError
if not defined Year goto :DateError

rem ------------------------------------------------
rem Validate the date values returned by PowerShell.
rem ------------------------------------------------
set /a "DaysInMonth=31"
if %Month%==2 set /a "DaysInMonth=28"
if %Month%==4 set /a "DaysInMonth=30"
if %Month%==6 set /a "DaysInMonth=30"
if %Month%==9 set /a "DaysInMonth=30"
if %Month%==11 set /a "DaysInMonth=30"

rem ------------------------------------------------
rem Determine whether the Gregorian year is a leap year.
rem ------------------------------------------------
set /a "YMod4=Year %% 4"
set /a "YMod100=Year %% 100"
set /a "YMod400=Year %% 400"
set /a "LYear=0"

if %YMod400%==0 (
    set /a "LYear=1"
) else if %YMod4%==0 if not %YMod100%==0 (
    set /a "LYear=1"
)

if %Month%==2 if %LYear%==1 set /a "DaysInMonth=29"

if %Month% LSS 1 goto :DateError
if %Month% GTR 12 goto :DateError
if %Day% LSS 1 goto :DateError
if %Day% GTR %DaysInMonth% goto :DateError

rem ------------------------------------------------
rem Number of days before the first day of each month.
rem The array is indexed by month number.
rem ------------------------------------------------
set /a "acm[1]=0"
set /a "acm[2]=31"
set /a "acm[3]=59"
set /a "acm[4]=90"
set /a "acm[5]=120"
set /a "acm[6]=151"
set /a "acm[7]=181"
set /a "acm[8]=212"
set /a "acm[9]=243"
set /a "acm[10]=273"
set /a "acm[11]=304"
set /a "acm[12]=334"

rem ------------------------------------------------
rem Calculate the Gregorian day of year.
rem Add the leap day only for dates after February.
rem ------------------------------------------------
set /a "DoY=!acm[%Month%]! + Day"
if %Month% GTR 2 if %LYear%==1 set /a "DoY+=1"

rem ------------------------------------------------
rem Convert Gregorian date to Thiruvalluvar year/day.
rem These formulas are retained from the original batch file.
rem ------------------------------------------------
set /a "TrYear=Year + 31"
set /a "TrDay=DoY - 15"

if %LYear%==1 set /a "TrDay-=1"

rem If the calculated day is before the beginning of the
rem Thiruvalluvar year, move to the previous Thiruvalluvar year.
if %Month%==1 if %TrDay% LSS 1 (
    set /a "TrYear-=1"
    set /a "TrDay+=365 + LYear"
)

rem ------------------------------------------------
rem Calculate the Kural number.
rem TYMod4 is retained from the original algorithm.
rem ------------------------------------------------
set /a "TYMod4=TrYear %% 4"
set /a "DoTLY=TrDay + TYMod4 * 365"
set /a "Kod=(DoTLY %% 1330) + 1"

rem ------------------------------------------------
rem Format the Kural number as a four-digit value:
rem   1    -> 0001
rem   25   -> 0025
rem   1330 -> 1330
rem ------------------------------------------------
set "Kod1=0000%Kod%"
set "Kod2=!Kod1:~-4!"

rem ------------------------------------------------
rem Select the correct BGInfo executable for Windows bitness.
rem PROCESSOR_ARCHITEW6432 identifies 64-bit Windows when this
rem batch file is running from a 32-bit process.
rem ------------------------------------------------
set "BgInfoExe="

if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "BgInfoExe=Bginfo64.exe"
if /i "%PROCESSOR_ARCHITEW6432%"=="ARM64" set "BgInfoExe=Bginfo64.exe"

if not defined BgInfoExe (
    if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "BgInfoExe=Bginfo64.exe"
    if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "BgInfoExe=Bginfo64.exe"
    if /i "%PROCESSOR_ARCHITECTURE%"=="x86" set "BgInfoExe=Bginfo.exe"
)

if not defined BgInfoExe (
    echo ERROR: Unable to determine Windows bitness.
    echo PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITECTURE%
    echo PROCESSOR_ARCHITEW6432=%PROCESSOR_ARCHITEW6432%
    goto :Cleanup
)

rem ------------------------------------------------
rem Verify that the selected BGInfo executable exists.
rem ------------------------------------------------
if not exist "%BgInfoExe%" (
    echo ERROR: Required BGInfo executable not found:
    echo        %BgInfoExe%
    goto :Cleanup
)

set "KuralFile=பின்னணி\திருக்குறள்-%Kod2%.bgi"

if not exist "%KuralFile%" (
    echo ERROR: Kural file not found:
    echo        %KuralFile%
    echo.
    echo Calculated Kural number: %Kod%
    goto :Cleanup
)

rem ------------------------------------------------
rem Launch the calculated Kural with the BGInfo executable
rem selected for the current Windows bitness.
rem ------------------------------------------------
echo Windows architecture: %PROCESSOR_ARCHITECTURE%
if defined PROCESSOR_ARCHITEW6432 echo Native architecture: %PROCESSOR_ARCHITEW6432%
echo BGInfo executable: %BgInfoExe%

start "" /min "%~dp0%BgInfoExe%" "%KuralFile%" /NOLICPROMPT /SILENT /timer:0

rem Display the calculated Thiruvalluvar date.
echo.
echo திருவள்ளுவர் ஆண்டு %TrYear% நாள் %TrDay%

rem ------------------------------------------------
rem Clear the Windows logon legal-notice caption and text.
rem This requires Administrator privileges.
rem ------------------------------------------------
chcp 65001 >nul
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /d "" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /d "" /f

:Cleanup
popd
endlocal
exit /b 0

:DateError
echo ERROR: Unable to obtain or validate the current Gregorian date.
echo Day=%Day% Month=%Month% Year=%Year%
popd
endlocal
exit /b 1
