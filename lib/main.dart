import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SafeZoneApp());

class SafeZoneApp extends StatelessWidget {
  const SafeZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeZone',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.green[700],
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
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
  bool _isLoading = false;

  Future<void> _getForegroundApp() async {
    setState(() => _isLoading = true);
    try {
      final String result = await platform.invokeMethod('getForegroundApp');
      setState(() {
        _foregroundApp = result;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _foregroundApp = "Failed to detect: '${e.message}'.";
        _isLoading = false;
      });
    }
  }

  Future<void> _openUsageSettings() async {
    try {
      await platform.invokeMethod('openUsageSettings');
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open settings: ${e.message}")),
      );
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
        title: const Text('App Monitoring'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.apps_rounded,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Currently Active App',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            _foregroundApp,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _getForegroundApp,
              child: const Text('Refresh Status'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _openUsageSettings,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.green[700]!),
              ),
              child: Text(
                'Usage Settings',
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'SafeZone v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}