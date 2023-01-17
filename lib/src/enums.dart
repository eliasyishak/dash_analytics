/// Values for the event name to be sent to Google Analytics
///
/// The [label] for each enum value is what will be logged, the [desc]
/// is here for documentation purposes
enum DashEvents {
  hotReloadTime(
    label: 'hot_reload_time',
    desc: 'Hot reload duration',
  ),
  ;

  final String label;
  final String desc;
  const DashEvents({
    required this.label,
    required this.desc,
  });
}

/// Enumerate options for platform
enum DevicePlatforms {
  windows('Windows'),
  macos('Macintosh'),
  linux('Linux');

  final String label;
  const DevicePlatforms(this.label);
}
