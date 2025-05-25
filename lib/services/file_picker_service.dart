import 'package:file_picker/file_picker.dart';

class FilePickerService {
  static Future<PlatformFile?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
      );
      return result?.files.first;
    } catch (e) {
      throw Exception('File picking failed: $e');
    }
  }
}