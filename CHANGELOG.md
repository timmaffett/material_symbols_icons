# Changelog for Material Symbols Icons package

## 4.2670.0

* Update to version 2.670 of the material symbols icons variable fonts released 07/27/2023
* Added < f87f  # passkey, f571  # vr180_create2d_off
* Changed many codepoints, see 'diff icon_unicodes_08_04_23.txt icon_unicodes_07_25_23.txt' for details

## 4.2668.0

* Update to version 2.668 of the material symbols icons variable fonts released 07/20/2023
* Added f587  # article_shortcut,f58c  # audio_description, f588  # candle,f585  # destruction,
  f580  # ev_shadow_add, f57f  # ev_shadow_minus, f586  # folder_data, f58b  # full_hd, f58f  # network_wifi_1_bar_locked,
  f58e  # network_wifi_2_bar_locked, f58d  # network_wifi_3_bar_locked, f584  # shadow_add, f583  # shadow_minus,
  f57e  # shutter_speed_add, f57d  # shutter_speed_minus, f57c  # texture_add, f57b  # texture_minus, f582  # thermometer_add
  f581  # thermometer_minus, f58a  # voice_selection
* Changed code points for battery_charging_30, battery_charging_50, battery_charging_60, battery_charging_80, battery_charging_90
  battery_charging_full, forward,  google_plus_reshare, google_wifi, nest_gale_wifi, shortcut, thumb_down, thumb_down_alt, thumb_down_filled,
  thumb_down_off, thumb_down_off_alt, thumb_up, thumb_up_alt, thumb_up_filled, thumb_up_off, thumb_up_off_alt

## 4.2667.0

* Update to version 2.667 of the material symbols icons variable fonts released 07/13/2023
* Added f591  # expand_circle_right, f592  # shield_locked

## 4.2665.0

* Update to version 2.665 of the material symbols icons variable fonts released 6/29/2023
* Added f1dd  #flutter

## 4.2663.0

* Update to version 2.663 of the material symbols icons variable fonts released 6/22/2023
* Added f59e  # emergency_share_off, f59b  # info_i, f59a  # person_raised_hand, and f59d  # safety_check_off
* Update readme files

## 4.2662.0

* Updsate to version 2.662 of material symbols icons variable fonts
* Added pub.dev shield link to README.md - fixes #5

## 4.2661.1

* Add version number of material symbols icons variable fonts to top of README.md

## 4.2661.0  

* Updated the font variable symbol fonts to versions 2.661 from 6/9/2023 from [official material symbols icon repo](https://github.com/google/material-design-icons)

## 4.2659.0  

* Updated the font variable symbol fonts to versions 2.659 from 6/5/2023 from [official material symbols icon repo](https://github.com/google/material-design-icons)
* Example enhanced to save state in URL of web version, and to copy the symbol name to the clipboard when icon is pressed.

## 4.39.5

* Made dart format/analyze happy, fixed update_package.dart to generate dart format safe code.

## 4.39.4

* Changed package to conform to the document defining the future built in 'native' support of the Material Symbols Icons fonts.
* The instructions and use should now be compatible with the future Flutter implementation as defined in [here](https://docs.google.com/document/d/1UHRKDl8-lzl_hW_K2AHnpMwvdPo0vGPbDI7mqACWXJY/edit).
* Added option to Remove @nodoc tag from symbols.dart for when dart doc supports removal of sidebar.. someday...

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
