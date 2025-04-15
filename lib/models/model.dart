class Model {
  String name;
  String url;
  String description;
  String author;
  String advantages;
  int ramRequirements;
  int vramRequirements;
  double? hardDriveSize;
  bool downloaded;
  String? downloadedPath;

  Model({
    required this.name,
    required this.url,
    required this.description,
    required this.author,
    required this.advantages,
    required this.ramRequirements,
    required this.vramRequirements,
    required this.hardDriveSize,
    required this.downloaded,
    required this.downloadedPath,
  });
}
