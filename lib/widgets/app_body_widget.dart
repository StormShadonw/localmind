import 'package:flutter/material.dart';
import 'package:localmind/pages/chat_page.dart';
import 'package:localmind/pages/models_page.dart';
import 'package:localmind/pages/test_page.dart';
import 'package:localmind/providers/data_provider.dart';
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
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Consumer<InterfaceProvider>(
                builder: (context, value, child) {
                  switch (value.sidebarIndex) {
                    case 0:
                      return const ChatPage(pageTitle: "Chat");
                    case 1:
                      return const ModelsPage(pageTitle: "Models");
                    // return ModelDownloadScreen(
                    //   modelName: "testModelName",
                    //   modelUrl:
                    //       "https://www.dropbox.com/s/2i7m0t8w0o0m8d1/testModel.zip?dl=1",
                    // );
                    default:
                      return const ChatPage(pageTitle: "Chat");
                  }
                },
              ),
            ),
            Consumer<DataProvider>(
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  width: size.width,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                    value.status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
