   @echo off
   REM Find Rscript in the system PATH
   for %%i in (Rscript.exe) do set R_PATH=%%~$PATH:i

   REM Check if Rscript exists
   if not defined R_PATH (
       echo R is not installed or Rscript.exe is not in the PATH. Please install R first.
       pause
       exit /b
   )

   REM Install R libraries if not already installed
   echo Installing required R packages...
   "%R_PATH%" -e "if (!requireNamespace('ggplot2', quietly = TRUE)) install.packages('ggplot2', repos='http://cran.r-project.org')"
   "%R_PATH%" -e "if (!requireNamespace('ggpubr', quietly = TRUE)) install.packages('ggpubr', repos='http://cran.r-project.org')"
   "%R_PATH%" -e "if (!requireNamespace('rstatix', quietly = TRUE)) install.packages('rstatix', repos='http://cran.r-project.org')"

   REM Start the Shiny app located in the same directory as the batch file
   set APP_PATH=%~dp0app.R
   start "" "%R_PATH%" -e "shiny::runApp('%APP_PATH%')"

   REM Open the default web browser to the R documentation
   start "" "https://cran.r-project.org/manuals.html"

   echo Installation of R packages complete. Press any key to exit.
   pause
