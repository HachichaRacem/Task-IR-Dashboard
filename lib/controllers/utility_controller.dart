import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:csv/csv.dart';

class UtilityController extends GetxController {
  /// Picks a CSV file using a file picker dialog and returns its content as a map.
  ///
  /// it returns a map containing the CSV data, file name, and file size.
  /// If an error occurs during the file pick process or no file is selected, an error notification is shown, and
  /// the function returns null or an empty list for the file data.
  ///
  /// Returns:
  ///   A future that resolves to a map with keys "fileData", "fileName", and
  ///   "fileSize" if a file is successfully picked, or null/empty list if not.

  Future<Map<String, dynamic>?> handleFilePick() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
        allowMultiple: false,
        dialogTitle: "Select a CSV file",
      );
    } catch (e, stack) {
      Get.log("[FILE PICKER]: $e");
      Get.log("$stack");
      toastification.show(
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 3),
          title: const Text("Failed to load file"),
          description: const Text(
              "Could be due to permissions denial or file not being found"),
          type: ToastificationType.error,
          style: ToastificationStyle.minimal);
      return null;
    }

    if (result != null && result.files.isNotEmpty) {
      final String csvContent = utf8.decode(result.files.first.bytes!);
      final List<List<dynamic>> csvData =
          const CsvToListConverter().convert(csvContent, eol: "\n");

      toastification.show(
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 3),
          title: const Text("Data file loaded"),
          type: ToastificationType.success,
          style: ToastificationStyle.minimal);

      return {
        "fileData": csvData,
        "fileName": result.files.first.name,
        "fileSize": convertBytesToString(result.files.first.size.toDouble()),
      };
    } else {
      return {
        "fileData": [],
      };
    }
  }

  String convertBytesToString(double bytes) {
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    int index = 0;
    while (bytes >= 1024) {
      bytes /= 1024;
      index++;
    }
    return "${bytes.toStringAsFixed(0)} ${suffixes[index]}";
  }
}
