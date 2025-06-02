// import 'package:injectable/injectable.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

// import '../../../environment_config.dart';

// @singleton
// class OneSignalNotificationsGateWay {
//   static final _oneSignal = OneSignal.shared;

//   Future<void> registerUser(String userId) async {
//     await _oneSignal.setAppId(EnvironmentConfig.oneSignalKey);
//     await _oneSignal.setExternalUserId(userId);
//   }
// }

import 'package:injectable/injectable.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../../environment_config.dart';

@singleton
class OneSignalNotificationsGateWay {
  Future<void> registerUser(String userId) async {
    // Initialize OneSignal with your app ID (only once, ideally during app startup)
    OneSignal.initialize(EnvironmentConfig.oneSignalKey);

    // Log in the user with the external user ID
    await OneSignal.login(userId);
  }
}
