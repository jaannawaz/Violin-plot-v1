@echo off

REM Locate R.exe dynamically in the default installation directory
set "R_PATH="
for /d %%d in ("C:\Program Files\R\R-*") do (
    if exist "%%d\bin\R.exe" (
        set "R_PATH=%%d\bin\R.exe"
        goto :found
    )
)

:found
if "%R_PATH%"=="" (
    echo R is not installed or R.exe is not in the default directory.
    echo Please install R or specify the path manually.
    pause
    exit /b
)

echo Found R.exe at: %R_PATH%

REM Check and install only missing libraries
echo Checking and installing required R libraries...
"%R_PATH%" -e "required_packages <- c('shiny', 'dplyr', 'ggplot2', 'ggpubr'); missing_packages <- setdiff(required_packages, installed.packages()[,'Package']); if(length(missing_packages)) install.packages(missing_packages, repos='http://cran.rstudio.com/')"

REM Start the Shiny app directly
echo Starting the Shiny app...
"%R_PATH%" -e "shiny::runApp('app.R', launch.browser = TRUE)"

REM Pause to keep the terminal open
echo.
echo Shiny app has started. Press any key to exit.
pause
