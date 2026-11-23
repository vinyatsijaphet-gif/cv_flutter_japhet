import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Chrome / Windows : localhost (le PC lui-même).
  // Émulateur Android : 10.0.2.2 = le PC hôte (XAMPP).
  // Téléphone réel : remplacer par l'IP du PC sur le Wi-Fi, ex. 192.168.1.10
  static String get host => kIsWeb ? 'localhost' : '10.0.2.2';
  static String get baseUrl => 'http://$host/api-test/public';
}
