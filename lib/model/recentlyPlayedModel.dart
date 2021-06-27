class RecentPlayedModel {
  String shareURL;
  String ids;
  String name;
  String image;
  String duration;

  RecentPlayedModel({this.ids, this.name, this.image, this.duration,this.shareURL});

  RecentPlayedModel.fromJson(Map<String, dynamic> json) {
    shareURL = json['shareURL'];
    ids = json['ids'];
    name = json['name'];
    image = json['image'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shareURL'] = this.shareURL;
    data['ids'] = this.ids;
    data['name'] = this.name;
    data['image'] = this.image;
    data['duration'] = this.duration;
    return data;
  }
}
