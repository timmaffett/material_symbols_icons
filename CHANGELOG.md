# Changelog for Material Symbols Icons package

## 4.2867.0

* Update to version 2.867 of the material icons variable fonts 'released' 08/14/2025 with 4092 icons
* (My PRs https://github.com/google/material-design-icons/pull/1928 and https://github.com/google/material-design-icons/pull/1929 
   were merged into https://github.com/google/material-design-icons and the main.ml action is generating fonts every
   thursday at 7pm pacific time. Yippee!)
* Added ef06  # android_cell_4_bar, ef09  # android_cell_4_bar_alert, ef08  # android_cell_4_bar_off, ef07  # android_cell_4_bar_plus,
  ef02  # android_cell_5_bar, ef05  # android_cell_5_bar_alert, ef04  # android_cell_5_bar_off, ef03  # android_cell_5_bar_plus,
  ef0d  # android_cell_dual_4_bar, ef0f  # android_cell_dual_4_bar_alert, ef0e  # android_cell_dual_4_bar_plus, ef0a  # android_cell_dual_5_bar,
  ef0c  # android_cell_dual_5_bar_alert, ef0b  # android_cell_dual_5_bar_plus, ef16  # android_wifi_3_bar, ef1b  # android_wifi_3_bar_alert,
  ef1a  # android_wifi_3_bar_lock, ef19  # android_wifi_3_bar_off, ef18  # android_wifi_3_bar_plus, ef17  # android_wifi_3_bar_question,
  ef10  # android_wifi_4_bar, ef15  # android_wifi_4_bar_alert, ef14  # android_wifi_4_bar_lock, ef13  # android_wifi_4_bar_off,
  ef12  # android_wifi_4_bar_plus, ef11  # android_wifi_4_bar_question, eef6  # arrow_shape_up, eef7  # arrow_shape_up_stack,
  eef8  # arrow_shape_up_stack_2, f241  # award_meal, f257  # battery_android_frame_1, f256  # battery_android_frame_2,
  f255  # battery_android_frame_3, f254  # battery_android_frame_4, f253  # battery_android_frame_5, f252  # battery_android_frame_6,
  f251  # battery_android_frame_alert, f250  # battery_android_frame_bolt, f24f  # battery_android_frame_full,
  f24e  # battery_android_frame_plus, f24d  # battery_android_frame_question, f24c  # battery_android_frame_share,
  f24b  # battery_android_frame_shield, f246  # briefcase_meal, ef2a  # bucket_check, f243  # calendar_check, f242  # calendar_lock,
  f240  # calendar_meal_2, ef30  # child_hat, ef2f  # conversation, f23f  # hanami_dango, f247  # image_inset, f23e  # kanji_alcohol,
  f249  # mail_shield, f23d  # meal_dinner, f23c  # meal_lunch, f245  # money_range, eefb  # page_menu_ios, f22d  # parent_child_dining,
  ef2e  # partner_heart, f244  # percent_discount, f22a  # rest_area, eefa  # search_gear, ef2d  # settings_seating, f225  # shaved_ice,
  ef36  # soba, ef35  # solo_dining, ef2c  # table_sign, ef34  # takeout_dining_2, ef33  # tatami_seat, eefc  # thumbs_up_double,
  ef32  # udon, f248  # windshield_defrost_auto, ef31  # yakitori

## 4.2858.1

* Update to version 2.858 of the material icons variable fonts 'released' 07/30/2025 with 4018 icons
  ('released' is in quotes because of offical repo action still being broken and I am pulling from my fixed
  repo)
* After waiting over 3 months for the official repo to fix their broken action to generate the fonts
  (which usually happens on thursday at midnight every week) the github user https://github.com/mwillsey
  educated me on the fact that the action can be fixed by changing the action runner to `ubuntu-latest` from
  `ubuntu-20.04-4core`.  I did this for my copy of the offical repo and was able to successfully generate the fonts!
  So we finally have new fonts after almost 4 months!  There have been many new symbols added as you can see below.
  I have submitted PR https://github.com/google/material-design-icons/pull/1922 to fix the official repo and I
  hope it gets merged soon.  For now I will be able to generate the fonts until google fixes the official repo.
