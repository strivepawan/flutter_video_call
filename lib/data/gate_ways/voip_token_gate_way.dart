import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@singleton
class VoipTokenGateWay {
  static const MethodChannel _channel = MethodChannel('com.yourapp.voip');

  Future<String?> getVoipToken() async {
    try {
      final String? token = await _channel.invokeMethod<String>('getVoipToken');
      return token;
    } catch (e) {
      print('Failed to get VoIP token: $e');
      return null;
    }
  }
}
