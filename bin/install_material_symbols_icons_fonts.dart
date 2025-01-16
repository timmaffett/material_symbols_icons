//  Copyright 2023 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import 'dart:io';
import 'package:chalkdart/chalk.dart';
import 'package:chalkdart/chalk_x11.dart';
import 'package:args/args.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

enum _Options {
  install('install'),
  uninstall('uninstall'),
  global('global'),
  usage('usage'),
  help('help'),
  debug('debug'),
  path('path');

  const _Options(this.name);

  final String name;
}

bool debugScripts = false;
String rootDir = '.';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      _Options.usage.name,
      defaultsTo: false,
      help:
          'Prints help on how to use the command. The same as --${_Options.usage.name}.',
    )
    ..addFlag(
      _Options.help.name,
      defaultsTo: false,
      help:
          'Prints help on how to use the command. The same as --${_Options.help.name}.',
    )
    ..addFlag(
      _Options.install.name,
      defaultsTo: true,
      help:
          'Install the material symbols icons fonts - optional as it is the default.',
    )
    ..addFlag(
      _Options.uninstall.name,
      defaultsTo: false,
      help:
          'Uninstall the material symbols icons fonts.',
    )
    //NOT SUPPORTED YET//..addFlag(
    //NOT SUPPORTED YET//  _Options.global.name,
    //NOT SUPPORTED YET//  defaultsTo: false,
    //NOT SUPPORTED YET//  help:
    //NOT SUPPORTED YET//      'MacOS specific flag to specify installing the fonts globally in /Library/Fonts instead of ~/Library/Fonts .',
    //NOT SUPPORTED YET//)
    ..addFlag(
      _Options.debug.name,
      defaultsTo: false,
      help:
          'Debug scripts.',
    )
    ..addOption(
      _Options.path.name,
      defaultsTo: '.',
      help: 'Path to the script directory.',
    );

  late final ArgResults parsedArgs;

  try {
    parsedArgs = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    print(parser.usage);
    return;
  }

  if (parsedArgs[_Options.debug.name] == true) {
    debugScripts = true;
  }

  if (parsedArgs[_Options.usage.name] == true ||
      parsedArgs[_Options.help.name] == true) {
    print(parser.usage);
    return;
  }

  if (parsedArgs[_Options.path.name] != '.') {
    rootDir = parsedArgs[_Options.path.name];
    print('Got path arg $rootDir');
  } else {
    final pathToScript = Platform.script.toFilePath();
    rootDir = path.dirname(pathToScript);
    print('Got pathToScript=$pathToScript arg $rootDir');
  }
  print(chalk.purple('Root directory: $rootDir'));

  if (parsedArgs[_Options.uninstall.name] == true) {
    print(chalk.yellow('Uninstalling Material Symbols Icons fonts...'));
    uninstallMaterialSymbolsIconsFonts();
  } else {
    print(chalk.green('Uninstalling Material Symbols Icons fonts...'));
    installMaterialSymbolsIconsFonts();
  }
}

void installMaterialSymbolsIconsFonts() {
  print(chalk.pink('running on ${Platform.operatingSystem}'));
  switch (Platform.operatingSystem) {
    case 'windows':
      installMaterialSymbolsIconsFontWindows();
      break;
    case 'macos':
      print(chalk.red('Installing Material Symbols Icons fonts is not supported on MacOS yet.'));
      installMaterialSymbolsIconsFontMacOS();
      break;
    case 'linux':
      print(chalk.red('Installing Material Symbols Icons fonts is not supported on Linux yet.'));
      installMaterialSymbolsIconsFontLinux();
      break;
    default:
      print(chalk.red('Unsupported operating system: ${Platform.operatingSystem}'));
  }
}
void uninstallMaterialSymbolsIconsFonts() {
  print(chalk.pink('running on ${Platform.operatingSystem}'));
  switch (Platform.operatingSystem) {
    case 'windows':
      uninstallMaterialSymbolsIconsFontWindows();
      break;
    case 'macos':
      print(chalk.red('Uninstalling Material Symbols Icons fonts is not supported on MacOS yet.'));
      //uninstallMaterialSymbolsIconsFontMacOS();
      break;
    case 'linux':
      print(chalk.red('Uninstalling Material Symbols Icons fonts is not supported on Linux yet.'));
      //uninstallMaterialSymbolsIconsFontLinux();
      break;
    default:
      print(chalk.red('Unsupported operating system: ${Platform.operatingSystem}'));
  }
}