* Changed the update_package.dart file to have a flag allowing pulling fonts from my fixed copy of the repo.
* Added f2c4  # acupuncture, f2c5  # approval_delegation_off, f267  # auto_stories_off, f2a8  # badminton,
  f286  # bath_bedrock, f2a0  # bath_soak, f285  # beer_meal, f296  # calendar_meal, f278  # car_defrost_mid_left,
  f277  # car_defrost_mid_low_right, f29f  # chair_counter, f29e  # chair_fireplace, f29d  # chair_umbrella,
  f27e  # check_circle_unread, f261  # chess_bishop, f262  # chess_bishop_2, f25f  # chess_king,
  f260  # chess_king_2, f25e  # chess_knight, f25d  # chess_pawn_2, f25c  # chess_queen, f25b  # chess_rook,
  f2b2  # diamond_shine, f29c  # dine_heart, f295  # dine_in, f29b  # dine_lamp, f25a  # drone, f259  # drone_2,
  f2c7  # eyeglasses_2, f265  # eyeglasses_2_sound, f28d  # garage_check, f28c  # garage_money, f294  # hand_meal,
  f293  # hand_package, f2c3  # health_cross, f2ec  # hearing_aid_disabled_left, f2ed  # hearing_aid_left,
  f292  # heart_smile, f29a  # high_chair, f284  # japanese_curry, f283  # japanese_flag, f298  # map_pin_heart,
  f297  # map_pin_review, f2c2  # massage, f291  # menu_book_2, e200  # mobile_friendly, e7ba  # mobile,
  f2db  # mobile_2, f2da  # mobile_3, f2d3  # mobile_alert, f2cd  # mobile_arrow_down, f2d2  # mobile_arrow_right,f2b9  # mobile_arrow_up_right, f2e5  # mobile_block, f44e  # mobile_camera, f2c9  # mobile_camera_front,
  f2c8  # mobile_camera_rear, f2ea  # mobile_cancel, f2cc  # mobile_cast, f2e3  # mobile_charge, f79f  # mobile_chat,
  f073  # mobile_check, f2e2  # mobile_code, f2d0  # mobile_dots, f073  # mobile_friendly, f2d9  # mobile_gear,
  f2dc  # mobile_info, ed3e  # mobile_landscape, f2bf  # mobile_layout, f2d8  # mobile_lock_landscape,
  f2be  # mobile_lock_portrait, f2d1  # mobile_menu, f2e1  # mobile_question, f2d5  # mobile_rotate,
  f2d6  # mobile_rotate_lock, f2ef  # mobile_sensor_hi, f2ee  # mobile_sensor_lo, f2df  # mobile_share,
  f2de  # mobile_share_stack, f2e8  # mobile_sound, f7aa  # mobile_sound_off, f2eb  # mobile_text,
  f2e6  # mobile_text_2, f2e4  # mobile_ticket, f2cb  # mobile_vibrate, f2b0  # mobile_wrench, f28b  # moped_package,
  f282  # mountain_steam, f2a3  # movie_speaker, f2c1  # music_history, f27d  # nest_farsight_cool,
  f27c  # nest_farsight_dual, f27b  # nest_farsight_eco, f27a  # nest_farsight_heat, f279  # nest_farsight_seasonal,
  f281  # okonomiyaki, f2a7  # padel, f28a  # parking_meter, f289  # parking_sign, f288  # parking_valet,
  f2c0  # payment_arrow_down, f2a1  # payment_card, f290  # person_heart, f2a6  # pickleball,
  f2ac  # plane_contrails, f28e  # playground, f28f  # playground_2, f266  # reset_exposure, f2ad  # shield_toggle,
  f258  # sign_language_2, f287  # subway_walk, f264  # sync_saved_locally_off, f299  # table_large,
  f2af  # timer_1, f2ae  # timer_2, f2b4  # tonality_2, f263  # translate_indic, f2b3  # vignette_2,
  f280  # washoku, f2ca  # watch_arrow, f27f  # yoshoku
  The following symbols changed their code points: ad_units ef39 > f2eb, add_to_home_screen  e1fe > f2b9,
  aod efda > f2e6, app_blocking  ef3f > f2e5, app_promo  e981 > f2cd, app_settings_alt ef41 > f2df,
  app_shortcut eae4 > f2d9, book_online f217 > f2e4, camera_front e3b1 > f2c9, camera_rear e3b2 > f2c8,
  charging_station f19d > f2e3, developer_mode e1b0 > f2e2, device_unknown e339 > f2e1, dock e30e > f2e0,
  edgesensor_high f005 > f2ef, edgesensor_low f006  > f2ee, install_mobile eb72 > f2cd,
  mobile_screen_share e0e7 > f2df, offline_share e9c5 > f2de, open_in_phone e702 > f2d2,
  perm_device_information e8a5 > f2dc, phone_android  e324 > f2db, phone_iphone e325 > f2da,
  phonelink_erase e0db > f2ea, phonelink_lock e0dc > f2be, phonelink_off e327  > f7a5,
  phonelink_ring e0dd > f2e8, phonelink_setup ef41 > f2d9, screen_lock_landscape e1be > f2d8,
  screen_lock_portrait e1bf  > f2be, screen_lock_rotation e1c0  > f2d6, screen_rotation e1c1 > f2d5,
  security_update f072 > f2cd, security_update_warning f074 > f2d3, send_to_mobile f05c > f2d2,
  settings_cell e8bc > f2d1, smart_screen f06b > f2d0, smartphone e32c > e7ba, stay_current_landscape e0d3 > ed3e,
  stay_current_portrait e0d4  > e7ba, stay_primary_landscape e0d5 > ed3e, stay_primary_portrait e0d6  > f2d3,
  system_security_update f072 > f2cd, system_security_update_warning f074 > f2d3, system_update f072 > f2cd,
  tap_and_play e62b > f2cc, vibration e62d > f2cb

## 4.2815.1

* Added Right To Left (RTL) language support for all of the icons (YeeHa!!)
* Added support for including all of the known metadata for each of the material symbols icons.
  This data is found in `libs\material_symbols_metadata.dart`
  This data may be useful for anyone creating a material symbols icon viewer, etc.
  This metadata includes icon categories, tags, original name (if it had to be renamed),
  popularity,  and RTL mirroring info.
