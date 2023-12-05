class Meet {
  final String id;
  final DateTime Date;
  final String Title;
  final String Link;
  final String User;
  final String createdAt;

  Meet(
      {required this.id,
      required this.Date,
      required this.Title,
      required this.Link,
      required this.User,
      required this.createdAt});

  factory Meet.fromJson(Map<String, dynamic> json) {
    return Meet(
      id: json['_id'],
      Date: DateTime(
        int.parse(json['Year']),
        int.parse(json['Month']),
        int.parse(json['Day']),
      ),
      Title: json['Description'],
      Link: json['Link'],
      User: json['User'],
      createdAt: json['createdAt'],
    );
  }
}
