import 'dart:io';
import 'dart:convert';

/// A conservative script to automate string extraction and replacement for localization.
/// It uses regex to specifically target:
/// 1. Text('Literal String')
/// 2. hintText: 'Literal String'
/// 3. label: 'Literal String'
///
/// It explicitly ignores strings with variables (e.g. '$myVar' or '${myVar}') to avoid breaking logic.

void main() async {
  final libDir = Directory('lib/ui');
  if (!libDir.existsSync()) {
    print('lib/ui directory not found.');
    return;
  }

  final enJsonFile = File('assets/translations/en.json');
  Map<String, dynamic> translations = {};
  if (enJsonFile.existsSync()) {
    translations = jsonDecode(await enJsonFile.readAsString());
  }

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalReplacements = 0;

  for (final file in files) {
    String content = await file.readAsString();
    bool fileModified = false;

    // Get feature name from path (e.g. lib/ui/branch/branch_list -> branch)
    final pathSegments = file.path.split(Platform.pathSeparator);
    String featureName = 'common';
    if (pathSegments.length > 2 && pathSegments.contains('ui')) {
      final uiIndex = pathSegments.indexOf('ui');
      if (uiIndex + 1 < pathSegments.length) {
        featureName = pathSegments[uiIndex + 1];
      }
    }

    if (!translations.containsKey(featureName)) {
      translations[featureName] = {};
    }

    // Regex 1: Text('literal string') or Text("literal string")
    // Note: We use negative lookahead to ignore strings with $
    final textRegex = RegExp(r'''Text\(\s*(['"])([^$'\"]+)\1''');
    
    // Regex 2: hintText: 'literal'
    final hintRegex = RegExp(r'''hintText:\s*(['"])([^$'\"]+)\1''');
    
    // Regex 3: label: 'literal'
    final labelRegex = RegExp(r'''label:\s*(['"])([^$'\"]+)\1''');

    content = content.replaceAllMapped(textRegex, (match) {
      final quote = match.group(1)!;
      final textValue = match.group(2)!;
      if (textValue.trim().isEmpty) return match.group(0)!;

      final key = _generateKey(textValue);
      translations[featureName][key] = textValue;
      fileModified = true;
      totalReplacements++;
      return "Text('$featureName.$key'.tr()";
    });

    content = content.replaceAllMapped(hintRegex, (match) {
      final quote = match.group(1)!;
      final textValue = match.group(2)!;
      if (textValue.trim().isEmpty) return match.group(0)!;

      final key = _generateKey(textValue);
      translations[featureName][key] = textValue;
      fileModified = true;
      totalReplacements++;
      return "hintText: '$featureName.$key'.tr()";
    });

    content = content.replaceAllMapped(labelRegex, (match) {
      final quote = match.group(1)!;
      final textValue = match.group(2)!;
      if (textValue.trim().isEmpty) return match.group(0)!;

      final key = _generateKey(textValue);
      translations[featureName][key] = textValue;
      fileModified = true;
      totalReplacements++;
      return "label: '$featureName.$key'.tr()";
    });

    if (fileModified) {
      await file.writeAsString(content);
      print('Updated: ${file.path}');
    }
  }

  if (totalReplacements > 0) {
    await enJsonFile.writeAsString(const JsonEncoder.withIndent('  ').convert(translations));
    print('✅ Success! Replaced $totalReplacements strings and updated en.json.');
  } else {
    print('No hardcoded strings found matching the strict criteria.');
  }
}

String _generateKey(String text) {
  // Convert to lowercase snake_case and limit length
  String key = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  key = key.replaceAll(RegExp(r'^_+|_+$'), ''); // trim underscores
  if (key.length > 30) {
    key = key.substring(0, 30);
    key = key.replaceAll(RegExp(r'_+$'), '');
  }
  if (key.isEmpty) key = 'empty_key';
  return key;
}
