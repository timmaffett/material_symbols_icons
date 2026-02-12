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
import 'package:pub_semver/pub_semver.dart';

enum Options {
  install('install'),
  uninstall('uninstall'),
  global('global'),
  usefontbook('usefontbook'),
  usage('usage'),
  help('help'),
  //OBSOLETE//path('path')
  localdev('localdev'),
  debug('debug');

  const Options(this.name);

  final String name;
}

bool globalMacOSInstall = false;
bool macOSUseFontBook = false;
bool debugScripts = false;
bool localDev = false;

// Directory where this script and other shell scripts reside (cli/bin)
late String _cliBinDir; 
String get cliBinDir => _cliBinDir;

// Directory where the material_symbols_icons package is located (has lib/fonts)
late String _resourcesDir;
String get resourcesDir => _resourcesDir;


// We need to resolve where this CLI package is, and where the resources (main) package is.
void resolvePackagePaths() {
  final pathToScript = Platform.script.toFilePath();
  _cliBinDir = path.dirname(pathToScript);

  if (debugScripts) print('Got pathToScript=$pathToScript  cliBinDir=$_cliBinDir');

  if(localDev) {
    _cliBinDir = path.join(Directory.current.path,'bin');
    // In local dev, we assume we are at the root of the repo, OR inside the cli package.
    // However, user usually runs from root.
    // If run from root of cli package:
    if (File(path.join(_cliBinDir, 'install_material_symbols_icons_fonts.dart')).existsSync()) {
        // We are likely in material_symbols_icons_cli/
        // Resources are in ../lib/fonts (relative to cli package root?)
        // Repo structure:
        // root/
        //   lib/fonts
        //   material_symbols_icons_cli/
        //     bin/
        
        // So resourcesDir is path.join(cliBinDir, '..', '..')
        _resourcesDir = path.normalize(path.join(_cliBinDir, '..', '..'));
    } else {
        // Fallback or error
         _resourcesDir = Directory.current.path;
    }

    if (debugScripts) print(chalk.cyan('LOCALDEV flag set. Using cliBinDir=$_cliBinDir resourcesDir=$_resourcesDir'));
    return;
  }

  // following for testing
  if (Platform.isWindows && !_cliBinDir.contains('global_packages')) {
    // This looks like specific debug code for Windows dev environment, leaving as is but using cliBinDir
    // But it sets cliBinDir.
    _cliBinDir =
        r"C:\Users\Tim\AppData\Local\Pub\Cache\global_packages\dart_frog_cli\bin";
  }

    String pubDevPackagesDir = path.normalize(path.absolute(
      path.join(_cliBinDir, '..', '..', '..', 'hosted', 'pub.dev')));

  if (debugScripts) print('pubDevPackagesDir=$pubDevPackagesDir');

  final packageDirs =
      Glob('material_symbols_icons-*', caseSensitive: false, recursive: false);
  final baseToChop = 'material_symbols_icons-';

  final listFSE = packageDirs.listSync(root: pubDevPackagesDir);
  Version? highestVersion;
  String latestPackageDir = '';

  for (final fse in listFSE) {
    String dirName = fse.basename;
    // START CHANGE: Filter out the cli package itself if it matches the glob (it shouldn't if name is different but glob is material_symbols_icons-*)
    // material_symbols_icons_cli-* matches material_symbols_icons-* glob?
    // Glob('material_symbols_icons-*') matches material_symbols_icons_cli-1.0.0
    // We want the MAIN package, not the CLI package.
    if (dirName.startsWith('material_symbols_icons_cli')) continue;

    final versionString = dirName.substring(baseToChop.length);
    if (debugScripts) print('Found directory $dirName version=$versionString');
    Version? version;
    try {
      version = Version.parse(versionString);
    } catch (_) {
      version = null;
    }
    if (version == null) continue;
    if (highestVersion == null || version > highestVersion) {
      highestVersion = version;
      latestPackageDir = fse.path;
    }
  }
  if (debugScripts) print('Highest Version = ${highestVersion?.toString() ?? 'none'}');
  if (debugScripts) print('latestPackageDir = $latestPackageDir');
  
  if (latestPackageDir.isNotEmpty) {
    // Ensure we have an absolute, normalized path with no '..' segments.
    if (!path.isAbsolute(latestPackageDir)) {
      latestPackageDir = path.join(pubDevPackagesDir, latestPackageDir);
    }
    _resourcesDir = path.normalize(path.absolute(latestPackageDir));
  } else {
    if (debugScripts) print(chalk.red('Could not find latest installed material_symbols_icons package in pub cache.'));
    // If not found, maybe we are running from the main package itself (legacy compat)?
    // Or maybe we just default to cliBinDir/../.. similar to localdev structure as fallback?
    // Use cliBinDir as fallback for safety to avoid crash, but it won't work if fonts aren't there.
    _resourcesDir = path.dirname(_cliBinDir); 
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
      Options.localdev.name,
      defaultsTo: false,
      negatable: false,
      help:
          'Local development flag to use current directory as root package dir.',
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
  if (parsedArgs[Options.localdev.name] == true) {
    localDev = true;
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

  resolvePackagePaths();

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
  
  // Font paths are relative to resourcesDir
  final fontsDir = path.join(resourcesDir, 'lib', 'fonts');
  
  runPowerShellInstallFont(path.join(fontsDir, 'MaterialSymbolsOutlined.ttf'));
  runPowerShellInstallFont(path.join(fontsDir, 'MaterialSymbolsRounded.ttf'));
  runPowerShellInstallFont(path.join(fontsDir, 'MaterialSymbolsSharp.ttf'));
}

void uninstallMaterialSymbolsIconsFontWindows() {
  print(chalk.cyanBright(
      'running powershell scripts to UNINSTALL Material Symbols Icons fonts...'));
      
  final fontsDir = path.join(resourcesDir, 'lib', 'fonts');

  runPowerShellUninstallFont(path.join(fontsDir, 'MaterialSymbolsOutlined.ttf'));
  runPowerShellUninstallFont(path.join(fontsDir, 'MaterialSymbolsRounded.ttf'));
  runPowerShellUninstallFont(path.join(fontsDir, 'MaterialSymbolsSharp.ttf'));
}

void runPowerShellInstallFont(String fontNameWithFullPath) {
  final fontFile = File(fontNameWithFullPath);
  if (!fontFile.existsSync()) {
    print(chalk.redBright(
        'Font file not found: $fontNameWithFullPath'));
    return;
  }

  var result = runPowerShellScriptOneArg(
      path.join(cliBinDir, 'Install-Font.ps1'), fontNameWithFullPath);
  
  final fontname =
      path.basename(path.withoutExtension(fontNameWithFullPath));
  final numberFacesInstalled = int.tryParse(result.trim());
  if (numberFacesInstalled != null && numberFacesInstalled > 0) {
    print(chalk.greenBright(
        '$fontname font was successfully installed ($numberFacesInstalled faces installed).'));
  } else {
    print(chalk.redBright(
        '$fontname font was not installed. The file exists but the install API returned 0 (already installed or install blocked).'));
  }
}

void runPowerShellUninstallFont(String fontNameWithFullPath) {
  var result = runPowerShellScriptOneArg(
      path.join(cliBinDir, 'Uninstall-Font.ps1'), fontNameWithFullPath);
  
  final fontname =
      path.basename(path.withoutExtension(fontNameWithFullPath));
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
  // Use cliBinDir as working directory for the process
  final processResult = Process.runSync('Powershell.exe',
      ['-executionpolicy', 'bypass', '-File', scriptPath, ...argumentsToScript],
      workingDirectory: cliBinDir 
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
      cliBinDir, scriptName); 
      
  final fontWorkingDir = path.join(resourcesDir, 'lib', 'fonts');
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

  print(chalk.yellowBright('runShellInstallFontsScriptGloballyOnMacOS. cliBinDir=$cliBinDir'));

  String scriptName = 'install-fonts-macAlt.sh';
  if (macOSUseFontBook) {
    scriptName = 'install-fonts-macAlt-withFontBook.sh';
  }
  final scriptPath = path.join(
      cliBinDir, scriptName); 
  final fontWorkingDir = path.join(resourcesDir, 'lib', 'fonts');
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
