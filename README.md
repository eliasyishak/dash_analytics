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
        count += i
    }
    
    // Calculate the metric to send
    final int runTime = DateTime.now().difference(start).inMilliseconds;

    // FINISH THIS PART WHEN WE HAVE DECIDED ON HOW TO SEND EVENTS
}
```