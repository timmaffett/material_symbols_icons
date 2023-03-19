# Material Symbols Icons for Flutter

## (with full variation support and automatic code generation capability for updating icon definition files)

Why another version of this for flutter ? Because every other package for material icons is either out of date or has *INCORRECT* and *MISSING* icon definitions.
These icons also support the complete set of icon variation parameters defined for the Material Symbols Icons.  This includes setting fill/not filled, various weights, grades and optical sizes.
This package contains a code generation dart file which automatically downloads the latest versions of the Material Symbols Icon font files from [https://github.com/google/material-design-icons](https://github.com/google/material-design-icons) and generates updated dart files containing all of the latest defined icons.  No more missing icons!

## [Live Example](https://timmaffett.github.io/material_symbols_icons)

Here is a [live example](https://timmaffett.github.io/material_symbols_icons) of the current version of this package where you can test any Material Symbols icon name to verify it's availability.  The example also allows playing with all of the font variation options to explore further customizing the look of our Material Symbols.

This package includes an automatic generator program so that the user has the option of RE-generating the package at any time with the most current Material Symbols Icons definitions.  This program downloads the latest Material Symbols fonts from the github repository [https://github.com/google/material-design-icons](https://github.com/google/material-design-icons), and their corresponding codepoint definition files.  It will then automatically create the material_symbols_icons.dart definition source file.    This automatic generations allows this package to use Github CI routines to ensure that it is always up to date and in-sync with the latet Material Symbols defintions.

(For users of the previous Flutter alternatives for Material Symbols Icons support - No more finding an icon on [https://fonts.google.com/icons?icon.style=Outlined](https://fonts.google.com/icons?icon.style=Outlined) and then trying to use it's name, and then discovering that it is missing, or worse yet having the incorrect icon appear!)


There are several options with how you reference the icons within your flutter program:

1) If you are using icon from a single style (outlined, rounded or sharp) then you can import 
  A) `package material_symbols_icons\outlined.dart` and using `MaterialSymbols.iconname` to reference icons.
  B) `package material_symbols_icons\outlined.dart` and using `MaterialSymbolsOutlined.iconname`
  C) `package material_symbols_icons\rounded.dart` and using `MaterialSymbols.iconname`
  D) `package material_symbols_icons\rounded_suffix.dart` and using `MaterialSymbolsRounded.iconname`  
  E) `package material_symbols_icons\sharp.dart` and using `MaterialSymbols.iconname`
  F) `package material_symbols_icons\sharp_suffix.dart` and using `MaterialSymbolsSharp.iconname`.

2) Alternatitely if you use icons from more than one of the styles, (or are coming from one of the previous Material Symbols Icon package) then importing `package material_symbols_icons\universal.dart` and using `MaterialSymbols.` as the base class.  This class contains outlined, rounded and sharp versions of every icon.  You access them using `MaterialSymbols.iconname_outlined`, `MaterialSymbols.iconname_rounded` or `MaterialSymbols.iconname_sharp`
This is the largest of the options as it includes all 3 versions of the Material Symbols variable fonts (outlined, rounded and sharp).  I would imagine that most users will pick the style of the icons they prefer and use one of the specific classes from #1.  This option is included primarily for users coming from one of the pre-existing packages.

Importing the XXX_suffix.dart versions allows you the option of combining their use together without name collisions.
Importing the `rounded.dart` or `sharp.dart` versions allows you to easily swap `outlined.dart` with either of them, with that being only change in your code needed to switch between the use of the regular, rounded or sharp styles.

--------------------------------------;

ALl icon names that start with a number (like `360` or `9M`) but have their icon names prefixed with a `$` to make the names valid dart class member names.
SO if you want to access the icon with the name `360` you use `MaterialSymbols.$360` instead.

Additionally the iconnames `class`, `switch` and `try` have been renamed with a leading underscore also (`$class`, `$switch` and `$try`) as these are dart language reserved words.

--------------------------------------;

The variable version so the Material Symbols fonts are used, so it is possible to further modify (or animate!) the icons by specifying your own paramters for XXX, YY and ZZZZ when creating your icons

```
    
    
    final myIcon = Icon( MaterialSymbols.settings, TextStyle( font_variations: [XXX:YYY]}



```

This package also includes a HELPER method for using Material Symbols varation fonts by allowing you to set DEFAULT variation settings and then have Icon() automatically use those variation settings each time a icon is created from the corresponding font.

[From https://github.com/google/material-design-icons/raw/master/README.md](https://github.com/google/material-design-icons/raw/master/README.md)
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
