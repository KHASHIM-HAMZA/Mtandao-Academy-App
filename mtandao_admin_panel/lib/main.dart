import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:mtandao_admin_panel/providers/auth_provider.dart';
import 'package:mtandao_admin_panel/router/App_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MtandaoAdminApp());
}

class MtandaoAdminApp extends StatelessWidget {
  const MtandaoAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here as we build them
      ],
      child: MaterialApp.router(
        title: 'Mtandao Academy Admin',
        debugShowCheckedModeBanner: false,
        theme:
            FlexColorScheme.light(
              scheme: FlexScheme.blueWhale,
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 7,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 10,
                blendOnColors: false,
                useTextTheme: true,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              useMaterial3: true,
              swapLegacyOnMaterial3: true,
            ).toTheme,
        darkTheme:
            FlexColorScheme.dark(
              scheme: FlexScheme.blueWhale,
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 13,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 20,
                useTextTheme: true,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              useMaterial3: true,
              swapLegacyOnMaterial3: true,
            ).toTheme,
        themeMode: ThemeMode.light,
        builder:
            (context, child) => ResponsiveWrapper.builder(
              ClampingScrollWrapper.builder(context, child!),
              defaultScale: true,
              breakpoints: [
                const ResponsiveBreakpoint.resize(350, name: MOBILE),
                const ResponsiveBreakpoint.autoScale(600, name: TABLET),
                const ResponsiveBreakpoint.resize(800, name: DESKTOP),
                const ResponsiveBreakpoint.autoScale(1700, name: 'XL'),
              ],
            ),
        routerConfig: AppRouter().router,
      ),
    );
  }
}
