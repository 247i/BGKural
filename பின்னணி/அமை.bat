Rem This script can launch an executable with the same name as this batch file (for example, xyz)
Rem from a matching xyz folder under the t folder located next to this batch file.
Rem The following command also forwards all command-line arguments to that executable.
Rem "%~dp0t\%~n0\%~n0" %*

@echo on
rem cd /d %~dp0
pushd %~dp0
cd ..

rem Get the current Gregorian day, month, and year.
for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set /a Day=%%L
        set /a Month=%%M
        set /a Year=%%N
    )
)

rem Determine whether the current year is treated as a leap year.
Set /a YMod4=%Year% %% 4, LYear = 0
if %YMod4% equ 0 set /a LYear = 1

rem Define the number of days before the first day of each month.
Set /a acm[1]=0, acm[2]=31, acm[3]=59, acm[4]=90, acm[5]=120, acm[6]=151, acm[7]=181, acm[8]=212, acm[9]=243, acm[10]=273, acm[11]=304, acm[12]=334

rem Enable command extensions and delayed expansion so the month-indexed array value can be accessed.
setlocal EnableExtensions EnableDelayedExpansion

if defined PROCESSOR_ARCHITEW6432 (
    set "ARCH=%PROCESSOR_ARCHITEW6432%"
) else (
    set "ARCH=%PROCESSOR_ARCHITECTURE%"
)

echo Detected architecture: %ARCH%

if /i "%ARCH%"=="AMD64" (
    echo System is 64-bit x86 ^(x64^)
	set /a App= "Bginfo64.exe"
) else if /i "%ARCH%"=="ARM64" (
    echo System is 64-bit ARM
) else if /i "%ARCH%"=="x86" (
    echo System is 32-bit x86
	set /a App= "Bginfo.exe"
) else (
    echo Unknown architecture: %ARCH%
)

rem Calculate the day number within the Gregorian year.
set /a DoY= !acm[%Month%]! + %Day%
if %Month% gtr 2 set /A DoY+=%LYear%

rem End the local environment while preserving the calculated day-of-year value.
endlocal & Set "Doy=%DoY%"

rem Convert the Gregorian date to the corresponding Thiruvalluvar year and day.
Set /a TrYear = %Year%+31, TrDay = %DoY% - 15
if %LYear% equ 1 set /A Trday = %TrDay% - 1
if %Month% equ 1 if %TrDay% lss 1 ( set /A TrYear = %TrYear% - 1, TrDay = %TrDay% + 365 + %LYear%)

rem Thiruvalluvar date conversion completed.

rem Calculate the position used to select the Kural number.
Set /a TYMod4=%TrYear% %% 4
set /a DoTLY = %TrDaY% + %TYMod4%*365
Set /a Kod= (%DoTLY% %% 1330)+1

rem Format the Kural number as a four-digit value (0001 through 1330).
Set Kod1=000%Kod%
Set Kod2=%Kod1:~-4%

rem Launch the corresponding Thirukkural BGI file using the background-information application.
start /min பின்னணிதகவல்.exe பின்னணி\திருக்குறள்-%Kod2%.bgi /NOLICPROMPT /SILENT /timer:0

echo திருவள்ளுவர் ஆண்டு  %TrYear% நாள் %TrDay%

rem Clear the Windows logon legal-notice caption and text from the system policy registry settings.
chcp 65001
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v legalnoticecaption /d "" /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v legalnoticetext /d "" /f

goto :eof