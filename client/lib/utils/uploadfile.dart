import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Uploadfile {
  /// Allows selecting only one profile photo (image file).
  /// Returns a map containing the file's path and name, or null if no file is selected.
  Future<Map<String, String>?> selectProfilePhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false, // Only one file allowed
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return {'path': file.path!, 'name': file.name};
      } else {
        debugPrint("No photo selected");
        return null;
      }
    } catch (e) {
      debugPrint("Error picking profile photo: $e");
      rethrow;
    }
  }

  /// Allows selecting multiple files of any type.
  /// Returns a list of maps containing file paths and names, or an empty list if no files are selected.
  Future<List<Map<String, String>>> selectMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allow any file type
        allowMultiple: true, // Enable multiple file selection
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.map((file) {
          return {'path': file.path!, 'name': file.name};
        }).toList();
      } else {
        debugPrint("No files selected");
        return [];
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
      rethrow;
    }
  }

  Future<void> requestStoragePermissions() async {
  if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception("Storage permission is required.");
    }
  }
}
}
