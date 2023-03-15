<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
#Material Symbols Icons for Flutter

Why another version of this for flutter ? Because every other package for material icons is either out of date or has *INCORRECT* and *MISSING* icon definitions.

Here is a [live example](https://timmaffett.github.io/material_symbols_icons) of the current version of this package where you can test any Material Symbols icon name to verify it's availability.  The example also allows playing with all of the font variation options to explore further customizing the look of our Material Symbols.



This package includes an automatic generator program so that the user has the option of RE-generating the package at any time with the most current Material Symbols Icons definitions.  This program downloads the latest Material Symbols fonts from the github repository  XCXXXXXXYYYYZZZZZZ, and their corresponding codepoint definition files.  It will then automatically create the material_symbols_icons.dart definition source file.    This automatic generations allows this package to use Github CI routines to ensure that it is always up to date and in-sync with the latet Material Symbols defintions.

(No more finding an icon on XXXYYZZZ and then trying to use it name from XXYYZZ, and then discovering that it is missing.  Or worse using the name and then having the incorrect icon appear when you test your app!)


There are several options with how you reference the icons within your flutter program:

1) Importing `package material_symbols_icons\universal.dart` and using `MaterialSymbols.` as the base class.  This class contains regular, rounded and sharp versions of every icon.  You access them using `MaterialSymbols.iconname`, `MaterialSymbols.iconname_rounded` or `MaterialSymbols.iconname_sharp`
This is the largest of the options as it includes all 3 versions of the Material Symbols variable fonts (regular, rounded and sharp).

2) Alternately you if you are using only icons for a single variation (regular, rounded or sharp) then you can import 
  A) `package material_symbols_icons\regular.dart` and using `MaterialSymbols.iconname`
  B) `package material_symbols_icons\rounded.dart` and using `MaterialSymbols.iconname`
  C) `package material_symbols_icons\rounded_suffix.dart` and using `MaterialSymbols.iconname_rounded`  
  D) `package material_symbols_icons\sharp.dart` and using `MaterialSymbols.iconname`
  E) `package material_symbols_icons\sharp_suffix.dart` and using `MaterialSymbols.iconname_sharp`.

Importing the XXX_suffix.dart versions allows you the option of combining their use together without name collisions.
Importing the `rounded.dart` or `sharp.dart` versions allows you to easily swap our `regular.dart` with either of them, with that being only change in your code needed to switch between the use of the regular, rounded or sharp versions.

-----

ALl icon names that start with a number (like `360` or `9M`) but have their icon names prefixed with a `$` to make the names valid dart class member names.
SO if you want to access the icon with the name `360` you use `MaterialSymbols.$360` instead.

Additionally the iconnames `class`, `switch` and `try` have been renamed with a leading underscore also (`$class`, `$switch` and `$try`) as these are dart language reserved words.


------

The variable version so the Material Symbols fonts are used, so it is possible to further modify (or animate!) the icons by specifying your own paramters for XXX, YY and ZZZZ when creating your icons

```
    
    
    final myIcon = Icon( MaterialSymbols.settings, TextStyle( font_variations: [XXX:YYY]}



```

This package also includes a HELPER method for using Material Symbols varation fonts by allowing you to set DEFAULT variation settings and then have Icon() automatically use those variation settings each time a icon is created from the corresponding font.




(From https://github.com/google/material-design-icons/raw/master/README.md]
## Material Symbols

These newer icons can be browsed in a more user-friendly way at https://fonts.google.com/icons. Use the popdown menu near top left to choose between the two sets; Material Symbols is the default.

These icons were built/designed as variable fonts first (based on the 24 px designs from Material Icons). There are three separate Material Symbols variable fonts, which also have static icons available (but those do not have all the variations available, as that would be hundreds of styles):
- Outlined
- Rounded
- Sharp
- Note that although there is no separate Filled font, the Fill axis allows access to filled styles—in all three fonts.

Each of the fonts has these design axes, which can be varied in CSS, or in many more modern design apps:
- Optical Size (opsz) from 20 to 48 px. The default is 24.
- Weight from 100 (Thin) to 700 (Bold). Regular is 400.
- Grade from -50 to 200. The default is 0 (zero).
- Fill from 0 to 100. The default is 0 (zero).

The following directories in this repo contain specifically Material Symbols (not Material Icons) content:
- symbols
- variablefont

What is currently _not_ available in Material Symbols?
- only the 20 and 24 px versions are designed with perfect pixel-grid alignment
- the only pre-made fonts are the variable fonts
- there are no two-tone icons



## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
