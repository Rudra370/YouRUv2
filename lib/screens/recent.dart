import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/recentlyPlayedModel.dart';
import 'package:youruv2/widgets/recent_youtube_widget.dart';

class RecentlyPlayed extends StatefulWidget {
  @override
  _RecentlyPlayedState createState() => _RecentlyPlayedState();
}

class _RecentlyPlayedState extends State<RecentlyPlayed> {
  List<String> _recent;
  List<RecentPlayedModel> _recentlyPlayed;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recent = prefs.getStringList(SPRECENTLY_PLAYED);
    _recentlyPlayed = [];
    if (_recent != null) {
      _recent.forEach((element) {
        if (_recentlyPlayed.length == 0 ||
            _recentlyPlayed.last.shareURL !=
                RecentPlayedModel.fromJson(json.decode(element)).shareURL)
          _recentlyPlayed.add(RecentPlayedModel.fromJson(json.decode(element)));
      });
    }
    setState(() {});
  }

  void _refresh() {
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: RefreshIndicator(
          backgroundColor: ColorCodes.cAccent,
          onRefresh: () async {
            _refresh();
            return;
          },
          child: _recentlyPlayed == null
              ? Container()
              : ListView.builder(
                  itemCount: _recentlyPlayed.length,
                  padding: EdgeInsets.only(bottom: size.height * 0.12),
                  itemBuilder: (context, index) => RecentYoutubeWidget(
                      recentPlayedModel: _recentlyPlayed[index]))),
    );
  }
}
