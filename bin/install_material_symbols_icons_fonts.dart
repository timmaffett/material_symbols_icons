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
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as path;

enum Options {
  install('install'),
  uninstall('uninstall'),
  global('global'),
  usefontbook('usefontbook'),
  usage('usage'),
  help('help'),
  //OBSOLETE//path('path')
  debug('debug');

  const Options(this.name);

  final String name;
}

bool globalMacOSInstall = false;
bool macOSUseFontBook = false;
bool debugScripts = false;
String _rootDir = path.join(Directory.current.path,'bin');

set rootDir(String value) {
  //if(value.length<10) throw('SOME ONE IS MESSING UP ROOTDIR');
  _rootDir = value;
}

String get rootDir => _rootDir;

// We need to get to the files of the LATEST material_symbols_icons package that is in the pub cache
String getRootPathsToLatestInstalledPackage() {
  final pathToScript = Platform.script.toFilePath();
  rootDir = path.dirname(pathToScript);

  if (debugScripts) print('Got pathToScript=$pathToScript arg $rootDir  curdir=${Directory.current.path}');
  
  rootDir = path.join(Directory.current.path,'bin');

  if (debugScripts) print(chalk.yellowBright('Root directory: $rootDir'));

  // following for testing
  if (Platform.isWindows && !rootDir.contains('global_packages')) {
    rootDir =
        r"C:\Users\Tim\AppData\Local\Pub\Cache\global_packages\dart_frog_cli\bin";
  }

  String pubDevPackagesDir =
      path.join(rootDir, '..', '..', '..', 'hosted', 'pub.dev');

  if (debugScripts) print('pubDevPackagesDir=$pubDevPackagesDir');

  final packageDirs =
      Glob('material_symbols_icons-*', caseSensitive: false, recursive: false);
  final baseToChop = 'material_symbols_icons-';

  final listFSE = packageDirs.listSync(root: pubDevPackagesDir);
  String highestVersion = '4.2600.0';
  String latestPackageDir = '';

  for (final fse in listFSE) {
    String dirName = fse.basename;
    String version = dirName.substring(baseToChop.length);
    if (debugScripts) print('Found directory $dirName version=$version');
    if (version.length >= 8) {
      if (version.compareTo(highestVersion) > 0) {
        highestVersion = version;
        latestPackageDir = fse.path;
      }
    }
  }
  if (debugScripts) print('Highest Version = $highestVersion');
  if (debugScripts) print('latestPackageDir = $latestPackageDir');
  if(latestPackageDir.isNotEmpty) {
    return path.join(latestPackageDir, 'bin');
  } else {
    if (debugScripts) print(chalk.red('Could not find latest installed material_symbols_icons package in pub cache.'));
    if (debugScripts) print(chalk.yellow.onBrightRed('Assuming we are running from root of the package!'));
    return rootDir;
  }
}

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
      help: 'Debug scripts.',
    )
    //OBSOLETE//..addOption(
    //OBSOLETE//  Options.path.name,
    //OBSOLETE//  defaultsTo: './bin',
    //OBSOLETE//  help: 'Path to the scripts directory.',
    //OBSOLETE//)
    ..addFlag(
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
    )
    ..addFlag(
      Options.uninstall.name,
      defaultsTo: false,
      negatable: false,
      help: 'Uninstall the material symbols icons fonts.',
    );

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

  //OBSOLETE//if (parsedArgs[Options.path.name] != './bin') {
  //OBSOLETE//  rootDir = parsedArgs[Options.path.name];
  //OBSOLETE//  //print('Got path arg $rootDir');
  //OBSOLETE//} else {
  //OBSOLETE//  final pathToScript = Platform.script.toFilePath();
  //OBSOLETE//  rootDir = path.dirname(pathToScript);
  //OBSOLETE//  //print('Got pathToScript=$pathToScript arg $rootDir  curdir=${Directory.current.path}');
  //OBSOLETE//}
  //OBSOLETE//print(chalk.yellowBright('Root directory: $rootDir'));

  rootDir = getRootPathsToLatestInstalledPackage();

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
      print(chalk.redBright(
          'Unsupported operating system: ${Platform.operatingSystem}'));
  }
}

