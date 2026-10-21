import 'dart:typed_data';


import 'package:appflowy_editor/src/editor/util/file_picker/file_picker_service.dart';
import 'package:file_picker/file_picker.dart' as fp;

/// Default implementation on top of file_picker 13, which replaced
/// `FilePicker.platform` with static methods.
class FilePicker implements FilePickerService {
  @override
  Future<String?> getDirectoryPath({String? title}) {
    return fp.FilePicker.getDirectoryPath(dialogTitle: title);
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    Function(fp.FilePickerStatus p1)? onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    // file_picker 13 no longer loads bytes or streams eagerly; callers read
    // them through `PlatformFile.xFile`.
    if (allowMultiple) {
      final files = await fp.FilePicker.pickFiles(
        dialogTitle: dialogTitle,
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
        onFileLoading: onFileLoading,
      );
      return FilePickerResult(files);
    }
    final file = await fp.FilePicker.pickFile(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      onFileLoading: onFileLoading,
    );
    return FilePickerResult([if (file != null) file]);
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) async {
    // file_picker 13 writes the bytes itself. Keep the old contract (pick a
    // path, the caller writes) by saving an empty file first.
    final uri = await fp.FilePicker.saveFile(
      fileName: fileName ?? 'untitled',
      bytes: Uint8List(0),
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
    );
    if (uri == null) return null;
    return uri.scheme == 'file' ? uri.toFilePath() : uri.toString();
  }
}
