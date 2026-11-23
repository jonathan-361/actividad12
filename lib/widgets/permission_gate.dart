import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/permission_service.dart';

/// Muestra [child] solo si el permiso está concedido. Si no, muestra una
/// pantalla para solicitarlo (o para abrir ajustes si fue denegado
/// permanentemente).
class PermissionGate extends StatefulWidget {
  const PermissionGate({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.permissions,
    required this.child,
  });

  final String name;
  final String description;
  final IconData icon;
  final List<Permission> permissions;
  final Widget child;

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with WidgetsBindingObserver {
  final _service = const PermissionService();
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Si el usuario cambia el permiso en ajustes y vuelve a la app,
  // se vuelve a consultar el estado.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await _service.check(widget.permissions);
    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _request() async {
    final status = await _service.request(widget.permissions, widget.name);
    if (!mounted) return;
    setState(() => _status = status);
  }

  String _label(PermissionStatus s) {
    if (s.isPermanentlyDenied) return 'Denegado permanentemente';
    if (s.isRestricted) return 'Restringido por el sistema';
    return 'Permiso no concedido';
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    if (status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status.isGranted || status.isLimited) {
      return widget.child;
    }

    final needsSettings = status.isPermanentlyDenied || status.isRestricted;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Permiso de ${widget.name}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(widget.description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Chip(label: Text(_label(status))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: needsSettings ? _service.openSettings : _request,
              icon: Icon(needsSettings ? Icons.settings : Icons.lock_open),
              label: Text(needsSettings ? 'Abrir ajustes' : 'Conceder permiso'),
            ),
          ],
        ),
      ),
    );
  }
}
