import 'package:flutter/material.dart';

import 'record_witness_screen.dart';
import 'voice_note_recorder.dart';

class RecordConsentScreen extends StatelessWidget {
  const RecordConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VoiceNoteRecorder(
      headerText: "Take leader's voice note as evidence",
      onProceed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecordWitnessScreen()),
      ),
    );
  }
}
