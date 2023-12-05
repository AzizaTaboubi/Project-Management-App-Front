import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
}

class TestWorkspace extends StatefulWidget {
  const TestWorkspace({Key? key}) : super(key: key);

  @override
  State<TestWorkspace> createState() => _TestWorkspaceState();
}

class _TestWorkspaceState extends State<TestWorkspace> {
  late List<Workspace> workspaces = [];
  late Future<bool> fetchedWS;
  Future<bool> fetchWorkspaces() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:9095/workspace/workspaces/user/6550b69d69c83c3f296e298c'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? responseData = jsonDecode(response.body);
      if (responseData != null && responseData.containsKey('Workspaces')) {
        List<dynamic> workspaceData = responseData['Workspaces'];
        workspaceData.forEach((element) {
          workspaces.add(Workspace(
            id: element["_id"],
            name: element["Name"],
            owner: "",
            createdAt: DateTime.parse(element["createdAt"]),
          ));
        });
        return true;
      }
    }
    throw Exception('Failed to fetch workspaces');
  }

  @override
  void initState() {
    super.initState();
    fetchedWS = fetchWorkspaces();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: fetchedWS,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching workspaces
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Show an error message if fetching workspaces failed
          return Text('Error: ${snapshot.error}');
        } else {
          // Show the GridView when workspaces are fetched successfully
          return ListView.builder(
            itemCount: workspaces.length,
            itemBuilder: (BuildContext context, int index) {
              return Text(workspaces[index].name);
            },
          );
        }
      },
    );
  }
}