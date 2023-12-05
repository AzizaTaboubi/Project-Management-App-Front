import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:managementappfront/button.dart';
import 'package:managementappfront/eventManager.dart';
import 'package:managementappfront/eventcalendar.dart';
import 'package:managementappfront/home.dart';
import 'package:managementappfront/login.dart';
import 'package:managementappfront/newboard.dart';
import 'package:managementappfront/newcard.dart';
import 'package:managementappfront/profile.dart';
import 'package:managementappfront/settings.dart';
import 'package:managementappfront/workspaces.dart';
import 'package:managementappfront/constants/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';

import 'classes/card.dart';
import 'classes/user.dart';
import 'package:http/http.dart' as http;

class cards extends StatefulWidget {
  const cards({super.key});

  @override
  State<cards> createState() => _cardsState();
}

class _cardsState extends State<cards> {

  late String? _cardName;
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  final String _baseUrl = constants.constants.BaseUrl;
  User? currentUser;
  List<Carddd> cardslist = [];
  late Future<bool> fetchedCS;

  Future<bool> deleteCards(String cardId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/card/cards/$cardId'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? responseData = jsonDecode(response.body);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => super.widget));
      return true;
    }
    throw Exception('Failed to fetch workspaces');
  }

  Future<bool> fetchCards(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/card/cards/user/$userId'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? responseData = jsonDecode(response.body);
      if (responseData != null && responseData.containsKey('Cards')) {
        List<dynamic> workspaceData = responseData['Cards'];
        setState(() {
          workspaceData.forEach((element) {
            List<dynamic> userData = element['Users'];
            List<String> userIds = userData.map((user) => user.toString()).toList();
            setState(() {
              cardslist.add(Carddd(
                id: element["_id"],
                Name: element["Name"],
                Description: element["Description"],
                Board: element["Description"],
                DueDate: element["DueDate"],
                Attachement: element["Attachement"],
                createdAt: DateTime.parse(element["createdAt"]),
                Users: userIds,
              ));
            });
          });
        });
        print("length :");
        print(cardslist.length);
        return true;
      }
    }
    throw Exception('Failed to fetch cards');
  }


  Future<User> fetchUser(String? token) async {
    final token = await getToken();
    if (token != null) {
      final url = Uri.parse('$_baseUrl/user/userget');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final user = User.fromJson(jsonResponse['user']);
        return user;
      } else {
        throw Exception('Failed to fetch user');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((_) {
      fetchedCS = fetchCards(currentUser!.id).then((value) {
        setState(() {}); // Trigger a state update after fetching cards
        return value; // Return the fetched value
      });
    });
  }

  Future<void> getUserData() async {
    try {
      final token = await getToken();
      final user = await fetchUser(token);
      setState(() {
        currentUser = user;
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable the back button press
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
         ),
         child: Scaffold(backgroundColor: Colors.white,
         drawer:   Drawer(
          backgroundColor: Colors.white,
              child: ListView(
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                        Image.asset('assets/espritlogo.png',
                 width: 90,
                 height: 90,),

                 SizedBox(width: 5,),

                 Text('Esprit\'s shelf',
                 style: TextStyle(
                   fontSize: 20,
                fontWeight: FontWeight.w600,
                 letterSpacing: 1,
                 color: Colors.black
                 ),)
                  ],
                  ),
                ListTile(
           leading: Icon(LineAwesomeIcons.home, color: Colors.black,),
          title: const Text('Boards',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black
          ),),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  Home(),),
                 );
          },
        ),

         ListTile(
          leading: Icon(LineAwesomeIcons.people_carry, color: Colors.black,),
          title: const Text('Workspaces',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black
          ),),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  Workspaces(),),
                 );
          },
        ),
         ListTile(
          leading: Icon(LineAwesomeIcons.clipboard, color: Colors.black,),
          title: const Text('Cards',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black
          ),),
          onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  cards(),),
                 );
          },
        ),
        ListTile(
          leading: Icon(LineAwesomeIcons.calendar, color: Colors.black,),
          title: const Text('Calendar',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black
          ),),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  Calendar()),
                 );
          },
        ),
         ListTile(
          leading: Icon(LineAwesomeIcons.facebook_messenger, color: Colors.black,),
          title: const Text('Chats',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black
          ),),
          onTap: () {
            // Update the state of the app.
            // ...
             Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(LineAwesomeIcons.calendar_with_day_focus, color: Colors.black,),
          title: const Text('Event Manager',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black
          ),),
          onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  eventManager()),
                 );
          },
        ),

        SizedBox(height: 170,),
        ListTile(
          leading: Icon(LineAwesomeIcons.alternate_sign_out, color: Colors.black,),
          title: const Text('Logout',
          style: TextStyle(
             fontSize: 17,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.red
          ),),
          onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MyLogin(),),
                 );
          },
        ),
                ],
              ),
            ),

         appBar: AppBar(backgroundColor: Colors.white60,
         title: Row(
          children: [

            Text(
              'Cards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                 letterSpacing: 1,
                 color: Colors.black87
              ),
            ),
             SizedBox(width: 117,),
            IconButton(
              onPressed: (){

            },
             icon: Icon(Icons.search), color: Colors.black87,),
             const SizedBox(width: 1),
            IconButton(
              onPressed: (){

            },
            icon: Icon(Icons.notifications), color: Colors.black87,),
            const SizedBox(width: 2),

             InkWell(
        onTap: () {
       Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfileScreen(),),
                 );
        },
        child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Ink(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/login.jpg'),
            fit: BoxFit.fill,
          ),
        ),
      ),
        ),
      )
            //CircleAvatar(backgroundImage: AssetImage('assets/login.jpg'), radius: 15,)
          ],
         ),
         ),
          body: SingleChildScrollView(
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (cardslist.isNotEmpty)
                    FutureBuilder<bool>(
                      future: fetchedCS,
                      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Show a loading indicator while fetching cards
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // Show an error message if fetching cards failed
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data == true) {
                          // Show the ListView when cards are fetched successfully
                          return Container(
                            width: MediaQuery.of(context).size.width * 1,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: cardslist.length,
                              itemBuilder: (BuildContext context, int index) {
                                final card = cardslist[index];
                                return ListTile(
                                  title: Text(card.Name), // Card name
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          print(card.id);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => newCard(card: card),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          deleteCards(card.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Show the card details dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(card.Name),
                                          content: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Description: ${card.Description}'),
                                              Text('Created At: ${card.createdAt.toString()}'),
                                              Text('Users: ${card.Users.join(", ")}'),
                                              Text('Due Date: ${card.DueDate}'),
                                              Text('Board: ${card.Board}'),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        } else {
                          // Show a message when there are no cards
                          return Text('No cards available');
                        }
                      },
                    ),
                ],
              ),


            ],
          ),

         ),
        floatingActionButton: ExpandableFab(
          distance: 112,
          children: [
            ActionButton(
              onPressed: ()  {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 300,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Create New Workspaces',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),),
                        Container(
                          margin: EdgeInsets.all(20),
                          child: Text('Workspaces help you organize and boost your works. So you can be more productive.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),),
                        ),
                         SizedBox(
                          height: 45,
                          width: 310,
                           child: TextField(
                                style: TextStyle(),
                                obscureText: true,
                                decoration: InputDecoration(
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "Workspace name",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.red)
                                    )),
                              ),
                         ),
                         SizedBox(
                          height: 15,
                         ),
                        SizedBox(
                          height: 35,
                          width: 290,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    )
                              ),
                            child: const Text('Create',
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                         ),
                         SizedBox(
                          height: 35,
                          width: 290,
                           child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                                   shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(30),

                                     )
                               ),
                            child: const Text('Cancel',
                            style: TextStyle(
                              color: Colors.black38
                            ),
                            ),
                            onPressed: () => Navigator.pop(context),
                                                   ),
                         )
                      ],
                    ),
                  ),
                );
              },
            );
              },
              icon: const Icon(Icons.people),
              text: Text('Workspaces'),
            ),
            ActionButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  newCard()),
              );
              },
              icon: const Icon(Icons.card_membership_rounded),
              text: Text('Cards'),
            ),
            ActionButton(
              onPressed: () {
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  newBoard()),
                 );
              },
              icon: const Icon(Icons.home),
              text: Text('Boards'),
            ),
          ],
        ),),

      ),
    );
  }
}