rem Start from the directory containing this batch file, then move to
rem its BGI directory. This preserves the original path behavior.
pushd "%~dp0" || (
    echo ERROR: Unable to access the batch file directory.
    exit /b 1
)
cd பின்னணி

start "" /min "அமை.bat"