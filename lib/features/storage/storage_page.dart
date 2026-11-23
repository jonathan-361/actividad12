import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/permission_gate.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PermissionGate(
      name: 'Storage',
      description: 'Necesitamos acceso al almacenamiento para que puedas elegir archivos.',
      icon: Icons.folder_outlined,
      // Android 12 o menor -> storage. Android 13+ -> photos (READ_MEDIA_IMAGES).
      permissions: [Permission.storage, Permission.photos],
      child: _StorageContent(),
    );
  }
}

class _StorageContent extends StatefulWidget {
  const _StorageContent();

  @override
  State<_StorageContent> createState() => _StorageContentState();
}

class _StorageContentState extends State<_StorageContent> {
  PlatformFile? _file;
  int? _size;

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile();
    if (file == null) return; // El usuario canceló

    final size = await file.length();
    if (!mounted) return;
    setState(() {
      _file = file;
      _size = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (file != null) ...[
            const Icon(Icons.insert_drive_file, size: 72),
            const SizedBox(height: 8),
            Text(file.name),
            if (_size != null) Text('${(_size! / 1024).toStringAsFixed(1)} KB'),
          ] else
            const Text('Aún no has elegido ningún archivo'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Elegir archivo'),
          ),
        ],
      ),
    );
  }
}
