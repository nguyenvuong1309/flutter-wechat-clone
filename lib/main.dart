import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/authentication/landing_screen.dart';
import 'package:flutter_chat_pro/authentication/login_screen.dart';
import 'package:flutter_chat_pro/authentication/opt_screen.dart';
import 'package:flutter_chat_pro/authentication/user_information_screen.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/firebase_options.dart';
import 'package:flutter_chat_pro/main_screen/chat_screen.dart';
import 'package:flutter_chat_pro/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_pro/main_screen/friends_screen.dart';
import 'package:flutter_chat_pro/main_screen/group_information_screen.dart';
import 'package:flutter_chat_pro/main_screen/group_settings_screen.dart';
import 'package:flutter_chat_pro/main_screen/home_screen.dart';
import 'package:flutter_chat_pro/main_screen/profile_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_chat_pro/sentry/bug_report_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await dotenv.load(fileName: ".env");

  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://55b5f67d28087a4a4da2a1381872fec3@o4507876622401536.ingest.de.sentry.io/4507876709367888';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => GroupProvider()),
        ],
        child: MyApp(savedThemeMode: savedThemeMode),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Chat Pro',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) =>
              const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) =>
              const FriendRequestScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.groupSettingsScreen: (context) =>
              const GroupSettingsScreen(),
          Constants.groupInformationScreen: (context) =>
              const GroupInformationScreen(),
        },
      ),
    );
  }
}
