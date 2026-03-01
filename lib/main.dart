import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_theme.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise offline storage.
  await StorageService.instance.init();

  runApp(const TreeSytApp());
}

class TreeSytApp extends StatelessWidget {
  const TreeSytApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit must wrap MaterialApp so that .w / .h / .sp extensions
    // are available to every widget in the tree. The design canvas matches the
    // Figma reference frame (393 × 852 px).
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'TreeSyt',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const HomeScreen(),
          // On web, wrap in a centred mobile-sized frame so it doesn't fill the
          // full desktop browser width.
          builder: (context, child) {
            if (!kIsWeb) return child!;
            return _WebPhoneFrame(child: child!);
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Phone frame — shown only when running on Flutter web
// ---------------------------------------------------------------------------
class _WebPhoneFrame extends StatelessWidget {
  final Widget child;
  const _WebPhoneFrame({super.key, required this.child});

  static const _phoneW = 393.0;
  static const _maxPhoneH = 852.0;

  @override
  Widget build(BuildContext context) {
    final viewSize = MediaQuery.of(context).size;

    // On a narrow viewport (real mobile browser) just render full-screen.
    if (viewSize.width <= _phoneW + 48) return child;

    final phoneH =
        viewSize.height < _maxPhoneH ? viewSize.height : _maxPhoneH;
    final hasRoundedCorners = phoneH >= _maxPhoneH - 1;

    return ColoredBox(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Container(
          width: _phoneW,
          height: phoneH,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: hasRoundedCorners
                ? BorderRadius.circular(44)
                : BorderRadius.zero,
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 80,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: Color(0x0AFFFFFF),
                blurRadius: 0,
                offset: Offset(-2, -2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
