This package is intended to be used on Dash (Flutter and Dart) related tooling.
It provides APIs to send events to Google Analytics using the Measurement Protocol.

## Usage

To get started using this package, import at the entrypoint dart file and
initialize with the required parameters

```dart
import 'dash_analytics';

// Constants that should be resolved by the client using package
final DashTool tool = DashTool.flutterTools; // Restricted to enum provided by package
final String measurementId = 'xxxxxxxxxxxx'; // To be provided to client
final String apiSecret = 'xxxxxxxxxxxx'; // To be provided to client

// Values that need to be provided by the client that may
// need to be calculated
final String branch = ...;
final String flutterVersion = ...;
final String dartVersion = ...;

// Initialize the [Analytics] class with the required parameters;
// preferably outside of the [main] method
final Analytics analytics = Analytics(
  tool: tool,
  measurementId: measurementId,
  apiSecret: apiSecret,
  branch: branch,
  flutterVersion: flutterVersion,
  dartVersion: dartVersion,
);

// Timing a process and sending the event
void main() {
    DateTime start = DateTime.now();
    int count = 0;

    // Example of long running process
    for (int i = 0; i < 2000; i++) {
        count += i;
    }
    
    // Calculate the metric to send
    final int runTime = DateTime.now().difference(start).inMilliseconds;

    // Generate the body for the event data
    final Map<String, int> eventData = {
      'time_ns': runTime,
    };

    // Choose one of the enum values for [DashEvent] which should
    // have all possible events; if not there, open an issue for the
    // team to add
    final DashEvent eventName = ...; // Select appropriate DashEvent enum value

    // Make a call to the [Analytics] api to send the data
    analytics.sendEvent(
      eventName: eventName,
      eventData: eventData,
    );

    // Close the client connection on exit
    analytics.close();
}
```

## Informing Users About Analytics Opt-In Status

When a user first uses any Dash tool with this package enabled, they
will be enrolled into Analytics collection. It will be the responsiblity
of the Dash tool using this package to display the proper Analytics messaging
and inform them on how to Opt-Out of Analytics collection if they wish. The
package will expose APIs that will make it easy to configure Opt-In status.

```dart
// Begin by initializing the class
final Analytics analytics = Analytics(...);

// This should be performed every time the Dash tool starts up
if (analytics.shouldShowMessage) {

  // How each Dash tool displays the message will be unique,
  // print statement used for trivial usage example
  print(analytics.toolsMessage);
}
```

## Checking User Opt-In Status

Some Dash tools may need to know if the user has opted in for Analytics
collection in order to enable additional functionality. The example below
shows how to check the status

```dart
// Begin by initializing the class
final Analytics analytics = Analytics(...);

// This getter will return a boolean showing the status;
// print statement used for trivial usage example
print('This user's status: ${analytics.telemetryEnabled}');  // true if opted-in
```