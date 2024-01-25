class Board {
  final String id;
  final String Name;
  final String Workspace;
  final List<String> Users;
  final DateTime createdAt;

  Board(
      {required this.id,
        required this.Name,
        required this.Workspace,
        required this.Users,
        required this.createdAt});

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
        id: json['_id'],
        Name: json['Name'],
        Workspace: json['Workspace'],
        Users: json['Users'],
        createdAt: json['createdAt']);
  }
}