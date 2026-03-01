import 'package:flutter/material.dart';

import 'success_screen.dart';
import 'voice_note_recorder.dart';

class RecordWitnessScreen extends StatelessWidget {
  const RecordWitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VoiceNoteRecorder(
      headerText: "Take witness's voice note as evidence",
      onProceed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
      ),
    );
  }
}
