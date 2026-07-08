import 'imports/core_imports.dart';
import 'imports/packages_imports.dart';
import 'shared/wrappers/localization_wrapper.dart';
import 'shared/wrappers/state_wrapper.dart';
import 'app.dart';
import 'services/mongo_service.dart';


Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  await AppConfig.init();

  // Connect to MongoDB
  try {
    await MongoService().connect();
  } catch (e) {
    // Print/log error but don't crash app startup if MongoDB isn't running locally yet
    print('MongoDB connection failed: $e');
  }

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}














