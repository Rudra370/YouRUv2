class Youtube {
  String id;
  bool cipher;
  Meta meta;
  String thumb;
  List<String> itags;
  List<String> videoQuality;
  List<Url> url;
  int hosting;
  String srv;
  Null sd;
  Null hd;

  Youtube(
      {this.id,
      this.cipher,
      this.meta,
      this.thumb,
      this.itags,
      this.videoQuality,
      this.url,
      this.hosting,
      this.srv,
      this.sd,
      this.hd});

  Youtube.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cipher = json['cipher'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    thumb = json['thumb'];
    itags = json['itags'] != null ? json['itags'].cast<String>() : null;
    videoQuality = json['video_quality'] != null
        ? json['video_quality'].cast<String>()
        : null;
    if (json['url'] != null) {
      url = <Url>[];
      json['url'].forEach((v) {
        url.add(new Url.fromJson(v));
      });
    }
    hosting = json['hosting'];
    srv = json['srv'];
    sd = json['sd'];
    hd = json['hd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cipher'] = this.cipher;
    if (this.meta != null) {
      data['meta'] = this.meta.toJson();
    }
    data['thumb'] = this.thumb;
    data['itags'] = this.itags;
    data['video_quality'] = this.videoQuality;
    if (this.url != null) {
      data['url'] = this.url.map((v) => v.toJson()).toList();
    }
    data['hosting'] = this.hosting;
    data['srv'] = this.srv;
    data['sd'] = this.sd;
    data['hd'] = this.hd;
    return data;
  }
}

class Meta {
  String title;
  String source;
  String duration;
  String tags;

  Meta({this.title, this.source, this.duration, this.tags});

  Meta.fromJson(Map<String, dynamic> json) {
    title = json['title'] != null ? json['title'] : null;
    source = json['source'];
    duration = json['duration'];
    tags = json['tags'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['source'] = this.source;
    data['duration'] = this.duration;
    data['tags'] = this.tags;
    return data;
  }
}

class Url {
  String url;
  String name;
  String subname;
  String infoUrl;
  String type;
  String ext;
  bool downloadable;
  String quality;
  bool audio;
  bool noAudio;
  String itag;
  int filesize;
  Attr attr;
  String infoToken;

  Url(
      {this.url,
      this.name,
      this.subname,
      this.infoUrl,
      this.type,
      this.ext,
      this.downloadable,
      this.quality,
      this.audio,
      this.noAudio,
      this.itag,
      this.filesize,
      this.attr,
      this.infoToken});

  Url.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    name = json['name'];
    subname = json['subname'];
    infoUrl = json['info_url'];
    type = json['type'];
    ext = json['ext'];
    downloadable = json['downloadable'];
    quality = json['quality'];
    audio = json['audio'];
    noAudio = json['no_audio'];
    itag = json['itag'];
    filesize = json['filesize'];
    attr = json['attr'] != null ? new Attr.fromJson(json['attr']) : null;
    infoToken = json['info_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['name'] = this.name;
    data['subname'] = this.subname;
    data['info_url'] = this.infoUrl;
    data['type'] = this.type;
    data['ext'] = this.ext;
    data['downloadable'] = this.downloadable;
    data['quality'] = this.quality;
    data['audio'] = this.audio;
    data['no_audio'] = this.noAudio;
    data['itag'] = this.itag;
    data['filesize'] = this.filesize;
    if (this.attr != null) {
      data['attr'] = this.attr.toJson();
    }
    data['info_token'] = this.infoToken;
    return data;
  }
}

class Attr {
  String title;
  String classes;

  Attr({this.title, this.classes});

  Attr.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    classes = json['class'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['class'] = this.classes;
    return data;
  }
}
