import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_components/livekit_components.dart'
    show RoomContext, VideoTrackRenderer, MediaDeviceContext;
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import './widgets/control_bar.dart';
import './services/token_service.dart';
import 'widgets/agent_status.dart';
import './utils/screen_share_helper.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import './screens/transcription_screen.dart';

import './screens/splash_screen.dart';
import './screens/welcome_screen.dart';
import './screens/privacy_policy_screen.dart';
import './screens/contact_us_screen.dart';
import './screens/account_screen.dart';
import './screens/location_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'netrai_foreground_task',
      channelName: 'NetrAI Screen Sharing',
      channelDescription: 'Notification untuk berbagi layar',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
      buttons: [
        NotificationButton(id: 'stopTask', text: 'Hentikan'),
      ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      autoRunOnBoot: false,
      allowWifiLock: true,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(
        "Firebase berhasil diinisialisasi menggunakan DefaultFirebaseOptions.");
  } catch (e) {
    print("Gagal inisialisasi Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: MaterialApp(
        title: 'AI Assistant',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            secondary: Colors.black,
            surface: Colors.white,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.white,
            surface: Colors.black,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/privacy': (context) => const PrivacyPolicyScreen(),
          '/main': (context) => const VoiceAssistant(),
          '/location': (context) => const LocationScreen(),
        },
      ),
    );
  }
}

