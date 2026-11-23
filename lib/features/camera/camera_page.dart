import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/permission_gate.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PermissionGate(
      name: 'Cámara',
      description: 'Necesitamos la cámara para que puedas tomar fotos.',
      icon: Icons.photo_camera_outlined,
      permissions: [Permission.camera],
      child: _CameraContent(),
    );
  }
}

class _CameraContent extends StatefulWidget {
  const _CameraContent();

  @override
  State<_CameraContent> createState() => _CameraContentState();
}

class _CameraContentState extends State<_CameraContent> {
  final _picker = ImagePicker();
  XFile? _photo;

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) setState(() => _photo = photo);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_photo != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(_photo!.path), height: 320),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no has tomado ninguna foto'),
            ),
          FilledButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tomar foto'),
          ),
        ],
      ),
    );
  }
}
