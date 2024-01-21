import 'package:path/path.dart' as path;

String getFolderName(String filePath) {
  String folderName = path.basename(filePath);
  return folderName;
}
