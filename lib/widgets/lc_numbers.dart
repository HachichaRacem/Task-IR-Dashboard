import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ir_dashboard/controllers/lcnumber_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class LcNumbers extends GetView<LcNumberController> {
  const LcNumbers({super.key});

  // you were stuck trying to figure out how to show the lines
  // the actual values depends on the selected entity and filter option
  // so if LC selected then you have to actually find out the region and then the MC to reach deep down the map
  // an idea occured to you is that to divide the "big" data into 3 seperate maps, regions, mcs and then lcs and you already
  // have the totals for regions and Mcs so it should be easy to do, and then use the corresponding map to get the data
  // depedning on the filters and the options choosen.

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: Text(
        controller.customerFlow[value.toInt()],
        style: Get.textTheme.bodySmall!
            .copyWith(color: Colors.white70, fontSize: 8),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      '$value',
      style:
          Get.textTheme.bodySmall!.copyWith(color: Colors.white70, fontSize: 8),
    );
  }

  List<FlSpot> _spots(int deptIndex) {
    List<FlSpot> spots = [];
    final String targetDepartment = controller.departments[deptIndex];
    switch (controller.filterByIndex.value) {
      case 0:
        controller.regionsData[controller.selectedEntity.value]
            ?.forEach((key, value) {
          final String status = key.split('-')[1];
          final String dept = key.split('-')[0];
          if (dept == targetDepartment) {
            spots.add(FlSpot(
                controller.customerFlow.indexOf(status).toDouble(), value));
          }
        });
        break;
      case 1:
        controller.mcsData[controller.selectedEntity.value]
            ?.forEach((key, value) {
          final String status = key.split('-')[1];
          final String dept = key.split('-')[0];
          if (dept == targetDepartment) {
            spots.add(FlSpot(
                controller.customerFlow.indexOf(status).toDouble(), value));
          }
        });
        break;
      case 2:
        controller.lcsData[controller.selectedEntity.value]
            ?.forEach((key, value) {
          final String status = key.split('-')[1];
          final String dept = key.split('-')[0];
          if (dept == targetDepartment) {
            spots.add(FlSpot(
                controller.customerFlow.indexOf(status).toDouble(), value));
          }
        });
        break;
    }
    return spots;
  }

  List<LineChartBarData> _lineBarsData({bool isEmptyState = false}) {
    List<LineChartBarData> lineBarsData = [];
    if (isEmptyState) {
      for (final _ in controller.departments) {
        lineBarsData.add(
          LineChartBarData(
            isCurved: true,
            barWidth: 1,
            isStrokeCapRound: true,
            preventCurveOverShooting: true,
            isStrokeJoinRound: true,
            spots: controller.customerFlow
                .map((e) =>
                    FlSpot(controller.customerFlow.indexOf(e).toDouble(), 0))
                .toList(),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: controller.gradientColors
                    .map((color) => color.withValues(alpha: 0.3))
                    .toList(),
              ),
            ),
          ),
        );
      }
    } else {
      for (int i = 0; i < controller.departments.length; i++) {
        lineBarsData.add(
          LineChartBarData(
            isCurved: true,
            barWidth: 2.0,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            color: controller.departmentColors[controller.departments[i]],
            spots: _spots(i),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: controller
                    .departmentGradients[controller.departments[i]]!
                    .map((color) => color.withValues(alpha: 0.15))
                    .toList(),
              ),
            ),
          ),
        );
      }
    }
    return lineBarsData;
  }

  Widget _lineChart() => LineChart(
        LineChartData(
            lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) => List.generate(
                  touchedSpots.length,
                  (index) => LineTooltipItem(
                        '${touchedSpots[index].y}',
                        TextStyle(
                            color: touchedSpots[index].bar.color,
                            fontSize: 8,
                            fontWeight: FontWeight.w500),
                      )),
            )),
            gridData: FlGridData(
              show: true,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.white38,
                  strokeWidth: 1,
                  dashArray: [5, 3],
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.white38,
                  strokeWidth: 1,
                  dashArray: [5, 3],
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 36,
                ),
              ),
            ),
            lineBarsData:
                _lineBarsData(isEmptyState: controller.selectedEntity.isEmpty)),
      );

  @override
  Widget build(BuildContext context) {
    Get.put(LcNumberController());
    return Obx(
      () => Card(
        color: Color(0xFFfefeff),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromWidth(380)),
            child: Column(
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
                          "Entities in Numbers",
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
                      padding:
                          EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
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
                    Obx(
                      () => Row(
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
                    ),
                    if (controller.lcNumbersFileData != null)
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
                    if (controller.lcNumbersFileData != null)
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
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Get.theme.colorScheme.inverseSurface,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 12.0, bottom: 12, left: 12.0, right: 34),
                      child: AspectRatio(aspectRatio: 2.5, child: _lineChart()),
                    ),
                  ),
                ),
                if (controller.selectedEntity.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        spacing: 16.0,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(controller.departments.length,
                            (index) {
                          return Column(
                              spacing: 4.0,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: controller.departmentColors[
                                          controller.departments[index]]),
                                  child: SizedBox(width: 10, height: 10),
                                ),
                                Text(
                                  controller.departments[index],
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 10,
                                  ),
                                ),
                              ]);
                        }),
                      ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
