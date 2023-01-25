// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Values for the event name to be sent to Google Analytics
///
/// The [label] for each enum value is what will be logged, the [description]
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

/// The tools that have been onboarded
///
/// All tools should use an underscore instead of
/// a hyphen to split text
enum DashTools {
  flutterTools(
    label: 'flutter_tools',
    description: 'Runs flutter applications',
  ),
  ;

  final String label;
  final String description;
  const DashTools({
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

// Supported queries on the persisted log file
enum LogFileQuery {
  /// Returns the unique number of sessions along with how the start
  /// and end dates for the entire log file
  sessionCount,
  ;
}
