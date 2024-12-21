import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ir_dashboard/controllers/utility_controller.dart';

import '../widgets/select_entity_sheet.dart';

class SlotsController extends GetxController {
  final UtilityController utilities = Get.find();
  final RxString fileStatusIndicator = "No data file loaded yet".obs;

  final List<String> chipFilters = ["Region", "MC", "LC"];
  final RxInt filterByIndex = 0.obs;
  final RxString selectedEntity = "".obs;

  Set<String> regionsList = {};
  Set<String> mcsList = {};
  Set<String> lcsList = {};
  Set<String> fieldsList = {};

  Map<String, Map> regionsData = {};
  Map<String, Map> mcsData = {};
  Map<String, Map> lcsData = {};

  RxList<dynamic> slotsData = RxList();

  void _init(List fileData) {
    final List<String> headers = fileData.first.cast<String>();
    for (int i = 1; i < fileData.length; i++) {
      final List<dynamic> row = fileData[i];

      final String region = row[19] as String;
      final String mc = row[18] as String;
      final String lc = row[17] as String;

      regionsList.add(region);
      mcsList.add(mc);
      lcsList.add(lc);

      for (int j = 0; j < headers.length; j++) {
        final String key = headers[j];
        final dynamic value = row[j];

        if (key == "Work Field") {
          if ((value as String).isNotEmpty) {
            fieldsList.add(value);
          }
        }
      }
    }
    slotsData.value = fileData.sublist(1);
  }

  void handleFilePick() async {
    final Map<String, dynamic>? fileData = await utilities.handleFilePick();
    if (fileData != null) {
      if (fileData['fileData'].isNotEmpty) {
        fileStatusIndicator.value =
            "${fileData['fileName']} (${fileData['fileSize']})";
        _init(fileData['fileData']);
      }
    }
  }

  void _onEntitySelect(String value) {
    selectedEntity.value = value;
  }

  void onSelectEntityClick(BuildContext context) {
    showBottomSheet(
      constraints: BoxConstraints.loose(Size.fromHeight(Get.height * 0.4)),
      context: context,
      builder: (context) => SelectEntitySheet(
        items: filterByIndex.value == 0
            ? regionsList.toList()
            : filterByIndex.value == 1
                ? mcsList.toList()
                : lcsList.toList(),
        onItemTap: _onEntitySelect,
      ),
    );
  }
}