void uninstallMaterialSymbolsIconsFonts() {
  print(chalk.cyanBright('running on ${Platform.operatingSystem}'));
  switch (Platform.operatingSystem) {
    case 'windows':
      uninstallMaterialSymbolsIconsFontWindows();
      break;
    case 'macos':
      print(chalk.redBright(
          'Uninstalling Material Symbols Icons fonts is not supported on MacOS yet.'));
      //uninstallMaterialSymbolsIconsFontMacOS();
      break;
    case 'linux':
      print(chalk.redBright(
          'Uninstalling Material Symbols Icons fonts is not supported on Linux yet.'));
      //uninstallMaterialSymbolsIconsFontLinux();
      break;
    default:
      print(chalk.redBright(
          'Unsupported operating system: ${Platform.operatingSystem}'));
  }
}

//Windows specific functions
void installMaterialSymbolsIconsFontWindows() {
  print(chalk.cyanBright(
      'running powershell scripts to install Material Symbols Icons fonts...'));
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsOutlined.ttf');
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsRounded.ttf');
  runPowerShellInstallFont(r'..\lib\fonts\MaterialSymbolsSharp.ttf');
}

void uninstallMaterialSymbolsIconsFontWindows() {
  print(chalk.cyanBright(
      'running powershell scripts to UNINSTALL Material Symbols Icons fonts...'));
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsOutlined.ttf');
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsRounded.ttf');
  runPowerShellUninstallFont(r'..\lib\fonts\MaterialSymbolsSharp.ttf');
}

void runPowerShellInstallFont(String fontNameWithRelativePath) {
  var result = runPowerShellScriptOneArg(
      r'.\Install-Font.ps1', fontNameWithRelativePath);
  final fontname =
      path.basename(path.withoutExtension(fontNameWithRelativePath));
  final numberFacesInstalled = int.tryParse(result);
  if (numberFacesInstalled != null && numberFacesInstalled > 0) {
    print(chalk.greenBright(
        '$fontname font was successfully installed ($numberFacesInstalled faces installed).'));
  } else {
    print(chalk.redBright(
        '$fontname font was not installed likely because the font $fontNameWithRelativePath was not found.'));
  }
}

void runPowerShellUninstallFont(String fontNameWithRelativePath) {
  var result = runPowerShellScriptOneArg(
      r'.\Uninstall-Font.ps1', fontNameWithRelativePath);
  final fontname =
      path.basename(path.withoutExtension(fontNameWithRelativePath));
  if (result.toLowerCase().contains('True'.toLowerCase())) {
    print(chalk.greenBright('$fontname font was successfully uninstalled.'));
  } else {
    print(chalk.redBright(
        '$fontname font was not uninstalled because it was not currently installed.'));
  }
}

String runPowerShellScriptOneArg(String scriptPath, String argumentToScript) {
  return runPowerShellScript(scriptPath, [argumentToScript]);
}

String runPowerShellScript(String scriptPath, List<String> argumentsToScript) {
  final processResult = Process.runSync('Powershell.exe',
      ['-executionpolicy', 'bypass', '-File', scriptPath, ...argumentsToScript],
      workingDirectory: rootDir //path.join(Directory.current.path, 'bin')
      );
  if (debugScripts) {
    print(chalk.yellowBright('Executing $scriptPath with $argumentsToScript'));
    print(chalk.redBright(processResult.stderr as String));
    print(chalk.cyanBright(processResult.stdout as String));
  }
  return processResult.stdout as String;
}

