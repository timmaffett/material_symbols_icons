import 'dart:io';
import 'dart:convert';

final metadataPath = '../lib/material_symbols_metadata.dart';
final symbolsPath = '../lib/symbols.dart';

void main() async {
  final metadataFile = File(metadataPath);
  final symbolsFile = File(symbolsPath);

  if (!metadataFile.existsSync() || !symbolsFile.existsSync()) {
    print('Required files not found.');
    exit(1);
  }

  final metadataContent = await metadataFile.readAsLines();
  final symbolsContent = await symbolsFile.readAsLines();

  // 1. Collect all icon names with rtlAutoMirrored: true
  final rtlIcons = <String>{};
  String? currentIcon;
  for (final line in metadataContent) {
    final iconMatch = RegExp(r'^\s*"([a-zA-Z0-9_]+)": SymbolsMetadata\(').firstMatch(line);
    if (iconMatch != null) {
      currentIcon = iconMatch.group(1);
    }
    if (line.contains('rtlAutoMirrored: true') && currentIcon != null) {
      rtlIcons.add(currentIcon);
    }
    if (line.trim() == '),' || line.trim() == '),') {
      currentIcon = null;
    }
  }

  // Normalize function to remove _rounded and _sharp suffixes
  String normalize(String name) {
    return name.replaceAll(RegExp(r'(_rounded|_sharp)\$'), '');
  }

  // 2. Collect all IconData declarations with matchTextDirection: true
  final mirroredIcons = <String>{};
  final mirroredIconsRaw = <String>{};
  String? lastIconName;
  for (final line in symbolsContent) {
    final iconMatch = RegExp(r'static const IconData ([a-zA-Z0-9_]+) ?=').firstMatch(line);
    if (iconMatch != null) {
      lastIconName = iconMatch.group(1);
    }
    if (line.contains('matchTextDirection: true') && lastIconName != null) {
      mirroredIcons.add(normalize(lastIconName));
      mirroredIconsRaw.add(lastIconName);
    }
    if (line.trim().isEmpty) {
      lastIconName = null;
    }
  }

  // 3. For every base icon in rtlIcons, check that all its _rounded and _sharp variants (if present) also have matchTextDirection: true
  final missingVariants = <String, List<String>>{};
  for (final base in rtlIcons) {
    final variants = [base, base + '_rounded', base + '_sharp'];
    for (final v in variants) {
      if (!mirroredIconsRaw.contains(v) && symbolsContent.any((l) => l.contains('static const IconData $v'))) {
        missingVariants.putIfAbsent(base, () => []).add(v);
      }
    }
  }

  // 4. Compare sets (normalized)
  print('Icons with rtlAutoMirrored: true in metadata (normalized): ${rtlIcons.length}');
  print('Checking for style variants missing matchTextDirection: true...');
  if (missingVariants.isEmpty) {
    print('SUCCESS: All style variants for mirrored icons have matchTextDirection: true.');
  } else {
    print('Variants missing matchTextDirection: true:');
    missingVariants.forEach((base, vars) {
      print('Base icon: $base, missing: ${vars.join(", ")}');
    });
  }
}
