import 'dart:convert';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/recentlyPlayedModel.dart';

import '../service.dart';

class RecentYoutubeWidget extends StatefulWidget {
  final RecentPlayedModel recentPlayedModel;
  final bool startDownload;
  final int playListIndex;
  const RecentYoutubeWidget({
    @required this.recentPlayedModel,
    this.startDownload = false,
    this.playListIndex,
  });

  @override
  _RecentYoutubeWidgetState createState() => _RecentYoutubeWidgetState();
}

class _RecentYoutubeWidgetState extends State<RecentYoutubeWidget> {
  bool startDownload;
  bool downloaded = false;
  bool downloadFailed = false;
  bool deleted = false;
  double progress = 0.05;
  RecentPlayedModel _recentPlayedModel;
  @override
  void initState() {
    _recentPlayedModel = widget.recentPlayedModel;
    startDownload = widget.startDownload;
    if (widget.recentPlayedModel.ids.contains(Platform.pathSeparator)) {
      downloaded = true;
    }
    // if (startDownload) {
    //   download();
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    CurrentPlaying _currentPlaying = Provider.of<CurrentPlaying>(context);
    AssetsAudioPlayer _player = Provider.of<AssetsAudioPlayer>(context);
    DownloadInformation _downloadInformation =
        Provider.of<DownloadInformation>(context);
    if (startDownload && _downloadInformation.getFailedStatus || deleted)
      return Container();
    return GestureDetector(
      onTap: () async {
        if (widget.playListIndex != null) {
          final _player =
              Provider.of<AssetsAudioPlayer>(context, listen: false);
          showYouruToast(context, 'Starting, please wait😛');
          _player.playlistPlayAtIndex(widget.playListIndex);
          return;
        }
        if (startDownload && _downloadInformation.getPercent != 100) {
          print((downloaded));
          return;
        }
        if (_currentPlaying.youtube == null ||
            _currentPlaying.youtube.ids != widget.recentPlayedModel.ids) {
          showYouruToast(context, STARTING_SONG);
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final showRelated = nullTOTrue(prefs.getBool(SSHOWRELATED));

        PlayAudio().play(context,
            recentPlayed: _recentPlayedModel, showRelated: showRelated);
        if (downloaded) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            setState(() {});
          });
        }
      },
      onLongPress: () {
        showYouruBottomSheet(context, downloaded != true).then((value) async {
          await Future.delayed(Duration(milliseconds: 300));
          if (value == DOWNLOAD) downloadAudio(context, _recentPlayedModel);
          if (value == SHARE) {
            print(_recentPlayedModel.shareURL);
            Share.share(
                'https://www.youtube.com/watch?v=${_recentPlayedModel.shareURL}');
          }
          if (value == DELETE) {
            File file = File(widget.recentPlayedModel.ids);
            await file.delete();
            setState(() {
              deleted = true;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();

            final _recent = prefs.getStringList(SPRECENTLY_PLAYED);
            final List<RecentPlayedModel> _recentlyPlayed = [];
            if (_recent != null) {
              _recent.forEach((element) {
                if (_recentlyPlayed.length == 0 ||
                    _recentlyPlayed.last.shareURL !=
                        RecentPlayedModel.fromJson(json.decode(element))
                            .shareURL)
                  _recentlyPlayed
                      .add(RecentPlayedModel.fromJson(json.decode(element)));
              });
            }
            if (_recentlyPlayed.contains(widget.recentPlayedModel)) {
              int index = _recentlyPlayed.indexOf(widget.recentPlayedModel);
              _recent.removeAt(index);
              prefs.setStringList(SPRECENTLY_PLAYED, _recent);
            }
          }
          if (value == ADD_TO_PLAYLIST)
            showYouruPlayListPopup(context, _recentPlayedModel);
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.012,
            ),
            child: Material(
              color: ColorCodes.cTransparent,
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorCodes.cPrimary,
                ),
                width: size.width,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.03,
                ),
                child: Row(
                  children: [
                    Container(
                      color: ColorCodes.cPrimary,
                      width: size.width * 0.3,
                      constraints:
                          BoxConstraints(minHeight: size.height * 0.08),
                      child:
                          _recentPlayedModel.image.contains(YOURU.toLowerCase())
                              ? Image.file(File(_recentPlayedModel.image))
                              : Image.network(
                                  _recentPlayedModel.image,
                                  fit: BoxFit.cover,
                                ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: size.width * 0.02,
                      ),
                      width: size.width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _recentPlayedModel.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextComponent.uTextStyle(
                              size,
                              16,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.008,
                          ),
                          if (_recentPlayedModel.duration != null)
                            Text(
                              _recentPlayedModel.duration.contains(MP3EXTNSN)
                                  ? _recentPlayedModel.duration.split('....')[0]
                                  : _recentPlayedModel.duration,
                              overflow: TextOverflow.ellipsis,
                              style: TextComponent.uTextStyle(
                                size,
                                12,
                                color: Colors.grey[400],
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          if ((startDownload != true && downloaded) ||
              _downloadInformation.getPercent == 100)
            Positioned(
              child: Icon(
                Icons.download_done_outlined,
                color: Colors.white,
              ),
              top: size.height * 0.01,
              right: size.width * 0.01,
            ),
          if (startDownload && _downloadInformation.getDownloadStatus)
            Container(
              width: size.width,
              color: Colors.black54,
              height: size.height * 0.13,
            ),
          if (startDownload && _downloadInformation.getDownloadStatus)
            Container(
              width: size.width * 0.925,
              child: LinearProgressIndicator(
                value: _downloadInformation.getPercent / 100,
                backgroundColor: ColorCodes.cAccent,
              ),
            ),
        ],
      ),
    );
  }
}
