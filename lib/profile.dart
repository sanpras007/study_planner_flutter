import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'User.dart';
import 'app.dart';

class ProfilePage extends StatefulWidget {
  final Store store;
  final int userId; // Add userId parameter to identify the logged-in user

  ProfilePage({required this.store, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Box<User> _userBox;
  late final User _currentUser;

  @override
  void initState() {
    super.initState();
    _userBox = widget.store.box<User>();

    // Fetch the logged-in user from the database using the userId
    _currentUser = _userBox.get(widget.userId) ??
        User(
          firstName: 'FirstName',
          lastName: 'LastName',
          email: 'email@example.com',
          password: 'password',
        ); // Fallback user if not found

    // Additional setup if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              '${_currentUser.firstName} ${_currentUser.lastName}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _currentUser.email,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.blueAccent),
                title: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_currentUser.email),
              ),
            ),
            SizedBox(height: 200),
            Expanded(
              child: FetchData(userName: _currentUser.firstName),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudyPlannerPage(store: widget.store),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Go to study planner',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FetchData extends StatefulWidget {
  final String userName;

  FetchData({required this.userName});

  @override
  _FetchDataState createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  String data = 'There is no substitute for hard work.';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://api.quotable.io/random'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body)['content'];
      });
    } else {
      setState(() {
        data = 'Failed to load data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${widget.userName}!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Quote of the day:',
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 10),
        Text(
          data,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
