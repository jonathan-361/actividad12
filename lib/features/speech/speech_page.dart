import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/app_toast.dart';
import '../../core/permission_service.dart';

class SpeechPage extends StatefulWidget {
  const SpeechPage({super.key});

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> with WidgetsBindingObserver {
  final _service = const PermissionService();
  PermissionStatus _status = PermissionStatus.denied;
  bool _requested = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final status = await _service.check([Permission.speech]);
    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _requestPermission() async {
    setState(() => _loading = true);
    final status = await _service.request([
      Permission.speech,
    ], 'Speech Recognition');
    if (!mounted) return;
    setState(() {
      _status = status;
      _requested = true;
      _loading = false;
    });
  }

  Future<void> _openSettings() async {
    await _service.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_status.isGranted || _status.isLimited) {
      return const _SpeechContent();
    }

    final theme = Theme.of(context);
    final needsSettings = _status.isPermanentlyDenied || _status.isRestricted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.record_voice_over_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Reconocimiento de voz', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Permite convertir lo que dices en texto.',
              textAlign: TextAlign.center,
            ),
            if (_requested) ...[
              const SizedBox(height: 16),
              Text(
                needsSettings
                    ? 'El permiso fue denegado. Actívalo en ajustes.'
                    : 'No se concedió el permiso de reconocimiento de voz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading
                  ? null
                  : needsSettings
                  ? _openSettings
                  : _requestPermission,
              icon: Icon(needsSettings ? Icons.settings : Icons.lock_open),
              label: Text(
                needsSettings ? 'Abrir ajustes' : 'Solicitar permiso de voz',
              ),
            ),
          ],
        ),
      ),
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
            label: Text(
              _listening ? 'Detener transcripción' : 'Comenzar a transcribir',
            ),
          ),
        ],
      ),
    );
  }
}
