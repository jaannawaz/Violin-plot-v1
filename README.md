# Violin Plot App

## Overview

This repository contains a Shiny application for generating violin plots. The application is designed to be user-friendly and can be run on both Windows and macOS.

## Requirements

- R (will be installed automatically)
- Homebrew (for macOS, will be installed automatically)
- Required R packages (will be installed automatically)

## Installation Instructions for macOS

### Step 1: Download the Shell Script

1. Download the `install_and_run.sh` script from this repository.

### Step 2: Install Platypus

1. **Download Platypus**:
   - Visit the [Platypus website](https://sveinbjorn.org/platypus) and download the latest version.

2. **Install Platypus**:
   - Open the downloaded `.dmg` file and drag the Platypus application to your Applications folder.

### Step 3: Create a macOS Application

1. **Open Platypus**:
   - Launch the Platypus application.

2. **Create a New Project**:
   - Click on "New Project".

3. **Configure the Project**:
   - **Script Type**: Select "Shell".
   - **Script**: Choose the `install_and_run.sh` script you downloaded.
   - **Name**: Enter a name for your application (e.g., "Violin Plot App").
   - **Icon**: Optionally, you can choose an icon for your application.
   - **Output**: Set the output type to "Application".

4. **Build the Application**:
   - Click on the "Create" button to build your application.
   - Choose a location to save the application bundle (e.g., your Applications folder).

### Step 4: Run the Application

1. **Locate the Application**:
   - Navigate to the location where you saved the application bundle.

2. **Run the Application**:
   - Double-click the application icon to run it.
   - The application will automatically install R, the required packages, and launch the Shiny app in your default web browser.

## Installation Instructions for Windows

### Step 1: Download the Batch File

1. Download the `install_and_run.bat` file from this repository.

### Step 2: Run the Batch File

1. **Locate the Batch File**:
   - Navigate to the folder where you saved the `install_and_run.bat` file.

2. **Run the Batch File**:
   - Right-click on the `install_and_run.bat` file and select "Run as administrator".
   - The script will automatically download and install R, the required packages, and launch the Shiny app in your default web browser.

## Usage

1. Upload your CSV file with the required data.
2. Customize the plot settings as needed.
3. Click "Generate Plot" to view the violin plot.

## Troubleshooting

- Ensure you have an active internet connection during the installation process.
- If you encounter any issues, please check the console output for error messages.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
