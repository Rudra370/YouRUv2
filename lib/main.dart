import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youruv2/admob_service.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/screens/home.dart';
import 'package:youruv2/service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    AdMobService.initialize();
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AssetsAudioPlayer>(create: (context) => AssetsAudioPlayer()),
        ChangeNotifierProvider<CurrentPlaying>(
            create: (context) => CurrentPlaying()),
        ChangeNotifierProvider<RelatedVideos>(
            create: (context) => RelatedVideos()),
        ChangeNotifierProvider<DownloadInformation>(
            create: (context) => DownloadInformation()),
        ChangeNotifierProvider<PlaylistDetails>(
            create: (context) => PlaylistDetails()),
        ListenableProvider<PageController>(
          create: (context) => PageController(keepPage: true),
        ),
        ListenableProvider<TabController>(
          create: (context) => TabController(length: 4, vsync: this),
        ),
      ],
      child: MaterialApp(
        title: YOURU_V2,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: ColorCodes.cPrimary,
          accentColor: Colors.white,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: ColorCodes.cBackground,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF0b1121),
            centerTitle: true,
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}
