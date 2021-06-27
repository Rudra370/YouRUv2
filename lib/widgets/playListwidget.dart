import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/model/playListModel.dart';
import 'package:youruv2/widgets/recent_youtube_widget.dart';
import 'package:youruv2/service.dart';

class PlayListWidget extends StatefulWidget {
  final PlayListModel playListModel;

  const PlayListWidget({@required this.playListModel});
  @override
  _PlayListWidgetState createState() => _PlayListWidgetState();
}

class _PlayListWidgetState extends State<PlayListWidget> {
  bool expanded = false;
  int _animationDuration = 200;
  var _list;
  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = _list.removeAt(oldindex);
      _list.insert(newindex, items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    PlaylistDetails _playlist = Provider.of<PlaylistDetails>(context);
    return GestureDetector(
      onTap: () {
        if (!expanded) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  backgroundColor: ColorCodes.cTransparent,
                  child: Container(
                    height: size.height * 0.055,
                    width: size.height * 0.055,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              });
          _playlist.playPlayList(context, widget.playListModel.pList);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.012,
        ),
        child: Material(
          color: ColorCodes.cTransparent,
          elevation: 4,
          child: AnimatedContainer(
            duration: Duration(milliseconds: _animationDuration),
            width: size.width,
            color: expanded ? ColorCodes.c2ndBackground : ColorCodes.cPrimary,
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.014,
            ),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.035,
                        ),
                        width: size.width * 0.83,
                        child: Text(
                          widget.playListModel.pname,
                          maxLines: expanded ? 4 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextComponent.uTextStyle(size, 18),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expanded = !expanded;
                          });
                        },
                        child: Container(
                          width: size.width * 0.1,
                          child: Icon(
                            expanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Colors.white,
                            size: size.height * 0.033,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (expanded)
                  Container(
                    height: widget.playListModel.pList.length < 2
                        ? size.height * 0.15
                        : size.height * 0.34,
                    child: widget.playListModel.pList.isEmpty
                        ? Center(
                            child: Text(
                              'You forgot to add music to this list🤦‍♂️',
                              style: TextComponent.uTextStyle(size, 14),
                            ),
                          )
                        : ListView.builder(
                            itemCount: widget.playListModel.pList.length,
                            itemBuilder: (context, index) =>
                                RecentYoutubeWidget(
                                    recentPlayedModel:
                                        widget.playListModel.pList[index]),
                          ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
