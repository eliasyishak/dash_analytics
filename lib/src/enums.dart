/// Values for the event name to be sent to Google Analytics
///
/// The [label] for each enum value is what will be logged, the [desc]
/// is here for documentation purposes
enum DashEvents {
  hotReloadTime(
    label: 'hot_reload_time',
    description: 'Hot reload duration',
    toolOwner: 'flutter_tools',
  ),
  ;

  final String label;
  final String description;
  final String toolOwner;
  const DashEvents({
    required this.label,
    required this.description,
    required this.toolOwner,
  });
}

/// Enumerate options for platform
enum DevicePlatform {
  windows('Windows'),
  macos('macOS'),
  linux('Linux');

  final String label;
  const DevicePlatform(this.label);
}
