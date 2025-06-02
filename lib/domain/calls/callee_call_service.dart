import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/gate_ways/calls/call_gate_way.dart';
import '../../data/gate_ways/user/user_gate_way.dart';
import '../../data/gate_ways/video_call/video_call_gate_way.dart';
import '../../data/models/call_engine.dart';
import 'call_service.dart';

@injectable
class CalleeCallService extends CallService {
  CalleeCallService(
    super.videoCallGateWay,
    this._userGateWay,
    this._callGateWay,
  ) : _videoCallGateWay = videoCallGateWay;

  final VideoCallGateWay _videoCallGateWay;
  final UserGateWay _userGateWay;
  final CallGateWay _callGateWay;

  /// Joins the call initiated by another user. Returns [CallEngine] if
  /// permissions were granted. Returns null if one of the following issues has
  /// appeared:
  /// - there is no singed in user
  /// - the user rejected to provide microphone permission
  /// - the user rejected to provide camera permission.
  Future<CallEngine?> joinCall({
    required String channelId,
  }) async {
    final user = await _userGateWay.getCurrentUser();
    if (user == null) return null;

    final microphonePermission = await Permission.microphone.request();
    if (!microphonePermission.isGranted) return null;

    final cameraPermission = await Permission.camera.request();
    if (!cameraPermission.isGranted) return null;

    final callToken = await _callGateWay.getChannelToken(channelId);

    final engine = await _videoCallGateWay.joinChanel(
      channelId: channelId,
      token: callToken,
      userId: user.id,
    );

    return engine;
  }
}