* Because of [this issue](https://github.com/google/material-design-icons/issues/1902) in the official repo
  new versions of the material symbols icons are no longer being generated.  UNFORTUNATELY.

## 4.2815.0

* Update to version 2.815 of the material icons variable fonts released 04/10/2025 with 3899 icons
* Added ed38  # threed, f30d  # battery_android_0, f30c  # battery_android_1, f30b  # battery_android_2,
  f30a  # battery_android_3, f309  # battery_android_4, f308  # battery_android_5, f307  # battery_android_6,
  f306  # battery_android_alert, f305  # battery_android_bolt, f304  # battery_android_full, f303  # battery_android_plus,
  f302  # battery_android_question, f301  # battery_android_share, f300  # battery_android_shield, f3e0  # book_4_spark,
  f2f3  # cannabis, f2f7  # computer_arrow_up, f2f6  # computer_cancel, f2f5  # device_band, f310  # landscape_2_edit,
  f313  # mobile_hand_left, f312  # mobile_hand_left_off, f314  # mobile_hand_off, f2f4  # router_off,
  f30f  # shield_watch, f2ff  # split_scene_down, f2fe  # split_scene_left, f2fd  # split_scene_right,
  f2fc  # split_scene_up, f2f2  # tab_search, f30e  # verified_off

## 4.2811.0

* Update to version 2.811 of the material icons variable fonts released 03/21/2025 with 3869 icons
* Added f317  # image_arrow_up, f318  # mobile_sound_2 and e384  # person_shield
* Fixed some analyzer warnings in the example.

## 4.2810.1

* Added example image of vscode icon preview
* Remove src font reference from svg icon preview because vscode sandbox ignores this anyway
  (locally installed font family is required so this was really just legacy attempt that failed
  and is now removed to make symbols.dart file significantly smaller)

## 4.2810.0

* Update to version 2.810 of the material icons variable fonts released 03/13/2025 with 3866 icons
* Added f327  # earbud_case, f326  # earbud_left, f325  # earbud_right,
  f324  # earbuds_2, f323  # mobile_hand, f322  # mobile_loupe, f321  # mobile_screensaver,
  f320  # mobile_speaker, f31d  # star_shine, f31c  # stars_2, f31f  # wand_shine
  and f31e  # wand_stars

## 4.2808.1

* Fix HR lines in README.md horizontal rule lines which were not rendering correctly after lint fix.

## 4.2808.0

* Update to version 2.808 of the material icons variable fonts released 03/06/2025 with 3854 icons
* Added f34e  # accessible_menu, f344  # car_defrost_left, f343  # car_defrost_low_left,
  f342  # car_defrost_low_right, f341  # car_defrost_mid_low_left, f340  # car_defrost_mid_right,
  f33f  # car_defrost_right, f33e  # car_fan_low_left, f33d  # car_fan_low_mid_left,
  f33c  # car_fan_low_right, f33b  # car_fan_mid_left, f33a  # car_fan_mid_low_right,
  f339  # car_fan_mid_right, f338  # car_fan_recirculate, f337  # car_gear,
  f336  # car_lock, f335  # car_mirror_heat, f357  # chef_hat, f351  # dropper_eye, f356  # ear_sound,
  f334  # fan_focus, f333  # fan_indirect, f345  # fragrance, f346  # graph_7, f332  # hvac_max_defrost,
  f34f  # moon_stars, f353  # notification_sound, f331  # seat_cool_left, f330  # seat_cool_right
  f32f  # seat_heat_left, f32e  # seat_heat_right, f32d  # seat_vent_left, f32c  # seat_vent_right,
  f32b  # steering_wheel_heat, f355  # subtitles_gear, f34d  # switch_access_3, f352  # voicemail_2,
  f350  # vpn_lock_2, f32a  # windshield_defrost_front, f329  # windshield_defrost_rear,
  f328  # windshield_heat_front

## 4.2805.2

* Fix typos in README.md, add repository: and topics: to pubspec.yaml

## 4.2805.1

* Remove test directory and dependency on flutter_test because there were no tests.
* Downgraded to path version 1.9.0 from 1.9.1 to avoid conflict with flutter_test on stable

## 4.2805.0

* Update to version 2.805 of the material icons variable fonts released 01/30/2025 with 3813 icons
* Added f35b  # alarm_pause, f35a  # plug_connect, f359  # stack_group
* Added outline to search box on example icon browser to highlight search term TextFormField

## 4.2804.1

* Updated README.md to include docs on supporting Gutter Icon Preview within Android Studio.
* NOPE: Turns out [this bug](https://github.com/flutter/flutter-intellij/issues/6932)
  still prevents Android Studio from working after restart - and it will just hang.
  (This has nothing to do with material_symbols_icons, it happens for whatever Font
  Package you add to the Flutter settings).

## 4.2804.0

* Update to version 2.804 of the material icons variable fonts released 01/23/2025 with 3810 icons
* Added f368  # article_person, f35d  # globe_location_pin, f360  # inbox_text_asterisk,
  f35e  # inbox_text_person, f35c  # inbox_text_share, f361  # lock_open_circle,
  f369  # nfc_off, f367  # notification_settings, f366  # stylus_brush, f365  # stylus_fountain_pen,
  f364  # stylus_highlighter, f363  # stylus_pen, f362  # stylus_pencil

## 4.2801.8

* Fixes to `install_material_symbols_icons_fonts` command

## 4.2801.2

* Add support for `dart pub global activate material_symbols_icons` and `install_material_symbols_icons_fonts` command
  to automatically install the fonts on windows, macos and linux to support VSCode icon previews.

## 4.2801.1

* Fix update_package.dart so that the generated `symbols_map.dart` file matches the dart format output and
  package does not get docked for having file that does not match dart format.

## 4.2801.0

* Update to version 2.801 of the material icons variable fonts released 12/05/2024 with 3797 icons
* Added f36d  # boat_bus, f36c  # boat_railway, f36b  # bus_railway, ecb3  # crown

## 4.2800.2

* Update the README.md file to include some info on installing the fonts directly from the package.

## 4.2800.1

* Regenerate the files with `update_package.dart -s` flag to generate the dart doc code for inline svg's that allow
  icon preview when the fonts are installed locally.  I had been missing this when generating the dart docs
  for some time !?

## 4.2800.0

* Update to version 2.800 of the material icons variable fonts released 11/22/2024 with 3793 icons
* Added f388  # brick, f386  # cloud_lock, f38e  # database_search, f385  # document_search,
  f380  # edit_arrow_down, f396  # fit_page_width, f395  # folder_info, f37e  # hourglass_arrow_down,
  f37d  # hourglass_arrow_up, f38c  # hourglass_pause, f36f  # match_case_off, f371  # network_intel_node,
  f383  # page_footer, f384  # page_header, f374  # screenshot_frame_2, f370  # skull_list,
  f37a  # thermostat_arrow_down, f379  # thermostat_arrow_up, f376  # view_apps

## 4.2799.0

* Update to version 2.799 of the material icons variable fonts released 11/15/2024 with 3774 icons
* Added f394  # arrows_input, f393  # arrows_output, f159  # bedtime, ef44  # bedtime,f375  # cards_star,
  f382  # clock_arrow_down, f381  # clock_arrow_up, f3a2  # delivery_truck_bolt, f3a1  # delivery_truck_speed,
  f37f  # edit_arrow_up, f397  # fit_page_height, f38d  # flowchart, f3a0  # graph_1, f39f  # graph_2,
  f39e  # graph_3, f39d  # graph_4, f39c  # graph_5, f39b  # graph_6, f3b0  # hearing_aid_disabled,
  f399  # inbox_text, f392  # mic_alert, f3aa  # modeling, f391  # music_note_add, f3ab  # pinboard,
  f3ac  # pinboard_unread, f387  # planet, f159  # quiet_time, eb76  # quiet_time_active, e1f9  # quiet_time,
  e291  # quiet_time_active, f398  # save_clock, f39a  # shopping_bag_speed, f3a7  # siren, f3a6  # siren_check,
  f3a5  # siren_open, f3a4  # siren_question, f37c  # sync_arrow_down, f37b  # sync_arrow_up,
  f378  # timer_arrow_down, f377  # timer_arrow_up, f38b  # touch_double, f38a  # touch_long,
  f389  # touch_triple, f390  # videocam_alert
* Changed code point of `grade` from e885 to f09a  

## 4.2791.1

* Total icons now 3736 after removing the two duplicated and erroneous icon names
* Fix symbol renaming so it makes more sense and does not rename symbols that do not need to be
  renamed.  This has resulted in some name changes to symbols - but it should make the symbol names
  more closely match the names of the Material Symbols Icons in Google Fonts.
* Rename 'door_back_door' to 'door_back'
* Rename 'door_front_door' to 'door_front'
* Rename 'error_circle_rounded_error' to 'error_circle_rounded'
* Remove 'power_rounded_power' - it was just a duplicate of 'power_settings_new'
* Remove 'expension_panels' (only found in 4.2791.0) - a spelling error in 2.791 codepoint files
* Removed original material symbols icons names which had to be renamed for dart to
  `materialSymbolsMap` map in `symbols_map.dart` and added them instead to a new
  Map called `renamedMaterialSymbolsMap` in `symbols_map.dart`.  This map contains the
  original name as the key and the renamed name as the value.
* Fix example app to transparently support searching over the original material symbols names

## 4.2791.0

* Update to version 2.791 of the material icons variable fonts released 10/17/2024 with 3738 icons
* Added ef82  # books_movies_and_music, f3b6  # chess_pawn, f3b5  # cognition_2, eb28  # delivery_dining,
  f3be  # desktop_cloud_stack, ea7d  # docs, ef90  # expansion_panels, ef90  # expension_panels,
  f3b2  # file_export, f3bb  # file_json, f3bc  # file_png, ea85  # files, ef52  # highlight_alt,
  e2dd  # identity_aware_proxy, ebb7  # identity_platform, ef52  # ink_selection, eb28  # moped,
  efab  # multiple_airports, efac  # network_intelligence, f3b4  # owl, e706  # rate_review_rtl,
  f3bd  # server_person, e5f7  # share_eta, f3bf  # split_scene, f3b3  # square_dot,
  eaed  # threat_intelligence, f3ba  # widget_medium, f3b9  # widget_small, f3b8  # widget_width
* Fixed [issue #9](https://github.com/timmaffett/material_symbols_icons/issues/9) so that URL query parameters
  now work again and URLs to example app state will properly restore that state (all settings and search
  parameters)
  Added original material symbols icons names which had to be renamed for dart to
  `materialSymbolsMap` map in `symbols_map.dart`
  Added original material symbols icons names which had to be renamed for dart to
  `materialSymbolsIconNameToUnicodeMap` map in `iconname_to_unicode_map.dart`

## 4.2789.0

* Update to version 2.789 of the material icons variable fonts released 10/11/2024 with 3709 icons
* Added f3cb  # chat_paste_go_2, f3c8  # folder_code, f3c9  # globe_book, f3ca  # map_search,
  f3c7  # table_convert, f3c6  # table_edit, f3c5  # text_compare, f3c3  # tile_large,
  f3c2  # tile_medium, f3c1  # tile_small and f3c4  # two_pager_store

## 4.2788.0

* Update to version 2.788 of the material icons variable fonts released 10/4/2024 with 3698 icons
* Added f3dd  # add_2, f3d3  # arrow_menu_close, f3d2  # arrow_menu_open,
  f3e0  # book_4_spark, f3df  # book_6, f3e7  # book_ribbon, f3cc  # cloud_alert,
  f3dc  # database_upload, f3db  # desktop_cloud, f3e2  # file_map_stack,
  f3d1  # filter_arrow_right, f3d8  # flag_check, f3d7  # folder_check,
  f3d6  # folder_check_2, f3d5  # folder_eye, f3d4  # folder_match, f3e4  # fork_spoon,
  f3ce  # group_search, f3da  # hard_disk, f3e6  # history_2, f3d9  # host,
  f3cd  # laptop_car, f3e3  # lightbulb_2, f3de  # list_alt_check, f3f0  # pixel_9_pro_fold,
  f3ef  # reg_logo_ift, f3e5  # search_activity, f3e1  # simulation,
  f3d0  # tab_close_inactive, f3cf  # upi_pay

## 4.2785.1

* Fix static analysis error 'Dangling library comment' in get.dart and material_symbols_icon.dart
  by adding `library;` line

## 4.2785.0

* Update to version 2.784 of the material icons variable fonts released 09/5/2024 with 3672 icons
* Added f3ea  # dashboard_2, f3ee  # money_bag, f3f0  # pixel_9_pro_fold, f3ef  # reg_logo_ift,
  f3ed  # tooltip_2, f3ec  # tv_displays, f3eb  # tv_next

## 4.2784.0

* Update to version 2.784 of the material icons variable fonts released 08/22/2024 with 3665 icons
* Added f3f2  # twenty_four_fps_select, f3f4  # arrow_upload_progress, f406  # devices_fold_2,
  f3fc  # eraser_size_1, f3fb  # eraser_size_2, f3fa  # eraser_size_3, f3f9  # eraser_size_4,
  f3f8  # eraser_size_5, f402  # face_down, f401  # face_left, f400  # face_nod,
  f3ff  # face_right, f3fe  # face_shake, f3fd  # face_up, f3f3  # hand_gesture_off,
  f407  # policy_alert, f40a  # receipt_long_off, f409  # trackpad_input_2, f408  # trackpad_input_3,
  f3f1  # transit_ticket

## 4.2780.0

* Update to version 2.780 of the material icons variable fonts released 08/09/2024 with 3644 icons
* Added f411  # bar_chart_off, f410  # bookmark_bag, f40d  # borg, f40f  # flag_2,
  f40e  # gif_2, f40b  # motion_play, f40c  # video_camera_back_add

## 4.2777.1

* Fix number of icons in README.md to 3637

## 4.2777.0

* Update to version 2.777 of the material icons variable fonts released 08/01/2024 with 3637 icons
* Added f414  # database_off, f413  # format_quote_off

## 4.2771.0

* Update to version 2.771 of the material icons variable fonts released 07/11/2024 with 3635 icons
* Added f41f  # convert_to_text, f41b  # multimodal_hand_eye, f418  # power_settings_circle,
  f417  # rotate_auto, f41c  # stack_hexagon, f41a  # sync_desktop, f42c  # voice_selection_off

## 4.2768.0

* Update to version 2.768 of the material icons variable fonts released 07/05/2024 with 3628 icons
* Added f425  # add_column_left, f424  # add_column_right, f423  # add_row_above,
  f422  # add_row_below, f43a  # arrow_back_2, f421  # automation, f437  # category_search,
  f420  # combine_columns, f438  # credit_card_clock, f439  # desktop_landscape_add,
  f41e  # diagonal_line, f41d  # drive_export, f42d  # edit_audio, f429  # encrypted_add,
  f42a  # encrypted_add_circle, f428  # encrypted_minus_circle, f427  # encrypted_off,
  f42b  # masked_transitions_add, f426  # orbit, f432  # view_object_track

## 4.2762.0

* Update to version 2.762 of the material icons variable fonts released 06/06/2024 with 3608 icons
* Added f451  # replace_audio,f450  # replace_image, f44f  # replace_video,
  f44e  # smartphone_camera, f43b  # tab_inactive, f44d  # tablet_camera,
  f44c  # wifi_calling_bar_1, f44b  # wifi_calling_bar_2, f44a  # wifi_calling_bar_3
* Added icon image preview to dart docs IF YOU INSTALL THE FONTS LOCALLY on your machine.
  (You must install the 3 MaterialSymbols*.ttf fonts from lib\fonts\)
  
## 4.2758.0

* Update to version 2.758 of the material icons variable fonts released 05/30/2024 with 3599 icons
* Added f47b  # bike_dock,f47a  # bike_lane,f457  # bookmark_check, f456  # bookmark_flag,
  f455  # bookmark_heart,f454  # bookmark_star, f479  # cable_car, f46b  # chevron_backward,
  f46a  # chevron_forward,f460  # currency_rupee_circle,f45e  # desktop_landscape,
  f45d  # desktop_portrait, f462  # directions_railway_2, f463  # fitness_tracker,
  f45c  # float_landscape_2, f45b  # float_portrait_2, f478  # flyover,
  f45a  # fullscreen_portrait, f477  # funicular, f476  # gondola_lift,
  f464  # hearing_aid, f475  # hov, f474  # metro, f473  # monorail, e408  # navigate_before,
  e409  # navigate_next, e5cb  # navigate_before, e5cc  # navigate_next,
  f461  # railway_alert_2, f482  # reset_brightness, f481  # reset_focus, f480  # reset_iso,
  f47f  # reset_settings, f47e  # reset_shadow, f47d  # reset_shutter_speed,
  f47c  # reset_white_balance, f472  # road, f471  # scooter, f45f  # script,
  f469  # search_check_2, f470  # speed_camera, f459  # splitscreen_landscape,
  f458  # splitscreen_portrait, f46c  # stairs_2, f466  # table_eye, f46f  # traffic_jam,
  f46e  # trolley_cable_car, f46d  # unpaved_road, f468  # watch_check,
  f467  # watch_vibration
* Changed codepoint of wifi_calling_1 from f0f6 to f0e7,
  changed codepoint of wifi_calling_3 from f0f6 to f0e7

## 4.2744.2

* Added `data-XXX` attributes to the `<span>` tags for each IconData member.  This information
  includes `data-fontfamily`, `data-codepoint` and `data-variation`.  This will allow my
  modifications to the VSCode dart/flutter extension to show icon previews for any icon
  package which includes this info (PR for [Dart-Code](https://github.com/Dart-Code/Dart-Code) to come).
* Clean up `update_package.dart` removing obsolete code.
* Remove @nodoc option from `update_package.dart` and always generate full dart docs because
  dart doc has now been fixed to generate sensible docs when there are over 10000 members of
  a class [dartdoc PR #3384](https://github.com/dart-lang/dartdoc/pull/3384).
* Moved `symbols_map.dart` from example lib directory to main package directory.  Users
  can include this if they chose to force references to every icon to prevent tree shaking.
  (For example for icon preview applications).
* Renamed all `rawFontsUnfixed/LAST_VERSION/icon_unicodes_XXXX.txt` files to use date
  in the YY_MM_DD format so that the files sort alphabetically in date order.

## 4.2744.1

* Update to use device_preview_plus for example (as device_preview no longer compiled with current
  flutter master channel.
* Changed example app to do toggle icon's fill state on mouse over.

## 4.2744.0

* Update to version 2.744 of the material icons variable fonts released 05/16/2024 with 3553 icons
* added f486  # contextual_token and f485  # contextual_token_add

## 4.2741.0

* Removed obsolete code for update_package.dart
* Updated to 2.741 of the material symbols font now that the pipeline generating the official github repo as been fixed
  (see [https://github.com/google/material-design-icons/issues/1706](https://github.com/google/material-design-icons/issues/1706) for more details.  This pipeline bug had delay releases for 3 months because the material symbols icon fonts where not being updated).
  Added f4cc  # adaptive_audio_mic,f4cb  # adaptive_audio_mic_off, f49c  # add_diamond, f48e  # add_triangle, f49a  # animated_images,
  f4b6  # arrow_cool_down, f4b5  # arrow_warm_up, f4b0  # av1, f4af  # avc, f4b4  # cadence, f4b9  # cardio_load, f4ae  # closed_caption_add, f49f  # contrast_circle, f4a0  # contrast_square, f4cd  # emoji_language, f4c9  # eye_tracking, f49d  # fingerprint_off,
  f4b8  # format_textdirection_vertical, f4d5  # frame_person_mic, f4c1  # guardian, f4c6  # handheld_controller, f4c5  # head_mounted_device,
  f4ca  # id_card, f026  # keep, e6f9  # keep_off, f026  # keep_pin, f56f  # keep_public, f492  # keyboard_lock, f491  # keyboard_lock_off,
  f4c4  # landscape_2, f4c3  # landscape_2_off, f48a  # lowercase, f48b  # mail_off, f490  # mouse_lock, f48f  # mouse_lock_off,
  f499  # movie_off, f4d0  # offline_pin_off, f4b7  # open_run, f4a9  # password_2, f4a8  # password_2_off, f49b  # poker_chip,
  f4c0  # recenter, f4bc  # search_insights, f4c8  # select_window_2, f4ac  # serif, f483  # shift_lock_off, f4ab  # slab_serif,
  f4a5  # smart_card_reader, f4a6  # smart_card_reader_off, f4cf  # spatial_speaker, f4d4  # speed_0_25, f498  # speed_0_2x,
  f497  # speed_0_5x, f4d3  # speed_0_75, f496  # speed_0_7x, f4d2  # speed_1_25, f495  # speed_1_2x, f494  # speed_1_5x,
  f4d1  # speed_1_75, f493  # speed_1_7x, f49e  # text_up, f4b1  # timer_5, f4b2  # timer_5_shutter, f4bb  # timer_pause,
  f4ba  # timer_play, f489  # titlecase, f4c7  # trackpad_input, f49f  # unknown_2, e6a2  # unknown_2, f49e  # unknown_7, e6f9  # unpin,
  f488  # uppercase, f4c2  # view_real_size and f4aa  # vo2_max

## 4.2719.3

* Added static IconData get(String name, SymbolStyle style) method on Symbols that is specified in the official Material
  Symbols [specification](https://docs.google.com/document/d/1UHRKDl8-lzl_hW_K2AHnpMwvdPo0vGPbDI7mqACWXJY/)
  This is included using import 'package:material_symbols_icons/get.dart';
  `Symbols.values` can be used to access an `Iterable<String>` of the icon names for each available icon.
  `Symbols.map` can be used to access a `Map<String,int>` of the icon names to unicode code points for each icon.

## 4.2719.2

* Make the `Icon(...)` example text selectable using SelectableText() widget - also copied example code to clipboard
  when the text is clicked - or a sub-selection can be selected and copied manually.

## 4.2719.1

* Fix incorrect import statement in README.md example.
* Added `Icon(...)` example text to the example app to illustrate widget parameters needs to accomplish
  the visible font axis settings.

## 4.2719.0

* Update to version 2.719 of the material icons variable fonts released 02/01/2024 with 3479 icons
* added f4d6  # comedy_mask

## 4.2718.1

* Changes to update_package.dart so that dart format is happy and does not change symbols.dart or
  iconname_to_unicode_map.dart
* Previous changes in 4.2716.1 do not seem to help IntelliJ show icon previews :(
  (but filesize is still smaller, so we will leave that for now)

## 4.2718.0

* Updated to version 2.718 of the material icons variable fonts released 01/25/2024 with 3478 icons
* Added f4d9  # attach_file_off,  f4d8  # file_copy_off, and f4da  # history_off

## 4.2716.1

* Re-enable @staticIconProvider to see if pub.dev will take it now (other icon packages use this now)
  (previously was rejected by pub.dev)
* Rework how IconData is defined to use classes for IconDataOutlined,IconDataRounded and IconDataSharp
  and the classes hold the family name/package.  Reduces size of file and hopefully allows us to work
  with icon preview in IntelliJ
* Symbols class does not extend any class anymore (again hoping this will allow IntelliJ to work)
* added exports to symbols.dart and material_symbols_icons.dart so they both make each other available
  (Note because Symbols NO LONGER extends MaterialSymbolsBase existing code that uses static methods
  from MaterialSymbolsBase will have to be change to use it directly from MaterialSymbolsBase. and not
  Symbols.)

## 4.2716.0

* Updated to version 2.716 of the material icons variable fonts released 01/11/2024 with 3475 icons
* Added f4ef  # backlight_high_off, f4f1  # brand_family, f4e3  # car_tag, f4e5  # emergency_heat_2, f4e4  # folder_limited,
  f4f2  # media_output, f4f3  # media_output_off, f4e2  # speed_0_5, f4e1  # speed_1_2, f4e0  # speed_1_5,
  f4eb  # speed_2x, f4e6  # touchpad_mouse_off
* Now generate `lib\iconname_to_unicode_map.dart` file which contains a iconname -> unicode codepoint map.
  Fixes [https://github.com/timmaffett/material_symbols_icons/issues/16](https://github.com/timmaffett/material_symbols_icons/issues/16)
  This file can optionally be used by users of the package to get a map of all iconnames to codepoint within the font.
* Now change the names of the fonts to remove the `[FILL,Grad,opsz,wght]` because the brackets [] were
   having to be URL encoded by part of the flutter build process and then the testing harness could not load the fonts
   because the URL encoded names are embedded in the flutter app and they can't be used on filesystem to load the fonts.
   (Fixes [https://github.com/timmaffett/material_symbols_icons/issues/12](https://github.com/timmaffett/material_symbols_icons/issues/12))

## 4.2713.0

* Updated to version 2.713 of the material icons variable fonts released 12/07/2023
* Added f4fa  # person_edit, f4f6  # prompt_suggestion, f4f7  # shopping_cart_off,
  f4fd  # splitscreen_add, f4fc  # splitscreen_vertical_add, f4f9  # thread_unread

## 4.2711.0

* Updated to version 2.711 of the material icons variable fonts released 11/16/2023
* Added f502  # action_key,f4fe  # notifications_unread,f501  # pulse_alert,
  f503  # security_key, f500  # stacks

## 4.2709.0

* Updated to version 2.709 of the material icons variable fonts released 11/09/2023
* Fixed version typo in 4.2706.0 change log message
* Added f514  # background_dot_small,f508  # close_small,f507  # collapse_content,f510  # highlight_keyboard_focus,
  f511  # highlight_mouse_cursor,f512  # highlight_text_cursor,f513  # language_japanese_kana,f509  # pageless,
  f515  # sensors_krx_off,f506  # switch_access_2,f50e  # transition_chop,f50d  # transition_dissolve,
  f50c  # transition_fade,f50b  # transition_push,f50a  # transition_slide

## 4.2706.0

* Changed update_package.dart to also automatically write rawFontsUnfixed/LAST_VERSION/icon_unicodes_MM_DD_YY.dart file
* Update to version 2.706 of the material symbols icons variable fonts released 10/26/2023
* Added e852  # account_child,e659  # account_child_invert, e97e  # air_purifier, ef7b  # apparel, f55a  # aq,
  f55b  # aq_indoor, e983  # ar_stickers, e01a  # artist, e987  # assistant_device, f525  # asterisk,
  e98a  # auto_draw_solid, e71e  # auto_towing, f53f  # auto_transmission, e669  # bigtop_updates,
  f53e  # book_2,f53d  # book_3,f53c  # book_4,f53b  # book_5,f540  # calendar_clock,eb08  # carry_on_bag,
  eb0b  # carry_on_bag_checked,eb0a  # carry_on_bag_inactive,eb09  # carry_on_bag_question,f52b  # chat_info,
  e70d  # checkbook,eb0c  # checked_bag,eb0d  # checked_bag_question,e995  # cleaning,e999  # contacts_product,
  f52d  # credit_card_gear,f52c  # credit_card_heart,f549  # crop_9_16,f518  # delete_history,
  f51b  # deployed_code_account,f539  # dictionary,ef86  # digital_wellbeing,e9a0  # dishwasher,f523  # download_2,
  eb00  # drawing_recognition,f528  # editor_choice,e9a6  # energy,e70e  # enterprise,eb4d  # enterprise_off,
  e686  # experiment,e538  # explore_nearby,eb26  # family_home,f527  # family_star,f559  # farsight_digital,
  ef91  # featured_seasonal_and_gifts,e2c5  # file_map,f17f  # file_save,e505  # file_save_off,e3e1  # filter_retrolux,
  ef92  # finance_mode,e9ab  # flights_and_hotels,e9ac  # for_you,e714  # garage_door,e6de  # general_device,
  e715  # google_home_devices,ef97  # grocery,eb02  # handwriting_recognition,e3ef  # hdr_plus_off,
  ef9d  # health_and_beauty,f537  # heat,f54b  # high_res,ef9f  # home_and_garden,efa0  # home_improvement_and_tools,
  ebff  # hourglass,efa1  # household_supplies,f558  # humidity_indoor,f524  # ink_highlighter_move,e027  # ios,
  f56f  # keep_public,f51a  # key_vertical,f526  # kid_star,eb04  # license,e9b8  # light_off,efa4  # lightning_stand,
  f535  # linked_services,e726  # manufacturing,f552  # markdown,f553  # markdown_copy,f554  # markdown_paste,
  efa9  # mintmark,e701  # missing_controller,f547  # mitre,f557  # mode_dual,eb1a  # music_cast,
  f532  # network_wifi_locked,e9c4  # newsstand,f54a  # not_accessible_forward,e6c3  # on_hub_device,eb14  # orders,
  e9c7  # oven,f52a  # p2p,eb0e  # personal_bag,eb0f  # personal_bag_off,eb10  # personal_bag_question,
  e703  # personal_places,f530  # photo_auto_merge,f550  # picture_in_picture_center,f54f  # picture_in_picture_large,
  f54e  # picture_in_picture_medium,f517  # picture_in_picture_mobile,f52f  # picture_in_picture_off,
  f54d  # picture_in_picture_small,e694  # planner_review,eb15  # quick_reorder,f555  # raven,e9da  # responsive_layout,
  eb27  # rubric,f542  # science_off,e720  # sdk,e696  # search_hands_free,f556  # sensors_krx,e717  # service_toolbox,
  f522  # settings_heart,eb01  # shape_recognition,f529  # shield_question,efb7  # shoppingmode,f543  # skillet,
  f544  # skillet_cooktop,e527  # source_environment,efb8  # sports_and_outdoors,e697  # stat_0,f545  # stockpot,
  e69e  # swap_driving_apps,e9f1  # text_fields_alt,eb2a  # things_to_do,efc2  # toys_and_games,
  efc3  # travel_luggage_and_bags,e6fb  # trip,e1de  # tv_options_input_settings,f51f  # two_pager,
  e9fa  # universal_currency,e9fb  # universal_local,eb05  # unlicense,f521  # upload_2,e708  # user_attributes,
  efc5  # vacuum,f51e  # variable_add,f51d  # variable_insert,f51c  # variable_remove,ea03  # web_traffic

## 4.2671.0

* Update to version 2.671 of the material symbols icons variable fonts released 08/24/2023
* Added f568  # bomb,f561  # concierge,e64c  # globe,f56d  # indeterminate_question_box,f56f  # keep_public,
  f56b  # nest_wifi_pro,f56a  # nest_wifi_pro_2,f56e  # network_node,f562  # note_stack,f563  # note_stack_add,
  f569  # package_2,f567  # person_alert,f566  # person_cancel,f565  # person_check,f560  # radio_button_partial,
  f56c  # reset_wrench,,f564  # tactic
  
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
