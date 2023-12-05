class Workspace {
  final String id;
  final String name;
  final String owner;
  final DateTime createdAt;

  Workspace({
    required this.id,
    required this.name,
    required this.owner,
    required this.createdAt,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
        id: json['_id'],
        name: json['Name'],
        owner: json['Owner'],
        createdAt: json['createdAt']);
  }
}