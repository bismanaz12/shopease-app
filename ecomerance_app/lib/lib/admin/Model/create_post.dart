class Post {
  String postName;
  String postDescription;
  String? postImage;

  Post({
    required this.postName,
    required this.postDescription,
    this.postImage,
  });

  @override
  String toString() {
    return 'Post{name: $postName, description: $postDescription,image: $postImage}';
  }
}
