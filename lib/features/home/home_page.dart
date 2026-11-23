import 'package:flutter/material.dart';

import '../camera/camera_page.dart';
import '../microphone/microphone_page.dart';
import '../speech/speech_page.dart';
import '../storage/storage_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _titles = [
    'Cámara',
    'Micrófono',
    'Speech recognition',
    'Storage',
  ];

  static const _pages = <Widget>[
    CameraPage(),
    MicrophonePage(),
    SpeechPage(),
    StoragePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            label: 'Cámara',
          ),
          NavigationDestination(icon: Icon(Icons.mic_none), label: 'Micrófono'),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_outlined),
            label: 'Voz',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Storage',
          ),
        ],
      ),
    );
  }
}
