import 'imports/core_imports.dart';
import 'imports/packages_imports.dart';
import 'shared/wrappers/localization_wrapper.dart';
import 'shared/wrappers/state_wrapper.dart';
import 'app.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  await AppConfig.init();

  // Initialize Hive
  try {
    await Hive.initFlutter();
  } catch (e) {
    print('Hive initialization failed: $e');
  }

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}














