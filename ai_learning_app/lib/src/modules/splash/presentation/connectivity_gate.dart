import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'no_internet_screen.dart';
import 'startup_gate.dart';

class ConnectivityGate extends StatelessWidget {
  const ConnectivityGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? const [ConnectivityResult.mobile];
        final hasInternet = !results.contains(ConnectivityResult.none);

        if (!hasInternet) {
          return const NoInternetScreen();
        }

        return const StartupGate();
      },
    );
  }
}
