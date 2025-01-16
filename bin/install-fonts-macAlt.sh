#!/bin/bash

# attribution source: https://github.com/Jatin-Makhija-sys/Powershell-Scripts/blob/master/Intune/macOS/FontsDeployment/installFonts.sh
# Script: install_font.sh
# Description: This script downloads a font from a specified URL and installs it silently on a macOS system.

}

# Check if the font file already exists in /Library/Fonts
if [ -f "/Library/Fonts/MaterialSymbolsOutlined.ttf" ]; then
    echo "MaterialSymbolsOutlined Font already exists in /Library/Fonts. Updating with new version."

    # Use sudo to copy the font to /Library/Fonts
    sudo cp "MaterialSymbolsOutlined.ttf" "/Library/Fonts/"
    sudo chown root:wheel "/Library/Fonts/MaterialSymbolsOutlined.ttf"
    echo "MaterialSymbolsOutlined Font copied to /Library/Fonts successfully."
else
    echo "MaterialSymbolsOutlined Font does not exist in /Library/Fonts. Installing the font with FontBook."

    # Use sudo to copy the font to /Library/Fonts
    open -b com.apple.FontBook MaterialSymbolsOutlined.ttf
fi

# Check if the font file already exists in /Library/Fonts
if [ -f "/Library/Fonts/MaterialSymbolsRounded.ttf" ]; then
    echo "MaterialSymbolsRounded Font already exists in /Library/Fonts. Updating with new version."

    # Use sudo to copy the font to /Library/Fonts
    sudo cp "MaterialSymbolsRounded.ttf" "/Library/Fonts/"
    sudo chown root:wheel "/Library/Fonts/MaterialSymbolsRounded.ttf"
    echo "MaterialSymbolsRounded Font copied to /Library/Fonts successfully."
else
    echo "MaterialSymbolsRounded Font does not exist in /Library/Fonts. Installing the font with FontBook."

    # Use sudo to copy the font to /Library/Fonts
    open -b com.apple.FontBook MaterialSymbolsRounded.ttf
fi


# Check if the font file already exists in /Library/Fonts
if [ -f "/Library/Fonts/MaterialSymbolsSharp.ttf" ]; then
    echo "MaterialSymbolsSharp Font already exists in /Library/Fonts. Updating with new version."

    # Use sudo to copy the font to /Library/Fonts
    sudo cp "MaterialSymbolsSharp.ttf" "/Library/Fonts/"
    sudo chown root:wheel "/Library/Fonts/MaterialSymbolsSharp.ttf"
    echo "MaterialSymbolsSharp Font copied to /Library/Fonts successfully."
else
    echo "MaterialSymbolsSharp Font does not exist in /Library/Fonts. Installing the font with FontBook."

    # Use sudo to copy the font to /Library/Fonts
    open -b com.apple.FontBook MaterialSymbolsSharp.ttf
fi

