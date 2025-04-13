import 'package:flutter/material.dart';
import 'package:localmind/helpers/theme.dart';
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
      providers: [ChangeNotifierProvider(create: (_) => InterfaceProvider())],
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
                            footerDivider: const Divider(),
                            footerBuilder:
                                (context, extended) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      !interfaceProvider
                                              .sidebarController
                                              .extended
                                          ? IconButton(
                                            onPressed: () {},
                                            icon: Icon(MdiIcons.logout),
                                          )
                                          : ElevatedButton.icon(
                                            icon: Icon(MdiIcons.logout),
                                            label: const Text("Cerrar sesión"),
                                            onPressed: () {},
                                          ),
                                    ],
                                  ),
                                ),
                            extendedTheme: SidebarXTheme(
                              width:
                                  size.width * 0.20 > 225
                                      ? 225
                                      : size.width * 0.20,
                            ),
                            headerBuilder:
                                (context, extended) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(MdiIcons.account),
                                      FittedBox(child: Text("LocalMind")),
                                      if (interfaceProvider
                                          .sidebarController
                                          .extended)
                                        FittedBox(child: Text("LocalMind")),
                                    ],
                                  ),
                                ),
                            items: [
                              SidebarXItem(icon: MdiIcons.home, label: "Inico"),
                              SidebarXItem(
                                icon: MdiIcons.cubeOutline,
                                label: "Productos",
                              ),
                              SidebarXItem(
                                icon: MdiIcons.sale,
                                label: "Subastas",
                              ),
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
