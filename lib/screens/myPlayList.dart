import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youruv2/components/Colors.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/components/stringConstant.dart';
import 'package:youruv2/model/playListModel.dart';
import 'package:youruv2/service.dart';
import 'package:youruv2/widgets/playListwidget.dart';

class MyPlayList extends StatefulWidget {
  @override
  _MyPlayListState createState() => _MyPlayListState();
}

class _MyPlayListState extends State<MyPlayList>
    with AutomaticKeepAliveClientMixin<MyPlayList> {
  @override
  bool get wantKeepAlive => true;
  List<PlayListModel> _playList;
  TextEditingController _textEditingController = TextEditingController();
  bool _loading = true;
  void _initialize() async {
    _playList = await getPlayList();
    setState(() {
      _loading = false;
    });
  }

  void createPlayList(String name) async {
    final _playListModel = PlayListModel(pname: name, pList: []);
    setState(() {
      _playList.insert(0, _playListModel);
    });
    _textEditingController.clear();
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> _list = prefs.getStringList(SPPLAY_LIST);
    if (_list == null) _list = [];
    _list.insert(0, json.encode(_playListModel.toJson()));
    updatePlayList(_list);
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.7,
      child: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: size.height * 0.12),
              itemCount: _playList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      vertical: size.height * 0.013,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.027,
                    ),
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: size.width * 0.68,
                          child: TextField(
                            controller: _textEditingController,
                            style: TextComponent.uTextStyle(size, 16),
                            cursorColor: ColorCodes.cAccent,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.011,
                                  horizontal: size.width * 0.027,
                                ),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCodes.cAccent,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorCodes.cAccent,
                                    width: 1,
                                  ),
                                ),
                                hintText: CREATE_NEW_PLAYLIST,
                                hintStyle: TextComponent.uTextStyle(size, 12,
                                    color: Colors.grey[400])),
                          ),
                        ),
                        Material(
                          elevation: 4,
                          color: ColorCodes.cTransparent,
                          child: InkWell(
                            enableFeedback: true,
                            onTap: () {
                              if (_textEditingController.text == null ||
                                  _textEditingController.text.isEmpty)
                                return;
                              else
                                createPlayList(_textEditingController.text);
                            },
                            child: Container(
                              width: size.width * 0.24,
                              height: size.height * 0.047,
                              decoration: BoxDecoration(
                                color: ColorCodes.cAccent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                CREATE,
                                style: TextComponent.uTextStyle(
                                  size,
                                  14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                index -= 1;
                return Dismissible(
                  key: ValueKey(_playList[index]),
                  direction: DismissDirection.endToStart,
                  background: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: ColorCodes.cTransparent,
                        child: Container(
                          width: size.width * 0.6,
                          decoration: BoxDecoration(
                              color: ColorCodes.cAppBarBackground,
                              borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.04,
                            horizontal: size.width * 0.05,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_sharp,
                                color: Colors.red[600],
                                size: size.height * 0.08,
                              ),
                              Text(
                                ARE_YOU_SURE,
                                style: TextComponent.uTextStyle(size, 22),
                              ),
                              SizedBox(
                                height: size.height * 0.04,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Material(
                                    elevation: 4,
                                    color: ColorCodes.cTransparent,
                                    child: InkWell(
                                      enableFeedback: true,
                                      onTap: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Container(
                                        width: size.width * 0.3,
                                        height: size.height * 0.047,
                                        decoration: BoxDecoration(
                                          color: ColorCodes.cPrimary,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          CANCEL,
                                          style: TextComponent.uTextStyle(
                                            size,
                                            14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    elevation: 4,
                                    color: ColorCodes.cTransparent,
                                    child: InkWell(
                                      enableFeedback: true,
                                      onTap: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Container(
                                        width: size.width * 0.3,
                                        height: size.height * 0.047,
                                        decoration: BoxDecoration(
                                          color: Colors.red[600],
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          DELETE,
                                          style: TextComponent.uTextStyle(
                                            size,
                                            14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    _playList.removeAt(index);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    List<String> _list = prefs.getStringList(SPPLAY_LIST);
                    _list.removeAt(index);
                    updatePlayList(_list);
                  },
                  child: PlayListWidget(
                    playListModel: _playList[index],
                  ),
                );
              },
            ),
    );
  }
}
