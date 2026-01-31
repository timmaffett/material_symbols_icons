# Material Symbols Icons CLI

A command-line tool to help with the installation of fonts for the [material_symbols_icons](https://pub.dev/packages/material_symbols_icons) package.

This tool is used to download and install the Material Symbols Icons fonts locally on your system so they can be previewed in IDEs like VS Code, or to install them for system-wide use on macOS/Linux.

## Installation

```shell
dart pub global activate material_symbols_icons_cli
```

## Usage

Once activated, you can run the installation command:

```shell
install_material_symbols_icons_fonts
```

This will download the latest fonts corresponding to the `material_symbols_icons` package version and install them.

## Features

- Installs Material Symbols Outlined, Rounded, and Sharp variable fonts.
- Supports macOS (user or global install), Linux, and Windows.
- Can validate fonts using FontBook on macOS.

## License

Apache 2.0
