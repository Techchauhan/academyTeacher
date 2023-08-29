class Chapter {
  String title;
  List<Lecture> lectures;

  Chapter(this.title, this.lectures);
}

class Lecture {
  String title;
  String videoUrl;

  Lecture(this.title, this.videoUrl);



  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoUrl': videoUrl,
    };
  }
}
