import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:io';
import './foreground_service_helper.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ScreenShareHelper {
  static void _logDetail(String message) {
    print('ScreenShareHelper: $message');
  }

  static Future<T> _withForegroundTask<T>(Future<T> Function() callback) async {
    if (!await FlutterForegroundTask.isRunningService) {
      await ForegroundServiceHelper.startForegroundService();

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return await callback();
  }

  static Future<bool> toggleScreenSharing(
    BuildContext context,
    LocalParticipant participant,
  ) async {
    try {
      _logDetail('Memulai toggle screen sharing');
      _logDetail(
          'Platform: ${Platform.operatingSystem}, versi: ${Platform.operatingSystemVersion}');

      final bool isCurrentlyEnabled = participant.isScreenShareEnabled();
      _logDetail('Status screen sharing saat ini: $isCurrentlyEnabled');

      if (!isCurrentlyEnabled) {
        _logDetail('Meminta konfirmasi pengguna');
        final bool shouldProceed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Konfirmasi Berbagi Layar'),
                content: const Text('Anda akan membagikan layar. Lanjutkan?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Lanjutkan'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!shouldProceed) {
          _logDetail('Pengguna membatalkan screen sharing');
          return false;
        }
      }

      if (!isCurrentlyEnabled && context.mounted) {
        _logDetail('Menampilkan indikator loading');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mempersiapkan berbagi layar...')),
        );
      }

      if (Platform.isAndroid) {
        _logDetail('Menggunakan metode Android dengan foreground service');

        if (!isCurrentlyEnabled) {
          await _withForegroundTask(() async {
            _logDetail('Mencoba setScreenShareEnabled(true) dengan foreground');
            await participant.setScreenShareEnabled(true);
            _logDetail(
                '[Android ENABLE] Status mikrofon: ${participant.isMicrophoneEnabled()}');
            _logDetail(
                '[Android ENABLE] Jumlah publikasi audio: ${participant.audioTrackPublications.length}');
            TrackPublication? micPubAndroidEnable;
            try {
              micPubAndroidEnable = participant.audioTrackPublications
                  .firstWhere((pub) => pub.source == TrackSource.microphone);
            } catch (e) {
              micPubAndroidEnable = null;
            }
            if (micPubAndroidEnable != null) {
              final micTrack = micPubAndroidEnable.track as LocalAudioTrack?;
              _logDetail(
                  '[Android ENABLE] Publikasi Mikrofon: SID=${micPubAndroidEnable.sid}, Muted=${micPubAndroidEnable.muted}, Name=${micPubAndroidEnable.name}, Kind=${micPubAndroidEnable.kind}, Track SID=${micTrack?.sid}, Track Muted=${micTrack?.muted}');

              if (participant.isMicrophoneEnabled() == false) {
                _logDetail(
                    '[Android ENABLE] Mikrofon nonaktif, mencoba mengaktifkan ulang.');
                await participant.setMicrophoneEnabled(true);
                _logDetail(
                    '[Android ENABLE] Status mikrofon setelah diaktifkan ulang: ${participant.isMicrophoneEnabled()}');
              }
              if (micPubAndroidEnable.muted) {
                _logDetail(
                    '[Android ENABLE] Mikrofon di-mute, mencoba unmute.');

                if (micPubAndroidEnable is LocalTrackPublication) {
                  await (micPubAndroidEnable as LocalTrackPublication).unmute();
                  _logDetail(
                      '[Android ENABLE] Status mute mikrofon setelah unmute (via LocalTrackPublication): ${participant.audioTrackPublications.firstWhere((pub) => pub.source == TrackSource.microphone).muted}');
                } else {
                  _logDetail(
                      '[Android ENABLE] Publikasi mikrofon termute tetapi bukan LocalTrackPublication atau tidak ada SID, mengandalkan setMicrophoneEnabled.');
                }
              }
            } else {
              _logDetail(
                  '[Android ENABLE] Publikasi mikrofon TIDAK DITEMUKAN. Mencoba mengaktifkan mikrofon.');
              await participant.setMicrophoneEnabled(true);
              _logDetail(
                  '[Android ENABLE] Status mikrofon setelah coba aktifkan: ${participant.isMicrophoneEnabled()}');
            }
          });
        } else {
          _logDetail('Menghentikan screen sharing dan foreground service');
          await participant.setScreenShareEnabled(false);
          _logDetail(
              '[Android DISABLE] Status mikrofon: ${participant.isMicrophoneEnabled()}');
          _logDetail(
              '[Android DISABLE] Jumlah publikasi audio: ${participant.audioTrackPublications.length}');
          TrackPublication? micPubAndroidDisable;
          try {
            micPubAndroidDisable = participant.audioTrackPublications
                .firstWhere((pub) => pub.source == TrackSource.microphone);
          } catch (e) {
            micPubAndroidDisable = null;
          }
          if (micPubAndroidDisable != null) {
            final micTrack = micPubAndroidDisable.track as LocalAudioTrack?;
            _logDetail(
                '[Android DISABLE] Publikasi Mikrofon: SID=${micPubAndroidDisable.sid}, Muted=${micPubAndroidDisable.muted}, Name=${micPubAndroidDisable.name}, Kind=${micPubAndroidDisable.kind}, Track SID=${micTrack?.sid}, Track Muted=${micTrack?.muted}');

            if (participant.isMicrophoneEnabled() == false) {
              _logDetail(
                  '[Android DISABLE] Mikrofon nonaktif, mencoba mengaktifkan ulang.');
              await participant.setMicrophoneEnabled(true);
              _logDetail(
                  '[Android DISABLE] Status mikrofon setelah diaktifkan ulang: ${participant.isMicrophoneEnabled()}');
            }
          } else {
            _logDetail('[Android DISABLE] Publikasi mikrofon TIDAK DITEMUKAN.');

            if (participant.isMicrophoneEnabled() == false) {
              _logDetail(
                  '[Android DISABLE] Mikrofon nonaktif (tanpa publikasi), mencoba mengaktifkan ulang.');
              await participant.setMicrophoneEnabled(true);
              _logDetail(
                  '[Android DISABLE] Status mikrofon setelah diaktifkan ulang (tanpa publikasi): ${participant.isMicrophoneEnabled()}');
            }
          }
          await ForegroundServiceHelper.stopForegroundService();
        }
      } else {
        _logDetail(
            'Menggunakan metode platform standard (Non-Android Desktop/iOS)');
        final bool willEnableScreenShare = !isCurrentlyEnabled;
        await participant.setScreenShareEnabled(willEnableScreenShare);

        _logDetail(
            '[Other Platforms TOGGLE: $willEnableScreenShare] Status mikrofon: ${participant.isMicrophoneEnabled()}');
        _logDetail(
            '[Other Platforms TOGGLE: $willEnableScreenShare] Jumlah publikasi audio: ${participant.audioTrackPublications.length}');
        TrackPublication? micPubOther;
        try {
          micPubOther = participant.audioTrackPublications
              .firstWhere((pub) => pub.source == TrackSource.microphone);
        } catch (e) {
          micPubOther = null;
        }

        if (willEnableScreenShare) {
          if (micPubOther != null) {
            final micTrack = micPubOther.track as LocalAudioTrack?;
            _logDetail(
                '[Other Platforms ENABLE] Publikasi Mikrofon: SID=${micPubOther.sid}, Muted=${micPubOther.muted}, Name=${micPubOther.name}, Kind=${micPubOther.kind}, Track SID=${micTrack?.sid}, Track Muted=${micTrack?.muted}');
            if (participant.isMicrophoneEnabled() == false) {
              _logDetail(
                  '[Other Platforms ENABLE] Mikrofon nonaktif, mencoba mengaktifkan ulang.');
              await participant.setMicrophoneEnabled(true);
              _logDetail(
                  '[Other Platforms ENABLE] Status mikrofon setelah diaktifkan ulang: ${participant.isMicrophoneEnabled()}');
            }
            if (micPubOther.muted) {
              _logDetail(
                  '[Other Platforms ENABLE] Mikrofon di-mute, mencoba unmute.');

              if (micPubOther is LocalTrackPublication) {
                await (micPubOther as LocalTrackPublication).unmute();
                _logDetail(
                    '[Other Platforms ENABLE] Status mute mikrofon setelah unmute (via LocalTrackPublication): ${participant.audioTrackPublications.firstWhere((pub) => pub.source == TrackSource.microphone).muted}');
              } else {
                _logDetail(
                    '[Other Platforms ENABLE] Publikasi mikrofon termute tetapi bukan LocalTrackPublication atau tidak ada SID, mengandalkan setMicrophoneEnabled.');
              }
            }
          } else {
            _logDetail(
                '[Other Platforms ENABLE] Publikasi mikrofon TIDAK DITEMUKAN. Mencoba mengaktifkan mikrofon.');
            await participant.setMicrophoneEnabled(true);
            _logDetail(
                '[Other Platforms ENABLE] Status mikrofon setelah coba aktifkan: ${participant.isMicrophoneEnabled()}');
          }
        } else {
          if (micPubOther != null) {
            final micTrack = micPubOther.track as LocalAudioTrack?;
            _logDetail(
                '[Other Platforms DISABLE] Publikasi Mikrofon: SID=${micPubOther.sid}, Muted=${micPubOther.muted}, Name=${micPubOther.name}, Kind=${micPubOther.kind}, Track SID=${micTrack?.sid}, Track Muted=${micTrack?.muted}');
            if (participant.isMicrophoneEnabled() == false) {
              _logDetail(
                  '[Other Platforms DISABLE] Mikrofon nonaktif, mencoba mengaktifkan ulang.');
              await participant.setMicrophoneEnabled(true);
              _logDetail(
                  '[Other Platforms DISABLE] Status mikrofon setelah diaktifkan ulang: ${participant.isMicrophoneEnabled()}');
            }
          } else {
            _logDetail(
                '[Other Platforms DISABLE] Publikasi mikrofon TIDAK DITEMUKAN.');
            if (participant.isMicrophoneEnabled() == false) {
              _logDetail(
                  '[Other Platforms DISABLE] Mikrofon nonaktif (tanpa publikasi), mencoba mengaktifkan ulang.');
              await participant.setMicrophoneEnabled(true);
              _logDetail(
                  '[Other Platforms DISABLE] Status mikrofon setelah diaktifkan ulang (tanpa publikasi): ${participant.isMicrophoneEnabled()}');
            }
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));
      final bool newState = participant.isScreenShareEnabled();
      _logDetail('Status screen sharing setelah toggle: $newState');
      _logDetail(
          '[After Delay] Status mikrofon: ${participant.isMicrophoneEnabled()}');
      _logDetail(
          '[After Delay] Jumlah publikasi audio: ${participant.audioTrackPublications.length}');
      TrackPublication? micPubDelay;
      try {
        micPubDelay = participant.audioTrackPublications
            .firstWhere((pub) => pub.source == TrackSource.microphone);
      } catch (e) {
        micPubDelay = null;
      }
      if (micPubDelay != null) {
        final micTrack = micPubDelay.track as LocalAudioTrack?;
        _logDetail(
            '[After Delay] Publikasi Mikrofon: SID=${micPubDelay.sid}, Muted=${micPubDelay.muted}, Name=${micPubDelay.name}, Kind=${micPubDelay.kind}, Track SID=${micTrack?.sid}, Track Muted=${micTrack?.muted}');
      } else {
        _logDetail('[After Delay] Publikasi mikrofon TIDAK DITEMUKAN.');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Berbagi layar ${newState ? 'dimulai' : 'dihentikan'}.'),
          ),
        );
      }

      return true;
    } catch (e) {
      _logDetail('Error saat toggle screen share: $e');
      _logDetail('Error detail: ${e.runtimeType}');

      String errorMessage;

      if (e.toString().contains("permission") ||
          e.toString().contains("izin") ||
          e.toString().contains("denied")) {
        errorMessage = 'Izin berbagi layar tidak diberikan.';
      } else if (e.toString().contains("cancelled") ||
          e.toString().contains("canceled") ||
          e.toString().contains("batal")) {
        errorMessage = 'Berbagi layar dibatalkan oleh pengguna.';
      } else if (e.toString().contains("not supported") ||
          e.toString().contains("tidak didukung")) {
        errorMessage = 'Perangkat tidak mendukung berbagi layar.';
      } else if (e.toString().contains("FOREGROUND_SERVICE") ||
          e.toString().contains("media projection") ||
          e.toString().contains("MediaProjection")) {
        errorMessage =
            'Error: Layanan foreground diperlukan untuk berbagi layar. Coba restart aplikasi.';

        try {
          await ForegroundServiceHelper.stopForegroundService();
        } catch (_) {}
      } else if (Platform.isAndroid &&
          (e.toString().contains("crash") ||
              e.toString().contains("process") ||
              e.toString().contains("process has died"))) {
        errorMessage =
            'Aplikasi mengalami crash saat berbagi layar. Restart aplikasi dan coba lagi.';
      } else {
        errorMessage =
            'Gagal mengubah status berbagi layar. Error: ${e.toString().split('\n').first}';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }

      return false;
    }
  }
}
