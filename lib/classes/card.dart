class Carddd {
  final String id;
  final String Name;
  final String Description;
  final String Board;
  final List<String> Users;
  final String DueDate;
  final String Attachement;
  final DateTime createdAt;

  Carddd(
      {required this.id,
        required this.Name,
        required this.Description,
        required this.Board,
        required this.Users,
        required this.DueDate,
        required this.Attachement,
        required this.createdAt});

  factory Carddd.fromJson(Map<String, dynamic> json) {
    return Carddd(
        id: json['_id'],
        Name: json['Name'],
        Description: json['Description'],
        Board: json['Board'],
        Users: json['Users'],
        DueDate: json['DueDate'],
        Attachement: json['Attachement'],
        createdAt: json['createdAt']);
  }
}