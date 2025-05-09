import 'package:flutter/material.dart';
import 'package:livekit_components/livekit_components.dart';
import 'package:provider/provider.dart';
import '../widgets/transcription_widget.dart' as local;

class TranscriptionScreen extends StatelessWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transkripsi Langsung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TranscriptionBuilder(
          builder: (context, roomCtx, transcriptions) {
            return local.TranscriptionWidget(
              textColor: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              transcriptions: transcriptions,
            );
          },
        ),
      ),
    );
  }
}
