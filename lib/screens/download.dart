import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:youruv2/admob_service.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/recentlyPlayedModel.dart';
import 'package:youruv2/widgets/recent_youtube_widget.dart';
import 'package:youruv2/service.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  String path;
  RecentPlayedModel recentPlayedModel;
  List<RecentPlayedModel> _downloadList = [];
  bool loading = true;
  bool first = true;

  @override
  void didChangeDependencies() {
    if (first) {
      initialize();
      first = false;
    }
    super.didChangeDependencies();
  }

  InterstitialAd ad;
  @override
  void initState() {
    ad = InterstitialAd(
        adUnitId: AdMobService.interstitialId,
        listener: AdListener(
          onAdClosed: (ad) {
            print('closed');
            ad.dispose();
          },
          onAdFailedToLoad: (ad, err) => print('failed'),
        ),
        request: AdRequest());
    ad
      ..load()
      ..show();

    super.initState();
  }

  void initialize() async {
    final info = Provider.of<DownloadInformation>(context, listen: false);
    if (info.getPercent == 100) {
      info.clearWidget();
    }
    await Permission.storage.request();
    final directory = (await getApplicationDocumentsDirectory()).path;
    final path = getMusicPath(directory);
    final imgPath = getThumbPath(directory);
    Directory dir = Directory(path);
    if (!(await dir.exists())) {
      setState(() {
        loading = false;
      });
      return;
    }
    dir.list(recursive: false).forEach((f) {
      if (f.path.contains(CUSTOM_SEPERATOR)) {
        final name = f.path
            .split(FORWARD_SLASH)[f.path.split(FORWARD_SLASH).length - 1]
            .split(CUSTOM_SEPERATOR)[0];
        final thumb = imgPath + name.split(CUSTOM_SEPERATOR)[0] + PNGEXTNSN;
        final duration = f.path
            .split(FORWARD_SLASH)[f.path.split(FORWARD_SLASH).length - 1]
            .split(CUSTOM_SEPERATOR)[1]
            .split('.')[0];
        final shareURL = f.path
            .split(FORWARD_SLASH)[f.path.split(FORWARD_SLASH).length - 1]
            .split('....')[1]
            .split(MP3EXTNSN)[0];
        RecentPlayedModel _recentPlayedModel = RecentPlayedModel(
          image: thumb,
          duration: duration,
          name: name,
          ids: f.path,
          shareURL: shareURL,
        );
        if (_recentPlayedModel.shareURL == info.getshareUrlOfDownlading) return;
        _downloadList.insert(0, _recentPlayedModel);
        print(f.path
            .split(FORWARD_SLASH)[f.path.split(FORWARD_SLASH).length - 1]);
      }
    }).then((value) => setState(() {
          loading = false;
        }));
  }

  // void initialize() async {
  //   await Provider.of<DownloadList>(context).initializeListIfNot();
  //   setState(() {
  //     loading = false;
  //   });
  // }
  //

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final _downloadList = Provider.of<DownloadList>(context).list;
    final _downloadInformation = Provider.of<DownloadInformation>(context);
    ad.isLoaded().then((value) {
      if (value && _downloadInformation.getWidget != null) {
        if (_downloadInformation.getadNotShown) {
          ad.show();
          _downloadInformation.setadNotShown = false;
        }
      }
    });
    return Container(
        child: loading
            ? Center(child: CircularProgressIndicator())
            :
            // SingleChildScrollView(
            //     child: Column(
            //       children: [
            //         ..._downloadList,
            //         SizedBox(height: size.height * 0.1)
            //       ],
            //     ),
            //   )
            ListView.builder(
                padding: EdgeInsets.only(bottom: size.height * 0.12),
                itemCount: _downloadInformation.getWidget != null
                    ? _downloadList.length + 1
                    : _downloadList.length,
                itemBuilder: (context, index) {
                  if (_downloadInformation.getWidget != null && index == 0) {
                    return _downloadInformation.getWidget;
                  }
                  if (_downloadInformation.getWidget != null) {
                    index -= 1;
                  }
                  return RecentYoutubeWidget(
                      recentPlayedModel: _downloadList[index]);
                },
              )

        // SingleChildScrollView(
        //     child: Column(
        //       children: [
        //         if (recentPlayedModel != null)
        //           RecentYoutubeWidget(
        //             recentPlayedModel: recentPlayedModel,
        //             startDownload: true,
        //           ),
        //         if (_downloadList.isNotEmpty)
        //           ..._downloadList
        //               .map((rPlayedModel) => RecentYoutubeWidget(
        //                   recentPlayedModel: rPlayedModel))
        //               .toList(),
        //         SizedBox(
        //           height: size.height * 0.15,
        //         )
        //       ],
        //     ),
        //   ),
        );
  }
}
