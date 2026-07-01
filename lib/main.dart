import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/stock_bloc.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/stock_dashboard_screen.dart';
import 'services/session_service.dart';
import 'services/stock_service.dart';

void main() {
  runApp(const StockPulseApp());
}

class StockPulseApp extends StatelessWidget {
  const StockPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sessionService),
        RepositoryProvider(create: (_) => StockService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(sessionService)..add(const AuthStarted()),
          ),
          BlocProvider(create: (_) => ProfileBloc(sessionService)),
          BlocProvider(
            create: (context) => StockBloc(context.read<StockService>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StockPulse',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F8FA),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          routes: {
            LoginScreen.routeName: (_) => const LoginScreen(),
            StockDashboardScreen.routeName: (_) => const StockDashboardScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            EditProfileScreen.routeName: (_) => const EditProfileScreen(),
          },
          home: const AppGate(),
        ),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const StockDashboardScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();
          case AuthStatus.unknown:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
