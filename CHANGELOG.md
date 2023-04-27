# Changelog for Material Symbols Icons package

## 4.39.4

*  Changed package to conform to the document defining the future built in 'native' support of the Material Symbols Icons fonts.
*  The instructions and use should now be compatible with the future Flutter implementation as defined in [here].(https://docs.google.com/document/d/1UHRKDl8-lzl_hW_K2AHnpMwvdPo0vGPbDI7mqACWXJY/edit)
*  Removed @nodoc tag from symbols.dart file so docs are generated, but they are 8gigs(!!!) dart doc needs to have the static sidebar fixed soon...

## 4.39.3

* Remove @staticIconProvider annotation because pub.dev does not like it no matter what the flutter version is.
* Added @nodoc to prevent documentation for outlined_suffix, rounded, rounded_suffix, sharp and sharp_suffix because dart doc is so large and inefficient that pub.dev generates 12gigs of docs otherwise.  Added listing of icon names/symbols for each class in lieu of proper dart docs.

## 4.39.2

* Changes to flutter 3.7.0/dart sdk 2.19.0 to get pub.dev to accept @staticIconProvider annotation
* Editted README.md, added dartdoc_options.yaml to get pub.dev to generate docs without errors,
* Lots of tweaking of update_package.dart code generator to generate better dart doc comments to generate better docs.

## 4.39.1

* Change to flutter 3.0.0/dart sdk 2.17.0 to support @staticIconProvider annotation
* Added screenshots to README.md and pubspec.yaml

## 4.39.0

* Initial release supporting the Material Symbols Icons variable fonts versions 4.39 for outline, rounded and sharp styles
  supporting dart sdk >=2.16.0
