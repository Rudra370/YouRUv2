import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youruv2/admob_service.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/youtube_model.dart';
import 'package:youruv2/widgets/youtube_widget.dart';

import '../service.dart';

class SearchResults extends StatefulWidget {
  final String searchText;

  const SearchResults({@required this.searchText});
  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _searching = false;
  List<Youtube> _list;
  String currentSearchText;
  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    if (oldWidget.searchText != widget.searchText) {
      currentSearchText = widget.searchText;
      _getUrls(widget.searchText);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _getUrls(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searching = true;
    });
    final links = await Api().getUrls(searchText);
    _list = [];
    setState(() {
      _searching = false;
    });
    links.forEach((element) async {
      final Youtube youtubeResult = await Api().getVideo(element);
      if (youtubeResult == null) return;
      if (youtubeResult.meta != null) {
        if (nullTOFalse(prefs.getBool(SFORCEMUSICSEARCH))) {
          if (isMusic(youtubeResult.meta.tags)) {
            setState(() {
              _list.add(youtubeResult);
            });
          }
        } else {
          setState(() {
            _list.add(youtubeResult);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _searching || (_list != null && _list.isEmpty)
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _list == null
            ? Container(
                )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
                itemCount: _list.length,
                padding: EdgeInsets.only(bottom: size.height * 0.12),
                itemBuilder: (context, index) => YoutubeWidget(
                  youtubeModel: _list[index],
                  isVideo: true,
                ),
              );
  }
}
