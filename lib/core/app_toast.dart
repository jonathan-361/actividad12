import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  AppToast._();

  static void show(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
