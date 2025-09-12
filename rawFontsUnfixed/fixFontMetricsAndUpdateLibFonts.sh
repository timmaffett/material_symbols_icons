#!/bin/bash
#
# The font metrics within the release fonts are incorrect.  This requires them to be replaced so that they render correctly
# within flutter.
# This script requires that fonttools is installed
#  Python 3.8 or later is required.
#      pip install fonttools        (or pip3 install fonttools)
#    https://fonttools.readthedocs.io/en/latest/index.html
# THis is using TTX to merge the correct metrics into the font files
#      ttx info: https://fonttools.readthedocs.io/en/latest/ttx.html
#
# TMM Jan 12, 2024 - Now change the names of the fonts to remove the "[FILL,Grad,opsz,wght]" because the brackets [] were
#     having to be URL encoded by part of the flutter build process and then the testing harness could not load the fonts
#     because the URL encoded names are embedded in the flutter app and they can't be used on filesystem to load the fonts.
#     (See https://github.com/timmaffett/material_symbols_icons/issues/12 )

rm ../lib/fonts/*.ttf
ttx -m 'MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf' -b --no-recalc-timestamp -o '../lib/fonts/MaterialSymbolsOutlined.ttf' good_outlined_hhea_os2_tables.ttx
ttx -m 'MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf' -b --no-recalc-timestamp -o '../lib/fonts/MaterialSymbolsRounded.ttf' good_rounded_hhea_os2_tables.ttx
ttx -m 'MaterialSymbolsSharp[FILL,GRAD,opsz,wght].ttf' -b --no-recalc-timestamp -o '../lib/fonts/MaterialSymbolsSharp.ttf' good_sharp_hhea_os2_tables.ttx
