import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:localmind/helpers/theme.dart';
import 'package:localmind/providers/data_provider.dart';
import 'package:localmind/providers/interface_provider.dart';
import 'package:localmind/widgets/app_body_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:window_manager/window_manager.dart';
import 'package:localmind/helpers/process_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cleanup any old orphaned instances before starting
  await ProcessHelper.cleanupOldGemmaInstances();
  
  await FlutterGemma.initialize();
  windowManager.ensureInitialized().then((value) async {
    // Set up window closing interception
    await windowManager.setPreventClose(true);
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Cleanup instances when the window is closed
    await ProcessHelper.cleanupOldGemmaInstances();
    // Effectively close the window
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InterfaceProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider.Init()),
      ],
      child: MaterialApp(
        title: 'LocalMind',
        theme: THEMEDATA,
        home: Builder(
          builder: (context) {
            var interfaceProvider = Provider.of<InterfaceProvider>(
              context,
              listen: false,
            );
            return Scaffold(
              body: Container(
                width: size.width,
                height: size.height,
                child: Stack(
                  children: [
                    // Background layer with subtle overlay
                    Positioned.fill(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              "assets/images/app_background.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: backgroundColor.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          SidebarX(
                            controller: interfaceProvider.sidebarController,
                            showToggleButton: size.width < 615 ? false : true,
                            theme: SidebarXTheme(
                              width: 70,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                              textStyle: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: secondaryTextColor),
                              selectedTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                              itemPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              selectedItemPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              itemMargin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              selectedItemMargin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              itemTextPadding: const EdgeInsets.only(left: 15),
                              selectedItemTextPadding: const EdgeInsets.only(
                                left: 15,
                              ),
                              iconTheme: IconThemeData(
                                color: secondaryTextColor,
                                size: 20,
                              ),
                              selectedIconTheme: IconThemeData(
                                color: Colors.white,
                                size: 20,
                              ),
                              selectedItemDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor.withOpacity(0.1),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                ),
                              ),
                            ),
                            extendedTheme: SidebarXTheme(
                              width:
                                  size.width * 0.20 > 225
                                      ? 225
                                      : size.width * 0.20,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                            ),
                            headerBuilder:
                                (context, extended) => Padding(
                                  padding: const EdgeInsets.only(
                                    top: 42,
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child:
                                      Image.asset(
                                        "assets/images/app_${interfaceProvider.sidebarController.extended ? "logo" : "icon"}.png",
                                        height: 40,
                                      ).animate().fadeIn(),
                                ),
                            items: [
                              SidebarXItem(
                                icon: MdiIcons.chat,
                                label: "Chat",
                                onTap:
                                    () => interfaceProvider.setSidebarIndex(0),
                              ),
                              SidebarXItem(
                                icon: MdiIcons.viewGridPlus,
                                label: "Modelos",
                                onTap:
                                    () => interfaceProvider.setSidebarIndex(1),
                              ),
                            ],
                          ),
                          Expanded(child: AppBody()),
                        ],
                      ),
                    ),
                    _buildDownloadOverlay(context, size),
                  ],
                ),
              ),
            );
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Widget _buildDownloadOverlay(BuildContext context, Size size) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isModelReady) return const SizedBox.shrink();

        return Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: backgroundColor.withOpacity(0.7),
              child: Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              MdiIcons.brain,
                              size: 48,
                              color: primaryColor,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2.seconds,
                            color: primaryColor.withOpacity(0.3),
                          ),
                      const SizedBox(height: 32),
                      Text(
                        dataProvider.downloadStatusText,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (dataProvider.hasError) ...[
                        ElevatedButton.icon(
                          onPressed: () => dataProvider.retryInitialization(),
                          icon: Icon(MdiIcons.refresh),
                          label: const Text("Intentar nuevamente"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ] else if (dataProvider.isDownloading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: dataProvider.downloadProgress / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${dataProvider.downloadProgressDouble.toStringAsFixed(1)}%",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: primaryColor),
                            ),
                            if (dataProvider.totalSizeText.isNotEmpty)
                              Text(
                                "${dataProvider.downloadedSizeText} / ${dataProvider.totalSizeText}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ] else ...[
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
