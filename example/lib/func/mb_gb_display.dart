String mbGbDisplay(int size) {
  final sizeMB = size / 1024 / 1024;
  final sizeGB = sizeMB / 1024;
  if (sizeGB > 1) {
    return "${sizeGB.toStringAsFixed(1)} GB";
  }
  return "${sizeMB.toStringAsFixed(1)} MB";
}
