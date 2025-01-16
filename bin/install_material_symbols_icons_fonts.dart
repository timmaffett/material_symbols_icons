//  Copyright 2025 Tim Maffett
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
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

enum Options {
  install('install'),
  uninstall('uninstall'),
  global('global'),
  usefontbook('usefontbook'),
  usage('usage'),
  help('help'),
  debug('debug'),
  path('path');

  const Options(this.name);

  final String name;
}

bool globalMacOSInstall = false;
bool macOSUseFontBook = false;
bool debugScripts = true;
String rootDir = '.';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      Options.usage.name,
      defaultsTo: false,
      negatable: false,
      help:
          'Prints help on how to use the command. The same as --${Options.usage.name}.',
    )
    ..addFlag(
      Options.help.name,
      defaultsTo: false,
      negatable: false,
      help:
          'Prints help on how to use the command. The same as --${Options.help.name}.',
    )
    ..addFlag(
      Options.install.name,
      defaultsTo: true,
      negatable: false,
      help:
          'Install the material symbols icons fonts - optional as it is the default.',
    )
    ..addFlag(
      Options.debug.name,
      defaultsTo: false,
      negatable: false,
      help:
          'Debug scripts.',
    )
    //NOT NEEDED//..addOption(
    //NOT NEEDED//  _Options.path.name,
    //NOT NEEDED//  defaultsTo: './bin',
    //NOT NEEDED//  help: 'Path to the scripts directory.',
    //NOT NEEDED//)
    ;
  if(Platform.isMacOS) {
      parser..addFlag(
      Options.global.name,
      defaultsTo: false,
      negatable: false,
      help:
          'MacOS specific flag to specify installing the fonts globally in /Library/Fonts instead of ~/Library/Fonts .',
    )
    ..addFlag(
      Options.usefontbook.name,
      defaultsTo: false,
      negatable: false,
      help:
          'MacOS specific flag to additionally validate fonts using FontBook.',
    );
  }
  if(Platform.isWindows) {
    parser.addFlag(
      Options.uninstall.name,
      defaultsTo: false,
      negatable: false,
      help:
          'Uninstall the material symbols icons fonts.',
    );
  }

  late final ArgResults parsedArgs;

  try {
    parsedArgs = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    print(parser.usage);
    return;
  }

  if (parsedArgs[Options.debug.name] == true) {
    debugScripts = true;
  }
  if (parsedArgs[Options.global.name] == true) {
    globalMacOSInstall = true;
  }
  if (parsedArgs[Options.usefontbook.name] == true) {
    macOSUseFontBook = true;
  }

  if (parsedArgs[Options.usage.name] == true ||
      parsedArgs[Options.help.name] == true) {
    print(parser.usage);
    return;
  }

  if (parsedArgs[Options.path.name] != '.') {
    rootDir = parsedArgs[Options.path.name];
    //print('Got path arg $rootDir');
  } else {
    final pathToScript = Platform.script.toFilePath();
    rootDir = path.dirname(pathToScript);
    //print('Got pathToScript=$pathToScript arg $rootDir');
  }
  print(chalk.yellowBright('Root directory: $rootDir'));

  if (parsedArgs[Options.uninstall.name] == true) {
    print(chalk.yellowBright('Uninstalling Material Symbols Icons fonts...'));
    uninstallMaterialSymbolsIconsFonts();
  } else {
    print(chalk.greenBright('Installing Material Symbols Icons fonts...'));
    installMaterialSymbolsIconsFonts();
  }
}

void installMaterialSymbolsIconsFonts() {
  print(chalk.cyanBright('running on ${Platform.operatingSystem}'));
  switch (Platform.operatingSystem) {
    case 'windows':
      installMaterialSymbolsIconsFontWindows();
      break;
    case 'macos':
      installMaterialSymbolsIconsFontMacOS();
      break;
    case 'linux':
      installMaterialSymbolsIconsFontLinux();
      break;
    default:
      print(chalk.redBright('Unsupported operating system: ${Platform.operatingSystem}'));
  }
}
void uninstallMaterialSymbolsIconsFonts() {
  print(chalk.cyanBright('running on ${Platform.operatingSystem}'));
  switch (Platform.operatingSystem) {
    case 'windows':
      uninstallMaterialSymbolsIconsFontWindows();
      break;
    case 'macos':
      print(chalk.redBright('Uninstalling Material Symbols Icons fonts is not supported on MacOS yet.'));
      //uninstallMaterialSymbolsIconsFontMacOS();
      break;
    case 'linux':
      print(chalk.redBright('Uninstalling Material Symbols Icons fonts is not supported on Linux yet.'));
      //uninstallMaterialSymbolsIconsFontLinux();
      break;
    default:
      print(chalk.redBright('Unsupported operating system: ${Platform.operatingSystem}'));
  }
}

