@echo off
setlocal

REM Define the path to R installer
set R_INSTALLER_URL=https://cran.r-project.org/bin/windows/base/R-4.2.2-win.exe
set R_INSTALLER_PATH=%TEMP%\R-Installer.exe

REM Download R installer
powershell -Command "Invoke-WebRequest -Uri %R_INSTALLER_URL% -OutFile %R_INSTALLER_PATH%"

REM Install R silently
start /wait %R_INSTALLER_PATH% /SILENT

REM Clean up
del %R_INSTALLER_PATH%

REM Install required R packages
Rscript -e "if (!requireNamespace('shiny', quietly = TRUE)) install.packages('shiny')"
Rscript -e "if (!requireNamespace('ggplot2', quietly = TRUE)) install.packages('ggplot2')"
Rscript -e "if (!requireNamespace('ggpubr', quietly = TRUE)) install.packages('ggpubr')"
Rscript -e "if (!requireNamespace('rstatix', quietly = TRUE)) install.packages('rstatix')"

REM Run the Shiny app
Rscript -e "shiny::runApp('path/to/your/app.R')"

endlocal
