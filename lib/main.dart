import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myfxmentor/bindings/auth_binding.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "myfxmentor",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.gate,
      getPages: AppPages.pages,
      initialBinding: AuthBinding(),
    );

  }
}
