// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Values for the event name to be sent to Google Analytics
///
/// The [label] for each enum value is what will be logged, the [description]
/// is here for documentation purposes
enum DashEvent {
  /// Hot reload duration
  ///
  /// **Required data to send with event**
  /// ```
  /// {
  ///   'time_ms': 500,  // time to complete in milliseconds
  /// }
  /// ```
  hotReloadTime(
    label: 'hot_reload_time',
    description: 'Hot reload duration',
    toolOwner: DashTool.flutterTools,
    requiredKeys: <String>{
      'time_ms',
    },
  ),
  ;

  final String label;
  final String description;
  final DashTool toolOwner;
  final Set<String> requiredKeys;
  const DashEvent({
    required this.label,
    required this.description,
    required this.toolOwner,
    required this.requiredKeys,
  });
}

/// Officially-supported clients of this package.
///
/// All [label] values should use a hyphen as a delimiter
enum DashTool {
  flutterTools(
    label: 'flutter-tools',
    description: 'Runs flutter applications from CLI',
  ),
  dartAnalyzer(
    label: 'dart-analyzer',
    description: 'Analyzes dart code in workspace',
  );

  final String label;
  final String description;
  const DashTool({
    required this.label,
    required this.description,
  });
}

/// Enumerate options for platform
enum DevicePlatform {
  windows('Windows'),
  macos('macOS'),
  linux('Linux'),
  ;

  final String label;
  const DevicePlatform(this.label);
}
