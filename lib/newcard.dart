import 'dart:convert';
import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:managementappfront/classes/user.dart';
import 'package:managementappfront/constants/constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'classes/calendar.dart';

import 'classes/card.dart';


class newCard extends StatefulWidget {
  final Carddd? card;

  const newCard({super.key, this.card});

  @override
  State<newCard> createState() => _newCardState();
}

const List<String> list = ["Select a board"];
late Future<bool> fetchedBS;
String dropdownValue = '';
List<String> boardsNames = [];
late String _endDate;

class _newCardState extends State<newCard> {
  final String _baseUrl = constants.constants.BaseUrl;
  User? currentUser;

  TextEditingController _NameTextController = TextEditingController();
  TextEditingController _DescriptionTextController = TextEditingController();
  TextEditingController _BoardTextController = TextEditingController();
  TextEditingController _UsersTextController = TextEditingController();
  TextEditingController _DueDateTextController = TextEditingController();

  late File _attachment; // File to be attached
  late File imageFile = File('');
  late File _image;

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        _image = imageFile;
      });
    }
  }

  /*Future<void> editCardInDatabase() async {
    print(_NameTextController.text);
    print(_DescriptionTextController.text);
    print(_BoardTextController.text);
    print(_UsersTextController.text);
    print(_DueDateTextController.text);
    print(dropdownValue);
    print(_endDate);
    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/card/cards/update/${widget.card?.id}'),
      );

      // Add form fields
      request.fields['Name'] = _NameTextController.text;
      request.fields['Description'] = _DescriptionTextController.text;
      request.fields['Board'] = dropdownValue;
      request.fields['Users'] = _UsersTextController.text;
      request.fields['DueDate'] = _endDate;

      // Add attachment file
      if (imageFile != null) {
        final attachmentStream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        final fileLength = await imageFile.length();

        final multipartFile = http.MultipartFile(
          'Attachement',
          attachmentStream,
          fileLength,
          filename: imageFile.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Set authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Card added successfully
        print('Card edited successfully');
      } else {
        // Error adding card
        throw Exception('Failed to edit card');
      }
    } catch (error) {
      print('Error editing card: $error');
    }
  }*/

  Future<void> editCardInDatabase() async {
    try {
      final token = await getToken();

      final url = Uri.parse('$_baseUrl/card/cards/update/${widget.card?.id}');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'Name': _NameTextController.text,
        'Description': _DescriptionTextController.text,
        'Board': dropdownValue,
        'Users': _UsersTextController.text,
        'DueDate': _endDate,
      });

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Card edited successfully
        print('Card edited successfully');
        Navigator.pushReplacementNamed(context, "/cards");
      } else {
        // Error editing card
        throw Exception('Failed to edit card');
      }
    } catch (error) {
      print('Error editing card: $error');
    }
  }

  Future<void> addCardToDatabase() async {
    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/card/cards'),
      );

      // Add form fields
      request.fields['Name'] = _NameTextController.text;
      request.fields['Description'] = _DescriptionTextController.text;
      request.fields['Board'] = dropdownValue;
      request.fields['Users'] = _UsersTextController.text;
      request.fields['DueDate'] = _endDate;

      // Add attachment file
      if (imageFile != null) {
        final attachmentStream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        final fileLength = await imageFile.length();

        final multipartFile = http.MultipartFile(
          'Attachement',
          attachmentStream,
          fileLength,
          filename: imageFile.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Set authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Card added successfully
        print('Card added successfully');
        Navigator.pushReplacementNamed(context, "/cards");
      } else {
        // Error adding card
        throw Exception('Failed to add card');
      }
    } catch (error) {
      print('Error adding card: $error');
    }
  }

  Future<bool> fetchBoards(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/board/boards/user/$userId'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('Boards')) {
        List<dynamic> boardData = responseData['Boards'];
        boardsNames = boardData.map<String>((element) => element["Name"]).toList();
        setState(() {
          dropdownValue = boardsNames.first;
        });
        return true;
      }
    }
    throw Exception('Failed to fetch workspaces');
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
        fetchedBS = fetchBoards(currentUser!.id);
    });
    if (widget.card != null) {
      _NameTextController.text = widget.card!.Name;
      _UsersTextController.text = widget.card!.Users.join(", ");
      _BoardTextController.text = widget.card!.Board;
      _DueDateTextController.text = widget.card!.DueDate;
      _DescriptionTextController.text = widget.card!.Description;
    }
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

  List<DateTime?> _dialogCalendarPickerValue = [
    DateTime.now(),
    DateTime.now(),
  ];

  List<DateTime?> _singleDatePickerValueWithDefaultValue = [
    DateTime.now(),
  ];

  List<DateTime?> _multiDatePickerValueWithDefaultValue = [
    DateTime(today.year, today.month, 1),
    DateTime(today.year, today.month, 5),
    DateTime(today.year, today.month, 14),
    DateTime(today.year, today.month, 17),
    DateTime(today.year, today.month, 25),
  ];

  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [
    DateTime(1999, 5, 6),
    DateTime(1999, 5, 21),
  ];

  List<DateTime?> _rangeDatePickerWithActionButtonsWithValue = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 5)),
  ];

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.card != null;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 244, 67, 54),
          title: Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Text(
                'New Cards',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 370,
                  height: 60,
                  child: DropdownButton(
                    value: dropdownValue,
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        _BoardTextController.text = value!;
                        dropdownValue = value!;
                      });
                    },
                    underline: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    items: boardsNames.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                TextField(
                  controller: _NameTextController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      filled: false,
                      hintText: "Card name",
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                ),
                SizedBox(
                  height: 13,
                ),
                TextField(
                  controller: _DescriptionTextController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      filled: false,
                      hintText: "Description",
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                ),
                SizedBox(
                  height: 13,
                ),
                TextField(
                  controller: _UsersTextController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      filled: false,
                      hintText: "Collaborators",
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                ),
                SizedBox(
                  height: 13,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Start & Due Date',
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                    _buildCalendarDialogButton(),
                    SizedBox(
                      width: 30,
                    )
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        _getImage();
                      },
                      child: Icon(Icons.attachment_outlined),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'attachment',
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    isEditing ? editCardInDatabase() : addCardToDatabase();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: Text(
                    isEditing ? 'Edit Card' : 'Add Card To Board',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getValueText(
      CalendarDatePicker2Type datePickerType,
      List<DateTime?> values,
      ) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
          .map((v) => v.toString().replaceAll('00:00:00.000', ''))
          .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1
            ? values[1].toString().replaceAll('00:00:00.000', '')
            : 'null';
        valueText = '$startDate to $endDate';
        _endDate = endDate;
        print("endDate :");
        print(_endDate);
      } else {
        return 'null';
      }
    }

    return valueText;
  }

  _buildCalendarDialogButton() {
    const dayTextStyle =
    TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
    final weekendTextStyle =
    TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600);
    final anniversaryTextStyle = TextStyle(
      color: Colors.red[400],
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    final config = CalendarDatePicker2WithActionButtonsConfig(
      dayTextStyle: dayTextStyle,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: Colors.purple[800],
      closeDialogOnCancelTapped: true,
      firstDayOfWeek: 1,
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      controlsTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
      dayTextStylePredicate: ({required date}) {
        TextStyle? textStyle;
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          textStyle = weekendTextStyle;
        }
        if (DateUtils.isSameDay(date, DateTime(2021, 1, 25))) {
          textStyle = anniversaryTextStyle;
        }
        return textStyle;
      },
      dayBuilder: ({
        required date,
        textStyle,
        decoration,
        isSelected,
        isDisabled,
        isToday,
      }) {
        Widget? dayWidget;
        if (date.day % 3 == 0 && date.day % 9 != 0) {
          dayWidget = Container(
            decoration: decoration,
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Text(
                    MaterialLocalizations.of(context).formatDecimal(date.day),
                    style: textStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 27.5),
                    child: Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isSelected == true
                            ? Colors.white
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return dayWidget;
      },
      yearBuilder: ({
        required year,
        decoration,
        isCurrentYear,
        isDisabled,
        isSelected,
        textStyle,
      }) {
        return Center(
          child: Container(
            decoration: decoration,
            height: 36,
            width: 72,
            child: Center(
              child: Semantics(
                selected: isSelected,
                button: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: textStyle,
                    ),
                    if (isCurrentYear == true)
                      Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(left: 5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              final values = await showCalendarDatePicker2Dialog(
                context: context,
                config: config,
                dialogSize: const Size(325, 400),
                borderRadius: BorderRadius.circular(15),
                value: _dialogCalendarPickerValue,
                dialogBackgroundColor: Colors.white,
              );
              if (values != null) {
                // ignore: avoid_print
                print(_getValueText(
                  config.calendarType,
                  values,
                ));
                setState(() {
                  _dialogCalendarPickerValue = values;
                });
              }
            },
            child: Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    );
  }
}
