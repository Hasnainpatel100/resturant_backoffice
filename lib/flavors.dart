import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, staging, prod }

class FlavorConfig {
  FlavorConfig(this.flavor);
  final Flavor flavor;

  static late FlavorConfig current;

  static void load(Flavor flavor) {
    current = FlavorConfig(flavor);
  }

  static String get name => current.flavor.name;

  static final Map<String, String> _flavorUrls = {
    'dev': 'http://172.29.208.1:8080',
    'staging': 'http://staging-api:8080',
    'prod': 'https://api.rhpos.com',
  };

  static String get baseUrl {
    final envOverride = dotenv.get('API_BASE_URL', fallback: '');
    if (envOverride.isNotEmpty) return envOverride;
    return _flavorUrls[name] ?? _flavorUrls['dev']!;
  }
}