//Windows specific functions
void installMaterialSymbolsIconsFontWindows() {
  print(chalk.cyanBright('running powershell scripts to install Material Symbols Icons fonts...'));
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsOutlined.ttf');
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsRounded.ttf');
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsSharp.ttf');
}

void uninstallMaterialSymbolsIconsFontWindows() {
  print(chalk.cyanBright('running powershell scripts to UNINSTALL Material Symbols Icons fonts...'));
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsOutlined.ttf');
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsRounded.ttf');
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsSharp.ttf');
}

void runPowerShellInstallFont(String fontNameWithRelativePath) {
  var result = runPowerShellScriptOneArg(r'.\Install-Font.ps1', fontNameWithRelativePath);
  final fontname = path.basename(path.withoutExtension(fontNameWithRelativePath));
  final numberFacesInstalled = int.tryParse(result);
  if(numberFacesInstalled != null && numberFacesInstalled > 0) {
    print(chalk.greenBright('$fontname font was successfully installed ($numberFacesInstalled faces installed).'));
  } else {
    print(chalk.redBright('$fontname font was not installed likely because the font $fontNameWithRelativePath was not found.'));
  }
}

void runPowerShellUninstallFont(String fontNameWithRelativePath) {
  var result = runPowerShellScriptOneArg(r'.\Uninstall-Font.ps1', fontNameWithRelativePath);
  final fontname = path.basename(path.withoutExtension(fontNameWithRelativePath));
  if(result.toLowerCase().contains('True'.toLowerCase())) {
    print(chalk.greenBright('$fontname font was successfully uninstalled.'));
  } else {
    print(chalk.redBright('$fontname font was not uninstalled because it was not currently installed.'));
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
    print(chalk.yellowBright('Executing $scriptPath with $argumentsToScript'));
    print(chalk.redBright(processResult.stderr as String));
    print(chalk.blueBright(processResult.stdout as String));
  }
  return processResult.stdout as String;
}

void runShellInstallFontsScriptLinux() {
  String scriptName = 'install-fonts.sh';
  if(macOSUseFontBook) {
    scriptName = 'install-fonts-withFontBook.sh';
  }
  final scriptPath = path.join(rootDir, scriptName);  
  final fontWorkingDir = path.join(rootDir, '..', 'lib', 'fonts' );
  //print(chalk.red('scriptPath=$scriptPath  fontWorkingDir=$fontWorkingDir'));  
  final processResult = Process.runSync(
          'sh', [ scriptPath ],
          workingDirectory: fontWorkingDir
        );
  if(debugScripts) {
    print(chalk.yellowBright('Executed $scriptName'));
    print(chalk.redBright(processResult.stderr as String));
    print(chalk.blueBright(processResult.stdout as String));
  }
}

void runShellInstallFontsScriptGloballyOnMacOS() {
  String scriptName = 'install-fonts-macAlt.sh';
  if(macOSUseFontBook) {
    scriptName = 'install-fonts-macAlt-withFontBook.sh';
  }
  final scriptPath = path.join(rootDir, scriptName);
  final fontWorkingDir = path.join(rootDir, '..', 'lib', 'fonts' );
  //print(chalk.red('scriptPath=$scriptPath  fontWorkingDir=$fontWorkingDir'));
  final processResult = Process.runSync(
          'sh', [ scriptPath ],
          workingDirectory: fontWorkingDir
        );
  if(debugScripts) {
    print(chalk.yellowBright('Executed $scriptName'));
    print(chalk.redBright(processResult.stderr as String));
    print(chalk.blueBright(processResult.stdout as String));
  }
}

//MacOS specific functions
void installMaterialSymbolsIconsFontMacOS() {
  if(globalMacOSInstall) {
    print(chalk.greenBright('Install Material Symbols Icons fonts globally${(macOSUseFontBook) ? ' and validating with FontBook.':'.'}'));
    runShellInstallFontsScriptGloballyOnMacOS();
  } else {
    print(chalk.greenBright('Install Material Symbols Icons fonts for current user${(macOSUseFontBook) ? ' and validating with FontBook.':'.'}...'));
    runShellInstallFontsScriptLinux();
  }
}

void uninstallMaterialSymbolsIconsFontMacOS() {
  print(chalk.redBright('UNINSTALLING Material Symbols Icons fonts not supported on MacOS.'));
}

//Linux specific functions
void installMaterialSymbolsIconsFontLinux() {
  print(chalk.greenBright('Install Material Symbols Icons fonts for current user using Linux script...'));
  runShellInstallFontsScriptLinux();
}

void uninstallMaterialSymbolsIconsFontLinux() {
  print(chalk.redBright('UNINSTALLING Material Symbols Icons fonts not supported on Linux.'));
}