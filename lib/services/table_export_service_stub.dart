import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Downloads [bytes] as [filename] to the platform Downloads folder (non-web).
Future<void> downloadBytes(Uint8List bytes, String filename) async {
  // Try the Downloads directory first; fall back to the application documents dir.
  Directory? dir;
  try {
    dir = await getDownloadsDirectory();
  } catch (_) {
    dir = await getApplicationDocumentsDirectory();
  }

  final file = File('${dir!.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
}
