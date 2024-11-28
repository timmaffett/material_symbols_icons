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


## Steps to update to new variable fonts release
-----
Steps to update pakcage when new fonts are released.

0.5) cd to \generator
1) `dart run update_package.dart -s -d` 
2) figure out source font version number with `ttx -s oneofthefonts.ttf`
    (cd ~/source/fonttools; copy font there 
      `cp /mnt/c/src/material_symbols_icons/rawFontsUnfixed/MaterialSymbolsOutline*.ttf .`
     and then ttx).
    (version number found at `fontRevision` entry in `MaterialSymbolsXXXXX._h_e_a_d.ttx`)
3) Update `CHANGELOG.md` with version number of new fonts
3.05) Do a diff of last two LAST_VERSION/icon_unicodes
      Edit and incorporate added/changed icons into the `CHANGELOG.md`
3.1) Update `pubspec.yaml` with new fonts version number
3.5) Update root `README.md` with version number of new fonts and date of their release on google material design github
4) linux run the rawFontsUnfixed/fixFontMetricsAndUpdateLibFonts.sh to patch fonts/install into lib/fonts
     `cd /material_symbols_icons/rawFontsUnfixed`
     `./fixFontMetricsAndUpdateLibFonts.sh`
5) update source font `materialSymbolsIconsSourceFontVersionNumber` and
   `materialSymbolsIconsSourceReleaseDate` to example\main.dart
6) `buildWeb.bat` example
7) update timmaffett.github.io with example
     `cp /mnt/c/src/material_symbols_icons/example/build/web/* . -r`
     `git add -A *`
     `git commit -m 'update to official font version XXX'`
     `git push https://timmaffett:.....`
8) sync source to github
9) `dart pub publish --dry-run`  package
10) `dart pub publish` package