//Windows specific functions
void installMaterialSymbolsIconsFontWindows() {
  print(chalk.pink('running powershell scripts to install Material Symbols Icons fonts...'));
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsOutlined.ttf');
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsRounded.ttf');
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsSharp.ttf');
}

void uninstallMaterialSymbolsIconsFontWindows() {
  print(chalk.pink('running powershell scripts to UNINSTALL Material Symbols Icons fonts...'));
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsOutlined.ttf');
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsRounded.ttf');
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsSharp.ttf');
}

void runPowerShellInstallFont(String fontNameWithRelativePath) {
  var result = runPowerShellScriptOneArg(r'.\Install-Font.ps1', fontNameWithRelativePath);
  final fontname = path.basename(path.withoutExtension(fontNameWithRelativePath));
  final numberFacesInstalled = int.tryParse(result);
  if(numberFacesInstalled != null && numberFacesInstalled > 0) {
    print(chalk.green('$fontname font was successfully installed ($numberFacesInstalled faces installed).'));
  } else {
    print(chalk.red('$fontname font was not installed likely because the font $fontNameWithRelativePath was not found.'));
  }
}

void runPowerShellUninstallFont(String fontNameWithRelativePath) {
  var result = runPowerShellScriptOneArg(r'.\Uninstall-Font.ps1', fontNameWithRelativePath);
  final fontname = path.basename(path.withoutExtension(fontNameWithRelativePath));
  if(result.toLowerCase().contains('True'.toLowerCase())) {
    print(chalk.green('$fontname font was successfully uninstalled.'));
  } else {
    print(chalk.red('$fontname font was not uninstalled because it was not currently installed.'));
  }
}

String runPowerShellScriptOneArg(String scriptPath, String argumentToScript) {
  return runPowerShellScript(scriptPath, [argumentToScript] );
}

String runPowerShellScript(String scriptPath, List<String> argumentsToScript) {
  final processResult = Process.runSync(
          'Powershell.exe', ['-executionpolicy', 'bypass', '-File', scriptPath, ...argumentsToScript],
          workingDirectory: rootDir //path.join(Directory.current.path, 'bin')
        );
  if(debugScripts) {
    print(chalk.yellow('Executing $scriptPath with $argumentsToScript'));
    print(chalk.red(processResult.stderr as String));
    print(chalk.blue(processResult.stdout as String));
  }
  return processResult.stdout as String;
}

void runShellInstallFontsScriptLinux() {
  final processResult = Process.runSync(
          'sh', [ path.join(rootDir, 'install_fonts.sh')],
          workingDirectory: path.join(rootDir, '..', 'lib', 'fonts' )
        );
  if(debugScripts) {
    print(chalk.yellow('Executing install_fonts.sh'));
    print(chalk.red(processResult.stderr as String));
    print(chalk.blue(processResult.stdout as String));
  }
}

void runShellInstallFontsScriptMacOS() {
  final processResult = Process.runSync(
          'sh', [ path.join(rootDir, 'install-fonts-macAlt.sh')],
          workingDirectory: path.join(rootDir, '..', 'lib', 'fonts' )
        );
  if(debugScripts) {
    print(chalk.yellow('Executing install-fonts-macAlt.sh'));
    print(chalk.red(processResult.stderr as String));
    print(chalk.blue(processResult.stdout as String));
  }
}




//MacOS specific functions
/*
Add this to your startup file (e.g. ~/.zshrc):

alias fontbook="open -b com.apple.FontBook"
Then, in a new Terminal, you can execute:

fontbook *.otf

*/

void installMaterialSymbolsIconsFontMacOS() {
  print(chalk.pink('Install Material Symbols Icons fonts...'));
  runShellInstallFontsScriptMacOS();
}

void uninstallMaterialSymbolsIconsFontMacOS() {
  print(chalk.pink('UNINSTALLING Material Symbols Icons fonts not supported on MacOS.'));
}


//Linux specific functions
void installMaterialSymbolsIconsFontLinux() {
  print(chalk.pink('Install Material Symbols Icons fonts...'));
  runShellInstallFontsScriptLinux();
}

void uninstallMaterialSymbolsIconsFontLinux() {
  print(chalk.pink('UNINSTALLING Material Symbols Icons fonts not supported on Linux.'));
}