import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/app_toast.dart';
import '../../widgets/permission_gate.dart';

class SpeechPage extends StatelessWidget {
  const SpeechPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PermissionGate(
      name: 'Speech Recognition',
      description: 'Necesitamos reconocimiento de voz para convertir lo que dices en texto.',
      icon: Icons.record_voice_over_outlined,
      permissions: [Permission.speech],
      child: _SpeechContent(),
    );
  }
}

class _SpeechContent extends StatefulWidget {
  const _SpeechContent();

  @override
  State<_SpeechContent> createState() => _SpeechContentState();
}

class _SpeechContentState extends State<_SpeechContent> {
  final _speech = SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final available = await _speech.initialize(
      onStatus: (_) {
        if (!mounted) return;
        setState(() => _listening = _speech.isListening);
      },
      onError: (e) => AppToast.show('Error: ${e.errorMsg}'),
    );
    if (!mounted) return;
    setState(() => _available = available);
    if (!available) AppToast.show('Reconocimiento de voz no disponible');
  }

  Future<void> _toggle() async {
    if (_speech.isListening) {
      await _speech.stop();
    } else {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() => _text = result.recognizedWords);
        },
      );
    }
    if (!mounted) return;
    setState(() => _listening = _speech.isListening);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _text.isEmpty ? 'Presiona el botón y habla...' : _text,
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: _available ? _toggle : null,
            icon: Icon(_listening ? Icons.stop : Icons.mic),
            label: Text(_listening ? 'Detener' : 'Escuchar'),
          ),
        ],
      ),
    );
  }
}
