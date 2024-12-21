import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ir_dashboard/controllers/utility_controller.dart';
import 'package:ir_dashboard/widgets/select_entity_sheet.dart';

class LcNumberController extends GetxController {
  final UtilityController utilities = Get.find();

  final List<String> customerFlow = [
    "OP",
    "APP",
    "ACC",
    "APD",
    "RE",
    "FI",
    "CO"
  ];
  final List<String> departments = [
    "iGV",
    "iGTa",
    "iGTe",
    "oGV",
    "oGTa",
    "oGTe",
  ];
  final List<String> chipFilters = ["Region", "MC", "LC"];

  final List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Color(0xFF2196F3),
  ];

  final Map<String, Color> departmentColors = {
    "iGV": Color(0xFF0cb9c1),
    "iGTa": Color(0xFF00c16e),
    "iGTe": Color(0xFF7552cc),
    "oGV": Color(0xFFf85a40),
    "oGTa": Color(0xFF037ef3),
    "oGTe": Color(0xFFf48924),
  };

  final Map<String, List<Color>> departmentGradients = {
    "iGV": [Color(0xFF0cb9c1), Color(0xFF00c16e), Color(0xFF037ef3)],
    "iGTa": [Color(0xFF00c16e), Color(0xFF0cb9c1), Color(0xFF037ef3)],
    "iGTe": [Color(0xFF7552cc), Color(0xFF037ef3), Color(0xFFffc845)],
    "oGV": [Color(0xFFf85a40), Color(0xFFf48924), Color(0xFFffc845)],
    "oGTa": [Color(0xFF037ef3), Color(0xFF0cb9c1), Color(0xFFffc845)],
    "oGTe": [Color(0xFFf48924), Color(0xFFf85a40), Color(0xFF7552cc)],
  };

  final RxString fileStatusIndicator = "No data file loaded yet".obs;
  final RxInt filterByIndex = 0.obs; // 0 - region, 1 - mc, 2 - lc
  final RxString selectedEntity = "".obs;

  Set<String> regionsList = {};
  Set<String> mcsList = {};
  Set<String> lcsList = {};

  Map<String, Map> regionsData = {};
  Map<String, Map> mcsData = {};
  Map<String, Map> lcsData = {};

  Map<String, dynamic>? lcNumbersFileData;

  void handleFilePick() async {
    final Map<String, dynamic>? fileData = await utilities.handleFilePick();
    if (fileData != null) {
      if (fileData['fileData'].isNotEmpty) {
        fileStatusIndicator.value =
            "${fileData['fileName']} (${fileData['fileSize']})";
        lcNumbersFileData = _formatLcNumbersData(fileData['fileData']);
        _seperateData(lcNumbersFileData!);
      }
    }
  }

  Map<String, dynamic> _formatLcNumbersData(List fileData) {
    /// Format the loaded LC numbers file data into a structured data format
    ///
    /// The structured data format is a nested map of the following structure:
    ///
    /// * Region
    ///   * MC
    ///     * LC
    ///       * Department: count
    ///     * total: count
    ///   * total: count
    ///
    /// The `total` key is used to store the total count for each MC
    /// and for the region as a whole.
    ///
    /// The formatted data is returned as a map where the keys are the region
    /// names and the values are the nested maps as described above.
    Map<String, dynamic> formattedData = {};
    Map<String, Map<String, Map<String, double>>> totals = {};
    final List<String> headers = fileData.first.cast<String>();

    for (int i = 1; i < fileData.length; i++) {
      final List<dynamic> row = fileData[i];

      final String region = row[2] as String;
      final String mc = row[1] as String;
      final String lc = row[0] as String;

      regionsList.add(region);
      mcsList.add(mc);
      lcsList.add(lc);

      formattedData[region] ??= {};
      formattedData[region]![mc] ??= {};
      formattedData[region]![mc]![lc] ??= {};

      totals[region] ??= {};
      totals[region]![mc] ??= {};
      totals[region]!['total'] ??= {};

      for (int j = 3; j < headers.length; j++) {
        final String department = headers[j];
        final int value = row[j];

        formattedData[region]![mc]![lc]![department] = value;
        totals[region]![mc]![department] =
            (totals[region]![mc]![department] ?? 0) + value;
        totals[region]!['total']![department] =
            (totals[region]!['total']![department] ?? 0) + value;
      }
      for (final region in totals.keys) {
        for (final mc in totals[region]!.keys) {
          if (mc != 'total') {
            formattedData[region]![mc]!['total'] = totals[region]![mc]!;
          }
        }
        formattedData[region]!['total'] = totals[region]!['total']!;
      }
    }
    return formattedData;
  }

  void _seperateData(Map<String, dynamic> formattedData) {
    for (final region in formattedData.keys) {
      regionsData[region] = formattedData[region]!['total']!;
      for (final mc in formattedData[region]!.keys) {
        if (mc != 'total') {
          mcsData['$mc'] = formattedData[region]![mc]!['total']!;
          for (final lc in formattedData[region]![mc]!.keys) {
            if (lc != 'total') {
              lcsData['$lc'] = formattedData[region]![mc]![lc]!;
            }
          }
        }
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
