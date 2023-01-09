/// The version number for the message below
///
/// If the message below is altered, the version should
/// be incremented so that users can be prompted with
/// the updated messaging
const int kToolsMessageVersion = 1;

/// The message that should be shown to the user
const String kToolsMessage = '''
Flutter and Dart related tooling uses Google Analytics to report usage and
diagnostic data along with package dependencies, and crash reporting to
send basic crash reports. This data is used to help improve the Dart
platform, Flutter framework, and related tools.

Telemetry is not sent on the very first run.
To disable reporting of telemetry, run this terminal command:

[dart|flutter] --disable-telemetry.
If you opt out of telemetry, an opt-out event will be sent, and then no further
information will be sent. This data is collected in accordance with the
Google Privacy Policy (https://policies.google.com/privacy).
''';

/// The string that will provide the boilerplate for the
/// configuration file stored on the user's machine
const String kConfigString = '''
# INTRODUCTION
#
# This is the Flutter and Dart telemetry reporting
# configuration file.
#
# Lines starting with a #" are documentation that
# the tools maintain automatically.
#
# All other lines are configuration lines. They have
# the form "name=value". If multiple lines contain
# the same configuration name with different values,
# the parser will default to a conservative value. 

# DISABLING TELEMETRY REPORTING
#
# To disable telemetry reporting, set "reporting" to
# the value "0" and to enable, set to "1":
reporting=1

# NOTIFICATIONS
#
# Each tool records when it last informed the user about
# analytics reporting and the privacy policy.
#
# The following tools have so far read this file:
#
#   dart-tools (Dart CLI developer tool)
#   devtools (DevTools debugging and performance tools)
#   flutter-tools (Flutter CLI developer tool)
#
# For each one, the file may contain a configuration line
# where the name is the code in the list above, e.g. "dart-tool",
# and the value is a date in the form YYYY-MM-DD, a comma, and
# a number representing the version of the message that was
# displayed.''';
