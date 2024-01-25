class User {
  final String id;
  final String fullname;
  final String email;
  final String image;
  final String password;
  final String createdAt;

  User(
      {required this.id,
      required this.fullname,
      required this.email,
      required this.image,
      required this.password,
      required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['_id'],
        fullname: json['fullname'],
        email: json['email'],
        image: json['image'],
        password: json['password'],
        createdAt: json['createdAt']);
  }
}
