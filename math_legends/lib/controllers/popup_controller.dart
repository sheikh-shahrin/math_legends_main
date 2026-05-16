import 'package:get/get.dart';

class PopupController extends GetxController {
  final RxBool isPressed = false.obs;

  void pressDown() => isPressed.value = true;
  void release() => isPressed.value = false;
}
