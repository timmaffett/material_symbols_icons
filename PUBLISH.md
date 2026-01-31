# Publishing Instructions

This repository contains two packages that need to be published separately to [pub.dev](https://pub.dev).

## Pre-Publishing: Updating Icons and Fonts

Before publishing a new version, if there are updates to the Google Material Symbols, you should run the generator tools.
See [generator/README.md](generator/README.md) for detailed instructions on how to:
1.  Download the latest fonts and codepoints.
2.  Fix font metrics.
3.  Regenerate the Dart source files.

## 1. Publish the Main Package (`material_symbols_icons`)

First, publish the main library package to ensure the latest version is available for the CLI tool to reference (if needed).

1.  **Navigate to the root directory:**
    Ensure you are in the root directory of the repository.

2.  **Verify the package:**
    Run a dry run to check for any warnings or errors.
    ```bash
    dart pub publish --dry-run
    ```

3.  **Publish:**
    If the dry run is successful, publish the package.
    ```bash
    dart pub publish
    ```

## 2. Publish the CLI Package (`material_symbols_icons_cli`)

After the main package is published, publish the CLI tool.

1.  **Navigate to the CLI directory:**
    ```bash
    cd material_symbols_icons_cli
    ```

2.  **Update Dependencies (Optional but Recommended):**
    If you want the CLI to strictly depend on the version you just published, update `pubspec.yaml` in this directory to use the new version number instead of `any`, then run `dart pub get`.

3.  **Verify the package:**
    Run a dry run to check for any warnings or errors.
    ```bash
    dart pub publish --dry-run
    ```

4.  **Publish:**
    If the dry run is successful, publish the package.
    ```bash
    dart pub publish
    ```

## 3. Verification

Once both packages are published:

1.  Check the pages on [pub.dev](https://pub.dev) to ensure the new versions are listed.
2.  Test the global activation command to make sure users can install the tool:
    ```bash
    dart pub global activate material_symbols_icons_cli
    install_material_symbols_icons_fonts --help
    ```
