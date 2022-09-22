class Post {
  Post(
      {required this.id,
        required this.title,
        required this.image,
        required this.time});

  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
        id: data['id'],
        title: data['title'],
        image: data['image'],
        time: data['created_at']);
  }

  final String id;
  final String title;
  final String image;
  final String time;
}
