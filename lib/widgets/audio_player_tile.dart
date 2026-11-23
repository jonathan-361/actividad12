import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerTile extends StatefulWidget {
  const AudioPlayerTile({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  State<AudioPlayerTile> createState() => _AudioPlayerTileState();
}

class _AudioPlayerTileState extends State<AudioPlayerTile> {
  final _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      _player.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _state = s);
      }),
      _player.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      }),
      _player.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _position = Duration.zero);
      }),
    ]);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
    } else if (_state == PlayerState.paused) {
      await _player.resume();
    } else {
      await _player.play(DeviceFileSource(widget.path));
    }
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == PlayerState.playing;
    final maxMs = _duration.inMilliseconds > 0 ? _duration.inMilliseconds : 1;
    final valueMs = _position.inMilliseconds.clamp(0, maxMs).toDouble();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            IconButton.filled(
              onPressed: _toggle,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title),
                  Slider(
                    min: 0,
                    max: maxMs.toDouble(),
                    value: valueMs,
                    onChanged: _duration.inMilliseconds > 0
                        ? (v) => _player.seek(Duration(milliseconds: v.round()))
                        : null,
                  ),
                ],
              ),
            ),
            Text('${_format(_position)} / ${_format(_duration)}'),
          ],
        ),
      ),
    );
  }
}
