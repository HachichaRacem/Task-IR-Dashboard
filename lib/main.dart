import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ir_dashboard/screens/home_screen.dart';
import 'package:toastification/toastification.dart';

import 'controllers/utility_controller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Color(
            0xFF037EF3,
          ),
        ),
        getPages: [
          GetPage(
            name: '/',
            page: () => HomeScreen(),
            binding: BindingsBuilder.put(
              () => UtilityController(),
            ),
          )
        ],
        initialRoute: '/',
      ),
    );
  }
}
