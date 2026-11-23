import 'package:permission_handler/permission_handler.dart';

import 'app_toast.dart';

class PermissionService {
  const PermissionService();

  bool _isOk(PermissionStatus s) => s.isGranted || s.isLimited;

  /// Consulta el estado sin mostrar ningún diálogo.
  Future<PermissionStatus> check(List<Permission> permissions) async {
    var last = PermissionStatus.denied;
    for (final permission in permissions) {
      last = await permission.status;
      if (_isOk(last)) return last;
    }
    return last;
  }

  /// Solicita el permiso y avisa el resultado con un toast.
  Future<PermissionStatus> request(
    List<Permission> permissions,
    String name,
  ) async {
    var last = PermissionStatus.denied;
    for (final permission in permissions) {
      last = await permission.request();
      if (_isOk(last)) break;
    }
    _notify(last, name);
    return last;
  }

  Future<bool> openSettings() => openAppSettings();

  void _notify(PermissionStatus status, String name) {
    if (status.isGranted) {
      AppToast.show('Permiso de $name concedido');
    } else if (status.isLimited) {
      AppToast.show('Permiso de $name con acceso limitado');
    } else if (status.isPermanentlyDenied) {
      AppToast.show(
        'Permiso de $name denegado permanentemente. Actívalo en ajustes.',
      );
    } else if (status.isRestricted) {
      AppToast.show('Permiso de $name restringido por el sistema');
    } else {
      AppToast.show('Permiso de $name denegado');
    }
  }
}
