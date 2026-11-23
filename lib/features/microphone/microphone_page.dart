import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../core/app_toast.dart';
import '../../widgets/permission_gate.dart';

class MicrophonePage extends StatelessWidget {
  const MicrophonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PermissionGate(
      name: 'Micrófono',
      description: 'Necesitamos el micrófono para grabar notas de voz.',
      icon: Icons.mic_none,
      permissions: [Permission.microphone],
      child: _MicrophoneContent(),
    );
  }
}

class _MicrophoneContent extends StatefulWidget {
  const _MicrophoneContent();

  @override
  State<_MicrophoneContent> createState() => _MicrophoneContentState();
}

class _MicrophoneContentState extends State<_MicrophoneContent> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _lastPath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _lastPath = path;
      });
      AppToast.show('Grabación guardada');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/nota_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() => _isRecording = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.graphic_eq : Icons.mic,
              size: 96,
              color: _isRecording ? Colors.red : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(_isRecording ? 'Grabando...' : 'Listo para grabar'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
              label: Text(_isRecording ? 'Detener' : 'Grabar'),
            ),
            if (_lastPath != null) ...[
              const SizedBox(height: 24),
              Text('Último audio:', style: theme.textTheme.labelLarge),
              Text(_lastPath!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
