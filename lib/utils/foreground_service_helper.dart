import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:isolate';

class ForegroundServiceHelper {
  static const _notificationChannelId = 'netrai_foreground_task';
  static const _notificationChannelName = 'NetrAI Screen Sharing';
  static const _notificationTitle = 'NetrAI Screen Sharing Aktif';
  static const _notificationMessage = 'Berbagi layar sedang berjalan';

  static Future<bool> startForegroundService() async {
    final running = await FlutterForegroundTask.isRunningService;
    if (running) {
      print('Foreground service sudah berjalan');
      return true;
    }

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _notificationChannelId,
        channelName: _notificationChannelName,
        channelDescription: 'Notification untuk berbagi layar',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: const [
          NotificationButton(
            id: 'stopTask',
            text: 'Hentikan',
          ),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    try {
      bool success = await FlutterForegroundTask.startService(
        notificationTitle: _notificationTitle,
        notificationText: _notificationMessage,
        callback: startCallback,
      );

      print('Foreground service started: $success');
      return success;
    } catch (e) {
      print('Error saat memulai foreground service: $e');
      return false;
    }
  }

  static Future<bool> stopForegroundService() async {
    try {
      final success = await FlutterForegroundTask.stopService();
      print('Foreground service stopped: $success');
      return success;
    } catch (e) {
      print('Error saat menghentikan foreground service: $e');
      return false;
    }
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MediaProjectionTaskHandler());
}

class MediaProjectionTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print('Foreground task dimulai');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('Foreground task dihentikan');
  }

  @override
  void onButtonPressed(String id) {
    if (id == 'stopTask') {
      FlutterForegroundTask.stopService();
    }
  }
}
