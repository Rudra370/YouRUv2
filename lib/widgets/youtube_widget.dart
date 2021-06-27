import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/recentlyPlayedModel.dart';
import 'package:youruv2/model/youtube_model.dart';
import 'package:youruv2/service.dart';

class YoutubeWidget extends StatefulWidget {
  final Youtube youtubeModel;
  final bool isVideo;

  const YoutubeWidget({@required this.youtubeModel, this.isVideo = false});
  @override
  _YoutubeWidgetState createState() => _YoutubeWidgetState();
}

class _YoutubeWidgetState extends State<YoutubeWidget> {
  bool _expanded = false;
  int _animationDuration = 200;
  BetterPlayerController _betterPlayerController;
  CurrentPlaying _currentPlaying;
  GlobalKey _key;
  BetterPlayer _betterPlayer;
  bool firstTimeExpanding = true;

  void initiateBetterPlayer() async {
    final _audioPlayer = Provider.of<AssetsAudioPlayer>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final bool _playOnBackground = prefs.getBool(SPLAYVIDEOONBACKGROUND);
    final bool _loopVideo = prefs.getBool(SLOOPVIDEO);
    _key = GlobalKey();
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        fit: BoxFit.contain,
        autoDispose: false,
        looping: _loopVideo == true,
        eventListener: (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            if (_audioPlayer.isPlaying.valueWrapper.value) {
              _audioPlayer.pause();
              _betterPlayerController.play();
            }
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
            if (_audioPlayer.isPlaying.valueWrapper.value) {
              _betterPlayerController.pause();
            }
          }
        },
        errorBuilder: (context, errorMessage) {
          final size = MediaQuery.of(context).size;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    FAILED_VIDEO_MSG,
                    textAlign: TextAlign.center,
                    style: TextComponent.uTextStyle(size, 16),
                  ),
                  TextButton(
                    onPressed: () {
                      _betterPlayerController.retryDataSource();
                    },
                    child: Text(
                      RETRY,
                      style: TextComponent.uTextStyle(size, 16),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePip: true,
          pipMenuIcon: Icons.picture_in_picture,
          enableOverflowMenu: false,
        ),
      ),
      betterPlayerDataSource:
          BetterPlayerDataSource.network(widget.youtubeModel.url[0].url,
              notificationConfiguration: BetterPlayerNotificationConfiguration(
                showNotification: _playOnBackground == true,
                title: widget.youtubeModel.meta.title,
                imageUrl: widget.youtubeModel.thumb,
              )),
    );
    _betterPlayer = BetterPlayer(
      controller: _betterPlayerController,
      key: _key,
    );
  }

  void alterExpand() {
    setState(() {
      _expanded = !_expanded;
    });
    if (firstTimeExpanding) {
      initiateBetterPlayer();
      firstTimeExpanding = false;
    }
  }

  @override
  void dispose() {
    if (widget.isVideo && !firstTimeExpanding) {
      _betterPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _currentPlaying = Provider.of<CurrentPlaying>(context);
    return GestureDetector(
      onTap: () async {
        if (!_expanded) {
          if (_currentPlaying.youtube == null ||
              _currentPlaying.youtube.ids != widget.youtubeModel.id) {
            showYouruToast(context, STARTING_SONG);
          }
          // showDialog(
          //     context: context,
          //     barrierDismissible: true,
          //     builder: (context) {
          //       return Dialog(
          //         backgroundColor: ColorCodes.cTransparent,
          //         child: Container(
          //           height: size.height * 0.055,
          //           width: size.height * 0.055,
          //           child: Center(child: CircularProgressIndicator()),
          //         ),
          //       );
          //     });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final showRelated = nullTOTrue(prefs.getBool(SSHOWRELATED));
          PlayAudio().play(context,
              youtube: widget.youtubeModel, showRelated: showRelated);
        }
      },
      onLongPress: () {
        showYouruBottomSheet(context, true).then((value) async {
          await Future.delayed(Duration(milliseconds: 300));

          if (value == DOWNLOAD) {
            downloadAudio(
                context,
                RecentPlayedModel(
                    ids: widget.youtubeModel.id,
                    duration: widget.youtubeModel.meta.duration,
                    image: widget.youtubeModel.thumb,
                    name: widget.youtubeModel.meta.title,
                    shareURL: widget.youtubeModel.id));
          }
          if (value == SHARE) {
            Share.share(
                'https://www.youtube.com/watch?v=${widget.youtubeModel.id}');
          }
          if (value == ADD_TO_PLAYLIST)
            showYouruPlayListPopup(
                context,
                RecentPlayedModel(
                    duration: widget.youtubeModel.meta.duration,
                    ids: widget.youtubeModel.id,
                    image: widget.youtubeModel.thumb,
                    name: widget.youtubeModel.meta.title,
                    shareURL: widget.youtubeModel.id));
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.012,
        ),
        child: Material(
          color: ColorCodes.cTransparent,
          elevation: _expanded ? 0 : 4,
          child: AnimatedContainer(
            duration: Duration(milliseconds: _animationDuration),
            color: ColorCodes.cPrimary,
            width: size.width,
            padding: EdgeInsets.symmetric(
              vertical: _expanded ? 0 : size.height * 0.01,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(
                        milliseconds: _animationDuration,
                      ),
                      color: ColorCodes.cPrimary,
                      constraints: BoxConstraints(
                          minHeight: _expanded
                              ? size.height * 0.25
                              : size.height * 0.12),
                      width: _expanded ? size.width : size.width * 0.3,
                      child: _expanded
                          ? _betterPlayer
                          : Image.network(
                              widget.youtubeModel.thumb,
                              fit: BoxFit.cover,
                            ),
                    ),
                    AnimatedContainer(
                      duration: Duration(
                        milliseconds: _animationDuration,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: _expanded ? size.height * 0.015 : 0,
                      ),
                      width: _expanded
                          ? size.width
                          : widget.isVideo
                              ? size.width * 0.58
                              : size.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            widget.youtubeModel.meta.title,
                            maxLines: _expanded ? 5 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextComponent.uTextStyle(
                              size,
                              16,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.008,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.youtubeModel.meta.duration,
                                overflow: TextOverflow.ellipsis,
                                style: TextComponent.uTextStyle(
                                  size,
                                  12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.isVideo)
                      GestureDetector(
                        onTap: alterExpand,
                        child: AnimatedContainer(
                          duration: Duration(
                            milliseconds: _animationDuration,
                          ),
                          decoration: _expanded
                              ? BoxDecoration(
                                  color: ColorCodes.cPrimary,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(0, -1),
                                      color: Colors.black,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4)))
                              : null,
                          width: _expanded ? size.width : size.width * 0.08,
                          alignment: Alignment.center,
                          child: Icon(
                            _expanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