void runShellInstallFontsScriptLinux() {
  String scriptName = 'install-fonts.sh';
  if (macOSUseFontBook) {
    scriptName = 'install-fonts-withFontBook.sh';
  }
  final scriptPath = path.join(
      rootDir, scriptName); //path.join('..', '..', 'bin', scriptName);
  final fontWorkingDir = path.join(rootDir, '..', 'lib', 'fonts');
  //
  if(debugScripts) {
    print(chalk.purple('print(Directory.current.path)=${Directory.current.path}'));
    print(chalk.red('scriptPath=$scriptPath  fontWorkingDir=$fontWorkingDir'));
  }
  // First we need to make sure the scipt is executable
  final chmodProcessResult =
      Process.runSync('chmod', ['+x',scriptPath], runInShell:true);
  if(debugScripts) {
    print(chalk.yellowBright('Chmod +x $scriptPath'));
    print(chalk.redBright(chmodProcessResult.stderr as String));
  }

  final processResult =
      Process.runSync(scriptPath, [], workingDirectory: fontWorkingDir, runInShell:true);

  if (debugScripts || processResult.stderr.toString().isNotEmpty) {
    print(chalk.yellowBright('Executed $scriptName'));
    print(chalk.cyanBright(processResult.stdout as String));
  }
  if(processResult.stderr.isNotEmpty) print(chalk.redBright.blink('StdErr:',processResult.stderr as String));
}

void runShellInstallFontsScriptGloballyOnMacOS() {

print(chalk.yellowBright('runShellInstallFontsScriptGloballyOnMacOS. rootDir=$rootDir'));

  String scriptName = 'install-fonts-macAlt.sh';
  if (macOSUseFontBook) {
    scriptName = 'install-fonts-macAlt-withFontBook.sh';
  }
  final scriptPath = path.join(
      rootDir, scriptName); //path.join('..', '..', 'bin', scriptName);
  final fontWorkingDir = path.join(rootDir, '..', 'lib', 'fonts');
  print(chalk.purple('print(Directory.current.path)=${Directory.current.path}'));
  print(chalk.red('scriptPath=$scriptPath  fontWorkingDir=$fontWorkingDir'));

  // First we need to make sure the script is executable
  final chmodProcessResult =
      Process.runSync('chmod', ['+x',scriptPath], runInShell:true);
  if(debugScripts) {
    print(chalk.yellowBright('Chmod +x $scriptPath'));
    print(chalk.redBright(chmodProcessResult.stderr as String));
  }
  final processResult =
      Process.runSync(scriptPath, [], workingDirectory: fontWorkingDir, runInShell:true);
  if (debugScripts || processResult.stderr.toString().isNotEmpty) {
    print(chalk.yellowBright('Executed $scriptName'));
    print(chalk.cyanBright(processResult.stdout as String));
  }
  if(processResult.stderr.isNotEmpty) print(chalk.redBright.blink('StdErr:',processResult.stderr as String));
}

//MacOS specific functions
void installMaterialSymbolsIconsFontMacOS() {
  if (globalMacOSInstall) {
    print(chalk.greenBright(
        'Install Material Symbols Icons fonts globally${(macOSUseFontBook) ? ' and validating with FontBook.' : '.'}'));
    runShellInstallFontsScriptGloballyOnMacOS();
  } else {
    print(chalk.greenBright(
        'Install Material Symbols Icons fonts for current user${(macOSUseFontBook) ? ' and validating with FontBook.' : '.'}...'));
    runShellInstallFontsScriptLinux();
  }
}

void uninstallMaterialSymbolsIconsFontMacOS() {
  print(chalk.redBright(
      'UNINSTALLING Material Symbols Icons fonts not supported on MacOS.'));
}

//Linux specific functions
void installMaterialSymbolsIconsFontLinux() {
  print(chalk.greenBright(
      'Install Material Symbols Icons fonts for current user using Linux script...'));
  runShellInstallFontsScriptLinux();
}

void uninstallMaterialSymbolsIconsFontLinux() {
  print(chalk.redBright(
      'UNINSTALLING Material Symbols Icons fonts not supported on Linux.'));
}
