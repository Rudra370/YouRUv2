import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:expandable_bottom_bar_new/expandable_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/recentlyPlayedModel.dart';
import 'package:youruv2/screens/download.dart';
import 'package:youruv2/screens/myPlayList.dart';
import 'package:youruv2/screens/recent.dart';
import 'package:youruv2/screens/search.dart';
import 'package:youruv2/screens/settings.dart';
import 'package:youruv2/service.dart';
import 'package:youruv2/widgets/recent_youtube_widget.dart';
import 'package:youruv2/widgets/tab_container.dart';
import 'package:youruv2/widgets/youtube_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  FloatingSearchBarController _searchController = FloatingSearchBarController();
  ScrollController _scrollController = ScrollController();
  PageController _pageController;
  BottomBarController _bottomBarController;
  TabController _tabController;

  AssetsAudioPlayer _player;
  SharedPreferences _prefs;
  List<String> _recentSearches;
  List<String> _searchResults = [];
  int currentPage = 0;
  String _searchText;
  CurrentPlaying _currentPlaying;
  RelatedVideos _relatedVideos;
  PlaylistDetails _playListDetails;
  bool hideControlls = true;
  String urlFromOutside;
  String deepOrAppLink;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() async {
    _bottomBarController =
        BottomBarController(vsync: this, dragLength: 400, snap: true);
    _bottomBarController.addListener(() {
      if (_bottomBarController.isOpening || _bottomBarController.isOpen) {
        setState(() {
          hideControlls = false;
        });
      }
      if (_bottomBarController.isClosed) {
        setState(() {
          hideControlls = true;
        });
      }
    });
    _prefs = await SharedPreferences.getInstance();
    _recentSearches = _prefs.getStringList(SPRECENT_SEARCH);

    handleDeepAndAppLink();
  }

  void handleDeepAndAppLink() async {
    urlFromOutside = await ReceiveSharingIntent.getInitialText();
    listenToStream(urlFromOutside, handleLast: true);

    ReceiveSharingIntent.getTextStream().listen((url) {
      listenToStream(url);
    });
  }

  void listenToStream(String url, {bool handleLast = false}) async {
    if (url != urlFromOutside) urlFromOutside = url;
    deepOrAppLink = convertUrlToId(urlFromOutside);
    if (deepOrAppLink != null) {
      showYouruToast(context, FETCHING_WAIT, duration: 5);
      final youtube = await Api().getVideo(deepOrAppLink);
      PlayAudio().play(
        context,
        youtube: youtube,
        showRelated: false,
      );
    } else {
      if (handleLast) handleLastPlayed();
    }
  }

  void handleLastPlayed() async {
    _prefs = await SharedPreferences.getInstance();
    bool lastFile = _prefs.getBool(SPLAST_FILE);
    final _youtube = _prefs.getString(SPLAST_PLAYED);
    if (lastFile == true) {
      RecentPlayedModel recentPlayedModel =
          RecentPlayedModel.fromJson(json.decode(_youtube));
      PlayAudio().play(context,
          recentPlayed: recentPlayedModel,
          autostart: false,
          showRelated: false);
      Future.delayed(Duration(seconds: 2)).then((value) {
        setState(() {});
        return;
      });
    } else {
      if (_youtube != null) {
        final _yt = await Api().getVideo(_youtube);
        PlayAudio()
            .play(context, youtube: _yt, autostart: false, showRelated: false);
      }
    }
  }

  void addToRecentSearches(String query) {
    setState(() {
      _searchText = query;
    });
    if (_recentSearches == null) {
      _recentSearches = [query];
    } else if (_recentSearches.contains(query)) {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
    } else if (_recentSearches.length < 30) {
      _recentSearches.insert(0, query);
    } else if (_recentSearches.length >= 30) {
      final _allSearches = _recentSearches;
      _recentSearches = [query];
      for (var i = 0; i < 5; i++) {
        _recentSearches.add(_allSearches[i]);
      }
    }
    _prefs.setStringList(SPRECENT_SEARCH, _recentSearches);
  }

  void _getSearchResults(String query) async {
    _searchResults = await Api().search(query);
    setState(() {});
  }

  void closeSearchAndSearch(String query) {
    addToRecentSearches(query);
    _searchController.close();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _player = Provider.of<AssetsAudioPlayer>(context);
    // _pageController = Provider.of<PageController>(context);
    _tabController = Provider.of<TabController>(context);
    _currentPlaying = Provider.of<CurrentPlaying>(context);
    _relatedVideos = Provider.of<RelatedVideos>(context);
    _playListDetails = Provider.of<PlaylistDetails>(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: size.width,
          height: size.height,
          child: SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: size.height * 0.079,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            color: ColorCodes.cAppBarBackground,
                            width: size.width,
                            child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                indicatorColor: Colors.white,
                                indicatorWeight: 1,
                                tabs: [
                                  TabContainer(
                                    icon: Icons.settings_backup_restore_sharp,
                                    isSelected: currentPage == 0,
                                  ),
                                  TabContainer(
                                    icon: Icons.search,
                                    isSelected: currentPage == 0,
                                  ),
                                  TabContainer(
                                    icon: Icons.music_note,
                                    isSelected: currentPage == 0,
                                  ),
                                  TabContainer(
                                    icon: Icons.download_rounded,
                                    isSelected: currentPage == 0,
                                  ),
                                ])
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     GestureDetector(
                            //       onTap: () {
                            //         if (currentPage != 0) {
                            //           _pageController.animateToPage(0,
                            //               duration: Duration(milliseconds: 400),
                            //               curve: Curves.easeInOut);
                            //         }
                            //       },
                            //       child: TabContainer(
                            //         icon: Icons.settings_backup_restore_sharp,
                            //         isSelected: currentPage == 0,
                            //       ),
                            //     ),
                            //     GestureDetector(
                            //       onTap: () {
                            //         if (currentPage != 1) {
                            //           _pageController.animateToPage(1,
                            //               duration: Duration(milliseconds: 400),
                            //               curve: Curves.easeInOut);
                            //         }
                            //       },
                            //       child: TabContainer(
                            //         icon: Icons.search,
                            //         isSelected: currentPage == 1,
                            //       ),
                            //     ),
                            //     GestureDetector(
                            //       onTap: () {
                            //         if (currentPage != 2) {
                            //           _pageController.animateToPage(2,
                            //               duration: Duration(milliseconds: 400),
                            //               curve: Curves.easeInOut);
                            //         }
                            //       },
                            //       child: TabContainer(
                            //         icon: Icons.music_note,
                            //         isSelected: currentPage == 2,
                            //       ),
                            //     ),
                            //     GestureDetector(
                            //       onTap: () {
                            //         if (currentPage != 3) {
                            //           _pageController.animateToPage(3,
                            //               duration: Duration(milliseconds: 400),
                            //               curve: Curves.easeInOut);
                            //         }
                            //       },
                            //       child: TabContainer(
                            //         icon: Icons.download_rounded,
                            //         isSelected: currentPage == 3,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            ),
                        Container(
                            width: size.width,
                            height: size.height * 0.84,
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                  RecentlyPlayed(),
                                  SearchResults(
                                    searchText: _searchText,
                                  ),
                                  MyPlayList(),
                                  Downloads(),
                                ])

                            // PageView(
                            //   controller: _pageController,
                            //   physics: AlwaysScrollableScrollPhysics(),
                            //   onPageChanged: (value) {
                            //     setState(() {
                            //       currentPage = value;
                            //     });
                            //     if (_bottomBarController.isOpen)
                            //       _bottomBarController.close(velocity: 100);
                            //   },
                            //   children: [
                            //     RecentlyPlayed(),
                            //     SearchResults(
                            //       searchText: _searchText,
                            //     ),
                            //     MyPlayList(),
                            //     Downloads(),
                            //   ],
                            // ),
                            )
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: FloatingSearchBar(
                    backdropColor: Colors.black.withOpacity(0.75),
                    controller: _searchController,
                    transitionDuration: Duration(
                      milliseconds: 300,
                    ),
                    automaticallyImplyDrawerHamburger: false,
                    clearQueryOnClose: true,
                    accentColor: Colors.white,
                    hint: SEARCH_HINT,
                    hintStyle: TextComponent.uTextStyle(
                      size,
                      14,
                      color: Colors.grey[300].withOpacity(0.8),
                    ),
                    transitionCurve: Curves.easeInOut,
                    physics: const BouncingScrollPhysics(),
                    debounceDelay: Duration(
                      milliseconds: 100,
                    ),
                    automaticallyImplyBackButton: false,
                    transition: ExpandingFloatingSearchBarTransition(),
                    leadingActions: [
                      FloatingSearchBarAction(
                        showIfOpened: false,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => YouRuSettings(
                                prefs: _prefs,
                              ),
                            ));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * 0.005),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: size.height * 0.027,
                            ),
                          ),
                        ),
                      ),
                      FloatingSearchBarAction.back(
                        color: Colors.white,
                        size: size.height * 0.027,
                      ),
                    ],
                    actions: [
                      FloatingSearchBarAction.searchToClear(
                        color: Colors.white,
                        size: size.height * 0.031,
                        duration: Duration(
                          milliseconds: 400,
                        ),
                      ),
                    ],
                    margins: EdgeInsets.all(0),
                    backgroundColor: ColorCodes.cAppBarBackground,
                    height: size.height * 0.08,
                    elevation: 0,
                    borderRadius: BorderRadius.circular(0),
                    title: Text(
                      YOURU,
                      style: TextComponent.uTextStyle(
                        size,
                        20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    onQueryChanged: (query) {
                      _getSearchResults(query);
                    },
                    queryStyle: TextComponent.uTextStyle(
                      size,
                      16,
                    ),
                    onFocusChanged: (isFocused) async {
                      if (isFocused) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                        if (_tabController.index != 1)
                          _tabController.animateTo(1);
                        if (_bottomBarController.isOpen)
                          _bottomBarController.close();
                      }
                    },
                    onSubmitted: (query) => closeSearchAndSearch(query),
                    builder: (context, transition) {
                      return Container(
                        width: size.width,
                        height: size.height * 0.75,
                        decoration: BoxDecoration(
                          color: ColorCodes.cAppBarBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _searchResults.isEmpty &&
                                    _recentSearches != null
                                ? _recentSearches
                                    .map(
                                      (result) => Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: size.height * 0.006,
                                        ),
                                        child: ListTile(
                                          minLeadingWidth: 20,
                                          leading: Icon(
                                            Icons.settings_backup_restore_sharp,
                                            color: Colors.white,
                                          ),
                                          tileColor: ColorCodes.cPrimary,
                                          title: Text(
                                            result,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextComponent.uTextStyle(
                                              size,
                                              16,
                                            ),
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              _searchController.query = result;
                                            },
                                            child: RotatedBox(
                                              quarterTurns: 15,
                                              child: Icon(
                                                Icons.call_made,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          onTap: () =>
                                              closeSearchAndSearch(result),
                                        ),
                                      ),
                                    )
                                    .toList()
                                : _searchResults
                                    .map(
                                      (result) => Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: size.height * 0.006,
                                        ),
                                        child: ListTile(
                                          minLeadingWidth: 20,
                                          leading: Icon(
                                            _recentSearches != null &&
                                                    _recentSearches
                                                        .contains(result)
                                                ? Icons
                                                    .settings_backup_restore_sharp
                                                : Icons.youtube_searched_for,
                                            color: Colors.white,
                                          ),
                                          tileColor: _recentSearches != null &&
                                                  _recentSearches
                                                      .contains(result)
                                              ? ColorCodes.cPrimary
                                              : Colors.transparent,
                                          title: Text(
                                            result,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextComponent.uTextStyle(
                                              size,
                                              16,
                                            ),
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              _searchController.query = result;
                                            },
                                            child: RotatedBox(
                                              quarterTurns: 15,
                                              child: Icon(
                                                Icons.call_made,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          onTap: () =>
                                              closeSearchAndSearch(result),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          // Set onVerticalDrag event to drag handlers of controller for swipe effect
          onVerticalDragUpdate: _bottomBarController.onDrag,
          onVerticalDragEnd: _bottomBarController.onDragEnd,
          child: StreamBuilder<RealtimePlayingInfos>(
              stream: _player.realtimePlayingInfos,
              builder: (context, snapshot) {
                return FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: snapshot.connectionState != ConnectionState.waiting &&
                          snapshot.data.isBuffering
                      ? Container(
                          width: size.width * 0.07,
                          height: size.width * 0.07,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(ColorCodes.cBackground),
                          ),
                        )
                      : Icon(
                          !snapshot.hasData ||
                                  snapshot.data.current == null ||
                                  !snapshot.data.isPlaying
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: ColorCodes.cBackground,
                          size: size.width * 0.07,
                        ),
                  onPressed: () async {
                    if (await _player.current.isEmpty) return;
                    try {
                      await _player.playOrPause();
                    } on Exception catch (_) {
                      return;
                    }
                  },
                );
              }),
        ),
        bottomNavigationBar: BottomExpandableAppBar(
          controller: _bottomBarController,
          expandedHeight: _relatedVideos.loading ||
                  _relatedVideos.list != null ||
                  _playListDetails.playList != null
              ? size.height * 0.764
              : size.height * 0.4,
          horizontalMargin: 0,
          shape: AutomaticNotchedShape(
              RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
          expandedBackColor: ColorCodes.c2ndBackground,
          bottomAppBarColor: ColorCodes.cAppBarBackground,
          bottomAppBarBody: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.fast_rewind,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final v = _player.current.valueWrapper == null;
                      print(v);
                      if (await _player.current.isEmpty) return;
                      try {
                        await _player.seekBy(
                          -Duration(seconds: 5),
                        );
                      } on Exception catch (_) {
                        return;
                      }
                    },
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.fast_forward,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (await _player.current.isEmpty) return;
                      try {
                        await _player.seekBy(
                          Duration(seconds: 5),
                        );
                      } on Exception catch (_) {
                        return;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          expandedBody: SingleChildScrollView(
            child: hideControlls
                ? Container()
                : Container(
                    width: size.width,
                    height: _relatedVideos.loading ||
                            _relatedVideos.list != null ||
                            _playListDetails.playList != null
                        ? size.height * 0.85
                        : size.height * 0.4,
                    padding: EdgeInsets.only(top: size.height / 2 * 0.05),
                    child: _currentPlaying.youtube != null
                        // _player.current.hasValue
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          _player.currentLoopMode ==
                                                  LoopMode.single
                                              ? Icons.repeat_one_rounded
                                              : Icons.repeat_outlined,
                                          size: size.width * 0.1,
                                          color: _player.currentLoopMode ==
                                                      LoopMode.single ||
                                                  _player.currentLoopMode ==
                                                      LoopMode.playlist
                                              ? Colors.pink[700]
                                              : ColorCodes.cAppBarBackground,
                                        ),
                                        onPressed: () {
                                          if (_player.current.valueWrapper ==
                                              null) return;
                                          if (_playListDetails.playList ==
                                              null) {
                                            if (_player.currentLoopMode ==
                                                LoopMode.single) {
                                              _player
                                                  .setLoopMode(LoopMode.none);
                                            } else {
                                              _player
                                                  .setLoopMode(LoopMode.single);
                                            }
                                          } else {
                                            if (_player.currentLoopMode ==
                                                LoopMode.single) {
                                              _player
                                                  .setLoopMode(LoopMode.none);
                                            } else if (_player
                                                    .currentLoopMode ==
                                                LoopMode.none) {
                                              _player.setLoopMode(
                                                  LoopMode.playlist);
                                            } else if (_player
                                                    .currentLoopMode ==
                                                LoopMode.playlist) {
                                              _player
                                                  .setLoopMode(LoopMode.single);
                                            }
                                          }
                                          setState(() {});
                                        }),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        _player.current.valueWrapper != null
                                            ? CircleAvatar(
                                                radius: size.width * 0.185,
                                                backgroundColor:
                                                    ColorCodes.cBackground,
                                                backgroundImage: _player
                                                            .getCurrentAudioImage ==
                                                        null
                                                    ? null
                                                    : !_player
                                                            .getCurrentAudioImage
                                                            .path
                                                            .contains(YOURU
                                                                .toLowerCase())
                                                        ? NetworkImage(_player
                                                            .getCurrentAudioImage
                                                            .path)
                                                        : _player
                                                                .getCurrentAudioImage
                                                                .path
                                                                .contains(YOURU
                                                                    .toLowerCase())
                                                            ? FileImage(File(_player
                                                                .getCurrentAudioImage
                                                                .path))
                                                            : null,
                                              )
                                            : CircleAvatar(
                                                radius: size.width * 0.2,
                                                backgroundColor:
                                                    ColorCodes.cBackground,
                                                //backgroundImage: NetworkImage(_image),
                                              ),
                                        StreamBuilder<RealtimePlayingInfos>(
                                            stream:
                                                _player.realtimePlayingInfos,
                                            builder: (context, snapshot) {
                                              return SleekCircularSlider(
                                                initialValue: snapshot.hasData
                                                    ? snapshot
                                                        .data
                                                        .currentPosition
                                                        .inSeconds
                                                        .toDouble()
                                                    : 0,
                                                min: 0,
                                                max: snapshot.hasData &&
                                                        snapshot
                                                                .data
                                                                .currentPosition
                                                                .inSeconds !=
                                                            0
                                                    ? snapshot
                                                        .data.duration.inSeconds
                                                        .toDouble()
                                                    : 100,
                                                onChange: (double value) {
                                                  _player.seek(Duration(
                                                    seconds: value.toInt(),
                                                  ));
                                                },
                                                onChangeStart:
                                                    (double startValue) {
                                                  _player.pause();
                                                },
                                                onChangeEnd: (double endValue) {
                                                  _player.play();
                                                },
                                                innerWidget: (percentage) {
                                                  return Container();
                                                },
                                                appearance:
                                                    CircularSliderAppearance(
                                                  startAngle: 270,
                                                  angleRange: 360,
                                                  size: size.width * 0.45,
                                                  customWidths:
                                                      CustomSliderWidths(
                                                          progressBarWidth:
                                                              size.width *
                                                                  0.038),
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                    StreamBuilder<double>(
                                        stream: _player.volume,
                                        builder: (context, snapshot) {
                                          return RotatedBox(
                                            quarterTurns: -1,
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                trackHeight: 2,
                                              ),
                                              child: Slider(
                                                value: snapshot.hasData
                                                    ? snapshot.data
                                                    : 1,
                                                activeColor: Colors.pink[700],
                                                inactiveColor: ColorCodes
                                                    .cAppBarBackground,
                                                onChanged: (value) {
                                                  _player.setVolume(value);
                                                },
                                                max: 1,
                                                min: 0,
                                              ),
                                            ),
                                          );
                                        })
                                  ],
                                ),
                                if (!(_relatedVideos.loading ||
                                    _relatedVideos.list != null))
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                if (_player.current.valueWrapper != null)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.013),
                                    child: Text(
                                      _player.getCurrentAudioTitle,
                                      style: TextComponent.uTextStyle(size, 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                if (!(_relatedVideos.loading ||
                                    _relatedVideos.list != null))
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                StreamBuilder<RealtimePlayingInfos>(
                                    stream: _player.realtimePlayingInfos,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data.currentPosition
                                                  .inSeconds !=
                                              0)
                                        return Text(
                                          (Duration(
                                                      seconds: snapshot
                                                          .data
                                                          .currentPosition
                                                          .inSeconds)
                                                  .inMinutes
                                                  .remainder(60)
                                                  .toString()
                                                  .padLeft(2, ZERO) +
                                              COLAN +
                                              Duration(
                                                      seconds: snapshot
                                                          .data
                                                          .currentPosition
                                                          .inSeconds)
                                                  .inSeconds
                                                  .remainder(60)
                                                  .toString()
                                                  .padLeft(2, ZERO) +
                                              FORWARD_SLASH +
                                              snapshot.data.duration.inMinutes
                                                  .remainder(60)
                                                  .toString()
                                                  .padLeft(2, ZERO) +
                                              COLAN +
                                              snapshot.data.duration.inSeconds
                                                  .remainder(60)
                                                  .toString()
                                                  .padLeft(2, ZERO)),
                                          style: TextComponent.uTextStyle(
                                              size, 14),
                                        );
                                      return Container();
                                    }),
                                SizedBox(
                                  height: size.height * 0.005,
                                ),
                                if (_relatedVideos.list != null ||
                                    _playListDetails.playList != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '  ${_playListDetails.playList != null ? 'Playlist' : RELATED_VIDEOS}',
                                      style: TextComponent.uTextStyle(size, 14),
                                    ),
                                  ),
                                if (_relatedVideos.loading ||
                                    _relatedVideos.list != null)
                                  Container(
                                    height: size.height * 0.44,
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: _relatedVideos.loading
                                          ? [CircularProgressIndicator()]
                                          : [
                                              ..._relatedVideos.list
                                                  .map(
                                                    (youtube) => YoutubeWidget(
                                                      youtubeModel: youtube,
                                                    ),
                                                  )
                                                  .toList(),
                                              SizedBox(
                                                height: size.height * 0.1,
                                              )
                                            ],
                                    )),
                                  ),
                                if (_playListDetails.playList != null)
                                  Container(
                                    height: size.height * 0.44,
                                    child: SingleChildScrollView(
                                        child:
                                            StreamBuilder<RealtimePlayingInfos>(
                                                stream: _player
                                                    .realtimePlayingInfos,
                                                builder: (context, snapshot) {
                                                  return Column(
                                                    children:
                                                        _playListDetails
                                                                .loadingPlayList
                                                            ? [
                                                                CircularProgressIndicator()
                                                              ]
                                                            : [
                                                                ..._playListDetails
                                                                    .playList
                                                                    .map(
                                                                      (recentPlayed) =>
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(border: Border(left: BorderSide(color: _player.readingPlaylist.currentIndex == _playListDetails.playList.indexOf(recentPlayed) ? ColorCodes.cAccent : Colors.transparent))),
                                                                        child:
                                                                            RecentYoutubeWidget(
                                                                          recentPlayedModel:
                                                                              recentPlayed,
                                                                          playListIndex: _playListDetails
                                                                              .playList
                                                                              .indexOf(recentPlayed),
                                                                        ),
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.1,
                                                                )
                                                              ],
                                                  );
                                                })),
                                  )
                              ],
                            ),
                          )
                        : Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                SONG_DETAILS_TEXT,
                                style: TextComponent.uTextStyle(size, 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
          ),
        ));
  }
}
