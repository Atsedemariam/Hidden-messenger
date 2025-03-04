import 'package:flutter/material.dart';
import 'chat_page_2.dart';
import 'chat_page_1.dart';
import 'profile_page.dart'; // Profile Page Import
import 'theme_settings_page.dart'; // Theme Settings Page Import
import 'notifications_settings_page.dart'; // Notifications Settings Page Import
import 'privacy_settings_page.dart'; // Privacy Settings Page Import
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Import login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? user = FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String currentUserName = '';
  String currentUserEmail = '';
  String currentUserId = '';

  // Initialize user data fetching
  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  // Fetch current user's name from Firestore
  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        //await Firebase.initializeApp();

        // // Get the reference to the 'messages' collection
        // final collection = FirebaseFirestore.instance.collection('messages');

        // // Get all documents in the collection
        // final snapshot = await collection.get();

        // // Loop through the documents and delete each one
        // for (var doc in snapshot.docs) {
        //   await doc.reference.delete();
        // }
        var userDoc = snapshot.docs.first;
        currentUserId = userDoc['user_id'];

        setState(() {
          currentUserName = userDoc.data()['name'] ?? 'Anonymous';
          currentUserEmail = userDoc.data()['email'] ?? 'Anonymous';
          isLoading = false;
        });
      } else {
        setState(() {
          currentUserName = 'Anonymous';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginPage();
    }

    String currentUserEmail = user.email ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Silent Messenger'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: SettingsDrawer(
        currentUserName: currentUserName, // Provide the current user's name
        currentUserEmail: currentUserEmail, // Provide the current user's email
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(isLoading
                  ? 'A'
                  : currentUserName.isNotEmpty
                      ? currentUserName[0].toUpperCase()
                      : 'A'),
            ),
            title: Text(isLoading ? 'Loading...' : currentUserName),
            subtitle: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('receiver_id',
                      isEqualTo: currentUserId) // Receiver is the current user
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No new messages');
                }

                // Get the last received message
                var lastMessageDoc = snapshot.data!.docs.first;
                String lastMessage = lastMessageDoc['message_content'];
                String senderId = lastMessageDoc['sender_id'];

                return Text(
                  lastMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Bold for emphasis
                    color: Colors.blueGrey,
                    backgroundColor: Colors.yellow[100], // Highlight background
                  ),
                );
              },
            ),
            tileColor: Colors.grey[200],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
          ),
          SizedBox(height: 20),
          Divider(
              color: Colors.grey[300], thickness: 5, indent: 40, endIndent: 40),
          SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Data Found'));
                }

                final users = snapshot.data!.docs;

                var filteredUsers = users.where((userDoc) {
                  return userDoc['email'] != currentUserEmail;
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    String name = user['name'] ?? 'Unknown';
                    String firstLetter =
                        name.isNotEmpty ? name[0].toUpperCase() : 'U';
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('messages')
                          .where('sender_id',
                              isEqualTo: FirebaseAuth.instance.currentUser!
                                  .uid) // current user's ID
                          .where('receiver_id',
                              isEqualTo:
                                  filteredUsers[index].id) // receiver's ID
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, messageSnapshot) {
                        // Check if the data is still loading
                        if (messageSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            leading: CircleAvatar(child: Text(firstLetter)),
                            title: Text(name),
                            subtitle: Text(
                                "Loading..."), // Show loading text until data arrives
                          );
                        }

                        // Handle the case where no messages are found
                        String message = "No messages yet";
                        bool isHighlighted =
                            false; // Track if this message should be highlighted

                        if (messageSnapshot.hasData &&
                            messageSnapshot.data!.docs.isNotEmpty) {
                          // Extract the message content from the snapshot
                          message = messageSnapshot
                              .data!.docs.first['message_content'];

                          // Check if the current user is the sender of the message
                          if (messageSnapshot.data!.docs.first['sender_id'] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            isHighlighted =
                                true; // Highlight the message if the current user sent it
                          }
                        }

                        return ListTile(
                          leading: CircleAvatar(child: Text(firstLetter)),
                          title: Text(name),
                          subtitle: Text(
                            message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: isHighlighted
                                  ? FontWeight.bold
                                  : FontWeight
                                      .normal, // Highlight if the most recent message
                              backgroundColor: isHighlighted
                                  ? Colors.transparent
                                  : Colors
                                      .transparent, // Highlight background color
                            ),
                          ),
                          onTap: () {
                            String receiverId = filteredUsers[index]
                                .id; // Receiver's ID from the list
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage_2(
                                  userName: name,
                                  userImageUrl:
                                      'https://via.placeholder.com/150',
                                  receiverId:
                                      receiverId, // Passing the receiver's ID to the chat page
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsDrawer extends StatefulWidget {
  final String currentUserName;
  final String currentUserEmail;

  SettingsDrawer(
      {required this.currentUserName, required this.currentUserEmail});

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  bool isDarkMode = false;
  bool showThemeDropdown = false;
  bool showNotificationDropDown = false;
  bool isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(widget.currentUserName), // Use widget here
            accountEmail: Text(widget.currentUserEmail), // Use widget here
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('My Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme Settings'),
            trailing: Icon(showThemeDropdown
                ? Icons.arrow_drop_up
                : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                showThemeDropdown = !showThemeDropdown;
              });
            },
          ),
          if (showThemeDropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Mode'),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                      // You can add theme logic here
                    },
                  ),
                ],
              ),
            ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Icon(showNotificationDropDown
                ? Icons.arrow_drop_up
                : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                showNotificationDropDown = !showNotificationDropDown;
              });
            },
          ),
          if (showNotificationDropDown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the content
                children: [
                  Text('on'),
                  SizedBox(width: 10),
                  Switch(
                    value: isNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        isNotificationsEnabled = value;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text('off'),
                ],
              ),
            ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySettingsPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log Out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
