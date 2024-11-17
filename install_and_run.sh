#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install R
echo "Installing R..."
brew install --cask r

# Install required R packages
Rscript -e "if (!requireNamespace('shiny', quietly = TRUE)) install.packages('shiny')"
Rscript -e "if (!requireNamespace('ggplot2', quietly = TRUE)) install.packages('ggplot2')"
Rscript -e "if (!requireNamespace('ggpubr', quietly = TRUE)) install.packages('ggpubr')"
Rscript -e "if (!requireNamespace('rstatix', quietly = TRUE)) install.packages('rstatix')"

# Run your Shiny app
Rscript -e "shiny::runApp('path/to/your/app.R')"