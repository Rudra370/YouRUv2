import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_india/upi_india.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/service.dart';

class YouRuSettings extends StatefulWidget {
  final SharedPreferences prefs;

  const YouRuSettings({@required this.prefs});
  @override
  _YouRuSettingsState createState() => _YouRuSettingsState();
}

class _YouRuSettingsState extends State<YouRuSettings> {
  List<UpiApp> apps = [];
  UpiIndia _upiIndia = UpiIndia();
  //Settings related variables
  bool forceMusicSearch = false;
  bool forceMusicRelated = true;
  bool pauseOnCall = false;
  bool playVideoOnBackground = false;
  bool loopVideo = false;
  bool showRelated = true;

  @override
  void initState() {
    forceMusicSearch = nullTOFalse(widget.prefs.getBool(SFORCEMUSICSEARCH));
    forceMusicRelated = nullTOTrue(widget.prefs.getBool(SFORCEMUSICRELATED));
    pauseOnCall = nullTOFalse(widget.prefs.getBool(SPAUSEONCALL));
    playVideoOnBackground =
        nullTOFalse(widget.prefs.getBool(SPLAYVIDEOONBACKGROUND));
    loopVideo = nullTOFalse(widget.prefs.getBool(SLOOPVIDEO));
    showRelated = nullTOTrue(widget.prefs.getBool(SSHOWRELATED));

    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "9506371140@paytm",
      receiverName: 'Rudra Gupta',
      transactionRefId: DateTime.now().toIso8601String(),
      transactionNote: 'Just to help developer',
      flexibleAmount: true,
    );
  }

  Future<UpiResponse> _transaction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          SETTINGS,
          style: TextComponent.uTextStyle(size, 18,
              fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                activeColor: Colors.blue,
                title: Text(
                  'Force Music (Search results)',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Results which are not likely to be a music will not be displayed',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                value: forceMusicSearch,
                onChanged: (value) async {
                  await widget.prefs.setBool(SFORCEMUSICSEARCH, value);
                  setState(() {
                    forceMusicSearch = value;
                  });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                activeColor: Colors.blue,
                title: Text(
                  'Force Music (Related)',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Related video which are not likely to be a music will not be displayed',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                value: forceMusicRelated,
                onChanged: (value) async {
                  await widget.prefs.setBool(SFORCEMUSICRELATED, value);
                  setState(() {
                    forceMusicRelated = value;
                  });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                activeColor: Colors.blue,
                title: Text(
                  'Pause on call',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Always pause and restrict the audio on call',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                value: pauseOnCall,
                onChanged: (value) async {
                  await widget.prefs.setBool(SPAUSEONCALL, value);
                  setState(() {
                    pauseOnCall = value;
                  });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                activeColor: Colors.blue,
                title: Text(
                  'Play video on background',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Video will continue even if the app is minimized',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                value: playVideoOnBackground,
                onChanged: (value) async {
                  await widget.prefs.setBool(SPLAYVIDEOONBACKGROUND, value);
                  setState(() {
                    playVideoOnBackground = value;
                  });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                activeColor: Colors.blue,
                title: Text(
                  'Loop video',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Loop mode will be activated on videos',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                value: loopVideo,
                onChanged: (value) async {
                  await widget.prefs.setBool(SLOOPVIDEO, value);
                  setState(() {
                    loopVideo = value;
                  });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                activeColor: Colors.blue,
                title: Text(
                  'Show Related Videos',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Related videos will be visible',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                value: showRelated,
                onChanged: (value) async {
                  await widget.prefs.setBool(SSHOWRELATED, value);
                  setState(() {
                    showRelated = value;
                  });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                title: Text(
                  'Play music directly from link',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'See how you can directly play youtube music from your whatsapp(social) shares',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: ColorCodes.cTransparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                              color: ColorCodes.cAccent,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Follow these steps to change settings',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  18,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Open settings of your app',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Tap on Apps',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Tap on All Apps(To see the list of apps on your phone)',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Scroll to Youtube and tap on it',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Tap on Open by default',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Tap on Open supported link and select Always ask',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                '⚪ Now you\'ll get an option to open Youtube links from this app.',
                                textAlign: TextAlign.left,
                                style: TextComponent.uTextStyle(
                                  size,
                                  16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ColorCodes.cAppBarBackground))),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                  vertical: size.height * 0.015,
                ),
                title: Text(
                  'Connect with the developer',
                  style: TextComponent.uTextStyle(size, 16),
                ),
                subtitle: Text(
                  'Report bug or request feature or ask something on Instagram',
                  style: TextComponent.uTextStyle(size, 12,
                      color: Colors.blueGrey[400]),
                ),
                onTap: () async {
                  canLaunch('https://www.instagram.com/rudra._/').then((value) {
                    if (value) {
                      launch('https://www.instagram.com/rudra._/');
                    }
                  });
                },
              ),
            ),
            if (apps.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.044,
                    vertical: size.height * 0.015,
                  ),
                  child: Text(
                    'Support developer',
                    style: TextComponent.uTextStyle(size, 16),
                  ),
                ),
              ),
            if (apps.isNotEmpty)
              Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.044,
                ),
                child: Wrap(
                  spacing: 20,
                  children: apps.map<Widget>(
                    (UpiApp app) {
                      return GestureDetector(
                        onTap: () {
                          _transaction = initiateTransaction(app);
                          setState(() {});
                        },
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.memory(
                                app.icon,
                                height: size.height * 0.06,
                              ),
                              Text(
                                app.name,
                                style: TextComponent.uTextStyle(size, 8),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
