import 'package:flutter/material.dart';
import 'package:localmind/providers/interface_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class AppBody extends StatefulWidget {
  const AppBody({super.key});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> with WindowListener {
  late InterfaceProvider interfaceProvider;

  Future<void> setInitState() async {
    await interfaceProvider.getWindowSize();
    await windowManager.setAspectRatio(1.77777);
    WindowOptions windowOptions = WindowOptions(
      size: interfaceProvider.windowSize,
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(this);
  }

  @override
  void initState() {
    super.initState();
    interfaceProvider = Provider.of<InterfaceProvider>(context, listen: false);
    setInitState();
  }

  @override
  void onWindowResized() async {
    Size newSize = await windowManager.getSize();
    interfaceProvider.setWindowSize(newSize);
    super.onWindowResized();
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        child: Center(
          child: Text("Hello!", style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}
