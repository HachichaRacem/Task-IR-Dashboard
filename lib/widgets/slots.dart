import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/slots_controller.dart';

class Slots extends GetView<SlotsController> {
  const Slots({super.key});

  Widget _fieldsDistribution() {
    int total = 0;
    Map<String, int> fieldsDistribution = {};
    for (final String field in controller.fieldsList) {
      int fieldCount = 0;
      for (int i = 0; i < controller.slotsData.length; i++) {
        if (controller.slotsData[i][5] == field) {
          switch (controller.filterByIndex.value) {
            case 0:
              if (controller.slotsData[i][19] ==
                  controller.selectedEntity.value) {
                fieldCount++;
                total++;
              }
              break;
            case 1:
              if (controller.slotsData[i][18] ==
                  controller.selectedEntity.value) {
                fieldCount++;
                total++;
              }
              break;
            case 2:
              if (controller.slotsData[i][17] ==
                  controller.selectedEntity.value) {
                fieldCount++;
                total++;
              }
              break;
          }
        }
      }
      fieldsDistribution[field] = fieldCount;
    }

    Map fieldsDistributionPercentages =
        fieldsDistribution.map((key, value) => MapEntry(key, value / total));
    final maxRadius = 40.0;
    final minRadius = 10.0;
    final maxPercentage =
        fieldsDistributionPercentages.values.reduce((a, b) => a > b ? a : b);

    return Wrap(
        children: fieldsDistributionPercentages.entries.map((entry) {
      final String field = entry.key;
      final double percentage = entry.value;
      final normalizedRadius = (percentage / maxPercentage) * maxRadius;
      final diameter =
          normalizedRadius < minRadius ? minRadius * 2 : normalizedRadius * 2;

      return Column(
        children: [
          Container(
            width: diameter.isNaN ? minRadius : diameter,
            height: diameter.isNaN ? minRadius : diameter,
            decoration: BoxDecoration(
              color: Colors.primaries[
                  fieldsDistribution.keys.toList().indexOf(field) %
                      Colors.primaries.length],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
          ),
          SizedBox(height: 8),
          Text(
            field,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '${percentage.isNaN ? '0%' : (percentage * 100).toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    Get.put(SlotsController());
    return Card(
      color: Color(0xFFfefeff),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromWidth(380)),
            child: Obx(
              () => Column(
                spacing: 14.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    spacing: 16.0,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Entities in Slots",
                            style: GoogleFonts.voces(
                                fontWeight: FontWeight.w700, fontSize: 16.0),
                          ),
                          Text(
                            controller.fileStatusIndicator.value,
                            style: GoogleFonts.inter(
                                color: Colors.black45, fontSize: 12),
                          ),
                        ],
                      ),
                      MaterialButton(
                        onPressed: controller.handleFilePick,
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1.0,
                            color: Get.theme.colorScheme.outline
                                .withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text("Pick File"),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6.0,
                        children: List.generate(controller.chipFilters.length,
                            (index) {
                          return ChoiceChip(
                            label: Text(controller.chipFilters[index]),
                            selected: index == controller.filterByIndex.value,
                            onSelected: (value) {
                              if (index != controller.filterByIndex.value &&
                                  value) {
                                controller.selectedEntity.value = "";
                                controller.filterByIndex.value = index;
                              }
                            },
                          );
                        }),
                      ),
                      if (controller.slotsData.isNotEmpty)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.symmetric(
                              vertical: BorderSide(
                                width: 1,
                                color: Get.theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: SizedBox(
                            width: 1,
                            height: 26,
                          ),
                        ),
                      if (controller.slotsData.isNotEmpty)
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints.loose(
                              Size.fromWidth(140),
                            ),
                            child: MaterialButton(
                              onPressed: () =>
                                  controller.onSelectEntityClick(context),
                              color: Color(0xFF037EF3),
                              splashColor: Color.fromARGB(255, 37, 143, 241)
                                  .withValues(alpha: 0.5),
                              padding: EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                controller.selectedEntity.isEmpty
                                    ? "Select Entity"
                                    : controller.selectedEntity.value,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (controller.selectedEntity.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
                      child: _fieldsDistribution(),
                    )
                ],
              ),
            )),
      ),
    );
  }
}
