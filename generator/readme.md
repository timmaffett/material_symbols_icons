# Generates the `lib\src\constants.dart` file for the flutter_font_picker package.
--------------------------------------------------------------

Should be used by flutter_font_picker package maintainers to update the `lib\src\constants.dart` file when the google_fonts package is updated.

## Usage:

A) Get the complete list of Google Fonts, their variants, languages, and weights. Two ways to achieve that:

  - Go to [https://developers.google.com/fonts/docs/developer_api](https://developers.google.com/fonts/docs/developer_api) and click the blue 'EXECUTE' button on the right. Grab the JSON output that appears, and paste it into a new file in this folder (ie. `api_output.json`).

  - Use your own private Google Fonts API key and supply that as a command line argument to the `update_constants.dart` tool. 

**NOTE 1**: The `google_fonts` Dart package supports **only a subset of the complete list**. This is automatically retrieved from `https://raw.githubusercontent.com/material-foundation/flutter-packages/main/packages/google_fonts/generator/families_supported`.

**NOTE 2**: Pass the `--legacylanguages` (or `-l`) command line option to keep the previous versions list of languages. There is quite a large list of languages now and the current version (as of 1.1.3) does not include most of them.

B) Execute the `update_constants.dart` generator tool. This will create a new `constants.dart` file in the current directory, along with info comparing it to the previous file. 

C) Copy the new `constants.dart` file into the `\lib\src\constants\` directory to overwrite the previous version.

**Each time we update the Google Fonts list, we should publish a new minor version of the flutter_font_picker package.**

## Examples:

I) Using a previously downloaded Google Fonts JSON file:

```shell
cd generator
dart run update_constants.dart -i api_output_feb_22_23.json
```

II) Using your private Google Fonts API key:

```shell
cd generator
dart run update_constants.dart --apikey YOUR_SECRET_API_KEY
```

III) Display the help and command line usage instructions:

```shell
cd generator
dart run update_constants.dart -h
```

IV) Example of entire process of creating new `constants.dart` file and replacing the old (using your private Google Fonts API key):

```shell
cd generator
dart run update_constants.dart --apikey YOUR_SECRET_API_KEY
cp constants.dart ../lib/src/constants/constants.dart
```

NOTE: Limit the list of languages to those of the previous version of constants.dart using the  `--legacylanguages` (or `-l`) command line argument.