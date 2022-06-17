import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseEventHandler {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static setUserProperties(Map<String, dynamic> properties) {
    properties.forEach((key, value) {
      analytics.setUserProperty(name: key, value: value);
    });
  }

  static sendEvent(String eventName, [Map<String, dynamic>? properties]) {
    analytics.logEvent(
        name: eventName, parameters: properties);
  }
}
