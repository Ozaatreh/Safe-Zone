import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SafeZoneApp());

class SafeZoneApp extends StatelessWidget {
  const SafeZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeZone',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ForegroundAppPage(),
    );
  }
}

class ForegroundAppPage extends StatefulWidget {
  const ForegroundAppPage({super.key});

  @override
  _ForegroundAppPageState createState() => _ForegroundAppPageState();
}

class _ForegroundAppPageState extends State<ForegroundAppPage> {
  static const platform = MethodChannel('safe_zone/foreground_app');
  String _foregroundApp = 'Unknown';

  Future<void> _getForegroundApp() async {
    try {
      final String result = await platform.invokeMethod('getForegroundApp');
      setState(() {
        _foregroundApp = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _foregroundApp = "Failed: '${e.message}'.";
      });
    }
  }

  Future<void> _openUsageSettings() async {
    try {
      await platform.invokeMethod('openUsageSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open settings: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    _getForegroundApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeZone - Active App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Last used app:\n$_foregroundApp',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getForegroundApp,
              child: const Text('Refresh App Info'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openUsageSettings,
              child: const Text('Open Usage Access Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
