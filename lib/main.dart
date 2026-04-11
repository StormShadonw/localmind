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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();
  windowManager.ensureInitialized().then((value) async {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
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
                    Container(
                      child: Image.asset("assets/images/app_background.png"),
                    ),
                    Container(
                      // width: size.width,
                      // height: size.height,
                      child: Row(
                        children: [
                          SidebarX(
                            controller: interfaceProvider.sidebarController,
                            showToggleButton: size.width < 615 ? false : true,

                            // footerDivider: const Divider(),
                            // footerBuilder:
                            //     (context, extended) => Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //         vertical: 15,
                            //         horizontal: 10,
                            //       ),
                            //       child: Column(
                            //         mainAxisAlignment: MainAxisAlignment.end,
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.center,
                            //         children: [
                            //           !interfaceProvider
                            //                   .sidebarController
                            //                   .extended
                            //               ? IconButton(
                            //                 onPressed: () {},
                            //                 icon: Icon(MdiIcons.logout),
                            //               )
                            //               : ElevatedButton.icon(
                            //                 icon: Icon(MdiIcons.logout),
                            //                 label: const Text("Cerrar sesión"),
                            //                 onPressed: () {},
                            //               ),
                            //         ],
                            //       ),
                            //     ),
                            theme: SidebarXTheme(
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                            extendedTheme: SidebarXTheme(
                              width:
                                  size.width * 0.20 > 225
                                      ? 225
                                      : size.width * 0.20,
                              textStyle: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: Colors.black87),

                              decoration: BoxDecoration(color: Colors.white),
                            ),
                            headerBuilder:
                                (context, extended) => Padding(
                                  padding: const EdgeInsets.only(
                                    top: 25,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: FittedBox(
                                    child:
                                        Image.asset(
                                          "assets/images/app_${interfaceProvider.sidebarController.extended ? "logo" : "icon"}.png",
                                        ).animate().fadeIn(),
                                  ),
                                ),
                            items: [
                              SidebarXItem(
                                icon: MdiIcons.home,
                                label: "Chat",
                                onTap:
                                    () => interfaceProvider.setSidebarIndex(0),
                              ),
                              SidebarXItem(
                                icon: MdiIcons.faceAgent,
                                label: "Models",

                                onTap:
                                    () => interfaceProvider.setSidebarIndex(1),
                              ),

                              // SidebarXItem(
                              //   icon: MdiIcons.sale,
                              //   label: "Subastas",
                              // ),
                              // if (dataProvider.user!.administrator == "1")
                              //   SidebarXItem(
                              //       icon: MdiIcons.poll,
                              //       label: value.languageDictionary[value.language]!["sideBar10"] ??
                              //           ""),
                            ],
                          ),
                          AppBody(),
                        ],
                      ),
                    ),
                    Consumer<DataProvider>(
                      builder: (context, dataProvider, child) {
                        if (dataProvider.isModelReady)
                          return const SizedBox.shrink();
                        return Positioned.fill(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: const Color(0xFF031734).withOpacity(
                                  0.6,
                                ), // Using theme color with opacity for glass effect
                                child: Center(
                                  child: Container(
                                    width: size.width * 0.45,
                                    padding: const EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          MdiIcons.brain,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          dataProvider.downloadStatusText,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        if (dataProvider.hasError) ...[
                                          const SizedBox(height: 20),
                                          ElevatedButton.icon(
                                            onPressed:
                                                () =>
                                                    dataProvider
                                                        .retryInitialization(),
                                            icon: Icon(MdiIcons.refresh),
                                            label: const Text(
                                              "Intentar nuevamente",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 18,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ] else if (dataProvider
                                            .isDownloading) ...[
                                          LinearProgressIndicator(
                                            value:
                                                dataProvider.downloadProgress /
                                                100,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            backgroundColor: Colors.white24,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${dataProvider.downloadProgressDouble.toStringAsFixed(0)}%",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              if (dataProvider
                                                  .totalSizeText
                                                  .isNotEmpty)
                                                Text(
                                                  "${dataProvider.downloadedSizeText} / ${dataProvider.totalSizeText}",
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ] else ...[
                                          CircularProgressIndicator(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
}
