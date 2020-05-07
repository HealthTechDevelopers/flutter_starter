import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_app/bloc/example_bloc.dart';
import 'package:flutter_starter_app/utils/api/api.dart';
import 'package:flutter/material.dart';
import 'package:http_api/http_api.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config.dart';
import 'utils/navigation/generate_route.dart';
import 'utils/style_provider/style.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// App supported orientations init
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      // Firebase analystics setup
      FirebaseAnalytics analytics = FirebaseAnalytics();

      // Whether to send reports during development
      Crashlytics.instance.enableInDevMode = false;

      // It automatically prints errors to the console
      FlutterError.onError = Crashlytics.instance.recordFlutterError;

      runApp(MyApp(
        analytics: analytics,
      ));
    },
  );
}

const _appColors = const AppColors(
  accent: Colors.redAccent,
  secondaryAccent: Colors.blueAccent,
  content: Colors.black,
  secondaryContent: Colors.white,
  background: Colors.white,
  secondaryBackground: Colors.black,
  shadow: Color.fromRGBO(0, 0, 0, 0.1),
  secondaryShadow: Color.fromRGBO(0, 0, 0, 0.05),
);

final Map<int, Color> _primarySwatch = {
  50: _appColors.accent,
  100: _appColors.accent,
  200: _appColors.accent,
  300: _appColors.accent,
  400: _appColors.accent,
  500: _appColors.accent,
  600: _appColors.accent,
  700: _appColors.accent,
  800: _appColors.accent,
  900: _appColors.accent,
};

final _materialColor = MaterialColor(_appColors.accent.value, _primarySwatch);

class MyApp extends StatelessWidget {
  final FirebaseAnalytics _analytics;

  MyApp({
    @required FirebaseAnalytics analytics,
  }) : _analytics = analytics;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: Style(
        child: MaterialApp(
          title: 'FlutterStarter',
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            FlutterI18nDelegate(
              fallbackFile: 'en_US',
              useCountryCode: true,
              path: 'assets/i18n',
            ),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          theme: ThemeData(
            primarySwatch: _materialColor,
            accentColor: _appColors.accent,
            appBarTheme: AppBarTheme(color: _appColors.accent),
            backgroundColor: _appColors.background,
            dialogBackgroundColor: _appColors.background,
            scaffoldBackgroundColor: _appColors.background,
          ),
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: _analytics),
          ],
          onGenerateRoute: Routes.generateRoute,
          initialRoute: Routes.home,
        ),
        colors: _appColors,
      ),
      providers: <SingleChildWidget>[
        Provider(
          create: (_) => Api(
            url: Uri.parse(Config.apiUrl),

            /// This headers will be retrived from response and send back
            /// with next request
            link: HeadersMapperLink(['uid', 'client', 'access-token'])

                /// Eesponsible for api request and response console prints
                .chain(DebugLink(
                  url: true,
                  statusCode: true,
                  responseBody: true,
                ))

                /// Lats link should be a [HttpLink]. It is responsible for
                /// api requests
                .chain(HttpLink()),
          ),
        ),

        /// Provide blocs that will be used for state management
        ChangeNotifierProvider<ExampleBloc>(
          create: (_) => ExampleBloc(),
        ),
      ],
    );
  }
}
