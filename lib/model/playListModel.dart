import 'package:youruv2/model/recentlyPlayedModel.dart';

class PlayListModel {
  String pname;
  List<RecentPlayedModel> pList;

  PlayListModel({this.pname, this.pList});

  PlayListModel.fromJson(Map<String, dynamic> json) {
    pname = json['pname'];
    if (json['PList'] != null) {
      pList = <RecentPlayedModel>[];
      json['PList'].forEach((v) {
        pList.add(RecentPlayedModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pname'] = this.pname;
    if (this.pList != null) {
      data['PList'] = this.pList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}