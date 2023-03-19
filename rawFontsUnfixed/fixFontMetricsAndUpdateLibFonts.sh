# The font metrics within the release fonts are incorrect.  This requires them to be replaced so that they render correctly
# within flutter.
# This script requires that fonttools is installed
#  Python 3.8 or later is required.
#      pip install fonttools        (or pip3 install fonttools)
#    https://fonttools.readthedocs.io/en/latest/index.html
# THis is using TTX to merge the correct metrics into the font files
#      ttx info: https://fonttools.readthedocs.io/en/latest/ttx.html
rm ../lib/fonts/*.ttf
ttx -m 'MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf' -b --no-recalc-timestamp -o '../lib/fonts/MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf' good_outlined_hhea_os2_tables.ttx
ttx -m 'MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf' -b --no-recalc-timestamp -o '../lib/fonts/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf' good_rounded_hhea_os2_tables.ttx
ttx -m 'MaterialSymbolsSharp[FILL,GRAD,opsz,wght].ttf' -b --no-recalc-timestamp -o '../lib/fonts/MaterialSymbolsSharp[FILL,GRAD,opsz,wght].ttf' good_sharp_hhea_os2_tables.ttx
