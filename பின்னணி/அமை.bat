Rem This will launch a executable with the name of this file (i.e.xyz) under samename (xyz) folder 
Rem inside the t folder next to this file. Also forwards all the arguments to that executable
Rem "%~dp0t\%~n0\%~n0" %*

@echo on
rem cd /d %~dp0
pushd %~dp0
cd ..
rem Below code will get date and time in this format.

for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set /a Day=%%L
        set /a Month=%%M
        set /a Year=%%N
    )
)

rem compute leap year
Set /a YMod4=%Year% %% 4, LYear = 0
if %YMod4% equ 0 set /a LYear = 1

rem Define accumulated days of the year for various months
Set /a acm[1]=0, acm[2]=31, acm[3]=59, acm[4]=90, acm[5]=120, acm[6]=151, acm[7]=181, acm[8]=212, acm[9]=243, acm[10]=273, acm[11]=304, acm[12]=334

rem To Access array indexed variable extensions are enabled 
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

rem compute day of the year
set /a DoY= !acm[%Month%]! + %Day%
if %Month% gtr 2 set /A DoY+=%LYear%

Rem Extensionts are disabled and variable value is takenout 
endlocal & Set "Doy=%DoY%"

Rem convert to Thiruvalluvar day of year and year.
Set /a TrYear = %Year%+31, TrDay = %DoY% - 15
if %LYear% equ 1 set /A Trday = %TrDay% - 1
if %Month% equ 1 if %TrDay% lss 1 ( set /A TrYear = %TrYear% - 1, TrDay = %TrDay% + 365 + %LYear%)
Rem Thiruvalluvar Day conversion over 

Set /a TYMod4=%TrYear% %% 4
set /a DoTLY = %TrDaY% + %TYMod4%*365
Set /a Kod= (%DoTLY% %% 1330)+1
Set Kod1=000%Kod%
Set Kod2=%Kod1:~-4%


start /min பின்னணிதகவல்.exe பின்னணி\திருக்குறள்-%Kod2%.bgi /NOLICPROMPT /SILENT /timer:0
echo திருவள்ளுவர் ஆண்டு  %TrYear% நாள் %TrDay% 

Rem clear message
chcp 65001
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v legalnoticecaption /d "" /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v legalnoticetext /d "" /f

goto :eof