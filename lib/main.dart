import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:localmind/helpers/theme.dart';
import 'package:localmind/providers/data_provider.dart';
import 'package:localmind/providers/interface_provider.dart';
import 'package:localmind/widgets/app_body_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
