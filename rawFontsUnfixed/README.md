# Material Symbols Icons Font font metrics correcting script

Currently (3/17/2023) the default fonts as release on the google material symbols repo [https://github.com/google/material-design-icons](https://github.com/google/material-design-icons) have incorrect font metrics and they do no render correctly within flutter. (They are not centered, they sit to low.)
This is caused by the font metrics tables within the fonts being incorrect.

According to :

[https://github.com/googlefonts/gf-docs/tree/main/VerticalMetrics#vertical-metrics](https://github.com/googlefonts/gf-docs/tree/main/VerticalMetrics#vertical-metrics)

Rule #1 is 'Vertical metrics must not be calculated by the font editor automatically'

So this is what I have done.
Each of the material symbols icon glyphs within the 3 fonts (outlined,rounded and sharp) are centered between the baseline at 0 and the top of the cell at 960.  The largest icons start at 110 and to to 850 - leaving a 110 margin at the top and bottom.
The good_XXXXXXX_hea_os2_tables.ttx files within this directory reset all of the ascender and descender settings to 960 and 0 respectively.
