   @echo off
   REM Change the path to where your R installer is located
   set R_INSTALLER=C:\Downloads\R-4.1.0-win.exe
   set R_PATH="C:\Program Files\R\R-4.1.0\bin\Rscript.exe"
   set APP_PATH=C:\MyRApp\app.R

   REM Check if R is already installed
   if exist %R_PATH% (
       echo R is already installed. Skipping installation.
   ) else (
       echo Installing R...
       start /wait "" "%R_INSTALLER%" /SILENT

       REM Check if R was installed successfully
       if exist %R_PATH% (
           echo R installed successfully.
       ) else (
           echo R installation failed.
           pause
           exit /b
       )
   )

   REM Install R libraries if not already installed
   echo Installing required R packages...
   "%R_PATH%" -e "if (!requireNamespace('ggplot2', quietly = TRUE)) install.packages('ggplot2', repos='http://cran.r-project.org')"
   "%R_PATH%" -e "if (!requireNamespace('ggpubr', quietly = TRUE)) install.packages('ggpubr', repos='http://cran.r-project.org')"
   "%R_PATH%" -e "if (!requireNamespace('rstatix', quietly = TRUE)) install.packages('rstatix', repos='http://cran.r-project.org')"

   REM Start the Shiny app
   start "" "%R_PATH%" -e "shiny::runApp('%APP_PATH%')"

   REM Open the default web browser to the R documentation
   start "" "https://cran.r-project.org/manuals.html"

   echo Installation complete. Press any key to exit.
   pause
