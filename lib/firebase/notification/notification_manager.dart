

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class PushNotificationManager {
  PushNotificationManager._();
  static final PushNotificationManager _instance = PushNotificationManager._();
  static PushNotificationManager get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    if (!_initialized){
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      _firebaseMessaging.getToken().then((token) => print('TOKEN: $token'));

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage: $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('onLaunch: $message');
        },
        onResume: (Map<String, dynamic> message) async {
          print('onResume: $message');
        }
      );

      _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true)
        );

      _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings){
        print('Settings registered: $settings');
      });

      _initialized = true;
    }
  }


}