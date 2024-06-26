import 'package:chat/Pages/ChatPage.dart';
import 'package:chat/Pages/register_Page.dart';
import 'package:chat/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void singOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.SingOut();
    print("User signed out");
  }

  List<String> images = [
    'assets/men4.png',
    'assets/men5.png',
    'assets/men8.png',
    'assets/men1.png',
    'assets/men3.png',
  ];

  @override
  Widget build(BuildContext context) {
    print("Building HomePage");
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: Container(
                child: _userList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        shape: CircleBorder(),
        // backgroundColor: GlobalColors.darkBlueColor,
        child: const Icon(
          CupertinoIcons.add,
          size: 35,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(),
              ));
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade200,
        shape: CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.chat_bubble_text,
                  size: 27,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(),
                      ));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.search,
                  size: 27,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Coming soon'),
                    backgroundColor: Colors.green,
                  ));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => SearchPage(),
                  //     ));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.phone,
                  size: 27,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Coming soon'),
                    backgroundColor: Colors.green,
                  ));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ContactPage(),
                  //     ));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.person_2_fill,
                  size: 27,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Coming soon'),
                    backgroundColor: Colors.green,
                  ));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ProfilePage(),
                  //     ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userList() {
    print("Fetching user list");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error fetching user list: ${snapshot.error}");
          return Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("User list is loading");
          return Center(child: CircularProgressIndicator());
        } else {
          print("User list fetched successfully");
          return ListView(
            children: snapshot.data!.docs
                .asMap()
                .entries
                .map<Widget>((entry) => _userListItem(entry.key, entry.value))
                .toList(),
          );
        }
      },
    );
  }

  Widget _userListItem(int index, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    print("Processing user: ${data['email']}");
    if (_auth.currentUser!.email != data['email']) {
      String avatarImage = images[index % images.length];
      return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10),
        child: GestureDetector(
          onTap: () {
            print("Navigating to chat with ${data['email']}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  reciverUsername: data['username'],
                  reciverUserEmail: data['email'],
                  reciverUserID: data['uid'],
                ),
              ),
            );
          },
          child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(avatarImage),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(
                  data['username'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  data['email'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w200,
                    fontSize: 10,
                  ),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
              )),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _appBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/women8.png'),
              backgroundColor: Colors.grey[100],
            ),
          ),
          _OptionButton(),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: Colors.white,
                  shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  padding: EdgeInsets.all(5)),
              onPressed: singOut,
              child: Icon(
                Icons.logout,
                color: Colors.black,
              ))
        ],
      ),
    );
  }

  Widget _OptionButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.04,
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(25),
          color: Colors.white),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.020,
          ),
          Text("Message"),
          VerticalDivider(
            indent: 2,
            endIndent: 2,
          ),
          Text("Groups")
        ],
      ),
    );
  }
}
