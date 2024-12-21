import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/utility_controller.dart';
import '../widgets/lc_numbers.dart';
import '../widgets/slots.dart';

class HomeScreen extends GetView<UtilityController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe8edf5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text("IR Dashboard",
                style: GoogleFonts.inter(
                    fontSize: 45, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16.0,
                children: [LcNumbers(), Slots()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
