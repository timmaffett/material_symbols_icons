# Generates the dart source files with all current icons defined within the respective Material Symbols Icons fonts.

The `update_package.dart` program downloads the latest code point and font files from the google github repo for the Material Symbols Icon fonts.  This tool should be re-run each time there is a new release of the Material Symbols Icon library with new icons.

The command to do this is :

```shell
dart run update_package.dart -d
```

The `-d` argument instucts the tool to also download the latest font files and place them in the `../rawFontsUnfixed' directory.
Currently the fonts have incorrect font metrics and do no render correctly within flutter  - so the `../rawFontsUnfixed' directory
contains correct metric files and a script that uses the python `fonttools` package to rebuild the fonts with the correct font metrics.
The ``../rawFontsUnfixed/fixFontMetricsAndUpdateLibFonts.sh` script then places the updated (now working) fonts within the `../lib/fonts' directory.

You run this script from the `../rawFontsUnfixed` directory using the `fixFontMetricsAndUpdateLibFonts.sh` script.


Issue [https://github.com/google/material-design-icons/issues/1500](https://github.com/google/material-design-icons/issues/1500) has been issued and the ruling
is that this is a NO FIX - as I suspected it might be - for compatibility with all existing and future non-flutter users of the material symbols icons fonts.

~~A issue has been filed for this problem and if the google repo corrects the building of the fonts to include correct metrics then the `update_package.dart` tool will be updated to directly download the fonts to the `../lib/fonts' directoty.
(This may not be possible for them to fix the metrics as existing users may depend on the incorrect metrics ?! I am not sure but I hope they can fix the metrics so we don't have to.)~~
