import 'package:fluttertoast/fluttertoast.dart';

void showAppSnackBar(dynamic context, String message) {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
}
