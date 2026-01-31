#!/bin/bash

echo "Installing Material Symbols Icons Font globally into /Library/Fonts. You will be asked for your sudo password."

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
    sudo cp "MaterialSymbolsOutlined.ttf" "/Library/Fonts/"
    sudo chown root:wheel "/Library/Fonts/MaterialSymbolsOutlined.ttf"
    echo "MaterialSymbolsOutlined Font copied to /Library/Fonts successfully."
    # Run FontBook to validate the font
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
    sudo cp "MaterialSymbolsRounded.ttf" "/Library/Fonts/"
    sudo chown root:wheel "/Library/Fonts/MaterialSymbolsRounded.ttf"
    echo "MaterialSymbolsRounded Font copied to /Library/Fonts successfully."
    # Run FontBook to validate the font
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
    sudo cp "MaterialSymbolsSharp.ttf" "/Library/Fonts/"
    sudo chown root:wheel "/Library/Fonts/MaterialSymbolsSharp.ttf"
    echo "MaterialSymbolsSharp Font copied to /Library/Fonts successfully."
    # Run FontBook to validate the font
    open -b com.apple.FontBook MaterialSymbolsSharp.ttf
fi

