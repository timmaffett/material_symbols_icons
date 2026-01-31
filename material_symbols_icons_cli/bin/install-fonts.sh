#!/bin/bash

# attribution: https://gist.github.com/kevin-lee/328e9993d6b3ad250636023fb2c7827f

the_fonts_dir=$(pwd)
echo "the_fonts_dir: $the_fonts_dir"

find_command="find \"$the_fonts_dir\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"

if [[ `uname` == 'Darwin' ]]; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p $font_dir
fi

echo -e "Run: $find_command | xargs -0 -I % cp \"%\" \"$font_dir/\"\n"

# Copy all fonts to user fonts directory
echo "Copying fonts..."
# printing
eval $find_command | xargs -0 -I %

eval $find_command | xargs -0 -I % cp "%" "$font_dir/"

# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    echo -e "\nResetting font cache, this may take a moment..."
    fc-cache -f $font_dir
fi

if [[ `uname` == 'Darwin' ]]; then
  # MacOS
  echo -e "\nSkipping FontBook validation - If fonts are not available re-run install_material_symbols_icons_fonts with --usefontbook option."
fi


echo -e "\nAll fonts have been installed to $font_dir"