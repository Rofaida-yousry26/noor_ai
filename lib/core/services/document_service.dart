import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class DocumentService {
  static Future<Map<String, dynamic>?> pickAndUploadPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;

    if (file.path == null) {
      throw Exception('Could not access the selected file.');
    }

    return ApiService.uploadPdf(file.path!);
  }
}