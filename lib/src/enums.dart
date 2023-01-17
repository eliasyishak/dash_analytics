/// Enumerate options for platform
enum DevicePlatforms {
  windows('Windows'),
  macos('Macintosh'),
  linux('Linux');

  const DevicePlatforms(this.label);
  final String label;
}