class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({super.key});
  @override
  State<VoiceAssistant> createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  CameraPosition _currentCameraPosition = CameraPosition.back;

  bool _isConnecting = false;

  bool _isReadyToConnect = false;

  final room = Room(
    roomOptions: const RoomOptions(
      enableVisualizer: true,
      defaultCameraCaptureOptions: CameraCaptureOptions(
        cameraPosition: CameraPosition.back,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    print("[initState] Memulai initState");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[addPostFrameCallback] Memulai callback setelah frame pertama");
      print("[addPostFrameCallback] Menandai siap untuk koneksi...");
      if (mounted) {
        setState(() {
          _isReadyToConnect = true;
        });
      }
    });
    print("[initState] Selesai initState");
  }

  Future<bool> _requestPermissions() async {
    print("[_requestPermissions] Meminta izin...");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    print(
        "[_requestPermissions] Hasil: Kamera=$cameraGranted, Mikrofon=$micGranted");

    if (!cameraGranted || !micGranted) {
      debugPrint(
          'Izin tidak diberikan: Kamera=$cameraGranted, Mikrofon=$micGranted');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin kamera dan mikrofon diperlukan.')),
        );
      }
    }
    return cameraGranted && micGranted;
  }

  Future<void> _autoConnect(RoomContext roomCtx, TokenService tkService) async {
    if (mounted) {
      print("[_autoConnect] Memulai proses, mengatur _isConnecting = true");
      setState(() {
        _isConnecting = true;
      });
    } else {
      print("[_autoConnect] Widget tidak terpasang saat memulai. Membatalkan.");
      return;
    }

    print("[_autoConnect] Memanggil _requestPermissions...");
    bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      debugPrint('[autoConnect] Izin tidak diberikan, koneksi dibatalkan.');

      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
      return;
    }

    if (!mounted) {
      print(
          "[_autoConnect] Widget tidak terpasang setelah cek izin. Membatalkan.");
      return;
    }

    print("[_autoConnect] Mengatur _isConnecting = true");

    setState(() {
      _isConnecting = true;
    });

    try {
      final roomName =
          'room-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
      final participantName =
          'user-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
      print("[_autoConnect] Room: $roomName, Participant: $participantName");

      print("[_autoConnect] Mengambil detail koneksi...");
      final connectionDetails = await tkService.fetchConnectionDetails(
        roomName: roomName,
        participantName: participantName,
      );

      if (connectionDetails == null) {
        print("[_autoConnect] Gagal mendapatkan detail koneksi.");
        throw Exception('Gagal mendapatkan detail koneksi');
      }
      print(
          "[_autoConnect] Detail koneksi didapatkan: Server=${connectionDetails.serverUrl}");

      if (!mounted) {
        print(
            "[_autoConnect] Widget tidak terpasang sebelum connect. Membatalkan.");

        setState(() {
          _isConnecting = false;
        });
        return;
      }

      print(
          '[autoConnect] Mencoba menghubungkan ke ${connectionDetails.serverUrl}...');
      await roomCtx.connect(
        url: connectionDetails.serverUrl,
        token: connectionDetails.participantToken,
      );

      print(
          '[autoConnect] Koneksi otomatis BERHASIL. Partisipan lokal: ${roomCtx.room.localParticipant?.identity}');

      if (!mounted) {
        print(
            "[_autoConnect] Widget tidak terpasang setelah connect. Membatalkan.");
        return;
      }

      print('[autoConnect] Mencoba mengaktifkan mikrofon...');
      await roomCtx.localParticipant?.setMicrophoneEnabled(true);

      if (!mounted) return;
      print(
          '[autoConnect] Mikrofon diaktifkan: ${roomCtx.localParticipant?.isMicrophoneEnabled()}');

      print('[autoConnect] Mencoba mengaktifkan kamera...');
      await roomCtx.localParticipant?.setCameraEnabled(true);
      if (!mounted) return;
      print(
          '[autoConnect] Kamera diaktifkan: ${roomCtx.localParticipant?.isCameraEnabled()}');

      print('[autoConnect] Menunggu 500ms untuk stabilisasi track...');
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      print(
          '[autoConnect] Publikasi video setelah delay: ${roomCtx.localParticipant?.videoTrackPublications.length}');
      print('[autoConnect] Proses koneksi otomatis SELESAI.');
    } catch (error) {
      print('[autoConnect] KESALAHAN koneksi otomatis: $error');

      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Kesalahan Koneksi: ${error.toString()}')),
        );
      }
    } finally {
      print("[_autoConnect] Blok finally dieksekusi.");

      if (mounted) {
        print("[_autoConnect] Mengatur _isConnecting = false di finally.");
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[build] Memulai build UI VoiceAssistant");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TokenService()),
        ChangeNotifierProvider(create: (context) => RoomContext(room: room)),
      ],
      child: Builder(builder: (context) {
        if (_isReadyToConnect &&
            !_isConnecting &&
            room.connectionState == ConnectionState.disconnected) {
          print(
              "[build] Kondisi terpenuhi, menjadwalkan pemanggilan _autoConnect()...");

          final roomCtxForCall = context.read<RoomContext>();
          final tkServiceForCall = context.read<TokenService>();
          print(
              "[build] Menjadwalkan _autoConnect dengan instance provider...");

          Future.microtask(
              () => _autoConnect(roomCtxForCall, tkServiceForCall));
        }

        final roomContext = context.watch<RoomContext>();
        final participant = roomContext.room.localParticipant;
        final connectionState = roomContext.room.connectionState;

        LocalVideoTrack? displayTrack;
        LocalTrackPublication<LocalVideoTrack>? screenSharePub;
        LocalTrackPublication<LocalVideoTrack>? cameraPub;

        if (participant != null) {
          try {
            screenSharePub = participant.videoTrackPublications.firstWhere(
              (pub) =>
                  pub.source == TrackSource.screenShareVideo &&
                  pub.track != null &&
                  !pub.muted,
            );
            displayTrack = screenSharePub.track as LocalVideoTrack?;
            print(
                '[build] Menggunakan track screen share: ${displayTrack?.sid}');
          } catch (e) {
            print(
                '[build] Tidak ada track screen share aktif, mencari track kamera.');
            screenSharePub = null;
          }

          if (displayTrack == null) {
            try {
              cameraPub = participant.videoTrackPublications.firstWhere(
                (pub) =>
                    pub.source == TrackSource.camera &&
                    pub.track != null &&
                    !pub.muted,
              );
              displayTrack = cameraPub.track as LocalVideoTrack?;
              print('[build] Menggunakan track kamera: ${displayTrack?.sid}');
            } catch (e) {
              cameraPub = null;
              displayTrack = null;
              print('[build] Tidak ada track kamera aktif.');
            }
          }
        }

        print('[build] State Koneksi: $connectionState');
        print('[build] Participant: ${participant?.identity}');
        print(
            '[build] Video Publications: ${participant?.videoTrackPublications.length}');
        print(
            '[build] Camera Pub: ${cameraPub?.sid}, ScreenShare Pub: ${screenSharePub?.sid}');
        print(
            '[build] Display Video Track: ${displayTrack?.sid} (Label: ${displayTrack?.mediaStreamTrack.label})');
        print('[build] Is Display Track Null: ${displayTrack == null}');
        print('[build] Is Connecting State: $_isConnecting');

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              if (displayTrack != null)
                Positioned.fill(
                  child: VideoTrackRenderer(
                    displayTrack!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              const Align(
                alignment: Alignment.center,
                child: AgentStatusWidget(),
              ),
              if (_isConnecting)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF3A59D1),
                  height: 56.0 + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'View',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              print(
                                  "[Header] Question button pressed - Navigating to Contact Us");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactUsScreen(),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final User? currentUser =
                                  FirebaseAuth.instance.currentUser;

                              print(
                                  "[Header] Avatar pressed - Navigating to Account Screen");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountScreen(
                                    displayName: currentUser?.displayName,
                                    email: currentUser?.email,
                                    photoURL: currentUser?.photoURL,
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  FirebaseAuth.instance.currentUser?.photoURL !=
                                              null &&
                                          FirebaseAuth.instance.currentUser!
                                              .photoURL!.isNotEmpty
                                      ? NetworkImage(FirebaseAuth
                                          .instance.currentUser!.photoURL!)
                                      : null,
                              child:
                                  FirebaseAuth.instance.currentUser?.photoURL ==
                                              null ||
                                          FirebaseAuth.instance.currentUser!
                                              .photoURL!.isEmpty
                                      ? const Icon(Icons.person, size: 18)
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<RoomContext>(
                builder: (context, roomCtx, child) {
                  print(
                      "[build] Building ControlBar wrapper. Connection state: ${roomCtx.room.connectionState}");
                  final isConnected =
                      roomCtx.room.connectionState == ConnectionState.connected;

                  final double opacityValue = isConnected ? 0.5 : 1.0;

                  return Opacity(
                    opacity: opacityValue,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: ControlBar(),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: Consumer<RoomContext>(
                  builder: (context, roomCtx, child) {
                    final isConnected = roomCtx.room.connectionState ==
                        ConnectionState.connected;
                    final isMicEnabled =
                        roomCtx.localParticipant?.isMicrophoneEnabled() ??
                            false;
                    final bool isButtonEnabled = isConnected && !_isConnecting;

                    return Center(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          (isButtonEnabled && isMicEnabled)
                              ? Icons.mic_off
                              : Icons.mic,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Speak to NetrAI',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500),
                        ),
                        onPressed: isButtonEnabled
                            ? () async {
                                print(
                                    "[Center Button Mic] Tombol mic ditekan.");
                                final participant =
                                    roomCtx.room.localParticipant;
                                if (participant != null) {
                                  try {
                                    final newMicState = !isMicEnabled;
                                    await participant
                                        .setMicrophoneEnabled(newMicState);
                                    print(
                                        "[Center Button Mic] Mikrofon di-toggle ke: $newMicState");
                                  } catch (e) {
                                    print(
                                        "[Center Button Mic] Error saat toggle mikrofon: $e");

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Tidak dapat toggle mikrofon.')),
                                      );
                                    }
                                  }
                                } else {
                                  print(
                                      "[Center Button Mic] Partisipan lokal null saat tombol ditekan.");
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled
                              ? const Color(0xFF406AFF)
                              : Colors.grey,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 90,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'arrow_up_fab',
                      mini: true,
                      onPressed: () async {
                        print("[FAB ArrowUp] Tombol Screen Share ditekan.");

                        final roomCtx = context.read<RoomContext>();
                        final participant = roomCtx.room.localParticipant;

                        if (participant != null) {
                          await ScreenShareHelper.toggleScreenSharing(
                              context, participant);
                        } else {
                          print(
                              "[FAB ArrowUp] Partisipan lokal null saat tombol ditekan.");
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Partisipan tidak ditemukan.')),
                            );
                          }
                        }
                      },
                      backgroundColor: const Color(0xFF324EFF),
                      child: const Icon(Icons.screen_share_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'camera_fab',
                      mini: true,
                      onPressed: (displayTrack != null &&
                              screenSharePub == null &&
                              !_isConnecting)
                          ? () async {
                              print(
                                  "[FAB Camera] Tombol ganti kamera ditekan.");
                              final roomCtx = context.read<RoomContext>();
                              final participant = roomCtx.room.localParticipant;
                              print(
                                  "[FAB Camera] Participant: ${participant?.sid}");
                              print(
                                  "[FAB Camera] Video Publications Count: ${participant?.videoTrackPublications.length}");

                              LocalVideoTrack? cameraTrackToRestart;
                              LocalTrackPublication<LocalVideoTrack>?
                                  currentCameraPub;

                              if (participant != null) {
                                try {
                                  currentCameraPub = participant
                                      .videoTrackPublications
                                      .firstWhere(
                                    (pub) =>
                                        pub.source == TrackSource.camera &&
                                        pub.track is LocalVideoTrack &&
                                        pub.track?.mediaStreamTrack.enabled ==
                                            true &&
                                        !pub.muted,
                                  );
                                  cameraTrackToRestart = currentCameraPub.track
                                      as LocalVideoTrack?;
                                } catch (e) {
                                  print(
                                      "[FAB Camera] Tidak menemukan track kamera aktif untuk di-restart: $e");
                                  cameraTrackToRestart = null;
                                }
                              }

                              print(
                                  "[FAB Camera] Camera Track to Restart Found: ${cameraTrackToRestart?.sid}");

                              if (cameraTrackToRestart != null) {
                                try {
                                  final newPosition = (_currentCameraPosition ==
                                          CameraPosition.front)
                                      ? CameraPosition.back
                                      : CameraPosition.front;
                                  print(
                                      '[FAB Camera] Mencoba mengganti kamera ke: $newPosition');
                                  final newOptions = CameraCaptureOptions(
                                      cameraPosition: newPosition);
                                  await cameraTrackToRestart
                                      .restartTrack(newOptions);
                                  print('[FAB Camera] restartTrack selesai.');
                                  if (mounted) {
                                    setState(() {
                                      _currentCameraPosition = newPosition;
                                      print(
                                          '[FAB Camera] State kamera diperbarui ke: $newPosition');
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Mengganti kamera ke ${newPosition.name}')),
                                    );
                                  }
                                } catch (e) {
                                  print(
                                      "[FAB Camera] Error saat restartTrack untuk ganti kamera: $e");
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Tidak dapat mengganti kamera.')),
                                    );
                                  }
                                }
                              } else {
                                print(
                                    "[FAB Camera] Track kamera aktif tidak ditemukan atau tidak dapat di-restart saat tombol ditekan.");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Track kamera tidak ditemukan atau belum siap untuk diganti.')),
                                  );
                                }
                              }
                            }
                          : null,
                      backgroundColor: (displayTrack != null &&
                              screenSharePub == null &&
                              !_isConnecting)
                          ? const Color(0xFF324EFF)
                          : Colors.grey,
                      child: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: const Color(0xFF3A59D1),
            elevation: 8.0,
            height: 70.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildNavItem(Icons.visibility_outlined, 'View', true),
                GestureDetector(
                  onTap: () {
                    print("[BottomNav] Tombol History ditekan.");

                    final roomCtx = context.read<RoomContext>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChangeNotifierProvider<RoomContext>.value(
                          value: roomCtx,
                          child: const TranscriptionScreen(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child:
                        _buildNavItem(Icons.history_outlined, 'History', false),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? Colors.white : const Color(0xFFB5C0ED);

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
