import 'dart:io';

void main() async {
  final dir = Directory('lib/ui');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int filesUpdated = 0;
  for (final file in files) {
    String content = await file.readAsString();
    
    // We remove `const ` before common Flutter widgets to fix const_eval_method_invocation 
    // caused by adding .tr()
    final regex = RegExp(r'\bconst\s+(Text|Padding|Column|Row|Center|SizedBox|Align|Expanded|Flexible|Container|Icon|AppTextField|AppButton|Widget|ListTile|Card|Drawer|Scaffold|AppBar|AppTopBar)\b');
    
    if (regex.hasMatch(content)) {
      content = content.replaceAllMapped(regex, (match) => match.group(1)!);
      await file.writeAsString(content);
      filesUpdated++;
    }
  }
  
  print('Removed const from $filesUpdated files.');
}
