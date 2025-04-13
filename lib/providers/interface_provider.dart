import 'package:flutter/material.dart';
import 'package:localmind/helpers/shared_preferences_helper.dart';
import 'package:sidebarx/sidebarx.dart';

class InterfaceProvider extends ChangeNotifier {
  Size windowSize = Size(1920, 1080);
  int sidebarIndex = 0;
  final SidebarXController sidebarController = SidebarXController(
    selectedIndex: 0,
  );

  Future<void> getWindowSize() async {
    var height = await SharedPreferencesHelper.getValue("size_height");
    var width = await SharedPreferencesHelper.getValue("size_width");
    if (height != "" && width != "") {
      windowSize = Size(double.parse(width), double.parse(height));
      notifyListeners();
    }
  }

  Future<void> setWindowSize(Size size) async {
    await SharedPreferencesHelper.setValue(
      "size_height",
      size.height.toString(),
    );
    await SharedPreferencesHelper.setValue("size_width", size.width.toString());
  }

  void setSidebarIndex(int index) {
    sidebarIndex = index;
    notifyListeners();
  }
}
