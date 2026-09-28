import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'widgets/state_placeholders.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<String> _uidFuture;
  String? _initedUid;

  @override
  void initState() {
    super.initState();
    _uidFuture = AuthService().signInAnon();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _uidFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: LoadingState());
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: ErrorState(
              message: 'Could not sign in: ${snapshot.error}',
              onRetry: () => setState(() {
                _uidFuture = AuthService().signInAnon();
              }),
            ),
          );
        }

        final uid = snapshot.data!;
        if (_initedUid != uid) {
          _initedUid = uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<ExpenseProvider>().init(uid);
            }
          });
        }
        return const HomeScreen();
      },
    );
  }
}